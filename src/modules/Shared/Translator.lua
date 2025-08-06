--[[
	@class Translator
]]

local require = require(script.Parent.loader).load(script)

return require("JSONTranslator").new("Translator", "en", {
	gameName = "IdleQuestAdventure";
})