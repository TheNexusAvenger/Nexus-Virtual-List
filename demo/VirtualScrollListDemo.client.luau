--Demo for the VirtualScrollList.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusVirtualList = ReplicatedStorage:WaitForChild("NexusVirtualList")
local VirtualScrollList = require(NexusVirtualList:WaitForChild("VirtualScrollList"))
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

local HorizontalScrollingFrame = Instance.new("ScrollingFrame")
HorizontalScrollingFrame.BackgroundTransparency = 0.5
HorizontalScrollingFrame.Size = UDim2.new(0, 400, 0, 100)
HorizontalScrollingFrame.Position = UDim2.new(0, 200, 0, 400)
HorizontalScrollingFrame.Parent = ScreenGui

local VerticalScrollList = VirtualScrollList.new(VerticalScrollingFrame, TestListEntry.new)
--VerticalScrollList:SetScrollWidth(UDim.new(0, 300))
VerticalScrollList:SetEntryHeight(24)

local HorizontalScrollList = VirtualScrollList.new(HorizontalScrollingFrame, TestListEntry.new, Enum.ScrollingDirection.X)
--HorizontalScrollList:SetScrollWidth(UDim.new(0, 300))
HorizontalScrollList:SetEntryHeight(50)

local TestData = {}
for i = 1, 1000 do
    table.insert(TestData, `Entry_{i}`)
end
VerticalScrollList:SetData(TestData)
HorizontalScrollList:SetData(TestData)
--To change 1 entry: VerticalScrollList:SetDataEntry(i, "SomeValue")