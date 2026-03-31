-- =========================
-- TELEPORT SYSTEM (FINAL FIX)
-- =========================

local TP_FOV = 12
local TP_DISTANCIA = 5

local tp_selecting = false
local tp_target = nil
local tp_highlight = nil
local tp_rightMouseHeld = false

-- TARGET
local function tp_getTarget()
	local closest = nil
	local smallestAngle = TP_FOV

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			
			if hrp and hum and hum.Health > 0 then
				
				local direction = (hrp.Position - Camera.CFrame.Position).Unit
				local dot = Camera.CFrame.LookVector:Dot(direction)
				dot = math.clamp(dot, -1, 1)
				
				local angle = math.deg(math.acos(dot))
				
				if angle < smallestAngle then
					smallestAngle = angle
					closest = plr
				end
			end
		end
	end

	return closest
end

-- HIGHLIGHT
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

local function tp_disable()
	tp_selecting = false
	tp_target = nil
	
	if tp_highlight then
		tp_highlight:Destroy()
		tp_highlight = nil
	end
	
	tp_rightMouseHeld = false
end

-- TELEPORT
local function tp_teleport()
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

-- INPUT LIMPO
UIS.InputBegan:Connect(function(input, g)
	if g then return end

	if input.KeyCode == Enum.KeyCode.One then
		tp_selecting = true
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		tp_rightMouseHeld = true
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if tp_selecting and tp_rightMouseHeld then
			tp_teleport()
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		tp_rightMouseHeld = false
	end
end)

-- LOOP ISOLADO (NÃO CONFLITA)
RunService:BindToRenderStep("TP_SYSTEM", Enum.RenderPriority.Camera.Value + 1, function()
	if not tp_selecting then return end

	local target = tp_getTarget()

	if target ~= tp_target then
		tp_target = target
		tp_setHighlight(target)
	end
end)
