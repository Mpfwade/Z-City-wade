local PANEL = {}

function PANEL:Init()
	if IsValid(zb.ZomBriefing) then
		zb.ZomBriefing:Remove()
	end

	zb.ZomBriefing = self
	self.alpha = 255

	self:SetSize(ScrW(), ScrH())

	self.dialogue = self:Add("ZB_DialogueZom")
	self.dialogue:SetPos(ScrW() / 2 - self.dialogue:GetWide() / 2, ScrH() / 2 - self.dialogue:GetTall() / 2)

	self.dialogue:SetText("SPREAD THE INFECTION, DEVOUR, EAT, FLESH, NOW..", 2)
	timer.Simple(15, function()
		if !IsValid(self) then return end
		self.dialogue:SetText("DON'T LET THEM KILL US, WE CANNOT FIZZLE OUT, SPREAD THE INFECTION, DEVOUR, EAT, FLESH...", 2)

		self:SetKeyboardInputEnabled(false)

		self:CreateAnimation(1, {
			index = 1,
			target = {
				alpha = 0
			},
			easing = "linear",
			bIgnoreConfig = true,
		})

		self.dialogue:CreateAnimation(1, {
			index = 1,
			target = {
				x = ScrW() * 0.07,
				y = ScrH() * 0.07
			},
			easing = "outQuint",
			bIgnoreConfig = true,
			Think = function()
				self.dialogue:SetPos(self.dialogue.x, self.dialogue.y)
			end
		})

		timer.Simple(3, function()
			if !IsValid(self) then return end
			self.dialogue:Close()
			timer.Simple(1, function()
				if !IsValid(self) then return end
				self:Remove()
			end)
		end)
	end)

	self:RequestFocus()
	self:MakePopup()

	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(false)

	sound.PlayFile("zcity_ost/uzelezz/final_heartbeat/ride.wav", "", function() end)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, self.alpha)
	surface.DrawRect(0, 0, w, h)

	-- RunConsoleCommand("soundfade", "100", "999")
end

vgui.Register("ZB_ZomZomBriefing", PANEL, "EditablePanel")