local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChunkModule = Modules:WaitForChild("ChunkModule")
local WaitModule = Modules:WaitForChild("WaitModule")

local Terrain = workspace:WaitForChild("Terrain")
local Triangles = Terrain:WaitForChild("Triangles")

local Player = Players.LocalPlayer

local V2New = Vector2.new

local insert = table.insert
local remove = table.remove
local find = table.find

local floor = math.floor
local abs = math.abs

local r = require

local RenderDistance = 2
local ChunksPerTick = 4
local Delay = .025

local Position = V2New()

local Chunks = r(ChunkModule)
local Wait = r(WaitModule)

local CharacterList = {}
local ChunkList = {}

local LoadFast = true
local ChunkCount = 0

local function Round(Vector : Vector2, Rounder : Vector2)
    return V2New(floor(Vector.X / Rounder.X), floor(Vector.Y / Rounder.Y))
end

local function GetChunkPosition(Position : Vector3)
    return Round(V2New(Position.X, Position.Z), Chunks.WidthScale)
end
local function GetLocalChunkPosition()
    local Character = Player.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

    return RootPart and GetChunkPosition(RootPart.Position) or V2New(), RootPart
end

local function DelayNextChunk()
    ChunkCount = (ChunkCount + 1) % ChunksPerTick
    if ChunkCount == 0 and not LoadFast then
        Wait:Wait(Delay)
    end
end

local function ChunkExists(Position : Vector2)
    for _, Chunk in pairs(ChunkList) do
        if Chunk.Position == Position then
            return true
        end
    end
    return false
end
local function ChunkOutOfRange(Chunk, Position : Vector2)
    local ChunkPos = Chunk.Position
    return abs(ChunkPos.X - Position.X) > RenderDistance or abs(ChunkPos.Y - Position.Y) > RenderDistance
end

local function LoadChunks(vPosition : Vector2?)
    local Position = vPosition or V2New()
    for XPos = Position.X - RenderDistance, Position.X + RenderDistance do
        for ZPos = Position.Y - RenderDistance, Position.Y + RenderDistance do
            local VectorPosition = V2New(XPos, ZPos)
            if not ChunkExists(VectorPosition) then
                insert(ChunkList, Chunks.new(VectorPosition, Triangles))
                DelayNextChunk()
            end
        end
    end
end
local function UnloadChunks()
    local Position, RootPart = GetLocalChunkPosition()

    local TotalChunks = #ChunkList
    local Length = 0
    
    for Index = 1, TotalChunks do
        local Chunk = ChunkList[Index]
        if not RootPart or ChunkOutOfRange(Chunk, Position) then
            Chunk:Destroy()
            DelayNextChunk()

            ChunkList[Index] = nil
        end
    end
    for Index = 1, TotalChunks do
        local Chunk = ChunkList[Index]
        if Chunk then
            Length += 1
            ChunkList[Length] = Chunk
        end
    end

    for Index = Length + 1, TotalChunks do
        ChunkList[Index] = nil
    end
end

while true do
    local Position, RootPart = GetLocalChunkPosition()

    UnloadChunks()
    if Position and RootPart then
        LoadChunks(Position)
        LoadFast = false
    end

    Wait:Wait(.5)
end