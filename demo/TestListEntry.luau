--Test ListEntry implementation for the demo.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusVirtualList = ReplicatedStorage:WaitForChild("NexusVirtualList")
local NexusVirtualListTypes = require(NexusVirtualList:WaitForChild("Types"))

local TestListEntry = {}
TestListEntry.__index = TestListEntry

export type TestListEntry = {
    GuiInstance: TextLabel,
} & typeof(setmetatable({}, TestListEntry))



--[[
Creates a test list entry.
--]]
function TestListEntry.new(InitialIndex: number, InitialData: string): NexusVirtualListTypes.ListEntry<string>
    local self = setmetatable({
        GuiInstance = Instance.new("TextLabel"),
    }, TestListEntry) :: TestListEntry
    self.GuiInstance.BackgroundTransparency = 0.5
    self.GuiInstance.TextScaled = true
    self:Update(InitialIndex, InitialData)
    return (self :: any) :: NexusVirtualListTypes.ListEntry<string>
end

--[[
Updates the tesst list entry.
--]]
function TestListEntry.Update(self: TestListEntry, Index: number, Data: string): ()
    self.GuiInstance.Text = `{Index}: {Data}`
end

--[[
Destroys the test list entry.
--]]
function TestListEntry.Destroy(self: TestListEntry): ()
    self.GuiInstance:Destroy()
end



return TestListEntry