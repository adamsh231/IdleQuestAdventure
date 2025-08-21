local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Maid = require("Maid")
local PromiseWrapperUtil = require("PromiseWrapperUtil")
local EventConstant = require("EventConstant")

local PlayerStatServiceServer = {}
PlayerStatServiceServer.ServiceName = "PlayerStatServiceServer"

PlayerStatServiceServer._defaultBasicStat = {
    HP = 150,
    AttackDamage = 15,
    SkillDamage = 20,
    Defense = 12,

    Level = 1,
    CurrentXP = 0,
    TargetXP = 200,
}   

PlayerStatServiceServer._defaultAdvancedStat = {
    CriticalAttackChance = 0,
    CriticalAttackDamage = 0,
    CounterAttackChance = 0,
}

local BASIC_STAT_STORE = "basic_stat"
local ADVANCED_STAT_STORE = "advanced_stat"
function PlayerStatServiceServer:Init(serviceBag)
    assert(not self._serviceBag, "Already initialized")
    self._serviceBag = assert(serviceBag, "No serviceBag")
    self._playerDataStoreService = serviceBag:GetService(require("PlayerDataStoreService"))

    self._maid = {} -- Initialize the _maid table
    self._playerData = {}
end

function PlayerStatServiceServer:Start()
    assert(self._serviceBag, "Not initialized")
    self:_initiateClientEvents()
end

function PlayerStatServiceServer:_initiateClientEvents()
	local RemoteEvents = ReplicatedStorage.RemoteEvents
	PromiseWrapperUtil:PromiseChild(RemoteEvents, "GetPlayerStat", function(getPlayerStatEvent)
        Players.PlayerAdded:Connect(function(player)
            self:_handlePlayerConnect(player, getPlayerStatEvent)
        end)
        Players.PlayerRemoving:Connect(function(player)
            self:_handlePlayerDisconnect(player)
        end)
        getPlayerStatEvent.OnServerEvent:Connect(function(player, eventInfo)
            self:_handleStatEvent(player, eventInfo)
            getPlayerStatEvent:FireClient(player, self._playerData[player].BASIC_STAT_STORE)
        end)
    end)
end


-- todo: make this as util..
function PlayerStatServiceServer:_handleStatEvent(player, eventInfo)
    if eventInfo == EventConstant.PlayerAddXPEvent then
        self._maid[player]:GivePromise(self._playerDataStoreService:PromiseDataStore(player))
            :Then(function(dataStore)
                local addedXP = self._playerData[player].BASIC_STAT_STORE.TargetXP * 0.2
                local totalXP = self._playerData[player].BASIC_STAT_STORE.CurrentXP + addedXP
                if totalXP >= self._playerData[player].BASIC_STAT_STORE.TargetXP then
                    -- Level up logic
                    self._playerData[player].BASIC_STAT_STORE.Level += 1
                    self._playerData[player].BASIC_STAT_STORE.CurrentXP = totalXP - self._playerData[player].BASIC_STAT_STORE.TargetXP
                    self._playerData[player].BASIC_STAT_STORE.TargetXP = self._playerData[player].BASIC_STAT_STORE.TargetXP * 1.2 -- Increase target XP for next level

                    -- Increase stats by reasonable percentages from previous value
                    self._playerData[player].BASIC_STAT_STORE.HP += math.floor(self._playerData[player].BASIC_STAT_STORE.HP * 0.15) -- 15% increase
                    self._playerData[player].BASIC_STAT_STORE.AttackDamage += math.floor(self._playerData[player].BASIC_STAT_STORE.AttackDamage * 0.12) -- 12% increase
                    self._playerData[player].BASIC_STAT_STORE.SkillDamage += math.floor(self._playerData[player].BASIC_STAT_STORE.SkillDamage * 0.10) -- 10% increase
                    self._playerData[player].BASIC_STAT_STORE.Defense += math.floor(self._playerData[player].BASIC_STAT_STORE.Defense * 0.08) -- 8% increase
                else
                    self._playerData[player].BASIC_STAT_STORE.CurrentXP = totalXP
                end
                dataStore:Store(BASIC_STAT_STORE, self._playerData[player].BASIC_STAT_STORE)
            end)
            :Catch(function(err)
                warn("Failed to save player stat for player:", player.Name, err)
            end)
        print("XP Added:", self._playerData[player])
    elseif eventInfo == EventConstant.PlayerAddAttackEvent then
        self._playerData[player].BASIC_STAT_STORE.AttackDamage += math.floor(self._playerData[player].BASIC_STAT_STORE.AttackDamage * 0.12) -- 12% increase
    elseif eventInfo == EventConstant.PlayerAddDefenseEvent then
        self._playerData[player].BASIC_STAT_STORE.Defense += math.floor(self._playerData[player].BASIC_STAT_STORE.Defense * 0.08) -- 8% increase
    elseif eventInfo == EventConstant.PlayerAddMaxHPEvent then
        self._playerData[player].BASIC_STAT_STORE.HP += math.floor(self._playerData[player].BASIC_STAT_STORE.HP * 0.15) -- 15% increase
    else
        print("Unknown event type:", eventInfo)
    end
end

-- todo: make this as util..
function PlayerStatServiceServer:_handlePlayerConnect(player, getPlayerStatEvent)
    self._maid[player] = Maid.new()
    self._playerData[player] = {
        BASIC_STAT_STORE = self._defaultBasicStat,
        ADVANCED_STAT_STORE = self._defaultAdvancedStat
    }
    self._maid[player]:GivePromise(self._playerDataStoreService:PromiseDataStore(player))
        :Then(function(dataStore)
            self._maid[player]:GivePromise(dataStore:Load(BASIC_STAT_STORE, self._defaultBasicStat))
                :Then(function(statValue)
                    self._playerData[player].BASIC_STAT_STORE = statValue
                    getPlayerStatEvent:FireClient(player, statValue)
                end)
                :Catch(function(err)
                    warn("Failed to get Stat for player:", player.Name, err)
                end)
        end)
        :Catch(function(err)
            warn("Failed to get DataStore for player:", player.Name, err)
        end)
end

function PlayerStatServiceServer:_handlePlayerDisconnect(player)
    self._playerData[player] = nil
    if self._maid[player] then
        self._maid[player]:DoCleaning()  -- Clean up the maid for the player
        self._maid[player] = nil  -- Remove the player from the maid table
    end
end

return PlayerStatServiceServer