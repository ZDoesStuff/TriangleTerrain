local ReplicatedStorage = game:GetService("ReplicatedStorage")

local random = math.random
local INew = Instance.new

local function RandomInt()
    return random(1_000_000)
end

local Seed = INew("IntValue")
Seed.Value = RandomInt()
Seed.Name = "Seed"

Seed.Parent = ReplicatedStorage