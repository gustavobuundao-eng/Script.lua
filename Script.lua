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

-- =========================
-- CONFIG
-- =========================
local FLY_KEY = Enum.KeyCode.PageDown
local INVIS_KEY = Enum.KeyCode.LeftControl

_G.FLY_NORMAL_SPEED = 150
_G.FLY_SHIFT_SPEED = 1289

local ESP_ENABLED = true

-- invis config
local seatDistance = 50000000
local seatHeight = 50000000
local seatX = -25.95

-- pulo
local alturaPrimeiroPulo = 120

-- =========================
-- VARIÁVEIS
-- =========================
local flying = false
local invis = false
local speed = _G.FLY_NORMAL_SPEED
local ESP_ON = ESP_ENABLED

local primeiroPuloFeito = false

-- 🔥 NOVO: controle double shift
local superPuloAtivo = false
local ultimoShift = 0
local TEMPO_DOUBLE = 0.3

-- =========================
-- FUNÇÕES AUX
-- =========================
local function getHRP()
	return (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
end

-- =========================
-- FLY
-- =========================
if _G.FLY_LOOP then _G.FLY_LOOP:Disconnect() end

local function clearFly()
	for _,v in pairs(getHRP():GetChildren()) do
		if v.Name=="FlyForce" or v.Name=="FlyGyro" then
			v:Destroy()
		end
	end
end

local function startFly()
	local root = getHRP()

	local gyro = Instance.new("BodyGyro",root)
	gyro.Name="FlyGyro"
	gyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
	gyro.P=9e4

	local vel = Instance.new("BodyVelocity",root)
	vel.Name="FlyForce"
	vel.MaxForce=Vector3.new(9e9,9e9,9e9)

	_G.FLY_LOOP = RunService.RenderStepped:Connect(function()
		if not flying then return end

		local cam = workspace.CurrentCamera
		local move = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then move+=cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move-=cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move-=cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move+=cam.CFrame.RightVector end

		if move.Magnitude>0 then move=move.Unit end

		vel.Velocity = move*speed
		gyro.CFrame = cam.CFrame
	end)
end

local function stopFly()
	clearFly()
	if _G.FLY_LOOP then _G.FLY_LOOP:Disconnect() end
end

-- =========================
-- INVIS
-- =========================
local function toggleInvis()

	invis = not invis

	local char = LocalPlayer.Character
	local root = getHRP()

	if invis then
		flying = true
		startFly()

		local saved = root.CFrame

		char:MoveTo(Vector3.new(seatX,seatHeight,seatDistance))
		task.wait(.15)

		local seat = Instance.new("Seat",workspace)
		seat.Name="invischair"
		seat.Transparency=1
		seat.CanCollide=false
		seat.Position=Vector3.new(seatX,seatHeight,seatDistance)

		local weld = Instance.new("Weld",seat)
		weld.Part0=seat
		weld.Part1=char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

		task.wait()

		seat.CFrame = saved

	else
		local chair = workspace:FindFirstChild("invischair")
		if chair then chair:Destroy() end

		flying = false
		stopFly()
	end
end

-- =========================
-- ESP
-- =========================
local function getColorByHP(h, maxH)
	local percent = h / maxH
	if percent > 0.6 then
		return Color3.fromRGB(0,255,0)
	elseif percent > 0.4 then
		return Color3.fromRGB(255,255,0)
	elseif percent > 0.2 then
		return Color3.fromRGB(255,140,0)
	else
		return Color3.fromRGB(255,0,0)
	end
end

local function createESP(player,char)
	if player==LocalPlayer then return end

	local head = char:WaitForChild("Head")
	local hum = char:WaitForChild("Humanoid")

	local gui = Instance.new("BillboardGui",head)
	gui.Name="PlayerESP"
	gui.Size=UDim2.new(0,120,0,30)
	gui.StudsOffset=Vector3.new(0,2.5,0)
	gui.AlwaysOnTop=true

	local name = Instance.new("TextLabel",gui)
	name.Size=UDim2.new(1,0,.5,0)
	name.BackgroundTransparency=1
	name.Text=player.Name
	name.Font=Enum.Font.GothamBold
	name.TextSize=14
	name.TextStrokeTransparency = 0.5

	local hp = Instance.new("TextLabel",gui)
	hp.Size=UDim2.new(1,0,.5,0)
	hp.Position=UDim2.new(0,0,.5,0)
	hp.BackgroundTransparency=1
	hp.Font=Enum.Font.Gotham
	hp.TextSize=13
	hp.TextStrokeTransparency = 0.5

	task.spawn(function()
		while char.Parent and hum.Parent do
			gui.Enabled = ESP_ON

			local h = hum.Health
			local c = getColorByHP(h, hum.MaxHealth)

			name.TextColor3=c
			hp.TextColor3=c
			hp.Text=math.floor(h).." HP"

			task.wait(.2)
		end
	end)
end

local function setup(player)
	if player.Character then
		createESP(player,player.Character)
	end

	player.CharacterAdded:Connect(function(c)
		task.wait(1)
		createESP(player,c)
	end)
end

for _,p in ipairs(Players:GetPlayers()) do
	setup(p)
end

Players.PlayerAdded:Connect(setup)

-- =========================
-- PULO MANUAL
-- =========================
local function aplicarPuloManual()
	if not superPuloAtivo then return end

	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if not primeiroPuloFeito then
		hrp.Velocity = Vector3.new(hrp.Velocity.X, alturaPrimeiroPulo, hrp.Velocity.Z)
		primeiroPuloFeito = true
	end
end

local function resetarPulo()
	local char = LocalPlayer.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
		primeiroPuloFeito = false
	end
end

RunService.RenderStepped:Connect(resetarPulo)

-- =========================
-- VISÃO (CINZA + SILHUETA)
-- =========================
local color = Lighting:FindFirstChild("VisionEffect")

if not color then
	color = Instance.new("ColorCorrectionEffect")
	color.Name = "VisionEffect"
	color.Parent = Lighting
end

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://95234990836147"
sound.Volume = 1
sound.Parent = LocalPlayer:WaitForChild("PlayerGui")

local highlights = {}
local funcionando = false

local function criarSilhuetas()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local highlight = Instance.new("Highlight")
			highlight.Adornee = plr.Character
			highlight.FillColor = Color3.fromRGB(255,0,0)
			highlight.FillTransparency = 0.3
			highlight.OutlineTransparency = 0
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = plr.Character

			table.insert(highlights, highlight)
		end
	end
end

local function removerSilhuetas()
	for _, h in pairs(highlights) do
		if h then h:Destroy() end
	end
	highlights = {}
end

local function ativarVisao()
	if funcionando then return end
	funcionando = true

	sound:Play()
	criarSilhuetas()

	local tweenIn = TweenService:Create(color, TweenInfo.new(0.5), {
		Brightness = -0.3,
		Contrast = 0.5,
		Saturation = -1
	})
	tweenIn:Play()

	task.wait(5)

	local tweenOut = TweenService:Create(color, TweenInfo.new(0.5), {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	})
	tweenOut:Play()

	removerSilhuetas()
	funcionando = false
end

-- =========================
-- CONTROLES
-- =========================
UIS.InputBegan:Connect(function(i,g)
	if g then return end

	if i.KeyCode == INVIS_KEY then
		toggleInvis()
	end

	if i.KeyCode == Enum.KeyCode.LeftShift then
		
		speed = _G.FLY_SHIFT_SPEED
		
		local tempoAtual = tick()
		if tempoAtual - ultimoShift <= TEMPO_DOUBLE then
			superPuloAtivo = not superPuloAtivo
			print("Super Pulo:", superPuloAtivo and "ATIVADO" or "DESATIVADO")
		end
		
		ultimoShift = tempoAtual
	end

	if i.KeyCode == FLY_KEY then
		ESP_ON = not ESP_ON
	end

	if i.KeyCode == Enum.KeyCode.Space then
		aplicarPuloManual()
	end

	if i.KeyCode == Enum.KeyCode.Delete then
		ativarVisao()
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.LeftShift then
		speed = _G.FLY_NORMAL_SPEED
	end
end)

-- evita duplicação
if _G.AIM_PREDICT_ATIVO then return end
_G.AIM_PREDICT_ATIVO = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local VELOCIDADE_PROJETIL = 300
local FOV = 8

local aiming = false
local lockedTarget = nil

function getTargetFromCrosshair()
	local closest = nil
	local smallestAngle = FOV

	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			
			local hrp = v.Character.HumanoidRootPart
			local pos = hrp.Position
			
			local direction = (pos - Camera.CFrame.Position).Unit
			local dot = Camera.CFrame.LookVector:Dot(direction)
			local angle = math.deg(math.acos(dot))
			
			if angle < smallestAngle then
				smallestAngle = angle
				closest = v
			end
		end
	end

	return closest
end

function getPredictedPosition(target)
	if not target.Character then return nil end
	
	local hrp = target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	
	local pos = hrp.Position
	local vel = hrp.AssemblyLinearVelocity

	local distancia = (pos - Camera.CFrame.Position).Magnitude
	
	local tempoBase = distancia / VELOCIDADE_PROJETIL
	
	local multiplier
	if distancia < 50 then
		multiplier = 0.4
	elseif distancia < 150 then
		multiplier = 0.6
	else
		multiplier = 0.3
	end
	
	local tempo = tempoBase * multiplier
	
	local MAX_TEMPO = 0.35
	tempo = math.min(tempo, MAX_TEMPO)
	
	return pos + vel * tempo
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		
		local target = getTargetFromCrosshair()
		
		if target then
			aiming = true
			lockedTarget = target
		else
			aiming = false
			lockedTarget = nil
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
		lockedTarget = nil
	end
end)

RunService.RenderStepped:Connect(function()
	if not aiming then return end
	if not lockedTarget then return end
	
	local predictedPos = getPredictedPosition(lockedTarget)
	if not predictedPos then return end
	
	Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
end)
