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
			local addXPButton = playerInfo:FindFirstChild("AddXP")
			addXPButton.MouseButton1Click:Connect(function()
				getPlayerStatEvent:FireServer(EventConstant.PlayerAddXPEvent)
			end)

			getPlayerStatEvent.OnClientEvent:Connect(function(statValue)
				self:SetLevel(statValue.Level)
			end)
		end)
	end)

	-- SoundTracks
	PromiseWrapperUtil:PromiseChild(SoundService, "SoundTracks", function(soundTracks)
		local soundtrackLobby = soundTracks:FindFirstChild("Lobby")
		soundtrackLobby:Play()
		soundtrackLobby.Looped = true
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