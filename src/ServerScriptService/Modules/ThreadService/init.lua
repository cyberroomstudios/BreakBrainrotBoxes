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
local GameSoundService = require(ServerScriptService.Modules.GameSoundService)

local animations = {}

function ThreadService:Init() end

function ThreadService:StartBrainrotsMoney(player: Player)
	local mutationMultipliers = {
		["NORMAL"] = 1,
		["GOLDEN"] = 20,
		["DIAMOND"] = 50,
	}

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
					local mutationType = value:GetAttribute("MUTATION_TYPE") or "NORMAL"

					if brainrotEnum then
						local slotNumber = value:GetAttribute("SLOT_NUMBER")
						local moneyPerSecond = getMoneyMoneyPerSecond(player, brainrotEnum.MoneyPerSecond)

						updatePlotMoney(slotNumber, brainrotEnum.MoneyPerSecond * mutationMultipliers[mutationType])
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

	local function UpdateContentColor(content, crate)
		local currentXp = crate:GetAttribute("CURRENT_XP")
		local maxXp = crate:GetAttribute("MAX_XP")

		if not currentXp or not maxXp or maxXp == 0 then
			return
		end

		local percent = currentXp / maxXp -- 0 a 1

		-- Ajusta a cor
		if percent < 0.40 then
			content.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- vermelho
		elseif percent < 0.80 then
			content.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- amarelo
		else
			-- Mantém cor atual (não altera)
		end

		-- Ajusta a largura proporcional
		-- content.Size.X.Scale = percent
		content.Size = UDim2.fromScale(percent, content.Size.Y.Scale)
	end

	local function updateCrateBillboardGui(crate: Model)
		if not player.Parent then
			return
		end

		if crate.Parent then
			local hp = crate.HP
			local billboardGui = hp.CrateHP
			local content = billboardGui.Frame.Content
			local textLabel = billboardGui.Frame.TextLabel

			local currentXp = crate:GetAttribute("CURRENT_XP")
			local maxXp = crate:GetAttribute("MAX_XP")

			textLabel.Text = currentXp .. "/" .. maxXp
			UpdateContentColor(content, crate)
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
						GameSoundService:Play(player, "HIT")
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

			local time = speedFromData + speedFromBreaker

			-- garante no mínimo 1 segundo
			if time < 1 then
				time = 1
			end

			local nextHit = breakersAreaFolder:WaitForChild("NextHit")
			local waiting = nextHit:WaitForChild("Waiting")
			local timeBillboard = nextHit:WaitForChild("Time")
			waiting.Enabled = false
			timeBillboard.Enabled = true

			local textLabel = timeBillboard.TextLabel

			-- cronômetro mais preciso
			local startTime = os.clock()
			local endTime = startTime + time

			while true do
				local now = os.clock()
				local remaining = endTime - now

				if remaining <= 0 then
					break
				end

				-- formatar segundos + milissegundos
				textLabel.Text = string.format("%.2fs", remaining)

				-- espera bem pequena para atualizar "rápido"
				task.wait(0.02) -- 50 updates por segundo
			end

			textLabel.Text = "0.000s"

			return true
		end)
	end

	task.spawn(function()
		while player.Parent do
			pcall(function()
				-- Verifica se tem alguma caixa para quebrar
				local hasCrate = hasCrate()

				if hasCrate then
					UpdateNextHitbillboard()

					-- Roda a animação
					local animation = getAnimation()

					if not animation then
						return
					end

					animation:Play()

					task.wait(1)
				else
					setWaitingForCrate()
				end
			end)
			task.wait()
		end
	end)
end
return ThreadService
