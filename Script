-- =========================
-- DASH ATRÁS DO ALVO (FIX REAL)
-- =========================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIG
local FOV_SELECT = 10
local DISTANCIA_TELEPORTE = 5
local DASH_SPEED = 2500

-- VARIÁVEIS
local selecting = false
local selectedTarget = nil
local highlight = nil
local rightMouseHeld = false
local dashing = false

-- FUNÇÃO PLAYER
local function getCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- PEGAR ALVO
local function getTargetFromCrosshair()
	local closest = nil
	local smallestAngle = FOV_SELECT

	for _, v in pairs(Players:GetPlayers()) do
		if v == LocalPlayer then continue end
		
		local char = v.Character
		if not char then continue end
		
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		
		if not hrp or not hum or hum.Health <= 0 then continue end
		
		local direction = (hrp.Position - Camera.CFrame.Position).Unit
		local dot = Camera.CFrame.LookVector:Dot(direction)
		dot = math.clamp(dot, -1, 1)
		
		local angle = math.deg(math.acos(dot))
		
		if angle < smallestAngle then
			smallestAngle = angle
			closest = v
		end
	end

	return closest
end

-- HIGHLIGHT
local function createHighlight(target)
	if highlight then highlight:Destroy() end
	
	if not target or not target.Character then return end
	
	highlight = Instance.new("Highlight")
	highlight.Adornee = target.Character
	highlight.FillColor = Color3.fromRGB(255,0,0)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = target.Character
end

local function removeHighlight()
	if highlight then
		highlight:Destroy()
		highlight = nil
	end
end

-- 🔥 DASH REAL (ATÉ CHEGAR)
local function dashBehind(target)

	if dashing then return end
	dashing = true
	
	local char = getCharacter()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
	
	if not hrp or not targetHRP then
		dashing = false
		return
	end
	
	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(1e9,1e9,1e9)
	bodyVel.Parent = hrp
	
	while dashing do
		
		if not targetHRP.Parent then break end
		
		local look = targetHRP.CFrame.LookVector
		local goalPos = targetHRP.Position - (look * DISTANCIA_TELEPORTE)
		
		local direction = (goalPos - hrp.Position)
		
		if direction.Magnitude < 3 then
			break
		end
		
		bodyVel.Velocity = direction.Unit * DASH_SPEED
		
		RunService.RenderStepped:Wait()
	end
	
	bodyVel:Destroy()
	
	-- ajuste final
	if targetHRP then
		local look = targetHRP.CFrame.LookVector
		local goalPos = targetHRP.Position - (look * DISTANCIA_TELEPORTE)
		hrp.CFrame = CFrame.new(goalPos, targetHRP.Position)
	end
	
	dashing = false
end

-- INPUT
UIS.InputBegan:Connect(function(input, g)
	if g then return end
	
	if input.KeyCode == Enum.KeyCode.One then
		selecting = true
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		rightMouseHeld = true
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if selecting and selectedTarget and rightMouseHeld then
			
			dashBehind(selectedTarget)
			
			selecting = false
			selectedTarget = nil
			removeHighlight()
			rightMouseHeld = false
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		rightMouseHeld = false
	end
end)

-- LOOP
RunService.RenderStepped:Connect(function()
	if not selecting then return end
	
	local target = getTargetFromCrosshair()
	
	if target ~= selectedTarget then
		selectedTarget = target
		createHighlight(target)
	end
end)
