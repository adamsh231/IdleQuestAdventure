local loader = game:GetService("ReplicatedStorage"):WaitForChild("IdleQuestAdventure"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent)

local serviceBag = require("ServiceBag").new()
local PlayerInfoClient = serviceBag:GetService(require("PlayerInfoClient"))

serviceBag:Init()
serviceBag:Start()

-- Trigger once Here
PlayerInfoClient:TriggerListener()