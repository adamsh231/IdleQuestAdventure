-- Utils/InstanceUtils.lua
-- Provides safe and convenient functions for working with Instances

local InstanceUtils = {}

--[[
	Get a descendant by name, deep search.
	Returns the instance or nil if not found.
]]
function InstanceUtils.GetDescendant(parent: Instance, name: string): Instance?
	return parent:FindFirstChild(name, true)
end

--[[
	Get a descendant by name or throw error if not found.
]]
function InstanceUtils.GetDescendantOrError(parent: Instance, name: string): Instance
	local found = parent:FindFirstChild(name, true)
	if not found then
		error(`[InstanceUtils] Missing descendant "{name}" under {parent:GetFullName()}`)
	end
	return found
end

--[[
	Waits for a descendant to appear under a parent.
	Optional timeout in seconds (default: infinite).
]]
function InstanceUtils.WaitForDescendant(parent: Instance, name: string, timeout: number?): Instance?
	local deadline = timeout and (tick() + timeout)
	repeat
		local found = parent:FindFirstChild(name, true)
		if found then return found end
		task.wait()
	until not timeout or tick() > deadline

	return nil
end

--[[
	Waits for a descendant or throws error if timeout exceeded.
]]
function InstanceUtils.WaitForDescendantOrError(parent: Instance, name: string, timeout: number?): Instance
	local instance = InstanceUtils.WaitForDescendant(parent, name, timeout)
	if not instance then
		error(`[InstanceUtils] Timed out waiting for descendant "{name}" under {parent:GetFullName()}`)
	end
	return instance
end

--[[
	Safely destroys an instance if it exists.
]]
function InstanceUtils.SafeDestroy(instance: Instance?)
	if instance and instance.Destroy then
		pcall(function() instance:Destroy() end)
	end
end

--[[
	Tags an instance (requires `CollectionService`)
]]
function InstanceUtils.Tag(instance: Instance, tag: string)
	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(instance, tag)
end

--[[
	Untags an instance
]]
function InstanceUtils.Untag(instance: Instance, tag: string)
	local CollectionService = game:GetService("CollectionService")
	CollectionService:RemoveTag(instance, tag)
end

--[[
	Returns all descendants of a certain class
]]
function InstanceUtils.GetDescendantsOfClass(parent: Instance, className: string): { Instance }
	local results = {}
	for _, descendant in ipairs(parent:GetDescendants()) do
		if descendant:IsA(className) then
			table.insert(results, descendant)
		end
	end
	return results
end

return InstanceUtils
