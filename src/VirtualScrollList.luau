--Wrapper for a ScrollingFrame that only creates the content it needs.
--!strict

local ADDITIONAL_ENTRIES_MULTIPLUER = 0.5

local Types = require(script.Parent:WaitForChild("Types"))

local VirtualScrollList = {}
VirtualScrollList.__index = VirtualScrollList

export type VirtualScrollList<T> = {
    ListEntryConstructor: Types.ListEntryConstructor<T>,
    ScrollingFrame: ScrollingFrame,
    Direction: Enum.ScrollingDirection,
    ScrollWidth: UDim,
    EntryHeight: number,
    OverrideAdditionalEntries: number?,
    LastEntryHeight: number,
    Data: {T},
    Entries: {[number]: Types.ListEntry<T>},
    StaleEntries: {{LastIndex: number, Entry: Types.ListEntry<T>}},
    EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, VirtualScrollList))



--[[
Creates a virtual scroll list from an existing ScrollingFrame.
--]]
function VirtualScrollList.new<T>(ScrollingFrame: ScrollingFrame, ListEntryConstructor: Types.ListEntryConstructor<T>, Direction: Enum.ScrollingDirection?): VirtualScrollList<T>
    --Create the initial object.
    local self = setmetatable({
        ListEntryConstructor = ListEntryConstructor,
        ScrollingFrame = ScrollingFrame,
        ScrollWidth = UDim.new(0, 0),
        Direction = Direction or Enum.ScrollingDirection.Y,
        EntryHeight = 20,
        LastEntryHeight = 20,
        Data = {},
        Entries = {},
        StaleEntries = {},
        EventConnections = {},
    }, VirtualScrollList) :: VirtualScrollList<T>

    --Warn if a UILayout is found in the ScrollingFrame, since it breaks the frame management.
    for _, ChildInstance in ScrollingFrame:GetChildren() do
        if not ChildInstance:IsA("UILayout") then continue end
        warn(`{ChildInstance.ClassName} at {ChildInstance:GetFullName()} child found in the ScrollingFrame being set up with VirtualScrollList. The layout will not appear as expected!\n{debug.traceback()}`)
    end
    table.insert(self.EventConnections, ScrollingFrame.ChildAdded:Connect(function(ChildInstance: Instance)
        if not ChildInstance:IsA("UILayout") then return end
        warn(`{ChildInstance.ClassName} at {ChildInstance:GetFullName()} child added to the ScrollingFrame set up with VirtualScrollList. The layout will not appear as expected!`)
    end))

    --Connect changes to the ScrollingFrame.
    table.insert(self.EventConnections, ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        self:UpdateScrollingFrameContents()
    end))
    table.insert(self.EventConnections, ScrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
        self:UpdateScrollingFrameContents()
    end))
    table.insert(self.EventConnections, ScrollingFrame.Destroying:Connect(function()
        self:Destroy()
    end))

    --Return the object.
    return self
end

