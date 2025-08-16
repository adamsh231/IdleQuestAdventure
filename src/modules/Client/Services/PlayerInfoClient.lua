local require = require(script.Parent.loader).load(script)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Signal = require("Signal")
local SoundService = game:GetService("SoundService")

local PlayerInfoClient = {}
PlayerInfoClient.ServiceName = "PlayerInfoClient"

function PlayerInfoClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- level
	self._level = "???"
	self._levelChanged = Signal.new()
end

function PlayerInfoClient:Start()
	assert(self._serviceBag, "Not initialized")

	-- player info promise
	PromiseChild(Player.PlayerGui, "PlayerInfo")
		:Then(function(playerInfo)
			local playerInfoFrame = playerInfo:FindFirstChild("PlayerInfoFrame")
			local playerName = playerInfoFrame:FindFirstChild("PlayerName")
			local playerLevel = playerInfoFrame:FindFirstChild("PlayerLevel")
			local playerPic = playerInfoFrame:FindFirstChild("PlayerPic")
			playerName.Text = Player.Name
			playerLevel.Text = self._level
			playerPic.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)

	-- sound service
	PromiseChild(SoundService, "Ambients")
		:Then(function(ambients)
			local mainAmbience = ambients:FindFirstChild("Main")
			mainAmbience:Play()
			mainAmbience.Looped = true
		end)
		:Catch(function(err)
			warn("Failed to get Ambients:", err)
		end)
end

function PlayerInfoClient:SetLevel(newLevel)
	assert(self._serviceBag, "Not initialized")
	
	-- Only fire signal if level actually changed
	if self._level ~= newLevel then
		self._level = newLevel
		self._levelChanged:Fire(newLevel)
	end
end

function PlayerInfoClient:TriggerListener()
	assert(self._serviceBag, "Not initialized")

	-- player level
	self._levelChanged:Connect(function(newLevel)
		print("Player level changed to:", newLevel)
		-- You can add more actions here when level changes
	end)

	-- player stats
	local getPlayerInfoEvent = ReplicatedStorage.RemoteEvents.PlayerInfoEvent
	PromiseChild(getPlayerInfoEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
			getPlayerStat.OnClientEvent:Connect(function(infoValue)
				print("Received PlayerStat:", infoValue)
			end)
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
end

return PlayerInfoClient