local loader = game:GetService("ReplicatedStorage"):WaitForChild("IdleQuestAdventure"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent)

local serviceBag = require("ServiceBag").new()
local playerStatService = serviceBag:GetService(require("PlayerStatServiceClient"))

serviceBag:Init()
serviceBag:Start()

-- Trigger once Here
playerStatService:TriggerListener()