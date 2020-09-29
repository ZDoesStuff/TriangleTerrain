local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChunkModule = Modules:WaitForChild("ChunkModule")

local r = require
local Chunks = r(ChunkModule)

local Chunk = Chunks.new(nil, workspace.Triangles)
wait(5)
Chunk:Destroy()