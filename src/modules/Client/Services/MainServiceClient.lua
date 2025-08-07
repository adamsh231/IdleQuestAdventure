local require = require(script.Parent.loader).load(script)
local PlayerStatConstant = require("PlayerStatConstant")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")

local MainServiceClient = {}
MainServiceClient.ServiceName = "MainServiceClient"

function MainServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._playerDefaultStats = PlayerStatConstant.GetDefaultStats()
end

function MainServiceClient:Start()
	assert(self._serviceBag, "Not initialized")
	print("MainServiceClient started:", self._playerDefaultStats)

	-- Initialize the GetPlayerStat event
	local getPlayerStatEvent = ReplicatedStorage.RemoteEvents.PlayerStatEvent
	PromiseChild(getPlayerStatEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
			print("GetPlayerStat event initialized successfully.")
			getPlayerStat:FireServer("Hello from MainServiceClient!")
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
end

return MainServiceClient