local ChunkModule = {}
ChunkModule.__index = ChunkModule

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local WaitModule = Modules:WaitForChild("WaitModule")

local SmoothSurface = Enum.SurfaceType.Smooth

local FromMatrix = CFrame.fromMatrix
local INew = Instance.new
local V3New = Vector3.new
local V2New = Vector2.new

local insert = table.insert

local noise = math.noise
local abs = math.abs

local setmt = setmetatable
local r = require

local Wait = r(WaitModule)

ChunkModule.ChunkSize = V2New(1, 1) * 16
ChunkModule.Frequency = 25
ChunkModule.Amplitude = 5
ChunkModule.Divider = 10

ChunkModule.WidthScale = ChunkModule.ChunkSize * ChunkModule.Amplitude

local function GetHeight(ChunkPosition : Vector2, ChunkIndices : Vector2)
    return noise(
        (ChunkModule.ChunkSize.X / ChunkModule.Divider * ChunkPosition.X) + ChunkIndices.X / ChunkModule.Divider,
        (ChunkModule.ChunkSize.Y / ChunkModule.Divider * ChunkPosition.Y) + ChunkIndices.Y / ChunkModule.Divider
    ) * ChunkModule.Frequency
end
local function GetPosition(ChunkPosition : Vector2, ChunkIndices : Vector2, FinalVectors : Vector2)
    return V3New(
        FinalVectors.X,
        GetHeight(ChunkPosition, ChunkIndices),
        FinalVectors.Y
    )
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

    if DotABD > DotABD and DotABD > DotBCD then
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
        Instances = {Model};
    }
    setmt(Chunk, ChunkModule)
    
    local PositionGrid = {}
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

            ChunkModule:DrawTriangle(PosA, PosB, PosC, Model, ...)
            ChunkModule:DrawTriangle(PosB, PosC, PosD, Model, ...)
        end
    end

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
end

return ChunkModule