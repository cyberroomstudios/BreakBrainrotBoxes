local ThreadService = {}

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Brainrots = require(ReplicatedStorage.Enums.Brainrots)
local BaseService = require(ServerScriptService.Modules.BaseService)
local UtilService = require(ServerScriptService.Modules.UtilService)
local WorkerService = require(ServerScriptService.Modules.WorkerService)
local PlayerDataHandler = require(ServerScriptService.Modules.Player.PlayerDataHandler)
local FunnelService = require(ServerScriptService.Modules.FunnelService)
local Upgrades = require(ReplicatedStorage.Enums.Upgrades)
local Breakers = require(ReplicatedStorage.Enums.Breakers)

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

	local function getMoneyMoneyPerSecond(player: Player, moneyPerSecondFromBrainrot: number)
		-- Verifica se o jogador tem o cash multiplier de brainrot
		local hasBrainrotCashMultiplier = player:GetAttribute("HAS_BRAINROT_CASH_MULTIPLIER") or false

		-- Obtem o multiplicador da base
		local baseCashMultiplier = player:GetAttribute("CASH_MULTIPLIER") or 1

		local moneyPerSecond = hasBrainrotCashMultiplier and moneyPerSecondFromBrainrot * 2
			or moneyPerSecondFromBrainrot

		moneyPerSecond = moneyPerSecond * baseCashMultiplier

		return moneyPerSecond
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
						local moneyPerSecond = getMoneyMoneyPerSecond(player, brainrotEnum.MoneyPerSecond)

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
	local breakersAreaFolder = main:WaitForChild("BreakersArea")
	local containersFolder = breakersAreaFolder:WaitForChild("Containers")
	local containersModel = containersFolder:WaitForChild("Container")
	local breakerFolder = containersModel:WaitForChild("Breaker")
	local breakerModel = breakerFolder:FindFirstChild("Breaker")
	local crateRefFolder = containersModel:WaitForChild("CrateRef")

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
					FunnelService:AddEvent(player, "OPEN_CRATE")
				end

				continue
			end
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
			local currentBreaker = PlayerDataHandler:Get(player, "crateBreaker").Equiped
			local animationsFolder = ReplicatedStorage.Animations.Breakers[currentBreaker]

			-- Definir a animação com base na existência do Humanoid
			local humanoid = breakerModel:FindFirstChild("Humanoid")
			local animationController
			local animator
			local animation

			if humanoid then
				animator = humanoid
				animation = animationsFolder.Attack
			else
				animationController = breakerModel:WaitForChild("AnimationController")
				animator = animationController:WaitForChild("Animator")
				animation = animationsFolder.Attack
			end

			-- Carregar a animação
			local track = animator:LoadAnimation(animation)
			track.Looped = false
			track.Priority = Enum.AnimationPriority.Action

			-- Conectar o HIT uma vez
			track:GetMarkerReachedSignal("HIT"):Connect(function()
				local cratesFolder = workspace.Runtime[player.UserId]:FindFirstChild("Crates")
				if not cratesFolder then
					return
				end

				for _, crate in ipairs(cratesFolder:GetChildren()) do
					if crate.PrimaryPart and crate.PrimaryPart:FindFirstChild("CrateHit") then
						crate.PrimaryPart.CrateHit:Emit(20)
					end
				end

				damageAllCrate()
			end)

			-- Guardar referência
			animations[breakerModel] = track
		end

		return animations[breakerModel]
	end

	local function setWaitingForCrate()
		pcall(function()
			local nextHit = breakersAreaFolder:WaitForChild("NextHit")
			local waiting = nextHit:WaitForChild("Waiting")
			local timeBillboard = nextHit:WaitForChild("Time")
			waiting.Enabled = true
			timeBillboard.Enabled = false
		end)
	end

	local function UpdateNextHitbillboard()
		pcall(function()
			local speedFromData = Upgrades.Speed[PlayerDataHandler:Get(player, "crateBreaker").Speed].Value
			local speedFromBreaker = Breakers[PlayerDataHandler:Get(player, "crateBreaker").Equiped].Boosts.Speed
			print("Speed From Data:" .. speedFromData)
			print("Speed From Breaker:" .. speedFromData)

			local time = speedFromData + speedFromBreaker
			print("Time:" .. time)
			if time < 1 then
				time = 1
			end

			local nextHit = breakersAreaFolder:WaitForChild("NextHit")

			local waiting = nextHit:WaitForChild("Waiting")
			local timeBillboard = nextHit:WaitForChild("Time")
			waiting.Enabled = false
			timeBillboard.Enabled = true

			local textLabel = timeBillboard.TextLabel

			local current = time
			local lastShown = -1 -- guarda o último valor inteiro mostrado

			while current > 0 do
				-- mostra apenas quando o valor inteiro muda
				local intValue = math.floor(current)

				if intValue ~= lastShown then
					textLabel.Text = intValue
					lastShown = intValue
				end

				current -= task.wait()
			end

			textLabel.Text = 0
		end)
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
					task.wait(1)
					UpdateNextHitbillboard()
				else
					setWaitingForCrate()
				end
			end)
			task.wait()
		end
	end)
end
return ThreadService
