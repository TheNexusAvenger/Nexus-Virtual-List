--Demo for the VirtualScrollList.
--!strict

local INCLUDE_UI_LAYOUT_DEMO = false --Enable to test warning messages for having UILayouts.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusVirtualList = require(ReplicatedStorage:WaitForChild("NexusVirtualList"))
local TestListEntry = require(script.Parent:WaitForChild("TestListEntry"))



local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VirtualScrollListDemo"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local VerticalScrollingFrame = Instance.new("ScrollingFrame")
VerticalScrollingFrame.BackgroundTransparency = 0.5
VerticalScrollingFrame.Size = UDim2.new(0, 200, 0, 300)
VerticalScrollingFrame.Position = UDim2.new(0, 200, 0, 50)
VerticalScrollingFrame.Parent = ScreenGui

if INCLUDE_UI_LAYOUT_DEMO then
    --UILayouts in the scrolling frames will cause issues!
    Instance.new("UIListLayout").Parent = VerticalScrollingFrame
    Instance.new("UITableLayout").Parent = VerticalScrollingFrame
end

local HorizontalScrollingFrame = Instance.new("ScrollingFrame")
HorizontalScrollingFrame.BackgroundTransparency = 0.5
HorizontalScrollingFrame.Size = UDim2.new(0, 400, 0, 100)
HorizontalScrollingFrame.Position = UDim2.new(0, 200, 0, 400)
HorizontalScrollingFrame.Parent = ScreenGui

if INCLUDE_UI_LAYOUT_DEMO then
    task.delay(1, function()
        --UILayouts in the scrolling frames will cause issues!
        Instance.new("UIGridLayout").Parent = VerticalScrollingFrame
    end)
end

local VerticalScrollList = NexusVirtualList.CreateVirtualScrollList(VerticalScrollingFrame, TestListEntry.new)
--VerticalScrollList:SetScrollWidth(UDim.new(0, 300))
VerticalScrollList:SetEntryHeight(24)

local HorizontalScrollList = NexusVirtualList.CreateVirtualScrollList(HorizontalScrollingFrame, TestListEntry.new, Enum.ScrollingDirection.X)
--HorizontalScrollList:SetScrollWidth(UDim.new(0, 300))
HorizontalScrollList:SetEntryHeight(50)

local TestData = {}
for i = 1, 1000 do
    table.insert(TestData, `Entry_{i}`)
end
VerticalScrollList:SetData(TestData)
HorizontalScrollList:SetData(TestData)
--To change 1 entry: VerticalScrollList:SetDataEntry(i, "SomeValue")