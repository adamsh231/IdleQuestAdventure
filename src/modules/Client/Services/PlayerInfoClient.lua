local require = require(script.Parent.loader).load(script)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")

local PlayerInfoClient = {}
PlayerInfoClient.ServiceName = "PlayerInfoClient"

function PlayerInfoClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
end

function PlayerInfoClient:TriggerListener()
	assert(self._serviceBag, "Not initialized")

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

	self._triggerButtonXP()
end

local Player = game:GetService("Players").LocalPlayer
function PlayerInfoClient._triggerButtonXP()
	PromiseChild(Player, "PlayerGui")
		:Then(function(playerGui)
			PromiseChild(playerGui, "ScreenGui")
				:Then(function(screenGui)
					local addXPButton = screenGui:FindFirstChild("AddXP")
					addXPButton.MouseButton1Click:Connect(function()
						print("AddXP button clicked")
					end)
				end)
				:Catch(function(err)
					warn("Failed to get ScreenGui:", err)
				end)
		end)
		:Catch(function(err)
			warn("Failed to get PlayerGui:", err)
		end)
end

return PlayerInfoClient