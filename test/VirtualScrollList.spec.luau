--Tests VirtualScrollList.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusVirtualList = ReplicatedStorage:WaitForChild("NexusVirtualList")
local VirtualScrollList = require(NexusVirtualList:WaitForChild("VirtualScrollList"))

return function()
    describe("A VirtualScrollList", function()
        local TestScrollingFrame, TestVirtualScrollList = nil, nil
        local TextLabels, UpdateCalls = {}, 0
        beforeEach(function()
            TestScrollingFrame = Instance.new("ScrollingFrame")
            TestScrollingFrame.Size = UDim2.new(0, 100, 0, 100)

            TestVirtualScrollList = VirtualScrollList.new(TestScrollingFrame, function(Index, Data)
                UpdateCalls += 1
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Text = `{Index}_{Data}`
                table.insert(TextLabels, TextLabel)
                return {
                    GuiInstance = TextLabel,
                    Update = function(self, Index, Data): ()
                        UpdateCalls += 1
                        TextLabel.Text = `{Index}_{Data}`
                    end,
                    Destroy = function(self): ()
                        TextLabel:Destroy()
                    end,
                } :: any
            end)
            for _, Connection in TestVirtualScrollList.EventConnections do
                Connection:Disconnect()
            end
            TestVirtualScrollList.EventConnections = {}
        end)

        afterEach(function()
            TestScrollingFrame:Destroy()
            TestVirtualScrollList:Destroy()
            TextLabels = {}
            UpdateCalls = 0
        end)

        it("should create frames from data.", function()
            TestVirtualScrollList:SetData({"1", "2", "3"})
            expect(#TextLabels).to.equal(3)
            expect(UpdateCalls).to.equal(3)
            expect(TextLabels[1].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[1].Position).to.equal(UDim2.new(0, 0, 0, 0))
            expect(TextLabels[1].Text).to.equal("1_1")
            expect(TextLabels[2].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[2].Position).to.equal(UDim2.new(0, 0, 0, 20))
            expect(TextLabels[2].Text).to.equal("2_2")
            expect(TextLabels[3].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[3].Position).to.equal(UDim2.new(0, 0, 0, 40))
            expect(TextLabels[3].Text).to.equal("3_3")
        end)

        it("should create additional frames from data.", function()
            TestVirtualScrollList:SetData({"1"})
            expect(#TextLabels).to.equal(1)
            expect(UpdateCalls).to.equal(1)
            expect(TextLabels[1].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[1].Position).to.equal(UDim2.new(0, 0, 0, 0))
            expect(TextLabels[1].Text).to.equal("1_1")
            TestVirtualScrollList:SetData({"1", "2", "3"})
            expect(#TextLabels).to.equal(3)
            expect(UpdateCalls).to.equal(4)
            expect(TextLabels[1].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[1].Position).to.equal(UDim2.new(0, 0, 0, 0))
            expect(TextLabels[1].Text).to.equal("1_1")
            expect(TextLabels[2].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[2].Position).to.equal(UDim2.new(0, 0, 0, 20))
            expect(TextLabels[2].Text).to.equal("2_2")
            expect(TextLabels[3].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[3].Position).to.equal(UDim2.new(0, 0, 0, 40))
            expect(TextLabels[3].Text).to.equal("3_3")
        end)

        it("should remove additional frames from data.", function()
            TestVirtualScrollList:SetData({"1", "2", "3"})
            TestVirtualScrollList:SetData({"1"})
            expect(#TextLabels).to.equal(3)
            expect(UpdateCalls).to.equal(4)
            expect(TextLabels[1].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[1].Position).to.equal(UDim2.new(0, 0, 0, 0))
            expect(TextLabels[1].Text).to.equal("1_1")
            expect(TextLabels[2].Parent).to.equal(nil)
            expect(TextLabels[3].Parent).to.equal(nil)
        end)

        it("should update data.", function()
            TestVirtualScrollList:SetData({"1", "2", "3"})
            expect(#TextLabels).to.equal(3)
            expect(UpdateCalls).to.equal(3)
            TestVirtualScrollList:SetData({"4", "5", "6"})
            expect(#TextLabels).to.equal(3)
            expect(UpdateCalls).to.equal(6)
            expect(TextLabels[1].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[1].Position).to.equal(UDim2.new(0, 0, 0, 0))
            expect(TextLabels[1].Text).to.equal("1_4")
            expect(TextLabels[2].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[2].Position).to.equal(UDim2.new(0, 0, 0, 20))
            expect(TextLabels[2].Text).to.equal("2_5")
            expect(TextLabels[3].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[3].Position).to.equal(UDim2.new(0, 0, 0, 40))
            expect(TextLabels[3].Text).to.equal("3_6")
        end)

        it("should update data entries.", function()
            TestVirtualScrollList:SetData({"1", "2", "3"})
            expect(#TextLabels).to.equal(3)
            expect(UpdateCalls).to.equal(3)
            TestVirtualScrollList:SetDataEntry(2, "5")
            expect(#TextLabels).to.equal(3)
            expect(UpdateCalls).to.equal(4)
            expect(TextLabels[1].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[1].Position).to.equal(UDim2.new(0, 0, 0, 0))
            expect(TextLabels[1].Text).to.equal("1_1")
            expect(TextLabels[2].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[2].Position).to.equal(UDim2.new(0, 0, 0, 20))
            expect(TextLabels[2].Text).to.equal("2_5")
            expect(TextLabels[3].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[3].Position).to.equal(UDim2.new(0, 0, 0, 40))
            expect(TextLabels[3].Text).to.equal("3_3")
        end)

        it("should update new data entries.", function()
            TestVirtualScrollList:SetData({"1", "2", "3"})
            expect(#TextLabels).to.equal(3)
            expect(UpdateCalls).to.equal(3)
            TestVirtualScrollList:SetDataEntry(4, "4")
            expect(#TextLabels).to.equal(4)
            expect(UpdateCalls).to.equal(4)
            expect(TextLabels[1].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[1].Position).to.equal(UDim2.new(0, 0, 0, 0))
            expect(TextLabels[1].Text).to.equal("1_1")
            expect(TextLabels[2].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[2].Position).to.equal(UDim2.new(0, 0, 0, 20))
            expect(TextLabels[2].Text).to.equal("2_2")
            expect(TextLabels[3].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[3].Position).to.equal(UDim2.new(0, 0, 0, 40))
            expect(TextLabels[3].Text).to.equal("3_3")
            expect(TextLabels[4].Size).to.equal(UDim2.new(1, 0, 0, 20))
            expect(TextLabels[4].Position).to.equal(UDim2.new(0, 0, 0, 60))
            expect(TextLabels[4].Text).to.equal("4_4")
        end)

        it("should respect OverrideAdditionalEntries.", function()
            local TestData = {}
            for i = 1, 100 do
                table.insert(TestData, tostring(i))
            end

            TestVirtualScrollList.OverrideAdditionalEntries = 1
            TestVirtualScrollList:SetData(TestData)
            expect(#TextLabels).to.equal(7)
            expect(UpdateCalls).to.equal(7)
        end)

        it("should scroll.", function()
            local TestData = {}
            for i = 1, 100 do
                table.insert(TestData, tostring(i))
            end

            TestVirtualScrollList:SetData(TestData)
            expect(#TextLabels).to.equal(9)
            expect(UpdateCalls).to.equal(9)
            for i = 1, 9 do
                expect(TextLabels[i].Text).to.equal(`{i}_{i}`)
                expect(TextLabels[i].Position).to.equal(UDim2.new(0, 0, 0, (i - 1) * 20))
                expect(TextLabels[i].Parent).to.never.equal(nil)
            end

            TestScrollingFrame.CanvasPosition = Vector2.new(0, 400)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(9 + 12)
            for i = 1, 12 do
                local Number = tonumber(string.match(TextLabels[i].Text, "%d+"))
                expect(Number >= 21 - 3).to.equal(true)
                expect(Number <= 26 + 3).to.equal(true)
                expect(TextLabels[i].Parent).to.never.equal(nil)
            end
        end)

        it("should scroll with unaltered frames.", function()
            local TestData = {}
            for i = 1, 100 do
                table.insert(TestData, tostring(i))
            end

            TestVirtualScrollList:SetData(TestData)
            expect(#TextLabels).to.equal(9)
            expect(UpdateCalls).to.equal(9)
            for i = 1, 9 do
                expect(TextLabels[i].Text).to.equal(`{i}_{i}`)
                expect(TextLabels[i].Parent).to.never.equal(nil)
            end

            TestScrollingFrame.CanvasPosition = Vector2.new(0, 60)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(9 + 3)
            for i = 1, 12 do
                expect(TextLabels[i].Text).to.equal(`{i}_{i}`)
                expect(TextLabels[i].Parent).to.never.equal(nil)
            end
        end)

        it("should make frames stale and reuse them.", function()
            local TestData = {}
            for i = 1, 100 do
                table.insert(TestData, tostring(i))
            end

            TestVirtualScrollList:SetData(TestData)
            expect(#TextLabels).to.equal(9)
            expect(UpdateCalls).to.equal(9)
            TestScrollingFrame.CanvasPosition = Vector2.new(0, 400)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(9 + 12)
            TestScrollingFrame.CanvasPosition = Vector2.new(0, 0)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(9 + 12 + 9)

            local FramesInNewRange, FramesInOldRange = 0, 0
            for i = 1, 12 do
                local Number = tonumber(string.match(TextLabels[i].Text, "%d+"))
                if Number >= 21 - 3 and Number <= 26 + 3 then
                    FramesInOldRange += 1
                elseif Number <= 9 then
                    FramesInNewRange += 1
                end
            end
            expect(FramesInNewRange).to.equal(9)
            expect(FramesInOldRange).to.equal(3)
            expect(#TestVirtualScrollList.StaleEntries).to.equal(3)

            TestScrollingFrame.CanvasPosition = Vector2.new(0, 400)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(9 + 12 + 9 + 12)
            for i = 1, 12 do
                local Number = tonumber(string.match(TextLabels[i].Text, "%d+"))
                expect(Number >= 21 - 3).to.equal(true)
                expect(Number <= 26 + 3).to.equal(true)
                expect(TextLabels[i].Parent).to.never.equal(nil)
            end
            expect(#TestVirtualScrollList.StaleEntries).to.equal(0)
        end)

        it("should reuse stale frames that become visible.", function()
            local TestData = {}
            for i = 1, 100 do
                table.insert(TestData, tostring(i))
            end

            TestVirtualScrollList:SetData(TestData)
            expect(#TextLabels).to.equal(9)
            expect(UpdateCalls).to.equal(9)
            TestScrollingFrame.CanvasPosition = Vector2.new(0, 60)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(12)
            TestScrollingFrame.CanvasPosition = Vector2.new(0, 1900)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(20)

            TestScrollingFrame.CanvasPosition = Vector2.new(0, 0)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(29)

            local FramesInNewRange = 0
            for i = 1, 12 do
                local Number = tonumber(string.match(TextLabels[i].Text, "%d+"))
                if Number <= 9 then
                    FramesInNewRange += 1
                end
            end
            expect(FramesInNewRange).to.equal(9)
        end)

        it("should remove stale frames that become visible before reused.", function()
            local TestData = {}
            for i = 1, 100 do
                table.insert(TestData, tostring(i))
            end

            TestVirtualScrollList:SetData(TestData)
            expect(#TextLabels).to.equal(9)
            expect(UpdateCalls).to.equal(9)
            TestScrollingFrame.CanvasPosition = Vector2.new(0, 60)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(12)

            TestScrollingFrame.CanvasPosition = Vector2.new(0, 0)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(12)

            for i = 1, 3 do
                table.insert(TestVirtualScrollList.StaleEntries, {
                    LastIndex = i,
                    Entry = TestVirtualScrollList.ListEntryConstructor(i, tostring(i)),
                })
            end
            expect(#TextLabels).to.equal(15)
            expect(UpdateCalls).to.equal(15)

            local FramesInNewRange = 0
            local ParentedFrames = 0
            for i = 1, 12 do
                if TextLabels[i].Parent then
                    ParentedFrames += 1
                    local Number = tonumber(string.match(TextLabels[i].Text, "%d+"))
                    if Number <= 9 then
                        FramesInNewRange += 1
                    end
                end
            end
            expect(FramesInNewRange).to.equal(9)
            expect(ParentedFrames).to.equal(12)
        end)

        it("should update the scroll width.", function()
            TestVirtualScrollList:SetData({"1", "2", "3"})
            TestVirtualScrollList:SetScrollWidth(UDim.new(1, 2))
            expect(UpdateCalls).to.equal(3)
            expect(TestScrollingFrame.CanvasSize).to.equal(UDim2.new(1, 2, 0, 60))
        end)

        it("should update the height.", function()
            local TestData = {}
            for i = 1, 100 do
                table.insert(TestData, tostring(i))
            end

            TestVirtualScrollList:SetData(TestData)
            TestVirtualScrollList:SetEntryHeight(25)
            expect(#TextLabels).to.equal(9)
            expect(UpdateCalls).to.equal(9)
            local TotalParentedFrame = 0
            for i = 1, 9 do
                expect(TextLabels[i].Text).to.equal(`{i}_{i}`)
                if TextLabels[i].Parent then
                    TotalParentedFrame += 1
                end
            end
            expect(TotalParentedFrame).to.equal(7)
        end)

        it("should scroll horizontally.", function()
            local TestData = {}
            for i = 1, 100 do
                table.insert(TestData, tostring(i))
            end

            TestVirtualScrollList.Direction = Enum.ScrollingDirection.X
            TestVirtualScrollList:SetData(TestData)
            expect(#TextLabels).to.equal(9)
            expect(UpdateCalls).to.equal(9)
            for i = 1, 9 do
                expect(TextLabels[i].Text).to.equal(`{i}_{i}`)
                expect(TextLabels[i].Position).to.equal(UDim2.new(0, (i - 1) * 20, 0, 0))
                expect(TextLabels[i].Parent).to.never.equal(nil)
            end

            TestScrollingFrame.CanvasPosition = Vector2.new(400, 0)
            TestVirtualScrollList:UpdateScrollingFrameContents()
            expect(#TextLabels).to.equal(12)
            expect(UpdateCalls).to.equal(9 + 12)
            for i = 1, 12 do
                local Number = tonumber(string.match(TextLabels[i].Text, "%d+"))
                expect(Number >= 21 - 3).to.equal(true)
                expect(Number <= 26 + 3).to.equal(true)
                expect(TextLabels[i].Parent).to.never.equal(nil)
            end
        end)
    end)
end