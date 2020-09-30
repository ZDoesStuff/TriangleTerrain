local ChunkModule = {}
ChunkModule.__index = ChunkModule

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Objects = ReplicatedStorage:WaitForChild("Objects")
local SeedValue = ReplicatedStorage:WaitForChild("Seed")

local WaitModule = Modules:WaitForChild("WaitModule")
local Tree = Objects:WaitForChild("Tree")

local Terrain = workspace:WaitForChild("Terrain")
local Seed = SeedValue.Value

local SmoothMaterial = Enum.Material.SmoothPlastic
local SmoothSurface = Enum.SurfaceType.Smooth
local GrassMaterial = Enum.Material.Grass
local SlateMaterial = Enum.Material.Slate
local WaterMaterial = Enum.Material.Water
local SandMaterial = Enum.Material.Sand
local AirMaterial = Enum.Material.Air

local FromMatrix = CFrame.fromMatrix
local CFAng = CFrame.Angles
local CFNew = CFrame.new

local C3RGB = Color3.fromRGB
local INew = Instance.new
local V3New = Vector3.new
local V2New = Vector2.new

local insert = table.insert

local randomseed = math.randomseed
local random = math.random
local noise = math.noise
local abs = math.abs
local pi = math.pi

local setmt = setmetatable
local r = require

local Wait = r(WaitModule)

ChunkModule.ChunkSize = V2New(1, 1) * 4
ChunkModule.Frequency = 100
ChunkModule.Amplitude = 15
ChunkModule.Divider = 20

ChunkModule.ExtrudeModifider = 1.25
ChunkModule.ExtrudeHeight = 20

ChunkModule.RandomOffset = 10
ChunkModule.TreeDensity = .25
ChunkModule.RandomAngle = .05

ChunkModule.MinTree = -15
ChunkModule.MaxTree = 30

ChunkModule.SeaLevel = -80

ChunkModule.WidthScale = ChunkModule.ChunkSize * ChunkModule.Amplitude
ChunkModule.HeightColors =
{
    [-50] = {C3RGB(200, 200, 150), SandMaterial, .25}; -- Yellow
    [-10] = {C3RGB(75, 100, 50), GrassMaterial, .5}; -- Green
    [75] = {C3RGB(75, 80, 85), SlateMaterial, .75}; -- Grey
    [0] = {C3RGB(75, 100, 50), GrassMaterial, .5}; -- Green
}

local function GetRandom()
    return random() * random(-ChunkModule.RandomOffset, ChunkModule.RandomOffset)
end
local function GetAngle()
    return ChunkModule.RandomAngle * pi * random()
end

local function GetHeight(ChunkPosition : Vector2, ChunkIndices : Vector2)
    local Height = noise(
        (ChunkModule.ChunkSize.X / ChunkModule.Divider * ChunkPosition.X) + ChunkIndices.X / ChunkModule.Divider,
        (ChunkModule.ChunkSize.Y / ChunkModule.Divider * ChunkPosition.Y) + ChunkIndices.Y / ChunkModule.Divider,
        Seed
    ) * ChunkModule.Frequency

    if Height > ChunkModule.ExtrudeHeight then
        local Diff = Height - ChunkModule.ExtrudeHeight
        Height += (Diff * ChunkModule.ExtrudeModifider)
    end
    if Height < -ChunkModule.ExtrudeHeight then
        local Diff = Height + ChunkModule.ExtrudeHeight
        Height += (Diff * ChunkModule.ExtrudeModifider)
    end

    return Height
end
local function GetPosition(ChunkPosition : Vector2, ChunkIndices : Vector2, FinalVectors : Vector2)
    return V3New(
        FinalVectors.X,
        GetHeight(ChunkPosition, ChunkIndices),
        FinalVectors.Y
    )
end

local function ColorTriangle(Model, Color : Color3, Material : Enum.Material?)
    Material = Material or SmoothMaterial
    for _, Part in pairs(Model:GetChildren()) do
        Part.Material = Material
        Part.Color = Color
    end
