local ChunkModule = {}

local SmoothSurface = Enum.SurfaceType.Smooth

local FromMatrix = CFrame.fromMatrix
local INew = Instance.new
local V3New = Vector3.new

local setmt = setmetatable
local abs = math.abs

local function DrawTriangle(PositionA, PositionB, PositionC, Parent, Name, Wedge1, Wedge2)
    local Model = INew("Model")
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

    return Wedge1, Wedge2, Model
end
-- DrawTriangle(workspace.A.Position, workspace.B.Position, workspace.C.Position, workspace)

return ChunkModule