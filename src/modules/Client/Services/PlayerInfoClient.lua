local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local PromiseWrapperUtil = require("PromiseWrapperUtil")

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
	local getPlayerInfoEvent = ReplicatedStorage.RemoteEvents.PlayerInfoEvent
	PromiseWrapperUtil:PromiseChild(Player.PlayerGui, "PlayerInfo", function(playerInfo)
		local playerInfoFrame = playerInfo:FindFirstChild("PlayerInfoFrame")
		local playerName = playerInfoFrame:FindFirstChild("PlayerName")
		local playerLevel = playerInfoFrame:FindFirstChild("PlayerLevel")
		local playerPic = playerInfoFrame:FindFirstChild("PlayerPic")
		playerName.Text = Player.Name
		playerLevel.Text = "..."
		playerPic.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	PromiseWrapperUtil:PromiseChild(getPlayerInfoEvent, "GetPlayerStat", function(getPlayerStat)
		getPlayerStat.OnClientEvent:Connect(function(statValue)
			self:SetLevel(statValue.Level)
		end)
	end)

	-- SoundTracks
	PromiseWrapperUtil:PromiseChild(SoundService, "SoundTracks", function(soundTracks)
		local mainAmbience = soundTracks:FindFirstChild("Main")
		mainAmbience:Play()
		mainAmbience.Looped = true
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