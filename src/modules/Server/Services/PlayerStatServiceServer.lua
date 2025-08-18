local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")
local Players = game:GetService("Players")
local Maid = require("Maid")

local PlayerStatServiceServer = {}
PlayerStatServiceServer.ServiceName = "PlayerStatServiceServer"

PlayerStatServiceServer._defaultStat = {
    BasicStats = {
        HP = 100,
        AttackDamage = 10,
        SkillDamage = 10,
        Defense = 10,

        Level = 1,
        XP = 0,
        MaxXP = 100,
    },
    AdvancedStats = {
        CriticalAttackChance = 0,
        CriticalAttackDamage = 0,
        CounterAttackChance = 0,
    },
}   

function PlayerStatServiceServer:Init(serviceBag)
    assert(not self._serviceBag, "Already initialized")
    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._playerDataStoreService = serviceBag:GetService(require("PlayerDataStoreService"))
    self._maid = {} -- Initialize the _maid table
end

function PlayerStatServiceServer:Start()
    assert(self._serviceBag, "Not initialized")
    self:_initiateClientEvents()
end

function PlayerStatServiceServer:_initiateClientEvents()
    assert(self._serviceBag, "Not initialized")

    local function _onPlayerConnect(getPlayerStat)
        Players.PlayerAdded:Connect(function(player)
            self._maid[player] = Maid.new()
            self._maid[player]:GivePromise(self._playerDataStoreService:PromiseDataStore(player))
                :Then(function(dataStore)
                    self._maid[player]:GivePromise(dataStore:Load("stat", self._defaultStat))
                        :Then(function(statValue)
                            getPlayerStat:FireClient(player, statValue)
                        end)
                        :Catch(function(err)
                            warn("Failed to get Stat for player:", player.Name, err)
                        end)
                end)
                :Catch(function(err)
                    warn("Failed to get DataStore for player:", player.Name, err)
                end)
        end)
    end

    local function _onPlayerDisconnect()
        Players.PlayerRemoving:Connect(function(player)
            if self._maid[player] then
                self._maid[player]:DoCleaning()  -- Clean up the maid for the player
                self._maid[player] = nil  -- Remove the player from the maid table
            end
        end)
    end

	local getPlayerStatEvent = ReplicatedStorage.RemoteEvents.PlayerInfoEvent
	PromiseChild(getPlayerStatEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
            _onPlayerConnect(getPlayerStat)
            _onPlayerDisconnect()
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
end

return PlayerStatServiceServer