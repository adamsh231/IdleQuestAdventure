local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Maid = require("Maid")
local PromiseWrapperUtil = require("PromiseWrapperUtil")

local PlayerStatServiceServer = {}
PlayerStatServiceServer.ServiceName = "PlayerStatServiceServer"

PlayerStatServiceServer._defaultBasicStat = {
    HP = 100,
    AttackDamage = 10,
    SkillDamage = 10,
    Defense = 10,

    Level = 1,
    XP = 0,
    MaxXP = 100,
}   

PlayerStatServiceServer._defaultAdvancedStat = {
    CriticalAttackChance = 0,
    CriticalAttackDamage = 0,
    CounterAttackChance = 0,
}

function PlayerStatServiceServer:Init(serviceBag)
    assert(not self._serviceBag, "Already initialized")
    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._playerDataStoreService = serviceBag:GetService(require("PlayerDataStoreService"))
    self._maid = {} -- Initialize the _maid table
    self._basicStatStore = "basic_stat"
    self._advancedStatStore = "advanced_stat"
end

function PlayerStatServiceServer:Start()
    assert(self._serviceBag, "Not initialized")
    self:_initiateClientEvents()
end

function PlayerStatServiceServer:_initiateClientEvents()
    assert(self._serviceBag, "Not initialized")

	local getPlayerStatEvent = ReplicatedStorage.RemoteEvents.PlayerInfoEvent
	PromiseWrapperUtil:PromiseChild(getPlayerStatEvent, "GetPlayerStat", function(getPlayerStat)
        Players.PlayerAdded:Connect(function(player)
            self:_connectPlayerStat(player, getPlayerStat)
        end)
        Players.PlayerRemoving:Connect(function(player)
            self:_disconnectPlayerStat(player)
        end)
    end)
end

function PlayerStatServiceServer:_connectPlayerStat(player, eventPlayerStat)
    self._maid[player] = Maid.new()
    self._maid[player]:GivePromise(self._playerDataStoreService:PromiseDataStore(player))
        :Then(function(dataStore)
            self._maid[player]:GivePromise(dataStore:Load(self._basicStatStore, self._defaultBasicStat))
                :Then(function(statValue)
                    eventPlayerStat:FireClient(player, statValue)
                end)
                :Catch(function(err)
                    warn("Failed to get Stat for player:", player.Name, err)
                end)
        end)
        :Catch(function(err)
            warn("Failed to get DataStore for player:", player.Name, err)
        end)
end

function PlayerStatServiceServer:_disconnectPlayerStat(player)
    if self._maid[player] then
        self._maid[player]:DoCleaning()  -- Clean up the maid for the player
        self._maid[player] = nil  -- Remove the player from the maid table
    end
end

return PlayerStatServiceServer