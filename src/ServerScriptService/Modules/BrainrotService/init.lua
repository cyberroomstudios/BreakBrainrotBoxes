local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseService = require(ServerScriptService.Modules.BaseService)

local BrainrotService = {}

function BrainrotService:Init() end

function BrainrotService:SetInMap(player: Player, slotNumber: number, brainrotType: string)
	local brainrotModel = ReplicatedStorage.Brainrots:FindFirstChild(brainrotType)

	if brainrotModel then
		local base = BaseService:GetBase(player)
		local main = base:WaitForChild("Main")
		local slot = main.BrainrotPlots:FindFirstChild(slotNumber)

		if slot then
			local newBrainrot = brainrotModel:Clone()
			newBrainrot.Parent = workspace.Runtime[player.UserId].Brainrots
			newBrainrot:SetPrimaryPartCFrame(slot.Attachment.WorldCFrame)
		end
	end
end

return BrainrotService
