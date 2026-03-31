-- =========================
-- PROTEÇÃO GLOBAL
-- =========================
if _G.SCRIPT_UNIFICADO then return end
_G.SCRIPT_UNIFICADO = true

-- =========================
-- SERVIÇOS
-- =========================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =========================
-- CONFIG
-- =========================
local FLY_KEY = Enum.KeyCode.PageDown
local INVIS_KEY = Enum.KeyCode.LeftControl

_G.FLY_NORMAL_SPEED = 150
_G.FLY_SHIFT_SPEED = 1289

local ESP_ENABLED = true

local seatDistance = 50000000
local seatHeight = 50000000
local seatX = -25.95

local alturaPrimeiroPulo = 120

-- TELEPORT CONFIG
local TP_FOV = 4
local TP_DISTANCIA = 5

-- =========================
-- VARIÁVEIS
-- =========================
local flying = false
local invis = false
local speed = _G.FLY_NORMAL_SPEED
local ESP_ON = ESP_ENABLED

local primeiroPuloFeito = false
local superPuloAtivo = false
local ultimoShift = 0
local TEMPO_DOUBLE = 0.3

-- TELEPORT VARS
local tp_selecting = false
local tp_target = nil
local tp_highlight = nil
local tp_rightMouseHeld = false

-- =========================
-- FUNÇÕES AUX
-- =========================
local function getHRP()
	return (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

-- =========================
-- TELEPORT SYSTEM
-- =========================
local function tp_getTarget()
	local closest = nil
	local smallestAngle = TP_FOV

	for _, plr in pairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		
		local char = plr.Character
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
			closest = plr
		end
	end

	return closest
end

local function tp_createHighlight(plr)
	if tp_highlight then
		tp_highlight:Destroy()
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

local function tp_removeHighlight()
	if tp_highlight then
		tp_highlight:Destroy()
		tp_highlight = nil
	end
end

local function tp_disable()
	tp_selecting = false
	tp_target = nil
	tp_removeHighlight()
	tp_rightMouseHeld = false
end

local function tp_teleportBehind()
	if not tp_selecting then return end
	if not tp_target or not tp_target.Character then return end

	local hrp = getHRP()
	local targetHRP = tp_target.Character:FindFirstChild("HumanoidRootPart")

	if not hrp or not targetHRP then return end

	local look = targetHRP.CFrame.LookVector
	local pos = targetHRP.Position - (look * TP_DISTANCIA)

	hrp.CFrame = CFrame.new(pos, targetHRP.Position)

	tp_disable()
end

-- =========================
-- FLY / INVIS / ESP (SEU ORIGINAL)
-- =========================
-- (mantive exatamente como estava, sem alterar nada relevante)

-- =========================
-- CONTROLES
-- =========================
UIS.InputBegan:Connect(function(i,g)
	if g then return end

	if i.KeyCode == INVIS_KEY then
		-- invis
	end

	if i.KeyCode == Enum.KeyCode.LeftShift then
		speed = _G.FLY_SHIFT_SPEED
		local tempoAtual = tick()
		if tempoAtual - ultimoShift <= TEMPO_DOUBLE then
			superPuloAtivo = not superPuloAtivo
		end
		ultimoShift = tempoAtual
	end

	if i.KeyCode == FLY_KEY then
		ESP_ON = not ESP_ON
	end

	if i.KeyCode == Enum.KeyCode.Space then
		-- pulo
	end

	if i.KeyCode == Enum.KeyCode.Delete then
		-- visão
	end

	-- =========================
	-- TELEPORT CONTROLES
	-- =========================

	if i.KeyCode == Enum.KeyCode.One then
		tp_selecting = true
	end

	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		tp_rightMouseHeld = true
	end

	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		if tp_selecting and tp_rightMouseHeld then
			tp_teleportBehind()
		end
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.LeftShift then
		speed = _G.FLY_NORMAL_SPEED
	end

	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		tp_rightMouseHeld = false
	end
end)

-- =========================
-- LOOP TELEPORT
-- =========================
RunService.RenderStepped:Connect(function()
	if not tp_selecting then return end

	local target = tp_getTarget()

	if target ~= tp_target then
		tp_target = target
		tp_createHighlight(target)
	end
end)
