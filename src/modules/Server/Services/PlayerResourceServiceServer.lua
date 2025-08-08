local loader = require(script.Parent.loader).load(script)

local PlayerResourceServiceServer = {}
PlayerResourceServiceServer.ServiceName = "PlayerResourceServiceServer"

function PlayerResourceServiceServer:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
end

function PlayerResourceServiceServer._getDefaultResource()
    local coin, gem = 0, 0
    return coin, gem
end

return PlayerResourceServiceServer