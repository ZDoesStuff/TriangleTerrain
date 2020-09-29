local WaitModule = {}

-- 56203888

local RunService = game:GetService("RunService")

local INew = Instance.new
local osclock = os.clock

local clamp = math.clamp
local huge = math.huge

local up = unpack
local t = tick

local Minimum = .01

-- Yields for a certain amount of seconds before it stops.
function WaitModule:Wait(Seconds)
	local IsClient = RunService:IsClient()
	local WaitType = IsClient and "RenderStepped" or "Stepped"
	
	Seconds = clamp(Seconds or Minimum, Minimum, huge)
	
	local OldTick = osclock()
	local NewTick = OldTick + Seconds
	
	local WaitFunction = RunService[WaitType]
	repeat WaitFunction:Wait() until osclock() >= NewTick
	
	return osclock() - OldTick
end
-- A better version of executing a function without stopping a script.
function WaitModule:Spawn(Function, ...)
	local Args = {...}
	
	local Bind = INew("BindableEvent")
	Bind.Event:Connect(function()
		Function(up(Args))
	end)
	
	Bind:Fire()
	Bind:Destroy()
end
-- Waits a certain amount of seconds without yielding to execute a function.
-- If you don't want to yield, this is best used for execution.
function WaitModule:Delay(Seconds, Function, ...)
	local Args = {...}
	
	WaitModule:Spawn(function()
		WaitModule:Wait(Seconds)
		Function(up(Args))
	end)
end

return WaitModule