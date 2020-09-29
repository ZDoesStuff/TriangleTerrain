local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ChunkModule = Modules:WaitForChild("ChunkModule")
local WaitModule = Modules:WaitForChild("WaitModule")

local Terrain = workspace:WaitForChild("Terrain")
local Triangles = Terrain:WaitForChild("Triangles")

local V2New = Vector2.new

local insert = table.insert
local remove = table.remove
local find = table.find

local floor = math.floor
local abs = math.abs

local r = require

local Position = V2New()
local RenderDistance = 1

local Chunks = r(ChunkModule)
local Wait = r(WaitModule)

local CharacterList = {}
local ChunkList = {}

local function Round(Vector : Vector2, Rounder : Vector2)
    return V2New(floor(Vector.X / Rounder.X), floor(Vector.Y / Rounder.Y))
end

local function GetChunkPositions()
    local Positions = {}
    for _, Character in pairs(CharacterList) do
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        local RootPosition = RootPart and RootPart.Position

        if RootPosition then
            local VectorPosition = Round(V2New(RootPosition.X, RootPosition.Z), Chunks.WidthScale)
            insert(Positions, VectorPosition)
        end
    end
    return Positions
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
    return abs(Chunk.Position.X - Position.X) > RenderDistance or abs(Chunk.Position.Y - Position.Y) > RenderDistance
end

local function LoadChunks(Position : Vector2?)
    Position = Position or V2New()
    for XPos = Position.X - RenderDistance, Position.X + RenderDistance do
        for ZPos = Position.Y - RenderDistance, Position.Y + RenderDistance do
            local VectorPosition = V2New(XPos, ZPos)
            if not ChunkExists(VectorPosition) then
                insert(ChunkList, Chunks.new(VectorPosition, Triangles))
            end
        end
    end
end
local function UnloadChunks()
    local TotalChunks = #ChunkList
    local Length = 0

    for Index = 1, TotalChunks do
        local Chunk = ChunkList[Index]
        for _, Position in pairs(GetChunkPositions()) do
            if ChunkOutOfRange(Chunk, Position) then
                Chunk:Destroy()
                ChunkList[Index] = nil

                break
            end
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

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterRemoving:Connect(function(Character)
        remove(CharacterList, find(CharacterList, Character))
    end)
    Player.CharacterAdded:Connect(function(Character)
        insert(CharacterList, Character)
    end)
end)

while true do
    local Positions = GetChunkPositions()
    UnloadChunks()

    for _, Position in pairs(Positions) do
        LoadChunks(Position)
    end

    wait(.5)
end