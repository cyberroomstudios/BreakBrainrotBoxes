local SoundManager = {}

-- Init Bridg Net
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Utility = ReplicatedStorage.Utility
local BridgeNet2 = require(Utility.BridgeNet2)
local bridge = BridgeNet2.ReferenceBridge("SoundManager")
local actionIdentifier = BridgeNet2.ReferenceIdentifier("action")
local statusIdentifier = BridgeNet2.ReferenceIdentifier("status")
local messageIdentifier = BridgeNet2.ReferenceIdentifier("message")
-- End Bridg Net

local sounds = {
	BGM = "",
	GET_MONEY_PLOT = "",
	UI_CLICK = "",
	HIT = "",
	UI_OPEN_SCREEN = "",
	MONEY_COMING_IN = "",
	MONEY_COMING_OUT = "",
	PLACE_CRATE = "",
	BananitaDolphinita = "",
	BanditoBobritto = "",
	BombardiroCrocodilo = "",
	SpioniroGolubiro = "",
	BombombiniGusini = "",
	SvininaBombardino = "",
	TaTaTaSahur = "",
	BonecaAmbalabu = "",
	BrrBrrPatapim = "",
	BubarolliLuliloli = "",
	CactoHipopotamo = "",
	TimCheese = "",
	TralaleroTralala = "",
	CappuccinoAssassino = "",
	CavalloVirtuoso = "",
	ChefCrabracadabra = "",
	TrippiTroppi = "",
	TrulimeroTrulicina = "",
	TungTungSahur = "",
	ChimpanziniBananini = "",
	CocofantoElefanto = "",
	Fluriflura = "",
	FrigoCamelo = "",
	GangsterFootera = "",
	GlorboFruttodrillo = "",
	LaVaccaSaturnoSaturnita = "",
	["LirilìLarilà"] = "",
	OdinDinDinDun = "",
}

local soundLooped = {}

function SoundManager:Init()
	SoundManager:InitRef()
	SoundManager:InitBridgeListener()
end



function SoundManager:InitRef()
	sounds["BGM"] = SoundService.Game.BGM
	sounds["GET_MONEY_PLOT"] = SoundService.Game.GetMoneyPlot
	sounds["HIT"] = SoundService.Game.Hit
	sounds["UI_CLICK"] = SoundService.GUI.Click
	sounds["UI_OPEN_SCREEN"] = SoundService.GUI.OpenScreen
	sounds["MONEY_COMING_IN"] = SoundService.GUI.MoneyComingIn
	sounds["MONEY_COMING_OUT"] = SoundService.GUI.MoneyComingOut
	sounds["PLACE_CRATE"] = SoundService.Game.PlaceCrate
	sounds["BananitaDolphinita"] = SoundService.Brainrots:FindFirstChild("BananitaDolphinita")
	sounds["BanditoBobritto"] = SoundService.Brainrots:FindFirstChild("BanditoBobritto")
	sounds["BombardiroCrocodilo"] = SoundService.Brainrots:FindFirstChild("BombardiroCrocodilo")
	sounds["SpioniroGolubiro"] = SoundService.Brainrots:FindFirstChild("SpioniroGolubiro")
	sounds["BombombiniGusini"] = SoundService.Brainrots:FindFirstChild("BombombiniGusini")
	sounds["SvininaBombardino"] = SoundService.Brainrots:FindFirstChild("SvininaBombardino")
	sounds["TaTaTaSahur"] = SoundService.Brainrots:FindFirstChild("TaTaTaSahur")
	sounds["BonecaAmbalabu"] = SoundService.Brainrots:FindFirstChild("BonecaAmbalabu")
	sounds["BrrBrrPatapim"] = SoundService.Brainrots:FindFirstChild("BrrBrrPatapim")
	sounds["BubarolliLuliloli"] = SoundService.Brainrots:FindFirstChild("BubarolliLuliloli")
	sounds["CactoHipopotamo"] = SoundService.Brainrots:FindFirstChild("CactoHipopotamo")
	sounds["TimCheese"] = SoundService.Brainrots:FindFirstChild("TimCheese")
	sounds["TralaleroTralala"] = SoundService.Brainrots:FindFirstChild("TralaleroTralala")
	sounds["CappuccinoAssassino"] = SoundService.Brainrots:FindFirstChild("CappuccinoAssassino")
	sounds["CavalloVirtuoso"] = SoundService.Brainrots:FindFirstChild("CavalloVirtuoso")
	sounds["ChefCrabracadabra"] = SoundService.Brainrots:FindFirstChild("ChefCrabracadabra")
	sounds["TrippiTroppi"] = SoundService.Brainrots:FindFirstChild("TrippiTroppi")
	sounds["TrulimeroTrulicina"] = SoundService.Brainrots:FindFirstChild("TrulimeroTrulicina")
	sounds["TungTungSahur"] = SoundService.Brainrots:FindFirstChild("TungTungSahur")
	sounds["ChimpanziniBananini"] = SoundService.Brainrots:FindFirstChild("ChimpanziniBananini")
	sounds["CocofantoElefanto"] = SoundService.Brainrots:FindFirstChild("CocofantoElefanto")
	sounds["Fluriflura"] = SoundService.Brainrots:FindFirstChild("Fluriflura")
	sounds["FrigoCamelo"] = SoundService.Brainrots:FindFirstChild("FrigoCamelo")
	sounds["GangsterFootera"] = SoundService.Brainrots:FindFirstChild("GangsterFootera")
	sounds["GlorboFruttodrillo"] = SoundService.Brainrots:FindFirstChild("GlorboFruttodrillo")
	sounds["LaVaccaSaturnoSaturnita"] = SoundService.Brainrots:FindFirstChild("LaVaccaSaturnoSaturnita")
	sounds["LirilìLarilà"] = SoundService.Brainrots:FindFirstChild("LirilìLarilà")
	sounds["OdinDinDinDun"] = SoundService.Brainrots:FindFirstChild("OdinDinDinDun")
