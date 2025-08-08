local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")
local Players = game:GetService("Players")
local PlayerStatConstant = require("PlayerStatConstant")
local Maid = require("Maid")

local PlayerStatServiceServer = {}
PlayerStatServiceServer.ServiceName = "PlayerStatServiceServer"

function PlayerStatServiceServer:Init(serviceBag)
    assert(not self._serviceBag, "Already initialized")
    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._playerDataStoreService = serviceBag:GetService(require("PlayerDataStoreService"))
    self._maid = {} -- Initialize the _maid table
end

function PlayerStatServiceServer:Start()
    assert(self._serviceBag, "Not initialized")
end

function PlayerStatServiceServer:TriggerClientEvent()
    assert(self._serviceBag, "Not initialized")

	local getPlayerStatEvent = ReplicatedStorage.RemoteEvents.PlayerStatEvent
	PromiseChild(getPlayerStatEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
            self:_onPlayerConnect(getPlayerStat)
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
end

function PlayerStatServiceServer:_onPlayerConnect(getPlayerStat)
    Players.PlayerAdded:Connect(function(player)
        self._maid[player] = Maid.new()
        self._maid[player]:GivePromise(self._playerDataStoreService:PromiseDataStore(player))
            :Then(function(dataStore)
                self._maid[player]:GivePromise(dataStore:Load("PlayerStat", PlayerStatConstant.GetDefaultStats()))
                    :Then(function(statValue)
                        getPlayerStat:FireClient(player, statValue)
                    end)
                    :Catch(function(err)
                        warn("Failed to get PlayerStat for player:", player.Name, err)
                    end)
            end)
            :Catch(function(err)
                warn("Failed to get DataStore for player:", player.Name, err)
            end)
    end)
end

function PlayerStatServiceServer:_onPlayerDisconnect(self)
    Players.PlayerRemoving:Connect(function(player)
        self._maid[player]:DoCleaning()
    end)
end

return PlayerStatServiceServer