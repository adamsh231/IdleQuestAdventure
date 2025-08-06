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
	-- self._serviceBag:GetService(require("Translator"))

	-- Utils plain module
	self._instanceUtils = require("InstanceUtil")
end

function CommonServiceServer:Start()
	assert(self._serviceBag, "Not initialized")
	print("CommonServiceServer started")

	-- use promise to ensure the service is ready before using it
	task.spawn(function()
		local bank = self._instanceUtils.WaitForDescendantOrError(game.Workspace, "Banks", 5)
	end)

end

return CommonServiceServer