
-- i copied the original star jug script for this and then modified it alot i made it the Givanium jug it can regen your health to 1000

local TweenService = game:GetService("TweenService")
local StarJug = game:GetObjects("rbxassetid://94180624435118")[1]
local light = StarJug:FindFirstChildOfClass("MeshPart"):FindFirstChildOfClass("PointLight")
local speedTweenValue = Instance.new("NumberValue", StarJug)
local sound = StarJug:FindFirstChildOfClass("MeshPart"):FindFirstChildOfClass("Sound")
local durability = 6
local debounce = false
StarJug:SetAttribute("Durability", durability)

StarJug.Parent = game.Players.LocalPlayer.Backpack

local character = game.Players.LocalPlayer.Character
local humanoid = character:FindFirstChildOfClass("Humanoid")

local Animations = StarJug:WaitForChild("Animations")
local LoadedAnims = {}

for _, anim in pairs(Animations:GetChildren()) do
	LoadedAnims[anim.Name] = humanoid:LoadAnimation(anim)

	if anim.Name == "idle" then
		LoadedAnims[anim.Name].Priority = Enum.AnimationPriority.Idle
		LoadedAnims[anim.Name].Looped = true
	end
end

StarJug.Equipped:Connect(function()
	LoadedAnims["equip"]:Play()

	task.wait(LoadedAnims["equip"].Length)

	if StarJug:IsDescendantOf(character) then
		LoadedAnims["idle"]:Play()
	end
end)

StarJug.Unequipped:Connect(function()
	sound:Pause()
	if LoadedAnims["idle"].IsPlaying then
		LoadedAnims["idle"]:Stop()
	end
end)

local collisionClone
StarJug.Activated:Connect(function()
	humanoid.MaxHealth = 1000
	humanoid.Health = 1000
	sound:Play()
	light.Enabled = true
	if debounce then return end
	debounce = true

	LoadedAnims["open"]:Play()

	if durability - 1 ~= 0 then
		durability = durability - 1
		StarJug:SetAttribute("Durability", durability)
	else
		StarJug:Destroy()
	end

	character:SetAttribute("Starlight", true)
	character:SetAttribute("StarlightHuge", false)

	local speedBoost, speedBoostFinished, mspaint_speed = 30, false, false
	if getgenv().mspaint_loaded then
		if collisionClone then collisionClone:Destroy() end
		mspaint_speed = true

		local originalSpeed = getgenv().Linoria.Toggles.SpeedBypass.Value
		repeat task.wait()
			if not getgenv().Linoria.Toggles.SpeedBypass.Value then
				getgenv().Linoria.Toggles.SpeedBypass:SetValue(true)
			end
		until speedBoostFinished
		getgenv().Linoria.Toggles.SpeedBypass:SetValue(originalSpeed)
	else
		if not collisionClone then
			collisionClone = character.Collision:Clone() do
				collisionClone.CanCollide = false
				collisionClone.Massless = true
				collisionClone.Name = "CollisionClone"
				if collisionClone:FindFirstChild("CollisionCrouch") then
					collisionClone.CollisionCrouch:Destroy()
				end

				collisionClone.Parent = character    
			end
		end

		task.spawn(function()
			while not speedBoostFinished do
				collisionClone.Massless = not collisionClone.Massless
				task.wait(0.21)
			end

			collisionClone.Massless = true
		end)
	end

	speedTweenValue.Value = 35
	TweenService:Create(speedTweenValue, TweenInfo.new(70, Enum.EasingStyle.Linear), {
		Value = 0
	}):Play()

	local conn; conn = speedTweenValue:GetPropertyChangedSignal("Value"):Connect(function()
		character:SetAttribute("SpeedBoost", speedTweenValue.Value)
	end)

	task.wait(5)
	light.Enabled = false
	
	speedBoostFinished = true
	conn:Disconnect()
	collisionClone:Destroy()

	character:SetAttribute("Starlight", false)
	character:SetAttribute("StarlightHuge", false)
	character:SetAttribute("SpeedBoost", 0)
	debounce = false
end)