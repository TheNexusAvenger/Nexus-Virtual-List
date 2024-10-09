--Extendedd version of VirtualScrollList that automatically scrolls.
--!strict

local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Types = require(script.Parent:WaitForChild("Types"))
local VirtualScrollList = require(script.Parent:WaitForChild("VirtualScrollList"))

local AutoScrollingVirtualScrollList = {}
AutoScrollingVirtualScrollList.__index = AutoScrollingVirtualScrollList

export type AutoScrollingVirtualScrollList<T> = {
    ScrollingFrame: ScrollingFrame,
    VirtualScrollList: VirtualScrollList.VirtualScrollList<T>,
    Data: {T},
    AutoScrollEventConnection: RBXScriptConnection?,
    EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, AutoScrollingVirtualScrollList))



--[[
Creates an auto-scrolling virtual scroll list from an existing ScrollingFrame.
--]]
function AutoScrollingVirtualScrollList.new<T>(ScrollingFrame: ScrollingFrame, ListEntryConstructor: Types.ListEntryConstructor<T>, Direction: Enum.ScrollingDirection?): AutoScrollingVirtualScrollList<T>
    --Create the initial object.
    local self = setmetatable({
        ScrollingFrame = ScrollingFrame,
        VirtualScrollList = VirtualScrollList.new(ScrollingFrame, ListEntryConstructor, Direction),
        Data = {},
        EventConnections = {},
    }, AutoScrollingVirtualScrollList) :: AutoScrollingVirtualScrollList<T>

    --Disable scrolling and the scroll bars.
    self.VirtualScrollList.OverrideAdditionalEntries = 0
    ScrollingFrame.ScrollingEnabled = false
    ScrollingFrame.ScrollBarThickness = 0

    --Connect changes to the ScrollingFrame.
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
function AutoScrollingVirtualScrollList.UpdateScrollingFrameContents<T>(self: AutoScrollingVirtualScrollList<T>): ()
    --Calculate the sizes for the entries.
    local IsHorizontal = (self.VirtualScrollList.Direction == Enum.ScrollingDirection.X)
    local WindowHeight = IsHorizontal and self.ScrollingFrame.AbsoluteWindowSize.X or self.ScrollingFrame.AbsoluteWindowSize.Y
    local EntryHeight = self.VirtualScrollList.EntryHeight
    local TotalDisplayEntries = math.ceil(WindowHeight / EntryHeight)

    --Build the data to display.
    local TotalDataEntries = #self.Data
    local NewData = {}
    for i = 1, TotalDataEntries do
        table.insert(NewData, self.Data[i])
    end
    if TotalDataEntries > TotalDisplayEntries then
        for i = 1, TotalDisplayEntries do
            table.insert(NewData, self.Data[i])
        end
    end

    --Set the underlying data.
    self.VirtualScrollList:SetData(NewData)
end

--[[
Moves the canvas to a given pixel location.
Values that overflow will be wrapped around.
--]]
function AutoScrollingVirtualScrollList.MoveCanvasTo<T>(self: AutoScrollingVirtualScrollList<T>, Offset: number): ()
    --Calculate the new position.
    local IsHorizontal = (self.VirtualScrollList.Direction == Enum.ScrollingDirection.X)
    local EntryHeight = self.VirtualScrollList.EntryHeight
    local CanvasMaxPosition = #self.Data * EntryHeight
    if CanvasMaxPosition == 0 then
        Offset = 0
    end
    while Offset < 0 do
        Offset += CanvasMaxPosition
    end
    while Offset > CanvasMaxPosition do
        Offset += -CanvasMaxPosition
    end

    --Set the new canvas position.
    if IsHorizontal then
        self.ScrollingFrame.CanvasPosition = Vector2.new(Offset, 0)
    else
        self.ScrollingFrame.CanvasPosition = Vector2.new(0, Offset)
    end
end

--[[
Moves the canvas to a given entry multiple.
Values that overflow will be wrapped around.
--]]
function AutoScrollingVirtualScrollList.MoveCanvasToRelative<T>(self: AutoScrollingVirtualScrollList<T>, Multiplier: number): ()
    self:MoveCanvasTo(Multiplier * self.VirtualScrollList.EntryHeight)
