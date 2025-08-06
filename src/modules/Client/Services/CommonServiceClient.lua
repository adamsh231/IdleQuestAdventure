--[=[
	@class CommonServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local CommonServiceClient = {}
CommonServiceClient.ServiceName = "CommonServiceClient"

function CommonServiceClient:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrServiceClient"))

	-- Internal
	self._serviceBag:GetService(require("Translator"))
end

return CommonServiceClient