end

function SoundManager:StartOrPauseBGM()
	local settingsMusicTheme = Players.LocalPlayer:GetAttribute("SETTINGS_BACKGROUND_MUSIC")
	if settingsMusicTheme then
		sounds["BGM"]:Play()
	else
		sounds["BGM"]:Stop()
	end
end
function SoundManager:Play(sondName: string)
	local settingsSoundEffect = Players.LocalPlayer:GetAttribute("SETTINGS_SOUND_EFFECT")

	if not settingsSoundEffect then
		return
	end

	if sounds[sondName] then
		local sound = sounds[sondName]:Clone()
		sound.Parent = script.Parent
		sound:Play()

		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
end

function SoundManager:PlayWithLooped(sondName: string)
	if not soundLooped[sondName] then
		local sound = sounds[sondName]:Clone()
		sound.Parent = script.Parent
		sound:Play()
		soundLooped[sondName] = sound

		return
	end

	soundLooped[sondName]:Play()
end

function SoundManager:StopWithLooped(sondName: string)
	if soundLooped[sondName] then
		soundLooped[sondName]:Stop()
	end
end

function SoundManager:PlayProgrammerSound(soundName: string, model: Model)
	local programmersSounds = {
		KEYBOARD_1 = "",
		KEYBOARD_2 = "",
		KEYBOARD_3 = "",
		SAHUR = "",
		CONSOLE_CONTROLLER = "",
		GAME_SPACE = "",
	}
	programmersSounds["KEYBOARD_1"] = SoundService.Programmers.KeyBoard1
	programmersSounds["KEYBOARD_2"] = SoundService.Programmers.KeyBoard2
	programmersSounds["KEYBOARD_3"] = SoundService.Programmers.KeyBoard3
	programmersSounds["SAHUR"] = SoundService.Programmers.Sahur
	programmersSounds["GAME_SPACE"] = SoundService.Programmers.GameSpace
	programmersSounds["CONSOLE_CONTROLLER"] = SoundService.Programmers.ConsoleController

	local sound = programmersSounds[soundName]
	if sound then
		local newSound = sound:Clone()
		newSound.Parent = model.PrimaryPart
		newSound:Play()
	end
end

function SoundManager:InitBridgeListener()
	bridge:Connect(function(response)
		if response[actionIdentifier] == "Play" then
			SoundManager:Play(response.data)
		end
	end)
end

return SoundManager
