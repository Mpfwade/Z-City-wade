// vibecode
local PANEL = {}
local sw, sh = ScrW(), ScrH()

surface.CreateFont("ZB_ZombieMatrix", {
	font = "Arial",
	size = ScreenScale(8),
	extended = true,
	weight = 900,
})

surface.CreateFont("ZB_ZombieMatrixSmall", {
	font = "Arial",
	size = ScreenScale(4),
	extended = true,
	weight = 700,
})

function PANEL:Init()
	self.dripsX = 60
	self.dripsY = 40
	
	self:SetSize(sw, sh)
	self:RequestFocus()
	
	if IsValid(hg.matrix) then
		hg.matrix:Remove()
	end
	hg.matrix = self
	
	-- Blood drip characters and disturbing text
	local zombieChars = {"▓", "▒", "░", "█", "╬", "╫", "╪", "┼", "┬", "┴", "├", "┤", "│", "─"}
	local fleshChars = {"FLESH", "BLOOD", "DEAD", "ROT", "DECAY", "BITE", "FEED", "MEAT", "BONE", "GORE"}
	
	self.TextArray = {}
	self.CharType = {} -- Track if it's a symbol or word
	for x = 1, self.dripsX do
		self.TextArray[x] = self.TextArray[x] or {}
		self.CharType[x] = self.CharType[x] or {}
		for y = 1, self.dripsY do
			if math.random(1, 8) == 1 then
				self.TextArray[x][y] = table.Random(fleshChars)
				self.CharType[x][y] = "word"
			else
				self.TextArray[x][y] = table.Random(zombieChars)
				self.CharType[x][y] = "symbol"
			end
		end
	end
	
	-- Blood drip speeds and positions
	self.DripSpeed = {}
	self.DripPosition = {}
	self.DripLength = {}
	for x = 1, self.dripsX do
		self.DripSpeed[x] = math.Rand(0.3, 1.5)
		self.DripPosition[x] = math.random(-self.dripsY, 0)
		self.DripLength[x] = math.random(8, 20)
	end
	
	-- Random flicker values
	self.RandomFlicker = {}
	for x = 1, self.dripsX do
		self.RandomFlicker[x] = self.RandomFlicker[x] or {}
		for y = 1, self.dripsY do
			self.RandomFlicker[x][y] = math.Rand(0, 1)
		end
	end
	
	-- Decay/corruption effect
	self.DecayProgress = 0
	self:CreateAnimation(15, {
		index = 5,
		target = {
			DecayProgress = 1
		},
		easing = "linear",
		bIgnoreConfig = true,
	})
	
	self.alpha = 0
	self:CreateAnimation(2, {
		index = 1,
		target = {
			alpha = 255
		},
		easing = "inOutQuad",
		bIgnoreConfig = true,
		Think = function()
			self:SetAlpha(self.alpha)
		end,
	})
	
	-- Play zombie ambience
	sound.PlayFile("sound/zbattle/zombie/ambience.ogg", "noblock", function(station)
		if IsValid(station) then
			station:SetVolume(0.3)
			station:Play()
			station:EnableLooping(true)
			self.AmbienceStation = station
		end
	end)
end

local darkRed = Color(100, 0, 0)
local blood = Color(139, 0, 0)
local freshBlood = Color(180, 0, 0)
local decay = Color(60, 80, 40)
local paleFlesh = Color(180, 165, 140)

function PANEL:Close()
	if IsValid(self.AmbienceStation) then
		self.AmbienceStation:Stop()
	end
	
	self:CreateAnimation(2, {
		index = 1,
		target = {
			alpha = 0
		},
		easing = "inOutQuad",
		bIgnoreConfig = true,
		Think = function()
			self:SetAlpha(self.alpha)
		end,
		OnComplete = function()
			self:Remove()
		end
	})
end

