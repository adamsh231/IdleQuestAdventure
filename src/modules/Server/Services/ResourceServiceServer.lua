local require = require(script.Parent.loader).load(script)
local Players = game:GetService("Players")
local Maid = require("Maid")

local ResourceServiceServer = {}
ResourceServiceServer.ServiceName = "ResourceServiceServer"

function ResourceServiceServer:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()
end

function ResourceServiceServer:Start()
	assert(self._serviceBag, "Not initialized")
	print("ResourceServiceServer started")

	Players.PlayerAdded:Connect(function(player)
		self:CreateLeaderBoard(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self._maid[player] = nil
	end)

	for _, player in pairs(Players:GetPlayers()) do
		self:CreateLeaderBoard(player)
	end
end

function ResourceServiceServer:CreateLeaderBoard(player)
	assert(self._serviceBag, "Not initialized")
	assert(player, "No player")

	-- Leaderstats setup
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats
	return nil -- Placeholder for actual leaderboard creation logic
end

return ResourceServiceServer