end
local function PaintTriangle(Triangle)
    local Position = Triangle:GetPrimaryPartCFrame()
    local TriangleHeight = Position.Y

    local HigherHeight = nil
    local LowerHeight = nil

    local Material = nil
    local Color = nil

    for Height, HeightColor in pairs(ChunkModule.HeightColors) do
        if TriangleHeight == Height then
            Material = HeightColor[2]
            Color = HeightColor[1]

            break
        end

        if TriangleHeight < Height and (not HigherHeight or Height < HigherHeight) then
            HigherHeight = Height
        end
        if TriangleHeight > Height and (not LowerHeight or Height > LowerHeight) then
            LowerHeight = Height
        end
    end
    if not Color then
        if not HigherHeight then
            local HeightItem = ChunkModule.HeightColors[LowerHeight]
            Color, Material = HeightItem[1], HeightItem[2]
        elseif not LowerHeight then
            local HeightItem = ChunkModule.HeightColors[HigherHeight]
            Color, Material = HeightItem[1], HeightItem[2]
        else
            local Alpha = (TriangleHeight - LowerHeight) / (HigherHeight - LowerHeight)

            local HigherHeightItem = ChunkModule.HeightColors[HigherHeight]
            local LowerHeightItem = ChunkModule.HeightColors[LowerHeight]
            
            Material = Alpha > LowerHeightItem[3] and HigherHeightItem[2] or LowerHeightItem[2]
            Color = LowerHeightItem[1]:Lerp(HigherHeightItem[1], Alpha)
        end
    end
    ColorTriangle(Triangle, Color, Material)
end

local function CreateWater(Chunk)
    local Multiplier = V2New(1, 1) * .5

    local ChunkSize = V3New(ChunkModule.WidthScale.X, abs(ChunkModule.SeaLevel), ChunkModule.WidthScale.Y)
    local ChunkWidth = (Chunk.Position + Multiplier) * ChunkModule.WidthScale

    local ChunkCFrame = CFNew(ChunkWidth.X, ChunkModule.SeaLevel, ChunkWidth.Y)
    Terrain:FillBlock(ChunkCFrame, ChunkSize, WaterMaterial)

    Chunk.Water =
    {
        CFrame = ChunkCFrame;
        Size = ChunkSize;
    }
end
local function CreateTrees(Chunk)
    local PositionGrid = Chunk.PositionGrid
    local Instances = Chunk.Instances

    local Position = Chunk.Position
    for PosX = 0, ChunkModule.ChunkSize.X - 1 do
        for PosZ = 0, ChunkModule.ChunkSize.Y - 1 do
            local GridPosition = PositionGrid[PosX][PosZ]
            if GridPosition.Y >= ChunkModule.MinTree and GridPosition.Y <= ChunkModule.MaxTree then
                randomseed(PosX * (Position.X + Seed) + PosZ * (Position.Y + Seed))
                if random() < ChunkModule.TreeDensity then
                    local TreeClone = Tree:Clone()
                    local TreeCFrame = CFNew(GridPosition)
                        * CFNew(
                            GetRandom(),
                            0,
                            GetRandom()
                        )
                        * CFAng(
                            GetAngle(),
                            0,
                            GetAngle()
                        )

                    TreeClone:SetPrimaryPartCFrame(TreeCFrame)
                    TreeClone.Parent = Instances.Model

                    insert(Instances, TreeClone)
                end
            end
        end
    end
end

