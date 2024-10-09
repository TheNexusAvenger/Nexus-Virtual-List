--Main module for creating virtual scroll lists.
--VirtualScrollList is intended for user scrolling, while AutoScrollingVirtualScrollList is intended for no user input.
--!strict

local Types = require(script:WaitForChild("Types"))
local VirtualScrollList = require(script:WaitForChild("VirtualScrollList"))
local AutoScrollingVirtualScrollList = require(script:WaitForChild("AutoScrollingVirtualScrollList"))

export type ListEntry<T> = Types.ListEntry<T>
export type ListEntryConstructor<T> = Types.ListEntryConstructor<T>
export type VirtualScrollList<T> = VirtualScrollList.VirtualScrollList<T>
export type AutoScrollingVirtualScrollList<T> = AutoScrollingVirtualScrollList.AutoScrollingVirtualScrollList<T>

local NexusVirtualList = {}



--[[
Creates a virtual scroll list from an existing ScrollingFrame.
--]]
function NexusVirtualList.CreateVirtualScrollList<T>(ScrollingFrame: ScrollingFrame, ListEntryConstructor: Types.ListEntryConstructor<T>, Direction: Enum.ScrollingDirection?): VirtualScrollList<T>
    return VirtualScrollList.new(ScrollingFrame, ListEntryConstructor, Direction)
end

--[[
Creates an auto-scrolling virtual scroll list from an existing ScrollingFrame.
--]]
function NexusVirtualList.CreateAutoScrollingVirtualScrollList<T>(ScrollingFrame: ScrollingFrame, ListEntryConstructor: Types.ListEntryConstructor<T>, Direction: Enum.ScrollingDirection?): AutoScrollingVirtualScrollList<T>
    return AutoScrollingVirtualScrollList.new(ScrollingFrame, ListEntryConstructor, Direction)
end



return NexusVirtualList