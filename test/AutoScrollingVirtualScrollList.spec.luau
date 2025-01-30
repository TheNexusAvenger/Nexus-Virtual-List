--Tests AutoScrollingVirtualScrollList.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusVirtualList = ReplicatedStorage:WaitForChild("NexusVirtualList")
local AutoScrollingVirtualScrollList = require(NexusVirtualList:WaitForChild("AutoScrollingVirtualScrollList"))

return function()
    describe("An AutoScrollingVirtualScrollList", function()
        local TestScrollingFrame, TestVirtualScrollList = nil, nil
        beforeEach(function()
            TestScrollingFrame = Instance.new("ScrollingFrame")
            TestScrollingFrame.Size = UDim2.new(0, 100, 0, 100)

            TestVirtualScrollList = AutoScrollingVirtualScrollList.new(TestScrollingFrame, function(Index, Data)
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Text = `{Index}_{Data}`
                return {
                    GuiInstance = TextLabel,
                    Update = function(self, Index, Data): ()
                        TextLabel.Text = `{Index}_{Data}`
                    end,
                    Destroy = function(self): ()
                        TextLabel:Destroy()
                    end,
                } :: any
            end)
            for _, Connection in TestVirtualScrollList.VirtualScrollList.EventConnections do
                Connection:Disconnect()
            end
            TestVirtualScrollList.VirtualScrollList.EventConnections = {}
            for _, Connection in TestVirtualScrollList.EventConnections do
                Connection:Disconnect()
            end
            TestVirtualScrollList.EventConnections = {}
        end)

        afterEach(function()
            TestScrollingFrame:Destroy()
            TestVirtualScrollList:Destroy()
        end)

        it("should change the ScrollingFrame.", function()
            expect(TestVirtualScrollList.VirtualScrollList.OverrideAdditionalEntries).to.equal(0)
            expect(TestScrollingFrame.ScrollingEnabled).to.equal(false)
            expect(TestScrollingFrame.ScrollBarThickness).to.equal(0)
        end)

        it("should display limited data without wrapping.", function()
            TestVirtualScrollList:SetData({"1", "2", "3"})
            expect(#TestVirtualScrollList.VirtualScrollList.Data).to.equal(3)
            expect(TestScrollingFrame.CanvasSize).to.equal(UDim2.new(0, 0, 0, 60))
        end)

        it("should display data with wrapping.", function()
            TestVirtualScrollList:SetData({"1", "2", "3"})
            TestVirtualScrollList:SetData({"1", "2", "3", "4", "5", "6"})
            expect(#TestVirtualScrollList.VirtualScrollList.Data).to.equal(6 + 5)
            expect(TestScrollingFrame.CanvasSize).to.equal(UDim2.new(0, 0, 0, 220))
            for i = 1, 5 do
                expect(TestVirtualScrollList.VirtualScrollList.Data[6 + i]).to.equal(tostring(i))
            end
        end)

        it("should move the canvas.", function()
            local Data = {}
            for i = 1, 100 do
                table.insert(Data, tostring(i))
            end
            TestVirtualScrollList:SetData(Data)

            TestVirtualScrollList:MoveCanvasTo(200)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(0, 200))
        end)

        it("should move the canvas with a negative overflow.", function()
            local Data = {}
            for i = 1, 100 do
                table.insert(Data, tostring(i))
            end
            TestVirtualScrollList:SetData(Data)

            TestVirtualScrollList:MoveCanvasTo(-5800)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(0, 200))
        end)

        it("should move the canvas with a positive overflow.", function()
            local Data = {}
            for i = 1, 100 do
                table.insert(Data, tostring(i))
            end
            TestVirtualScrollList:SetData(Data)

            TestVirtualScrollList:MoveCanvasTo(4200)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(0, 200))
        end)

        it("should move the canvas with no data.", function()
            TestVirtualScrollList:SetData({})

            TestVirtualScrollList:MoveCanvasTo(4200)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(0, 0))
        end)

        it("should move the canvas relatively.", function()
            local Data = {}
            for i = 1, 100 do
                table.insert(Data, tostring(i))
            end
            TestVirtualScrollList:SetData(Data)

            TestVirtualScrollList:MoveCanvasToRelative(10)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(0, 200))
        end)

        it("should offset the canvas.", function()
            local Data = {}
            for i = 1, 100 do
                table.insert(Data, tostring(i))
            end
            TestVirtualScrollList:SetData(Data)

            TestVirtualScrollList:MoveCanvasTo(200)
            TestVirtualScrollList:OffsetCanvas(100)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(0, 300))
        end)

        it("should offset the canvas relatively.", function()
            local Data = {}
            for i = 1, 100 do
                table.insert(Data, tostring(i))
            end
            TestVirtualScrollList:SetData(Data)

            TestVirtualScrollList:MoveCanvasTo(200)
            TestVirtualScrollList:OffsetCanvasRelative(5)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(0, 300))
        end)

        it("should move the canvas horizontally.", function()
            TestVirtualScrollList.VirtualScrollList.Direction = Enum.ScrollingDirection.X
            local Data = {}
            for i = 1, 100 do
                table.insert(Data, tostring(i))
            end
            TestVirtualScrollList:SetData(Data)

            TestVirtualScrollList:MoveCanvasTo(200)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(200, 0))
        end)

        it("should offset the canvas horizontally.", function()
            TestVirtualScrollList.VirtualScrollList.Direction = Enum.ScrollingDirection.X
            local Data = {}
            for i = 1, 100 do
                table.insert(Data, tostring(i))
            end
            TestVirtualScrollList:SetData(Data)

            TestVirtualScrollList:MoveCanvasTo(200)
            TestVirtualScrollList:OffsetCanvasRelative(5)
            expect(TestScrollingFrame.CanvasPosition).to.equal(Vector2.new(300, 0))
        end)

        it("should pass through scroll width.", function()
            TestVirtualScrollList:SetScrollWidth(UDim.new(1, 0))
            expect(TestVirtualScrollList.VirtualScrollList.ScrollWidth).to.equal(UDim.new(1, 0))
        end)

        it("should pass through entry height.", function()
            TestVirtualScrollList:SetData({"1", "2", "3", "4", "5", "6"})
            TestVirtualScrollList:SetEntryHeight(25)
            expect(TestVirtualScrollList.VirtualScrollList.EntryHeight).to.equal(25)

            expect(#TestVirtualScrollList.VirtualScrollList.Data).to.equal(6 + 4)
            expect(TestScrollingFrame.CanvasSize).to.equal(UDim2.new(0, 0, 0, 250))
            for i = 1, 4 do
                expect(TestVirtualScrollList.VirtualScrollList.Data[6 + i]).to.equal(tostring(i))
            end
        end)
    end)
end