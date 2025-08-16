local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.IdleQuestAdventure:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapGame(ServerScriptService.IdleQuestAdventure)

local serviceBag = require("ServiceBag").new()
local playerStatService = serviceBag:GetService(require("PlayerStatServiceServer"))
local playerResourceService = serviceBag:GetService(require("PlayerResourceServiceServer"))

serviceBag:Init()
serviceBag:Start()

-- Trigger once Here
playerStatService:TriggerClientEvent()