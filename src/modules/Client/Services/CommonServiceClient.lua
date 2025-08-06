--[=[
	@class IdleQuestAdventureServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local IdleQuestAdventureServiceClient = {}
IdleQuestAdventureServiceClient.ServiceName = "IdleQuestAdventureServiceClient"

function IdleQuestAdventureServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrServiceClient"))

	-- Internal
	self._serviceBag:GetService(require("IdleQuestAdventureTranslator"))
end

return IdleQuestAdventureServiceClient