--[[
Updates the contents of the ScrollingFrame.
--]]
function VirtualScrollList.UpdateScrollingFrameContents<T>(self: VirtualScrollList<T>): ()
    --Calculate the sizes for the entries.
    debug.profilebegin("VirtualScrollList.UpdateScrollingFrameContents")
    local IsHorizontal = (self.Direction == Enum.ScrollingDirection.X)
    local CanvasPosition = IsHorizontal and self.ScrollingFrame.CanvasPosition.X or self.ScrollingFrame.CanvasPosition.Y
    local WindowHeight = IsHorizontal and self.ScrollingFrame.AbsoluteWindowSize.X or self.ScrollingFrame.AbsoluteWindowSize.Y
    local EntryHeight = self.EntryHeight
    local TotalDisplayEntries = math.ceil(WindowHeight / EntryHeight)
    local AdditionalEntries = self.OverrideAdditionalEntries or math.ceil(ADDITIONAL_ENTRIES_MULTIPLUER * TotalDisplayEntries)
    local BaseStartIndex = math.floor(CanvasPosition / EntryHeight)
    local StartIndex = math.max(0, BaseStartIndex - AdditionalEntries)
    local MaxEndIndex = #self.Data - 1
    local EndIndex = math.min(MaxEndIndex, BaseStartIndex + TotalDisplayEntries + AdditionalEntries)
    
    --Remove entries that are out of range.
    --Entries are marked as stale but kept, 
    --Entires are remove in a separate loop to prevent modifying the table when iterating.
    --This step is done before creating frames to allow for new stale frames to be reused.
    debug.profilebegin("VirtualScrollList.UpdateScrollingFrameContents.InvalidateFrames")
    local ResizeExistingEntries = (self.LastEntryHeight ~= EntryHeight)
    local EntriesToRemove = {}
    for i, Entry in self.Entries do
        if i - 1 >= StartIndex and i - 1 <= EndIndex then continue end
        EntriesToRemove[i] = Entry
    end
    for i, Entry in EntriesToRemove do
        self.Entries[i] = nil
        if ResizeExistingEntries or i > #self.Data then
            Entry:Destroy()
        else
            table.insert(self.StaleEntries, {LastIndex = i, Entry = Entry})
        end
    end
    debug.profileend()

    --Re-use stale entries if they became visible.
    debug.profilebegin("VirtualScrollList.UpdateScrollingFrameContents.ReuseStaleFrames")
    local EntrySize = (IsHorizontal and UDim2.new(0, EntryHeight, 1, 0) or UDim2.new(1, 0, 0, EntryHeight))
    for i = #self.StaleEntries, 1, -1 do
        local StaleEntry = self.StaleEntries[i]
        local StaleEntryIndex = StaleEntry.LastIndex
        if self.Entries[StaleEntryIndex] then continue end
        if StaleEntryIndex - 1 < StartIndex or StaleEntryIndex - 1 > EndIndex then continue end
        
        local EntryPosition = (IsHorizontal and UDim2.new(0, (StaleEntryIndex - 1) * EntryHeight, 0, 0) or UDim2.new(0, 0, 0, (StaleEntryIndex - 1) * EntryHeight))
        local ExistingEntry = StaleEntry.Entry
        ExistingEntry.GuiInstance.Position = EntryPosition
        ExistingEntry.GuiInstance.Size = EntrySize
        ExistingEntry:Update(StaleEntryIndex, self.Data[StaleEntryIndex])
        table.remove(self.StaleEntries, i)
        self.Entries[StaleEntryIndex] = ExistingEntry
    end
    debug.profileend()

    --Create the new list entries.
    --As an optimization, entries don't need to be updated because they have been set before.
    --Only the size is changed for existing entries since the contents will be correct.
    debug.profilebegin("VirtualScrollList.UpdateScrollingFrameContents.UpdateContents")
    for i = StartIndex, EndIndex do
        --Resize the GUI instance if it was resized.
		local Index = i + 1
        local ExistingEntry = self.Entries[Index]
        local EntryPosition = (IsHorizontal and UDim2.new(0, i * EntryHeight, 0, 0) or UDim2.new(0, 0, 0, i * EntryHeight))
        if ExistingEntry then
            if ResizeExistingEntries then
                ExistingEntry.GuiInstance.Position = EntryPosition
                ExistingEntry.GuiInstance.Size = EntrySize
            end
            continue
        end
        
        --Get and reuse a stale entry or create a new entry.
        local NewEntry = nil
        if #self.StaleEntries > 0 then
            NewEntry = self.StaleEntries[#self.StaleEntries].Entry
            table.remove(self.StaleEntries, #self.StaleEntries)
            NewEntry:Update(Index, self.Data[Index])
        else
            NewEntry = self.ListEntryConstructor(Index, self.Data[Index])
            NewEntry.GuiInstance.Parent = self.ScrollingFrame
        end

        --Move the list entry.
        NewEntry.GuiInstance.Position = EntryPosition
        NewEntry.GuiInstance.Size = EntrySize
        self.Entries[Index] = NewEntry
    end
    self.LastEntryHeight = EntryHeight
    debug.profileend()

    --Remove stale frames that are within the current view.
    debug.profilebegin("VirtualScrollList.UpdateScrollingFrameContents.RemoveVisibleStaleFrames")
    for i = #self.StaleEntries, 1, -1 do
        local StaleEntry = self.StaleEntries[i]
        local StaleEntryIndex = StaleEntry.LastIndex
        if StaleEntryIndex - 1 < StartIndex or (StaleEntryIndex - 1 > EndIndex and MaxEndIndex >= EndIndex) then continue end
        StaleEntry.Entry:Destroy()
        table.remove(self.StaleEntries, i)
    end
    debug.profileend()
    debug.profileend()
end

--[[
Updates the size of the ScrollingFrame canvas.
--]]
function VirtualScrollList.UpdateScrollingFrameSize<T>(self: VirtualScrollList<T>): ()
    local IsHorizontal = (self.Direction == Enum.ScrollingDirection.X)
    local ScrollingEntryWidth = UDim.new(self.ScrollWidth.Scale, self.ScrollWidth.Offset)
    local ScrollingEntryHeight = UDim.new(0, #self.Data * self.EntryHeight)
    self.ScrollingFrame.CanvasSize = UDim2.new(IsHorizontal and ScrollingEntryHeight or ScrollingEntryWidth, IsHorizontal and ScrollingEntryWidth or ScrollingEntryHeight)
end

--[[
Sets the width (scale + offset) of the ScrollingFrame.
--]]
function VirtualScrollList.SetScrollWidth<T>(self: VirtualScrollList<T>, ScrollWidth: UDim): ()
    --Set the width.
    self.ScrollWidth = ScrollWidth

    --Update only the size.
    --Since the height is the same, no changes to the contents are required.
    self:UpdateScrollingFrameSize()
end

--[[
Sets the height of the invidual list entries.
Only pixel-based heights are supported.
--]]
function VirtualScrollList.SetEntryHeight<T>(self: VirtualScrollList<T>, EntryHeight: number): ()
    --Update the entry height and clear stale entries.
    --Stale entries can't be guarenteed to be out of the way when scrolling using the new height.
    self.EntryHeight = EntryHeight
    for _, Entry in self.StaleEntries do
        Entry.Entry:Destroy()
    end
    self.StaleEntries = {}
    
    --Update the size and contents.
    self:UpdateScrollingFrameSize()
    self:UpdateScrollingFrameContents()
end

--[[
Sets the data for a specific index.
This is only intended for single-entry updates (not bulk changes).
--]]
function VirtualScrollList.SetDataEntry<T>(self: VirtualScrollList<T>, Index: number, Data: T): ()
    --Store the updated entry.
    local PreviousDataEntry = self.Data[Index]
    self.Data[Index] = Data

    --Update the visible entry if there is one.
    local ExistingEntry = self.Entries[Index]
    if ExistingEntry then
        ExistingEntry:Update(Index, Data)
    end
    
    --Update the size and contents if there was no previous data entry.
    --If a previous data entry exists, no additional entries need to be created.
    if PreviousDataEntry then return end
    self:UpdateScrollingFrameSize()
    self:UpdateScrollingFrameContents()
end

--[[
Sets the data for all entries.
--]]
function VirtualScrollList.SetData<T>(self: VirtualScrollList<T>, Data: {T}): ()
    --Store the new data.
    self.Data = Data

    --Update the visible entries.
    for i, Entry in self.Entries do
        local ExistingData = Data[i]
        if not ExistingData then continue end
        Entry:Update(i, ExistingData)
    end

    --Update the size and contents of the new data.
    self:UpdateScrollingFrameSize()
    self:UpdateScrollingFrameContents()
end

--[[
Destroys the virtual scroll list.
--]]
function VirtualScrollList.Destroy<T>(self: VirtualScrollList<T>): ()
    --Disconnect the events.
    for _, Connection in self.EventConnections do
        Connection:Disconnect()
    end
    self.EventConnections = {}

    --Clear the instances.
    for _, Entry in self.Entries do
        Entry:Destroy()
    end
    self.Entries = {}
    for _, Entry in self.StaleEntries do
        Entry.Entry:Destroy()
    end
    self.StaleEntries = {}
end



return VirtualScrollList