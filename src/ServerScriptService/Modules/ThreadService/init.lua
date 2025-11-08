local ThreadService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local BaseService = require(ServerScriptService.Modules.BaseService)
local UtilService = require(ServerScriptService.Modules.UtilService)
local WorkerService = require(ServerScriptService.Modules.WorkerService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)

local animations = {}

function ThreadService:Init() end

function ThreadService:StartBrainrotsMoney(player: Player)
	local function updatePlotMoney(plotNumber: number, moneyPerSecond: number)
		local base = BaseService:GetBase(player)
		local main = base:WaitForChild("Main")
		local slot = main.BrainrotPlots:FindFirstChild(plotNumber)

		local amountMoney = slot:GetAttribute("AMOUNT_MONEY") or 0
		amountMoney = amountMoney + moneyPerSecond

		slot:SetAttribute("AMOUNT_MONEY", amountMoney)

		local touchPart = slot:WaitForChild("TouchPart")
		local billBoard = touchPart:WaitForChild("BillBoard")
		billBoard.Cash.Text = UtilService:FormatToUSD(amountMoney)
		billBoard.Enabled = true
	end

	task.spawn(function()
		while player.Parent do
			-- Obtem todos os brainrots do jogador
			local brainrotsFolder = workspace.Runtime[player.UserId].Brainrots

			if brainrotsFolder then
				for _, value in brainrotsFolder:GetChildren() do
					local brainrotName = value.Name
					local brainrotEnum = Brainrots[brainrotName]

					if brainrotEnum then
						local slotNumber = value:GetAttribute("SLOT_NUMBER")
						updatePlotMoney(slotNumber, brainrotEnum.MoneyPerSecond)
					end
				end
			end
			task.wait(1)
		end
	end)
end

function ThreadService:StartBreaker(player: Player)
	local base = BaseService:GetBase(player)
	local main = base:FindFirstChild("Main")
	local breakersAreaFolder = main:FindFirstChild("BreakersArea")
	local containersFolder = breakersAreaFolder:FindFirstChild("Containers")
	local worker = containersFolder:FindFirstChild("Worker")
	local breakerFolder = worker:FindFirstChild("Breaker")
	local breakerModel = breakerFolder:FindFirstChild("Breaker")
	local crateRefFolder = worker:WaitForChild("CrateRef")

	local function updateCrateBillboardGui(crate: Model)
		if not player.Parent then
			return
		end

		if crate.Parent then
			local hp = crate.HP
			local billboardGui = hp.CrateHP
			local textLabel = billboardGui.Frame.TextLabel

			local currentXp = crate:GetAttribute("CURRENT_XP")
			local maxXp = crate:GetAttribute("MAX_XP")

			textLabel.Text = currentXp .. "/" .. maxXp
		end
	end

	local function getAnimation()
		if not player.Parent then
			return
		end

		if not breakerModel.Parent then
			breakerModel = breakerFolder:WaitForChild("Breaker")
		end

		if not animations[breakerModel] then
			local humanoid = breakerModel:WaitForChild("Humanoid")
			local currentBreaker = PlayerDataHandler:Get(player, "crateBreaker").Equiped
			local animation = ReplicatedStorage.Animations.Breakers[currentBreaker].Attack
			local track = humanoid:LoadAnimation(animation)
			track.Looped = false
			animations[breakerModel] = track
		end

		return animations[breakerModel]
	end

	local function damageAllCrate()
		if not player.Parent then
			return
		end

		local workerPower = player:GetAttribute("Power")

		local crates = workspace.Runtime[player.UserId].Crates

		for _, crate in crates:GetChildren() do
			local currentXp = crate:GetAttribute("CURRENT_XP")
			local newCurrent = currentXp - workerPower
			crate:SetAttribute("CURRENT_XP", newCurrent)
			updateCrateBillboardGui(crate)

			if crate:GetAttribute("CURRENT_XP") <= 0 then
				local crateType = crate:GetAttribute("CRATE_TYPE")
				local positionNumber = crate:GetAttribute("POSITION_NUMBER")
				local crateRefPosition = crateRefFolder:FindFirstChild(positionNumber)

				if crateRefPosition then
					crateRefPosition:SetAttribute("BUSY", false)
					crate:Destroy()
					WorkerService:CreateBrainrot(player, crateType, crateRefPosition)
				end

				continue
			end
		end
	end

	local function hasCrate()
		if not player.Parent then
			return
		end

		local crates = workspace.Runtime[player.UserId].Crates

		for _, crate in crates:GetChildren() do
			return true
		end

		return false
	end

	local function waitNextCycle()
		if not player.Parent then
			return
		end

		local workerSpeed = player:GetAttribute("Speed")
		local baseWait = 0.5
		local reductionPerLevel = 0.05
		local waitTime = math.max(0.1, baseWait - (workerSpeed - 1) * reductionPerLevel)
		task.wait(waitTime)
	end

	task.spawn(function()
		while player.Parent do
			pcall(function()
				-- Verifica se tem alguma caixa para quebrar
				local hasCrate = hasCrate()

				if hasCrate then
					-- Roda a animação
					local animation = getAnimation()

					if not animation then
						return
					end

					animation:Play()

					-- Espera a animação acabar
					animation.Stopped:Wait()

					-- Dar o dano em todas as caixas
					damageAllCrate()
				end

				-- Aguarda o temo para o proximo ciclo
			end)

			waitNextCycle()
		end
	end)
end
return ThreadService
