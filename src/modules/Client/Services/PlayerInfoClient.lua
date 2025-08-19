local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local PromiseWrapperUtil = require("PromiseWrapperUtil")
local EventConstant = require("EventConstant")

local PlayerInfoClient = {}
PlayerInfoClient.ServiceName = "PlayerInfoClient"

function PlayerInfoClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
end

function PlayerInfoClient:Start()
	assert(self._serviceBag, "Not initialized")
	self:_initiateServerEvents()
end

function PlayerInfoClient:_initiateServerEvents()
	assert(self._serviceBag, "Not initialized")

	-- player info promise
	PromiseWrapperUtil:PromiseChild(Player.PlayerGui, "PlayerInfo", function(playerInfo)
		local playerInfoFrame = playerInfo:FindFirstChild("PlayerInfoFrame")
		local playerName = playerInfoFrame:FindFirstChild("PlayerName")
		local playerLevel = playerInfoFrame:FindFirstChild("PlayerLevel")
		local playerPic = playerInfoFrame:FindFirstChild("PlayerPic")
		playerName.Text = Player.DisplayName
		playerLevel.Text = "-"
		playerPic.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		
		-- event xp
		local RemoteEvents = ReplicatedStorage.RemoteEvents
		PromiseWrapperUtil:PromiseChild(RemoteEvents, "GetPlayerStat", function(getPlayerStatEvent)
			getPlayerStatEvent.OnClientEvent:Connect(function(statValue)
				self:SetLevel(statValue.Level)
			end)
		end)
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

		-- event xp
		local RemoteEvents = ReplicatedStorage.RemoteEvents
		PromiseWrapperUtil:PromiseChild(RemoteEvents, "GetPlayerStat", function(getPlayerStatEvent)
			getPlayerStatEvent.OnClientEvent:Connect(function(statValue)
				playerHP.Text = string.format("HP: %d", statValue.HP)
				playerAttackDamage.Text = string.format("Attack Damage: %d", statValue.AttackDamage)
				playerSkillDamage.Text = string.format("Skill Damage: %d", statValue.SkillDamage)
				playerDefense.Text = string.format("Defense: %d", statValue.Defense)
				playerLevel.Text = string.format("Level: %d", statValue.Level)
				playerXP.Text = string.format("XP: %d / %d", statValue.CurrentXP, statValue.TargetXP)
			end)
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

	-- SoundTracks
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