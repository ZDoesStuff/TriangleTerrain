local ChunkModule = {}

local SmoothSurface = Enum.SurfaceType.Smooth

local FromMatrix = CFrame.fromMatrix
local INew = Instance.new
local V3New = Vector3.new
local V2New = Vector2.new

local insert = table.insert
local setmt = setmetatable

local noise = math.noise
local abs = math.abs

ChunkModule.Size = V2New(24, 24)

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

function ChunkModule:CreateGrid()
    local PositionGrid = {}
    for XPos = 0, ChunkModule.Size.X do
        local Grid = {}
        for ZPos = 0, ChunkModule.Size.Y do
            Grid[ZPos] = V3New(XPos * 5, noise(XPos / 10, ZPos / 10) * 25, ZPos * 5)
        end

        PositionGrid[XPos] = Grid
    end
    return PositionGrid
end
function ChunkModule:CreateTriangles(PositionGrid, ...)
    for XPos = 0, ChunkModule.Size.X - 1 do
        local AddedX = PositionGrid[XPos + 1]
        local NormX = PositionGrid[XPos]
        
        for ZPos = 0, ChunkModule.Size.Y - 1 do
            local AddZ = ZPos + 1

            local PosA = NormX[ZPos]
            local PosB = AddedX[ZPos]
            local PosC = NormX[AddZ]
            local PosD = AddedX[AddZ]

            ChunkModule:DrawTriangle(PosA, PosB, PosC, ...)
            ChunkModule:DrawTriangle(PosB, PosC, PosD, ...)
        end
    end
end

return ChunkModule