function ChunkModule:DrawTriangle(PositionA, PositionB, PositionC, Parent, Name, Model, Wedge1, Wedge2)
    local Model = Model or INew("Model")
    Model.Name = Name or "Triangles"

    local Wedge = INew("WedgePart")
    Wedge.BottomSurface = SmoothSurface
    Wedge.TopSurface = SmoothSurface
    Wedge.Name = "Triangle"
    Wedge.Anchored = true

    local function GetPositions()
        return PositionB - PositionA, PositionC - PositionA, PositionC - PositionB
    end
    
    local PosAB, PosAC, PosBC = GetPositions()
    local DotABD, DotACD, DotBCD = PosAB:Dot(PosAB), PosAC:Dot(PosAC), PosBC:Dot(PosBC)

    if DotABD > DotACD and DotABD > DotBCD then
        PositionC, PositionA = PositionA, PositionC
    elseif DotACD > DotBCD and DotACD > DotABD then
        PositionA, PositionB = PositionB, PositionA
    end

    PosAB, PosAC, PosBC = GetPositions()

    local RightVector = PosAC:Cross(PosAB).Unit
    local UpVector = PosBC:Cross(RightVector).Unit
    local BackVector = PosBC.Unit

    local Height = abs(PosAB:Dot(UpVector))

    local Wedge1 = Wedge1 or Wedge:Clone()
    Wedge1.CFrame = FromMatrix((PositionA + PositionB) / 2, RightVector, UpVector, BackVector)
    Wedge1.Size = V3New(0, Height, abs(PosAB:Dot(BackVector)))
    Wedge1.Name = Wedge.Name .. "A"

    local Wedge2 = Wedge2 or Wedge:Clone()
    Wedge2.CFrame = FromMatrix((PositionA + PositionC) / 2, -RightVector, UpVector, -BackVector)
    Wedge2.Size = V3New(0, Height, abs(PosAC:Dot(BackVector)))
    Wedge2.Name = Wedge.Name .. "B"

    Wedge1.Parent = Model
    Wedge2.Parent = Model

    Model.PrimaryPart = Wedge1
    Model.Parent = Parent

    Wedge:Destroy()
    return Model, Wedge1, Wedge2
end
function ChunkModule.new(ChunkPosition : Vector2?, Parent, ...)
    ChunkPosition = ChunkPosition or V2New()

    local Model = INew("Folder")
    Model.Name = "Chunk"

    local Chunk =
    {
        Position = ChunkPosition;
        Instances = {Model = Model};
        PositionGrid = {};
    }
    setmt(Chunk, ChunkModule)
    
    local PositionGrid = Chunk.PositionGrid -- Pointer
    for XPos = 0, ChunkModule.ChunkSize.X do
        local Grid = {}

        local AmpedSizeX = ChunkPosition.X * ChunkModule.ChunkSize.X * ChunkModule.Amplitude
        local AmpedX = XPos * ChunkModule.Amplitude

        local FinalX = AmpedSizeX + AmpedX

        for ZPos = 0, ChunkModule.ChunkSize.Y do
            local AmpedSizeZ = ChunkPosition.Y * ChunkModule.ChunkSize.Y * ChunkModule.Amplitude
            local AmpedZ = ZPos * ChunkModule.Amplitude

            local FinalZ = AmpedSizeZ + AmpedZ

            Grid[ZPos] = GetPosition(ChunkPosition, V2New(XPos, ZPos), V2New(FinalX, FinalZ))
        end
        PositionGrid[XPos] = Grid
    end
    for XPos = 0, ChunkModule.ChunkSize.X - 1 do
        local AddedX = PositionGrid[XPos + 1]
        local NormX = PositionGrid[XPos]
        
        for ZPos = 0, ChunkModule.ChunkSize.Y - 1 do
            local AddZ = ZPos + 1

            local PosA = NormX[ZPos]
            local PosB = AddedX[ZPos]
            local PosC = NormX[AddZ]
            local PosD = AddedX[AddZ]

            local TriangleA = ChunkModule:DrawTriangle(PosA, PosB, PosC, Model, ...)
            local TriangleB = ChunkModule:DrawTriangle(PosB, PosC, PosD, Model, ...)

            PaintTriangle(TriangleA)
            PaintTriangle(TriangleB)
        end
    end

    CreateWater(Chunk)
    CreateTrees(Chunk)

    Model.Parent = Parent
    return Chunk
end
function ChunkModule:Destroy(Modulo, Timer)
    for Index, Instance in pairs(self.Instances) do
        Instance:Destroy()
        if Modulo and Index % Modulo == 0 then
            Wait:Wait(Timer)
        end
    end
    Terrain:FillBlock(self.Water.CFrame, self.Water.Size, AirMaterial)
end

return ChunkModule