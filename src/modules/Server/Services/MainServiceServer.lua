local require = require(script.Parent.loader).load(script)

local MainServiceServer = {}
MainServiceServer.ServiceName = "MainServiceServer"

function MainServiceServer:Init(serviceBag)
    assert(not self._serviceBag, "Already initialized")
    self._serviceBag = assert(serviceBag, "No serviceBag")

    self._playerStatService = self._serviceBag:GetService(require("PlayerStatServiceServer"))
end

return MainServiceServer