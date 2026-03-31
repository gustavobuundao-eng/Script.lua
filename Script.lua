-- =====================================================
-- 🔒 PROTEÇÃO GLOBAL (evita duplicar script)
-- =====================================================
if _G.SCRIPT_UNIFICADO then return end
_G.SCRIPT_UNIFICADO = true

-- =====================================================
-- 📦 SERVIÇOS
-- =====================================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =====================================================
-- ⚙️ CONFIGURAÇÕES
-- =====================================================

-- teclas
local FLY_KEY = Enum.KeyCode.PageDown
local INVIS_KEY = Enum.KeyCode.LeftControl

-- velocidade fly
_G.FLY_NORMAL_SPEED = 150
_G.FLY_SHIFT_SPEED = 1289

-- ESP
local ESP_ON = true

-- invis
local seatDistance = 50000000
local seatHeight = 50000000
local seatX = -25.95

-- pulo
local alturaPrimeiroPulo = 120

-- teleport
local TP_FOV = 12
local TP_DISTANCIA = 5

-- =====================================================
-- 📊 ESTADOS
-- =====================================================
local flying = false
local invis = false
local speed = _G.FLY_NORMAL_SPEED

local superPuloAtivo = false
local ultimoShift = 0
local TEMPO_DOUBLE = 0.3

-- teleport
local tp_ativo = false
local tp_alvo = nil
local tp_highlight = nil

-- =====================================================
-- 🔧 FUNÇÕES BASE
-- =====================================================
local function getHRP()
	return (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

-- =====================================================
-- ✈️ FLY
-- =====================================================
local function startFly()
	local root = getHRP()

	local gyro = Instance.new("BodyGyro", root)
	gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)

	local vel = Instance.new("BodyVelocity", root)
	vel.MaxForce = Vector3.new(9e9,9e9,9e9)

	RunService.RenderStepped:Connect(function()
		if not flying then return end
		
		local cam = Camera
		local move = Vector3.zero
		
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		
		if move.Magnitude > 0 then move = move.Unit end
		
		vel.Velocity = move * speed
		gyro.CFrame = cam.CFrame
	end)
end

-- =========================
-- TELEPORT SYSTEM (COMPATÍVEL)
-- =========================

local TP_FOV = 12
local TP_DISTANCIA = 5

local tp_ativo = false
local tp_alvo = nil
local tp_highlight = nil

-- ativar com tecla 1
UIS.InputBegan:Connect(function(input, g)
	if g then return end
	
	if input.KeyCode == Enum.KeyCode.One then
		tp_ativo = true
	end
end)

-- pegar alvo pela mira
local function tp_getAlvo()
	local melhor = nil
	local menorAngulo = TP_FOV

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			
			if hrp and hum and hum.Health > 0 then
				
				local dir = (hrp.Position - Camera.CFrame.Position).Unit
				local dot = Camera.CFrame.LookVector:Dot(dir)
				dot = math.clamp(dot, -1, 1)
				
				local ang = math.deg(math.acos(dot))
				
				if ang < menorAngulo then
					menorAngulo = ang
					melhor = plr
				end
			end
		end
	end

	return melhor
end

-- highlight
local function tp_setHighlight(plr)
	if tp_highlight then
		tp_highlight:Destroy()
		tp_highlight = nil
	end
	
	if not plr or not plr.Character then return end
	
	tp_highlight = Instance.new("Highlight")
	tp_highlight.Adornee = plr.Character
	tp_highlight.FillColor = Color3.fromRGB(255,0,0)
	tp_highlight.FillTransparency = 0.4
	tp_highlight.OutlineTransparency = 0
	tp_highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	tp_highlight.Parent = workspace
end

-- desativar
local function tp_desativar()
	tp_ativo = false
	tp_alvo = nil
	
	if tp_highlight then
		tp_highlight:Destroy()
		tp_highlight = nil
	end
end

-- teleporte
local function tp_teleportar()
	if not tp_alvo or not tp_alvo.Character then return end
	
	local hrp = getHRP()
	local targetHRP = tp_alvo.Character:FindFirstChild("HumanoidRootPart")
	
	if not hrp or not targetHRP then return end
	
	local look = targetHRP.CFrame.LookVector
	local pos = targetHRP.Position - (look * TP_DISTANCIA)
	
	hrp.CFrame = CFrame.new(pos, targetHRP.Position)

	tp_desativar()
end

-- LOOP SIMPLES (NÃO QUEBRA NADA)
RunService.RenderStepped:Connect(function()

	if not tp_ativo then return end

	-- selecionar alvo
	local alvo = tp_getAlvo()

	if alvo ~= tp_alvo then
		tp_alvo = alvo
		tp_setHighlight(alvo)
	end

	-- detectar clique
	if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		
		tp_teleportar()
	end

end)
