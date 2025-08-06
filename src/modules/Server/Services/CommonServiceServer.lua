--[=[
	@class IdleQuestAdventureService
]=]

local require = require(script.Parent.loader).load(script)

local IdleQuestAdventureService = {}
IdleQuestAdventureService.ServiceName = "IdleQuestAdventureService"

function IdleQuestAdventureService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))

	-- Internal
	self._serviceBag:GetService(require("IdleQuestAdventureTranslator"))
end

return IdleQuestAdventureService