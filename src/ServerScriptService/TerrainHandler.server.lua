local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChunkModule = Modules:WaitForChild("ChunkModule")

local V2New = Vector2.new
local r = require

local Chunks = r(ChunkModule)
local ChunkList =
{
    Chunks.new(nil, workspace.Triangles);
    Chunks.new(V2New(1), workspace.Triangles);
    Chunks.new(V2New(0, 1), workspace.Triangles);
    Chunks.new(V2New(1, 1), workspace.Triangles);
}