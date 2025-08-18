local require = require(script.Parent.loader).load(script)

local PromiseChild = require("promiseChild")

local PromiseWrapperUtil = {}

function PromiseWrapperUtil:PromiseChild(parent, child, callback)
	PromiseChild(parent, child)
		:Then(function(result)
			callback(result)
		end)
		:Catch(function(err)
			warn(string.format("Failed to get %s in %s event: %s", tostring(child), tostring(parent), tostring(err)))
		end)
end

return PromiseWrapperUtil