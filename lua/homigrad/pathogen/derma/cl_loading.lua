// yes i just vibecoded this shit, i hate derma someone else can make a better one idc.
local PANEL = {}

local gradient_l = Material("vgui/gradient-l")

surface.CreateFont("ZB_ZombieScream", {
	font = "Arial",
	size = ScreenScale(30),
	extended = true,
	weight = 900,
})

surface.CreateFont("ZB_ZombieText", {
	font = "Arial",
	size = ScreenScale(10),
	extended = true,
	weight = 700,
})

surface.CreateFont("ZB_ZombieSmall", {
	font = "Arial",
	size = ScreenScale(5),
	extended = true,
	weight = 400,
})

local darkred = Color(80, 0, 0)
local blood = Color(139, 0, 0)
local paleflesh = Color(180, 165, 140)

local sw, sh = ScrW(), ScrH()

function PANEL:Init()
	system.FlashWindow()

	self.progress = 0
	self.alpha = 255
	self.eyeOpen = 0
	self.blinkCycle = 0
	self.blinkSpeed = 0.3
	self.textShake = 0
	self.fadeProgress = 0
	
	self.blur = 10
	self.done = false
	
	-- Text shake intensity (decreases as you wake up)
	self:CreateAnimation(8, {
		index = 50,
		target = {
			textShake = 1
		},
		easing = "inOutQuad",
		bIgnoreConfig = true,
	})
	
	-- Initial eye opening (slow and struggling)
	self:CreateAnimation(3, {
		index = 1,
		target = {
			eyeOpen = 1
		},
		easing = "inOutQuad",
		bIgnoreConfig = true,
	})
	
	-- Start blinking cycle after initial opening
	timer.Simple(3, function()
		if !IsValid(self) then return end
		self:StartBlinkCycle()
	end)
	
	-- Progress through awakening stages
	timer.Simple(1, function()
		if !IsValid(self) then return end
		self:CreateAnimation(8, {
			index = 10,
			target = {
				progress = 1
			},
			easing = "inOutQuad",
			bIgnoreConfig = true,
			OnComplete = function()
				timer.Simple(0.5, function()
					if !IsValid(self) then return end
					self:Close()
				end)
			end
		})
	end)

	if IsValid(hg.zomload) then
		hg.zomload:Remove()
	end
	hg.zomload = self

	self:SetSize(sw, sh)
	self:RequestFocus()

	-- Zombie awakening sounds
	surface.PlaySound("cry1.wav")

	timer.Simple(0.5, function()
		surface.PlaySound("vomit/vomit1.mp3")
	end)
	
	timer.Simple(2, function()
		surface.PlaySound("player/zombie_head_explode_06.wav")
	end)
	
	timer.Simple(3.5, function()
		surface.PlaySound("gnisha_dickchoking_3.wav")
	end)
	
	timer.Simple(5, function()
		surface.PlaySound("gnisha_dickchoking_4.wav")
	end)

	self.AwakeningStage = 1
	
	local StageTimes = {
		1,   -- Darkness
		2,   -- First eye flutter
		3.5, -- Confusion
		5,   -- Realization
		6.5, -- Transformation complete
	}

	for k, v in ipairs(StageTimes) do
		timer.Simple(v, function()
			if IsValid(self) then
				self.AwakeningStage = k
			end
		end)
	end
end

function PANEL:StartBlinkCycle()
	if !IsValid(self) or self.done then return end
	
	-- Random blink
	local blinkDuration = math.Rand(0.1, 0.3)
	local nextBlinkDelay = math.Rand(1, 3)
	
	self:CreateAnimation(blinkDuration / 2, {
		index = 100 + CurTime(),
		target = {
			blinkCycle = 1
		},
		easing = "linear",
		bIgnoreConfig = true,
		OnComplete = function()
			self:CreateAnimation(blinkDuration / 2, {
				index = 101 + CurTime(),
				target = {
					blinkCycle = 0
				},
				easing = "linear",
				bIgnoreConfig = true,
			})
		end
	})
	
	timer.Simple(blinkDuration + nextBlinkDelay, function()
		self:StartBlinkCycle()
	end)
end

function PANEL:Close()
	self.done = true
	
	surface.PlaySound("ambient/creatures/town_zombie_call1.wav")

	-- Start gradual fade
	self:CreateAnimation(1.5, {
		index = 2,
		target = {
			fadeProgress = 1
		},
		easing = "inOutQuad",
		bIgnoreConfig = true,
	})

	timer.Simple(0.5, function()
		if !IsValid(self) then return end
		self:CreateAnimation(3, {
			index = 3,
			target = {
				alpha = 0
			},
			easing = "outCubic",
			bIgnoreConfig = true,
			Think = function()
				self:SetAlpha(self.alpha)
			end,
			OnComplete = function()
				self:Remove()
			end
		})
	end)
