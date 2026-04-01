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

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =====================================================
-- ⚙️ CONFIG
-- =====================================================
local FLY_KEY = Enum.KeyCode.PageDown

_G.FLY_NORMAL_SPEED = 150
_G.FLY_SHIFT_SPEED = 1289

local TEMPO_DOUBLE = 0.3

-- =====================================================
-- 📊 ESTADOS
-- =====================================================
local flying = false
local speed = _G.FLY_NORMAL_SPEED

local superPuloAtivo = false
local ultimoShift = 0

-- =====================================================
-- 🔧 BASE
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

-- =====================================================
-- 🎮 INPUT
-- =====================================================
UIS.InputBegan:Connect(function(input, g)
	if g then return end

	-- FLY TOGGLE
	if input.KeyCode == FLY_KEY then
		flying = not flying
		if flying then
			startFly()
		end
	end

	-- SHIFT SPEED + DOUBLE SHIFT
	if input.KeyCode == Enum.KeyCode.LeftShift then
		local tempo = tick()
		if tempo - ultimoShift <= TEMPO_DOUBLE then
			superPuloAtivo = not superPuloAtivo
		end
		ultimoShift = tempo
		
		speed = _G.FLY_SHIFT_SPEED
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		speed = _G.FLY_NORMAL_SPEED
	end
end)
