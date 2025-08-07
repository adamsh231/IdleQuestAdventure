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

	self:LoadGUI(PlayerStatConstant.GetDefaultStats()) -- Only for testing purposes

	PromiseChild(getPlayerStatEvent, "GetPlayerStat")
		:Then(function(getPlayerStat)
			getPlayerStat.OnClientEvent:Connect(function(statValue)
				print(statValue)
			end)
		end)
		:Catch(function(err)
			warn("Failed to get GetPlayerStat event:", err)
		end)
end

-- Only for testing purposes
local Player = game:GetService("Players").LocalPlayer
local XPGUI = Player:WaitForChild("PlayerGui"):WaitForChild("XPGUI")
local ButtonXPGUI = Player:WaitForChild("PlayerGui"):WaitForChild("ButtonXPGUI"):WaitForChild("AddXP")
local currentXP = 0
function PlayerStatServiceClient:LoadGUI(stats)
	assert(self._serviceBag, "Not initialized")

	local XPBar = XPGUI.XP.Bar
	if not XPBar then
		print("XP Bar not found in XPGUI")
	else
		XPBar.Size = UDim2.new(0, 0, 1, 0)
	end

	ButtonXPGUI.MouseButton1Click:Connect(function()
		if currentXP >= 100 then
			currentXP = 0
		end
		XPBar.Size = UDim2.new(currentXP / 100, 0, 1, 0)
		currentXP += 10
	end)
end

return PlayerStatServiceClient