end

local blur = Material("pp/blurscreen")

-- Helper function to get shake offset
local function GetShakeOffset(intensity, seed)
	local time = CurTime() * 3
	local x = math.sin(time * 2.3 + seed) * intensity + math.cos(time * 1.7 + seed * 2) * intensity * 0.5
	local y = math.cos(time * 2.1 + seed) * intensity + math.sin(time * 1.9 + seed * 2) * intensity * 0.5
	return x, y
end

local AwakeningStages = {
	[1] = function(eyeOpenness, shakeIntensity, fadeAmount)
		-- Complete darkness, just starting to wake
		local x, y = GetShakeOffset(shakeIntensity * 20, 1)
		local alpha = (100 * eyeOpenness) * (1 - fadeAmount)
		draw.SimpleText("...", "ZB_ZombieText", sw * 0.5 + x, sh * 0.5 + y, ColorAlpha(darkred, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end,
	[2] = function(eyeOpenness, shakeIntensity, fadeAmount)
		-- First sensations
		local x1, y1 = GetShakeOffset(shakeIntensity * 30, 2)
		local x2, y2 = GetShakeOffset(shakeIntensity * 25, 3)
		local alpha1 = (150 * eyeOpenness) * (1 - fadeAmount)
		local alpha2 = (100 * eyeOpenness) * (1 - fadeAmount)
		
		draw.SimpleText("what...", "ZB_ZombieText", sw * 0.5 + x1, sh * 0.4 + y1, ColorAlpha(blood, alpha1), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("...am I?", "ZB_ZombieSmall", sw * 0.5 + x2, sh * 0.5 + y2, ColorAlpha(darkred, alpha2), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end,
	[3] = function(eyeOpenness, shakeIntensity, fadeAmount)
		-- Confusion and pain
		local x1, y1 = GetShakeOffset(shakeIntensity * 40, 4)
		local x2, y2 = GetShakeOffset(shakeIntensity * 35, 5)
		local alpha1 = (200 * eyeOpenness) * (1 - fadeAmount)
		local alpha2 = (150 * eyeOpenness) * (1 - fadeAmount)
		
		-- Add extra wobble to "HUNGRY"
		local wobbleX = math.sin(CurTime() * 5) * shakeIntensity * 15
		local wobbleY = math.cos(CurTime() * 4) * shakeIntensity * 10
		
		draw.SimpleText("HUNGRY", "ZB_ZombieText", sw * 0.5 + x1 + wobbleX, sh * 0.35 + y1 + wobbleY, ColorAlpha(blood, alpha1), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("so... hungry...", "ZB_ZombieSmall", sw * 0.5 + x2, sh * 0.45 + y2, ColorAlpha(darkred, alpha2), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end,
	[4] = function(eyeOpenness, shakeIntensity, fadeAmount)
		-- Transformation awareness
		local x1, y1 = GetShakeOffset(shakeIntensity * 50, 6)
		local x2, y2 = GetShakeOffset(shakeIntensity * 45, 7)
		local alpha1 = (255 * eyeOpenness) * (1 - fadeAmount)
		local alpha2 = (220 * eyeOpenness) * (1 - fadeAmount)
		
		-- Violent shaking for scream
		local violentX = math.random(-shakeIntensity * 30, shakeIntensity * 30)
		local violentY = math.random(-shakeIntensity * 20, shakeIntensity * 20)
		
		draw.SimpleText("RAAAGH", "ZB_ZombieScream", sw * 0.5 + x1 + violentX, sh * 0.3 + y1 + violentY, ColorAlpha(blood, alpha1), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("FEED", "ZB_ZombieText", sw * 0.5 + x2, sh * 0.5 + y2, ColorAlpha(blood, alpha2), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end,
	[5] = function(eyeOpenness, shakeIntensity, fadeAmount)
		-- Full zombie consciousness
		local x1, y1 = GetShakeOffset(shakeIntensity * 60, 8)
		local x2, y2 = GetShakeOffset(shakeIntensity * 40, 9)
		local alpha1 = (255 * eyeOpenness) * (1 - fadeAmount)
		local alpha2 = (255 * eyeOpenness) * (1 - fadeAmount)
		
		-- Extreme shaking and movement
		local crazyX = math.sin(CurTime() * 8) * shakeIntensity * 40 + math.random(-10, 10)
		local crazyY = math.cos(CurTime() * 6) * shakeIntensity * 30 + math.random(-10, 10)
		
		draw.SimpleText("GRAAAAAAHHH", "ZB_ZombieScream", sw * 0.5 + x1 + crazyX, sh * 0.4 + y1 + crazyY, ColorAlpha(blood, alpha1), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("MUST... FEED...", "ZB_ZombieText", sw * 0.5 + x2, sh * 0.6 + y2, ColorAlpha(darkred, alpha2), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end,
}

function PANEL:Paint()
	local eyeOpenness = self.eyeOpen * (1 - self.blinkCycle)
	local awakening = self.progress
	local shakeIntensity = math.max(0, 1 - self.textShake) -- Decreases as you wake up
	local fadeAmount = self.fadeProgress -- 0 to 1, increases when closing
	
	-- Black background (closed eyes)
	surface.SetDrawColor(0, 0, 0, 255 * (1 - eyeOpenness * 0.7 + fadeAmount * 0.7))
	surface.DrawRect(0, 0, sw, sh)
	
	-- Blood-red vignette (when eyes open)
	if eyeOpenness > 0 and fadeAmount < 0.9 then
		render.UpdateScreenEffectTexture()
		
		local vignetteIntensity = (1 - awakening) * 0.5
		DrawMotionBlur(0.4 * (1 - awakening) * (1 - fadeAmount), 0.8, 0.01)
		
		-- Reddish tint for zombie vision (fades out at end)
		local redTint = {
			["$pp_colour_addr"] = 0.15 * eyeOpenness * (1 - fadeAmount),
			["$pp_colour_addg"] = -0.1 * eyeOpenness * (1 - fadeAmount),
			["$pp_colour_addb"] = -0.1 * eyeOpenness * (1 - fadeAmount),
			["$pp_colour_brightness"] = -0.2 * (1 - awakening) - (fadeAmount * 0.5),
			["$pp_colour_contrast"] = 1 + (0.3 * awakening) * (1 - fadeAmount),
			["$pp_colour_colour"] = 0.5 + (0.5 * awakening) * (1 - fadeAmount),
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}
		DrawColorModify(redTint)
	end
	
	-- Eyelid effect (top and bottom closing)
	local eyelidHeight = sh * 0.5 * (1 - eyeOpenness + fadeAmount * 0.3)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(0, 0, sw, eyelidHeight) -- Top eyelid
	surface.DrawRect(0, sh - eyelidHeight, sw, eyelidHeight) -- Bottom eyelid
	
	-- Bloodshot/veiny effect on edges when eyes open (fades out at end)
	if eyeOpenness > 0.3 and fadeAmount < 0.7 then
		surface.SetDrawColor(blood.r, blood.g, blood.b, 100 * eyeOpenness * (1 - fadeAmount))
		for i = 1, 5 do
			local veinY = eyelidHeight + math.random(0, 50)
			surface.DrawRect(math.random(0, sw), veinY, math.random(2, 5), math.random(sh * 0.1, sh * 0.3))
		end
	end
	
	-- Awakening text with shake and fade
	if AwakeningStages[self.AwakeningStage] then
		AwakeningStages[self.AwakeningStage](eyeOpenness, shakeIntensity, fadeAmount)
	end
	
	-- Flesh tearing/transformation effect (screen shake simulation) - fades out at end
	if awakening < 0.7 and eyeOpenness > 0.5 and fadeAmount < 0.5 then
		local shake = math.sin(CurTime() * 20) * 10 * (1 - awakening)
		local tearAlpha = 200 * math.random() * (1 - fadeAmount * 2)
		draw.SimpleText("*TEAR*", "ZB_ZombieSmall", sw * 0.1 + shake, sh * 0.8, ColorAlpha(blood, tearAlpha), TEXT_ALIGN_LEFT)
		draw.SimpleText("*RIP*", "ZB_ZombieSmall", sw * 0.9 - shake, sh * 0.2, ColorAlpha(blood, tearAlpha), TEXT_ALIGN_RIGHT)
	end
	
	-- Gradual black overlay at the very end
	if fadeAmount > 0 then
		local finalFade = math.ease.InQuad(fadeAmount)
		surface.SetDrawColor(0, 0, 0, 255 * finalFade)
		surface.DrawRect(0, 0, sw, sh)
	end
end

hook.Add("RenderScreenspaceEffects", "zomload", function()
	if IsValid(hg.zomload) then
		local fadeAmount = hg.zomload.fadeProgress or 0
		local brightness = ((hg.zomload.alpha / 255) - 1) * (1 - fadeAmount)
		
		local tab = {
			["$pp_colour_brightness"] = brightness,
			["$pp_colour_contrast"] = 1 - (fadeAmount * 0.3),
			["$pp_colour_colour"] = 1 - (fadeAmount * 0.5),
		}
		DrawColorModify(tab)
	end
end)

hook.Add("ModifyTinnitusFactor", "zom", function(value)
	if IsValid(hg.zomload) then
		local fadeAmount = hg.zomload.fadeProgress or 0
		local modified = value + ((1 - hg.zomload.progress) * 50 * (1 - fadeAmount))
		return modified
	end
end)

vgui.Register("ZB_ZomLoading", PANEL, "EditablePanel")