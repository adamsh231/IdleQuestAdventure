--[=[
	@class CommonServiceServer
]=]

local require = require(script.Parent.loader).load(script)
-- local commonUtils = require("CommonUtil")
local RxInstanceUtils = require("RxInstanceUtils")
local Workspace = game:GetService("Workspace")
local Maid = require("Maid")
local PromiseChild = require("promiseChild")

local CommonServiceServer = {}
CommonServiceServer.ServiceName = "CommonServiceServer"

function CommonServiceServer:Init(serviceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrService"))
	self._resourceService = self._serviceBag:GetService(require("ResourceServiceServer"))

	-- Internal
	self._serviceBag:GetService(require("Translator"))
end

function CommonServiceServer:Start()
	assert(self._serviceBag, "Not initialized")
	print("CommonServiceServer started")

	RxInstanceUtils.observeLastNamedChildBrio(Workspace.Dynamics, "Part", "Bank"):Subscribe(function(bankBrio)
		if bankBrio:IsDead() then
			return
		end

		local bank = bankBrio:GetValue()
		local maid = Maid.new()
		PromiseChild(bank, "ProximityPrompt"):Then(function(bankProximity)
			if not bankProximity then
				return
			end

			print("Bank proximity prompt found:", bankProximity)

			-- Connect the proximity prompt trigger event
			maid:GiveTask(bankProximity.Triggered:Connect(function(player)
				print("Bank proximity prompt triggered by:", player)
				self._resourceService:GetResource("Bank")
			end))
		end):Catch(function(err)
			warn("Failed to find ProximityPrompt in Bank:", err)
		end)
	end)
end

return CommonServiceServer