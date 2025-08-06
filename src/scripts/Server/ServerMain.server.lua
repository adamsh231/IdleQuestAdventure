--[[
	@class ServerMain
]]
local ServerScriptService = game:GetService("ServerScriptService")

local loader = ServerScriptService.IdleQuestAdventure:FindFirstChild("LoaderUtils", true).Parent
local require = require(loader).bootstrapGame(ServerScriptService.IdleQuestAdventure)

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("IdleQuestAdventureService"))
serviceBag:Init()
serviceBag:Start()