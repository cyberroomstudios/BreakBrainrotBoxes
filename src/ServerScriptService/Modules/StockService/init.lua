local StockService = {}

-- Init Bridg Net
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("StockService")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local TIME_TO_RESTOCK = 60 * 5

function StockService:Init()
	StockService:Start()
end

function StockService:Start()
	task.spawn(function()
		local currentTime = TIME_TO_RESTOCK
		StockService:RestockAll()
		while true do
			if currentTime == 0 then
				StockService:RestockAll()
				currentTime = TIME_TO_RESTOCK
			end

			currentTime = currentTime - 1
			workspace:SetAttribute("CURRENT_TIME_STOCK", currentTime)
			task.wait(1)
		end
	end)
end

function StockService:RestockAll()
	print("Restocando")
end

return StockService