function PANEL:Paint()
	-- Dark reddish background with pulsing
	local pulse = math.abs(math.sin(CurTime() * 0.5))
	surface.SetDrawColor(10 + pulse * 5, 0, 0, 255)
	surface.DrawRect(0, 0, sw, sh)
	
	-- Update drip positions
	for x = 1, self.dripsX do
		self.DripPosition[x] = self.DripPosition[x] + self.DripSpeed[x] * FrameTime() * 60
		
		if self.DripPosition[x] > self.dripsY + self.DripLength[x] then
			self.DripPosition[x] = -self.DripLength[x]
			self.DripSpeed[x] = math.Rand(0.3, 1.5)
			self.DripLength[x] = math.random(8, 20)
		end
	end
	
	-- Draw blood drips
	for x = 1, self.dripsX do
		for y = 1, self.dripsY do
			local posX = (sw / self.dripsX) * (x - 1) + ScreenScale(2)
			local posY = (sh / self.dripsY) * (y - 1)
			
			if posY > sh or posY < 0 then continue end
			
			-- Calculate distance from drip head
			local distanceFromHead = y - self.DripPosition[x]
			
			-- Only draw if within drip length
			if distanceFromHead > 0 and distanceFromHead < self.DripLength[x] then
				-- Alpha based on position in drip (brightest at head)
				local dripAlpha = math.Clamp(1 - (distanceFromHead / self.DripLength[x]), 0, 1)
				
				-- Head of drip is brighter
				if distanceFromHead < 2 then
					dripAlpha = 1
				end
				
				-- Flicker effect
				local flicker = math.sin(CurTime() * 10 + self.RandomFlicker[x][y] * 10)
				dripAlpha = dripAlpha * (0.7 + flicker * 0.3)
				
				-- Color based on decay
				local color
				if self.DecayProgress > 0.7 then
					-- Later stage - more decay/green
					color = LerpVector(self.DecayProgress - 0.7, blood, decay)
				elseif distanceFromHead < 3 then
					-- Fresh blood at head
					color = freshBlood
				else
					-- Older blood in trail
					color = blood
				end
				
				-- Add random darker spots
				if math.random(1, 20) == 1 then
					color = darkRed
				end
				
				local finalAlpha = dripAlpha * 255 * (self.alpha / 255)
				
				-- Draw the character
				local font = self.CharType[x][y] == "word" and "ZB_ZombieMatrixSmall" or "ZB_ZombieMatrix"
				draw.SimpleText(
					self.TextArray[x][y], 
					font, 
					posX, 
					posY, 
					ColorAlpha(color, finalAlpha)
				)
				
				-- Glow effect on drip head
				if distanceFromHead < 2 then
					draw.SimpleText(
						self.TextArray[x][y], 
						font, 
						posX + 1, 
						posY + 1, 
						ColorAlpha(freshBlood, finalAlpha * 0.3)
					)
				end
			else
				-- Draw static corrupted background
				local staticAlpha = math.random(5, 30) * (self.DecayProgress * 0.5)
				if math.random(1, 3) == 1 then
					draw.SimpleText(
						self.TextArray[x][y], 
						"ZB_ZombieMatrix", 
						posX, 
						posY, 
						ColorAlpha(darkRed, staticAlpha)
					)
				end
			end
		end
	end
	
	-- Occasional blood splatter flashes
	if math.random(1, 100) == 1 then
		local splatterX = math.random(0, sw)
		local splatterY = math.random(0, sh)
		surface.SetDrawColor(freshBlood.r, freshBlood.g, freshBlood.b, 150)
		surface.DrawRect(splatterX, splatterY, math.random(50, 200), math.random(2, 10))
	end
	
	-- Disturbing text overlays based on decay
	if self.DecayProgress > 0.3 then
		local textAlpha = (self.DecayProgress - 0.3) * 200
		draw.SimpleText("HUNGRY", "ZB_ZombieMatrixSmall", sw * 0.1, sh * 0.2, ColorAlpha(blood, textAlpha * math.random(0.5, 1)))
	end
	
	if self.DecayProgress > 0.5 then
		local textAlpha = (self.DecayProgress - 0.5) * 200
		draw.SimpleText("FEED", "ZB_ZombieMatrixSmall", sw * 0.8, sh * 0.7, ColorAlpha(darkRed, textAlpha * math.random(0.5, 1)))
	end
	
	if self.DecayProgress > 0.7 then
		local textAlpha = (self.DecayProgress - 0.7) * 200
		local shake = math.random(-5, 5)
		draw.SimpleText("CONSUME", "ZB_ZombieMatrixSmall", sw * 0.5 + shake, sh * 0.5 + shake, ColorAlpha(freshBlood, textAlpha * math.random(0.5, 1)))
	end
	
	-- Vignette effect
	surface.SetDrawColor(0, 0, 0, 150)
	surface.DrawRect(0, 0, sw, sh * 0.1) -- Top
	surface.DrawRect(0, sh * 0.9, sw, sh * 0.1) -- Bottom
	surface.DrawRect(0, 0, sw * 0.05, sh) -- Left
	surface.DrawRect(sw * 0.95, 0, sw * 0.05, sh) -- Right
	
	if self:GetAlpha() <= 0 then
		self:Remove()
	end
end

function PANEL:Think()
	-- Randomly change some characters for corruption effect
	if math.random(1, 10) == 1 then
		local x = math.random(1, self.dripsX)
		local y = math.random(1, self.dripsY)
		
		local zombieChars = {"▓", "▒", "░", "█", "╬", "╫", "╪", "┼", "┬", "┴", "├", "┤", "│", "─"}
		local fleshChars = {"FLESH", "BLOOD", "DEAD", "ROT", "DECAY", "BITE", "FEED", "MEAT", "BONE", "GORE"}
		
		if math.random(1, 5) == 1 then
			self.TextArray[x][y] = table.Random(fleshChars)
			self.CharType[x][y] = "word"
		else
			self.TextArray[x][y] = table.Random(zombieChars)
			self.CharType[x][y] = "symbol"
		end
	end
end

vgui.Register("ZB_Zom_Matrix", PANEL, "EditablePanel")