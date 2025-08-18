local require = require(script.Parent.loader).load(script)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SoundService = game:GetService("SoundService")

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
	PromiseChild(Player.PlayerGui, "PlayerInfo")
		:Then(function(playerInfo)
			local playerInfoFrame = playerInfo:FindFirstChild("PlayerInfoFrame")
			local playerName = playerInfoFrame:FindFirstChild("PlayerName")
			local playerLevel = playerInfoFrame:FindFirstChild("PlayerLevel")
			local playerPic = playerInfoFrame:FindFirstChild("PlayerPic")
			playerName.Text = Player.Name
			playerLevel.Text = "..."
			playerPic.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
	PromiseChild(getPlayerInfoEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
			getPlayerStat.OnClientEvent:Connect(function(infoValue)
				self:SetLevel(infoValue.BasicStats.Level)
			end)
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)

	-- SoundTracks
	-- PromiseChild(SoundService, "Ambients")
	-- 	:Then(function(ambients)
	-- 		local mainAmbience = ambients:FindFirstChild("Main")
	-- 		mainAmbience:Play()
	-- 		mainAmbience.Looped = true
	-- 	end)
	-- 	:Catch(function(err)
	-- 		warn("Failed to get Ambients:", err)
	-- 	end)
end

function PlayerInfoClient:SetLevel(newLevel)
	PromiseChild(Player.PlayerGui, "PlayerInfo")
		:Then(function(playerInfo)
			local playerInfoFrame = playerInfo:FindFirstChild("PlayerInfoFrame")
			local playerLevel = playerInfoFrame:FindFirstChild("PlayerLevel")
			playerLevel.Text = newLevel
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
end

return PlayerInfoClient