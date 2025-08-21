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
	self:_initiateServerEvents()

	task.delay(4, function()
		print("UPDATE!!!")
		self._levelState.Value = 100
	end)
end

function PlayerInfoClient:_initiateServerEvents()
	assert(self._serviceBag, "Not initialized")

	local RemoteEvents = ReplicatedStorage.RemoteEvents
	PromiseUtils.combine({
		getPlayerStatEvent = PromiseChild(RemoteEvents, "GetPlayerStat"),
		playerInfo = PromiseChild(Player.PlayerGui, "PlayerInfo"),
		playerStat = PromiseChild(Player.PlayerGui, "PlayerStat")
	}):Then(function(combined)
		print(combined)
	end)

	PromiseWrapperUtil:PromiseChild(RemoteEvents, "GetPlayerStat", function(getPlayerStatEvent)

		-- todo: this is not proper
		-- add cache in each var
		-- study promises
		getPlayerStatEvent.OnClientEvent:Connect(function(statValue)

			-- player info promise
			PromiseWrapperUtil:PromiseChild(Player.PlayerGui, "PlayerInfo", function(playerInfo)
				local playerInfoFrame = playerInfo:FindFirstChild("PlayerInfoFrame")
				local playerName = playerInfoFrame:FindFirstChild("PlayerName")
				local playerPic = playerInfoFrame:FindFirstChild("PlayerPic")
				local playerLevel = playerInfoFrame:FindFirstChild("PlayerLevel")

				Blend.mount(playerLevel, {
					Text = self._levelState
				})

				playerName.Text = Player.DisplayName
				playerPic.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)

			-- player stat promise
			PromiseWrapperUtil:PromiseChild(Player.PlayerGui, "PlayerStat", function(playerStat)
				local playerStatFrame = playerStat:FindFirstChild("PlayerStatFrame")
				local playerHP = playerStatFrame:FindFirstChild("PlayerHP")
				local playerAttackDamage = playerStatFrame:FindFirstChild("PlayerAttackDamage")
				local playerSkillDamage = playerStatFrame:FindFirstChild("PlayerSkillDamage")
				local playerDefense = playerStatFrame:FindFirstChild("PlayerDefense")
				local playerLevel = playerStatFrame:FindFirstChild("PlayerLevel")
				local playerXP = playerStatFrame:FindFirstChild("PlayerXP")

				Blend.mount(playerLevel, {
					Text = self._levelState
				})

				-- event xp
				playerHP.Text = string.format("HP: %d", statValue.HP)
				playerAttackDamage.Text = string.format("Attack Damage: %d", statValue.AttackDamage)
				playerSkillDamage.Text = string.format("Skill Damage: %d", statValue.SkillDamage)
				playerDefense.Text = string.format("Defense: %d", statValue.Defense)
				playerLevel.Text = string.format("Level: %d", statValue.Level)
				playerXP.Text = string.format("XP: %d / %d", statValue.CurrentXP, statValue.TargetXP)
			end)

			self:SetLevel(statValue.Level)
		end)
	end)

	-- player card promise
	PromiseWrapperUtil:PromiseChild(Player.PlayerGui, "PlayerCard", function(playerCard)
		local playerCardFrame = playerCard:FindFirstChild("PlayerCardFrame")
		local RemoteEvents = ReplicatedStorage.RemoteEvents
		PromiseWrapperUtil:PromiseChild(RemoteEvents, "GetPlayerStat", function(getPlayerStatEvent)
				local addAttack = playerCardFrame:FindFirstChild("AddAttack")
			addAttack.MouseButton1Click:Connect(function()
				getPlayerStatEvent:FireServer(EventConstant.PlayerAddAttackEvent)
			end)

			local addDefense = playerCardFrame:FindFirstChild("AddDefense")
			addDefense.MouseButton1Click:Connect(function()
				getPlayerStatEvent:FireServer(EventConstant.PlayerAddDefenseEvent)
			end)

			local addMaxHP = playerCardFrame:FindFirstChild("AddMaxHP")
			addMaxHP.MouseButton1Click:Connect(function()
				getPlayerStatEvent:FireServer(EventConstant.PlayerAddMaxHPEvent)
			end)
			
			local addXP = playerCard:FindFirstChild("AddXP")
			addXP.MouseButton1Click:Connect(function()
				getPlayerStatEvent:FireServer(EventConstant.PlayerAddXPEvent)
			end)
		end)
	end)

	-- play lobby sound track
	self:PlayLobbySoundTrack()
end

function PlayerInfoClient:PlayLobbySoundTrack()
	PromiseWrapperUtil:PromiseChild(SoundService, "SoundTracks", function(soundTracks)
		local soundtrackLobby = soundTracks:FindFirstChild("Lobby")
		soundtrackLobby:Play()
		soundtrackLobby.Looped = true
		soundtrackLobby.Volume = 0.1
	end)
end

function PlayerInfoClient:SetLevel(newLevel)
	PromiseWrapperUtil:PromiseChild(Player.PlayerGui, "PlayerInfo", function(playerInfo)
		local playerInfoFrame = playerInfo:FindFirstChild("PlayerInfoFrame")
		local playerLevel = playerInfoFrame:FindFirstChild("PlayerLevel")
		playerLevel.Text = newLevel
	end)
end

return PlayerInfoClient