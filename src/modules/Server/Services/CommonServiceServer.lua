--[=[
	@class CommonServiceServer
]=]

local require = require(script.Parent.loader).load(script)

local CommonServiceServer = {}
CommonServiceServer.ServiceName = "CommonServiceServer"

function CommonServiceServer:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))

	-- Internal
	self._serviceBag:GetService(require("Translator"))
end

return CommonServiceServer