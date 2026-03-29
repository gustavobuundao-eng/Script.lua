-- evita duplicação
if _G.AIM_PREDICT_ATIVO then return end
_G.AIM_PREDICT_ATIVO = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIG
local VELOCIDADE_PROJETIL = 300
local FOV = 8 -- 🔥 ultra preciso

local aiming = false
local lockedTarget = nil

-- 🎯 pegar alvo baseado no centro da tela
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

-- 🚀 PREDICT INTELIGENTE (corrigido pra qualquer distância)
function getPredictedPosition(target)
	if not target.Character then return nil end
	
	local hrp = target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	
	local pos = hrp.Position
	local vel = hrp.AssemblyLinearVelocity

	local distancia = (pos - Camera.CFrame.Position).Magnitude
	
	-- tempo base
	local tempoBase = distancia / VELOCIDADE_PROJETIL
	
	-- 🔥 ajuste por distância
	local multiplier
	if distancia < 50 then
		multiplier = 0.4
	elseif distancia < 150 then
		multiplier = 0.6
	else
		multiplier = 0.3
	end
	
	local tempo = tempoBase * multiplier
	
	-- 🔥 limite máximo pra não bugar longe
	local MAX_TEMPO = 0.35
	tempo = math.min(tempo, MAX_TEMPO)
	
	return pos + vel * tempo
end

-- 🖱️ botão direito
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		
		local target = getTargetFromCrosshair()
		
		-- 🎯 só ativa se já estiver mirando
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

-- 🔥 LOOP PRINCIPAL (LOCK BRUTAL)
RunService.RenderStepped:Connect(function()
	if not aiming then return end
	if not lockedTarget then return end
	
	local predictedPos = getPredictedPosition(lockedTarget)
	if not predictedPos then return end
	
	-- 🎯 mira 100% grudada no predict
	Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
end)
