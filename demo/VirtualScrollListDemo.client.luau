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

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.BackgroundTransparency = 0.5
ScrollingFrame.Size = UDim2.new(0, 200, 0, 300)
ScrollingFrame.Position = UDim2.new(0, 200, 0, 50)
ScrollingFrame.Parent = ScreenGui

local ScrollList = VirtualScrollList.new(ScrollingFrame, TestListEntry.new)
--ScrollList:SetScrollWidth(UDim.new(0, 300))
ScrollList:SetEntryHeight(24)

local TestData = {}
for i = 1, 1000 do
    table.insert(TestData, `Entry_{i}`)
end
ScrollList:SetData(TestData)
--To change 1 entry: ScrollList:SetDataEntry(i, "SomeValue")