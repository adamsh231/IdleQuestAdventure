local require = require(script.Parent.loader).load(script)

local PlayerResourceServiceServer = {}
PlayerResourceServiceServer.ServiceName = "PlayerResourceServiceServer"

PlayerResourceServiceServer._defaultResource = {
    Coin = 0,
    Gem = 0,
}

function PlayerResourceServiceServer:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
    self._playerStatService = serviceBag:GetService(require("PlayerStatServiceServer"))
end

function PlayerResourceServiceServer:Start()
    assert(self._serviceBag, "Not initialized")
end

return PlayerResourceServiceServer