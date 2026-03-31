-- =====================================================
-- 🔒 PROTEÇÃO GLOBAL
-- =====================================================
if _G.SCRIPT_UNIFICADO then return end
_G.SCRIPT_UNIFICADO = true

-- =====================================================
-- 📦 SERVIÇOS
-- =====================================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =====================================================
-- ⚙️ CONFIG
-- =====================================================
local TP_FOV = 12
local TP_DISTANCIA = 5

local FLY_SPEED_NORMAL = 150
local FLY_SPEED_SHIFT = 1200

-- =====================================================
-- 📊 ESTADOS
-- =====================================================
local tp_ativo = false
local tp_alvo = nil
local tp_highlight = nil
local tp_click = false

local flying = false
local speed = FLY_SPEED_NORMAL

local aiming = false
local aim_target = nil

-- =====================================================
-- 🔧 FUNÇÕES BASE
-- =====================================================
local function getHRP()
	return (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

-- =====================================================
-- 🎯 TARGET (usado por TP e AIM)
-- =====================================================
local function getTarget(fov)
	local melhor = nil
	local menor = fov

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			
			if hrp and hum and hum.Health > 0 then
				
				local dir = (hrp.Position - Camera.CFrame.Position).Unit
				local dot = Camera.CFrame.LookVector:Dot(dir)
				dot = math.clamp(dot, -1, 1)
				
				local ang = math.deg(math.acos(dot))
				
				if ang < menor then
					menor = ang
					melhor = plr
				end
			end
		end
	end

	return melhor
end

-- =====================================================
-- 🟥 HIGHLIGHT
-- =====================================================
local function setHighlight(plr)
	if tp_highlight then tp_highlight:Destroy() end
	
	if not plr or not plr.Character then return end
	
	tp_highlight = Instance.new("Highlight")
	tp_highlight.Adornee = plr.Character
	tp_highlight.FillColor = Color3.fromRGB(255,0,0)
	tp_highlight.FillTransparency = 0.4
	tp_highlight.OutlineTransparency = 0
	tp_highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	tp_highlight.Parent = workspace
end

local function clearHighlight()
	if tp_highlight then
		tp_highlight:Destroy()
		tp_highlight = nil
	end
end

-- =====================================================
-- ⚡ TELEPORT
-- =====================================================
local function teleportBehind()
	if not tp_alvo or not tp_alvo.Character then return end
	
	local hrp = getHRP()
	local targetHRP = tp_alvo.Character:FindFirstChild("HumanoidRootPart")
	
	if not hrp or not targetHRP then return end
	
	local look = targetHRP.CFrame.LookVector
	local pos = targetHRP.Position - (look * TP_DISTANCIA)
	
	hrp.CFrame = CFrame.new(pos, targetHRP.Position)
	
	-- reset
	tp_ativo = false
	tp_alvo = nil
	tp_click = false
	clearHighlight()
end

-- =====================================================
-- ✈️ FLY
-- =====================================================
local function updateFly()
	if not flying then return end
	
	local root = getHRP()
	local cam = Camera
	
	local move = Vector3.zero
	
	if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
	
	if move.Magnitude > 0 then move = move.Unit end
	
	root.Velocity = move * speed
end

-- =====================================================
-- 🎯 AIMBOT SIMPLES
-- =====================================================
local function updateAim()
	if not aiming or not aim_target then return end
	
	local hrp = aim_target.Character and aim_target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
end

-- =====================================================
-- 🎮 INPUT ÚNICO
-- =====================================================
UIS.InputBegan:Connect(function(input, g)
	if g then return end

	-- TELEPORT ATIVAR
	if input.KeyCode == Enum.KeyCode.One then
		tp_ativo = true
	end

	-- CLIQUE TELEPORT
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			tp_click = true
		end
	end

	-- AIMBOT (segurar botão direito)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		local target = getTarget(15)
		if target then
			aiming = true
			aim_target = target
		end
	end

	-- FLY
	if input.KeyCode == Enum.KeyCode.PageDown then
		flying = not flying
	end

	-- SHIFT SPEED
	if input.KeyCode == Enum.KeyCode.LeftShift then
		speed = FLY_SPEED_SHIFT
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
		aim_target = nil
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		speed = FLY_SPEED_NORMAL
	end
end)

-- =====================================================
-- 🔁 LOOP ÚNICO
-- =====================================================
RunService.RenderStepped:Connect(function()

	-- TELEPORT
	if tp_ativo then
		local alvo = getTarget(TP_FOV)
		
		if alvo ~= tp_alvo then
			tp_alvo = alvo
			setHighlight(alvo)
		end
		
		if tp_click then
			teleportBehind()
		end
	end

	-- FLY
	updateFly()

	-- AIM
	updateAim()

end)
