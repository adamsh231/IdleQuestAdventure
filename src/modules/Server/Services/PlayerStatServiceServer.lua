local require = require(script.Parent.loader).load(script)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")

local PlayerStatServiceServer = {}
PlayerStatServiceServer.ServiceName = "PlayerStatServiceServer"

function PlayerStatServiceServer:Init(serviceBag)
    assert(not self._serviceBag, "Already initialized")
    self._serviceBag = assert(serviceBag, "No serviceBag")

    -- Initialize the GetPlayerStat event
	local getPlayerStatEvent = ReplicatedStorage.RemoteEvents.PlayerStatEvent
	PromiseChild(getPlayerStatEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
			getPlayerStat.OnServerEvent:Connect(function(player, message)
                print("Received message from client:", message)
            end)
            print("GetPlayerStat event initialized successfully.")
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
end

function PlayerStatServiceServer:Start()
    assert(self._serviceBag, "Not initialized")
end

return PlayerStatServiceServer