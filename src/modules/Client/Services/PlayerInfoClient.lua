local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local PromiseWrapperUtil = require("PromiseWrapperUtil")
local PromiseChild = require("promiseChild")
local EventConstant = require("EventConstant")
local Blend = require("Blend")
local PromiseUtils = require("PromiseUtils")

local PlayerInfoClient = {}
PlayerInfoClient.ServiceName = "PlayerInfoClient"

function PlayerInfoClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- initiate state management
	self._levelState = Blend.State("0")
end

function PlayerInfoClient:Start()
	assert(self._serviceBag, "Not initialized")

	local RemoteEvents = ReplicatedStorage.RemoteEvents
	PromiseUtils.combine({
		getPlayerStatEvent = PromiseChild(RemoteEvents, "GetPlayerStat"),
		playerInfo = PromiseChild(Player.PlayerGui, "PlayerInfo"),
		playerStat = PromiseChild(Player.PlayerGui, "PlayerStat"),
		playerCard = PromiseChild(Player.PlayerGui, "PlayerCard"),
	}):Then(function(instances)
		self._getPlayerStatEvent = instances.getPlayerStatEvent
		self._playerInfo = instances.playerInfo
		self._playerStat = instances.playerStat
		self._playerCard = instances.playerCard
		self:_initiatePlayerInfo()
		self:_initiatePlayerStat()
		self:_initiatePlayerCard()
		self:PlayLobbySoundTrack()
	end)
end

function PlayerInfoClient:_initiatePlayerInfo()
	local playerInfoFrame = self._playerInfo:FindFirstChild("PlayerInfoFrame")
	local playerName = playerInfoFrame:FindFirstChild("PlayerName")
	local playerPic = playerInfoFrame:FindFirstChild("PlayerPic")
	local playerLevel = playerInfoFrame:FindFirstChild("PlayerLevel")
	playerName.Text = Player.DisplayName
	playerPic.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	Blend.mount(playerLevel, {
		Text = self._levelState
	})
end

function PlayerInfoClient:_initiatePlayerCard()
	local playerStatFrame = self._playerStat:FindFirstChild("PlayerStatFrame")
	local playerHP = playerStatFrame:FindFirstChild("PlayerHP")
	local playerAttackDamage = playerStatFrame:FindFirstChild("PlayerAttackDamage")
	local playerSkillDamage = playerStatFrame:FindFirstChild("PlayerSkillDamage")
	local playerDefense = playerStatFrame:FindFirstChild("PlayerDefense")
	local playerStatLevel = playerStatFrame:FindFirstChild("PlayerLevel")
	local playerXP = playerStatFrame:FindFirstChild("PlayerXP")
	local levelStatCompute = Blend.Computed(self._levelState, function(level)
		return string.format("Level: %d", level)
	end)
	levelStatCompute:Subscribe(function(levelText)
		playerStatLevel.Text = levelText
	end)

	self._getPlayerStatEvent.OnClientEvent:Connect(function(statValue)
		playerHP.Text = string.format("HP: %d", statValue.HP)
		playerAttackDamage.Text = string.format("Attack Damage: %d", statValue.AttackDamage)
		playerSkillDamage.Text = string.format("Skill Damage: %d", statValue.SkillDamage)
		playerDefense.Text = string.format("Defense: %d", statValue.Defense)
		playerXP.Text = string.format("XP: %d / %d", statValue.CurrentXP, statValue.TargetXP)

		self._levelState.Value = statValue.Level
	end)
end

function PlayerInfoClient:_initiatePlayerStat()
	local playerCardFrame = self._playerCard:FindFirstChild("PlayerCardFrame")
	local addXP = self._playerCard:FindFirstChild("AddXP")
	local addAttack = playerCardFrame:FindFirstChild("AddAttack")
	local addDefense = playerCardFrame:FindFirstChild("AddDefense")
	local addMaxHP = playerCardFrame:FindFirstChild("AddMaxHP")
	addAttack.MouseButton1Click:Connect(function()
		self._getPlayerStatEvent:FireServer(EventConstant.PlayerAddAttackEvent)
	end)
	addDefense.MouseButton1Click:Connect(function()
		self._getPlayerStatEvent:FireServer(EventConstant.PlayerAddDefenseEvent)
	end)
	addMaxHP.MouseButton1Click:Connect(function()
		self._getPlayerStatEvent:FireServer(EventConstant.PlayerAddMaxHPEvent)
	end)
	addXP.MouseButton1Click:Connect(function()
		self._getPlayerStatEvent:FireServer(EventConstant.PlayerAddXPEvent)
	end)
end

function PlayerInfoClient:PlayLobbySoundTrack()
	PromiseWrapperUtil:PromiseChild(SoundService, "SoundTracks", function(soundTracks)
		local soundtrackLobby = soundTracks:FindFirstChild("Lobby")
		soundtrackLobby:Play()
		soundtrackLobby.Looped = true
		soundtrackLobby.Volume = 0.1
	end)
end

return PlayerInfoClient