end
--[[
Offsets the canvas by an amount of pixels.
--]]
function AutoScrollingVirtualScrollList.OffsetCanvas<T>(self: AutoScrollingVirtualScrollList<T>, Offset: number): ()
    local IsHorizontal = (self.VirtualScrollList.Direction == Enum.ScrollingDirection.X)
    local CanvasPosition = IsHorizontal and self.ScrollingFrame.CanvasPosition.X or self.ScrollingFrame.CanvasPosition.Y
    self:MoveCanvasTo(CanvasPosition + Offset)
end

--[[
Offsets the cavnas by a multiplier of the entry height.
--]]
function AutoScrollingVirtualScrollList.OffsetCanvasRelative<T>(self: AutoScrollingVirtualScrollList<T>, Multiplier: number): ()
    self:OffsetCanvas(Multiplier * self.VirtualScrollList.EntryHeight)
end

--[[
Stops the current auto-scrolling.
--]]
function AutoScrollingVirtualScrollList.StopAutoScrolling<T>(self: AutoScrollingVirtualScrollList<T>): ()
    if not self.AutoScrollEventConnection then return end
    self.AutoScrollEventConnection:Disconnect()
    self.AutoScrollEventConnection = nil
end

--[[
Starts auto-scrolling with the given speed in entry heights per seconds.
The speed can be negative.
--]]
function AutoScrollingVirtualScrollList.StartAutoScrolling<T>(self: AutoScrollingVirtualScrollList<T>, Multiplier: number): ()
    self:StopAutoScrolling()

    --Start the update loop.
    local LastShiftTime: number? = nil
    self.AutoScrollEventConnection = RunService.Stepped:Connect(function(_, DeltaTime: number)
        if GuiService.ReducedMotionEnabled then
            --Set the last shift time if ReducedMotionEnabled was not run yet, and align the list.
            local IsHorizontal = (self.VirtualScrollList.Direction == Enum.ScrollingDirection.X)
            local EntryHeight = self.VirtualScrollList.EntryHeight
            local WindowHeight = IsHorizontal and self.ScrollingFrame.AbsoluteWindowSize.X or self.ScrollingFrame.AbsoluteWindowSize.Y
            if not LastShiftTime then
                local CanvasPosition = IsHorizontal and self.ScrollingFrame.CanvasPosition.X or self.ScrollingFrame.CanvasPosition.Y
                self:MoveCanvasToRelative(math.floor(CanvasPosition / EntryHeight))
                LastShiftTime = tick()
            end

            --Shift the list if enough time has passed.
            local VisibleEntries = math.floor(WindowHeight / EntryHeight)
            if (tick() - LastShiftTime :: number) >= VisibleEntries / Multiplier then
                self:OffsetCanvasRelative(VisibleEntries)
                LastShiftTime = tick()
            end
        else
            --Move the offset based on the frame time.
            self:OffsetCanvasRelative(DeltaTime * Multiplier)
            LastShiftTime = nil
        end
    end)
end

--[[
Sets the width (scale + offset) of the ScrollingFrame.
--]]
function AutoScrollingVirtualScrollList.SetScrollWidth<T>(self: AutoScrollingVirtualScrollList<T>, ScrollWidth: UDim): ()
    self.VirtualScrollList:SetScrollWidth(ScrollWidth)
end

--[[
Sets the height of the invidual list entries.
Only pixel-based heights are supported.
--]]
function AutoScrollingVirtualScrollList.SetEntryHeight<T>(self: AutoScrollingVirtualScrollList<T>, EntryHeight: number): ()
    self.VirtualScrollList:SetEntryHeight(EntryHeight)
    self:UpdateScrollingFrameContents()
end

--[[
Sets the data for all entries.
--]]
function AutoScrollingVirtualScrollList.SetData<T>(self: AutoScrollingVirtualScrollList<T>, Data: {T}): ()
    self.Data = Data
    self:UpdateScrollingFrameContents()
end

--[[
Destroys the auto-scrolling virtual scroll list.
--]]
function AutoScrollingVirtualScrollList.Destroy<T>(self: AutoScrollingVirtualScrollList<T>): ()
    --Disconnect the events.
    self:StopAutoScrolling()
    for _, Connection in self.EventConnections do
        Connection:Disconnect()
    end
    self.EventConnections = {}

    --Destroy the virtual scroll list.
    self.VirtualScrollList:Destroy()
end



return AutoScrollingVirtualScrollList