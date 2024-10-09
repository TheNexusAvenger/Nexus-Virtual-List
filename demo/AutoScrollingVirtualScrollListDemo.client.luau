--Demo for the AutoScrollingVirtualScrollList.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NexusVirtualList = ReplicatedStorage:WaitForChild("NexusVirtualList")
local AutoScrollingVirtualScrollList = require(NexusVirtualList:WaitForChild("AutoScrollingVirtualScrollList"))
local TestListEntry = require(script.Parent:WaitForChild("TestListEntry"))



local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoScrollingVirtualScrollListDemo"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local VerticalScrollingFrame = Instance.new("ScrollingFrame")
VerticalScrollingFrame.BackgroundTransparency = 0.5
VerticalScrollingFrame.Size = UDim2.new(0, 200, 0, 300)
VerticalScrollingFrame.Position = UDim2.new(0, 650, 0, 50)
VerticalScrollingFrame.Parent = ScreenGui

local HorizontalScrollingFrame = Instance.new("ScrollingFrame")
HorizontalScrollingFrame.BackgroundTransparency = 0.5
HorizontalScrollingFrame.Size = UDim2.new(0, 400, 0, 100)
HorizontalScrollingFrame.Position = UDim2.new(0, 650, 0, 400)
HorizontalScrollingFrame.Parent = ScreenGui

local VerticalScrollList = AutoScrollingVirtualScrollList.new(VerticalScrollingFrame, TestListEntry.new)
--VerticalScrollList:SetScrollWidth(UDim.new(0, 300))
VerticalScrollList:SetEntryHeight(24)

local HorizontalScrollList = AutoScrollingVirtualScrollList.new(HorizontalScrollingFrame, TestListEntry.new, Enum.ScrollingDirection.X)
--HorizontalScrollList:SetScrollWidth(UDim.new(0, 300))
HorizontalScrollList:SetEntryHeight(50)

local TestData = {}
for i = 1, 20 do
    table.insert(TestData, `Entry_{i}`)
end
VerticalScrollList:SetData(TestData)
HorizontalScrollList:SetData(TestData)
--Note: SetDataEntry is not supported.

--For automatic scrolling, the following will scroll 2 entries per second.
VerticalScrollList:StartAutoScrolling(2)

--For manual scrolling, use MoveCanvasTo, MoveCanvasToRelative, OffsetCanvas, or OffsetCanvasRelative.
local LastPosition = 0
while true do
    local StartTime = tick()
    while true do
        local TimeOffset = tick() - StartTime
        if TimeOffset > 5 then break end
        HorizontalScrollList:MoveCanvasToRelative(LastPosition + (25 - ((5 - TimeOffset) ^ 2)))
        RunService.Stepped:Wait()
    end
    task.wait(0.5)
end