local require = require(script.Parent.loader).load(script)
local PlayerStatConstant = require("PlayerStatConstant")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")

local PlayerStatServiceClient = {}
PlayerStatServiceClient.ServiceName = "PlayerStatServiceClient"

function PlayerStatServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._playerDefaultStats = PlayerStatConstant.GetDefaultStats()
end

function PlayerStatServiceClient:TriggerListener()
	assert(self._serviceBag, "Not initialized")

	local getPlayerStatEvent = ReplicatedStorage.RemoteEvents.PlayerStatEvent
	PromiseChild(getPlayerStatEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
			getPlayerStat.OnClientEvent:Connect(function(message)
				print("Received message:", message)
			end)
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
end

return PlayerStatServiceClient