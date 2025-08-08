local require = require(script.Parent.loader).load(script)

local Signal = require("Signal")

local PlayerResourceServiceServer = {}
PlayerResourceServiceServer.ServiceName = "PlayerResourceServiceServer"

function PlayerResourceServiceServer:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

    self._coinChanged = Signal.new()
    self._coinChanged:Connect(function(newAmount)
        print(" now has " .. newAmount .. " coins.")
    end)
end

function PlayerResourceServiceServer._getDefaultResource()
    local coin, gem = 0, 0
    return coin, gem
end

function PlayerResourceServiceServer:SetCoin(value)
    assert(self._serviceBag, "Not initialized")
    self._coin = value
    self._coinChanged:Fire(value)
end

return PlayerResourceServiceServer