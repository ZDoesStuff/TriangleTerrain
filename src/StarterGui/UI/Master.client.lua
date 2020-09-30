local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Loaded = ReplicatedStorage:WaitForChild("Loaded")

local WaitModule = Modules:WaitForChild("WaitModule")
local UI = script.Parent

local Soundtrack = UI:WaitForChild("Soundtrack")
local Frame = UI:WaitForChild("Frame")

local TINew = TweenInfo.new
local r = require

local Wait = r(WaitModule)
local Info = TINew(2)

local Tweens =
{
	TweenService:Create(
		Soundtrack,
		Info,
		{
			Volume = .25;
		}
	);
	TweenService:Create(
		Frame,
		Info,
		{
			BackgroundTransparency = 1;
		}
	);
}

repeat RunService.RenderStepped:Wait() until Loaded.Value == true
Wait:Wait(2)

print("receiver home cleanaer")
Soundtrack.Volume = 0
Soundtrack:Play()

for Index, Tween in pairs(Tweens) do
	Tween:Play()
	if Index >= #Tweens then
		Tween.Completed:Wait()
	end
end
Frame:Destroy()