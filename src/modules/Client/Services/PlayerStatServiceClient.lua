local require = require(script.Parent.loader).load(script)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromiseChild = require("promiseChild")
local PlayerStatConstant = require("PlayerStatConstant")

local PlayerStatServiceClient = {}
PlayerStatServiceClient.ServiceName = "PlayerStatServiceClient"

function PlayerStatServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
end

function PlayerStatServiceClient:TriggerListener()
	assert(self._serviceBag, "Not initialized")

	local getPlayerStatEvent = ReplicatedStorage.RemoteEvents.PlayerStatEvent
	PromiseChild(getPlayerStatEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
			getPlayerStat.OnClientEvent:Connect(function(statValue)
				print("Received PlayerStat:", statValue)
			end)
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)

	self._triggerButtonXP()
end

local Player = game:GetService("Players").LocalPlayer
function PlayerStatServiceClient._triggerButtonXP()
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

return PlayerStatServiceClient