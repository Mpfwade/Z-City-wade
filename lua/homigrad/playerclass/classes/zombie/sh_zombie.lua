local CLASS = player.RegClass("zombie")

function CLASS.Off(self)
	if CLIENT then return end

	ApplyAppearance(self,false,false,false,true)

	-- if self.oldspeed then
	-- 	self:SetRunSpeed(self.oldspeed)
	-- 	self.oldspeed = nil
	-- end

	if SERVER then
		self.organism.bloodtype = self.oldbloodtype or "o-"
		
		hg.ClearArmorRestrictions(self)
	end

	self.JumpPowerMul = nil
	self.SpeedGainClassMul = nil
	self:SetNWInt("SpeedGainClassMul", nil)
	self.MeleeDamageMul = nil
	self.StaminaExhaustMul = nil
end

local sw, sh = CLIENT and ScrW() or nil, CLIENT and ScrH() or nil

local oneofus = {
	"MUST CONSUME! INFECT.",
	"MORE MEAT!",
	"FUCKING MORE!",
	"THIS WILL DO!",
	"KEEP CONSUMING!",
	"IT'S NOT ENOUGH...",
	"KEEP EXPANDING!"
}

local function Randomize(self)
	if SERVER then
		local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
		Appearance.AAttachments = ""
		Appearance.AColthes = ""
		local plycolor = Color(Appearance.AColor.r, Appearance.AColor.g, Appearance.AColor.b)

		self:SetNetVar("Accessories", "")

		self.CurAppearance = Appearance
	end
end

CLASS.NoGloves = true
local col1 = Color(139, 52, 43)
if CLIENT then
	surface.CreateFont("ZB_ProotOSChat", {
		font = "Ari-W9500",
		size = ScreenScale(4),
		extended = true,
		weight = 400,
	})
end

function CLASS.On(self, data)
	if SERVER then
		if eightbit and eightbit.EnableEffect and self.UserID then
            eightbit.EnableEffect(self:UserID(), eightbit.EFF_MASKVOICE)
		end

		if self.organism then
			self.oldbloodtype = self.organism.bloodtype
			self.organism.bloodtype = "c-"
		end

		local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()

		local name = "Patient #" .. math.random(1, 999)

		self:SetNWString("PlayerName", name)
		Appearance.AName = name

		hg.SetArmorRestrictions(self, {all = true})
	end

	if data.instant then
		if SERVER then
			-- self.oldspeed = self:GetRunSpeed()
			-- self:SetRunSpeed(3000)
			self.JumpPowerMul = 2
			self.StaminaExhaustMul = 0.3
			self.SpeedGainClassMul = 2

			zb.GiveRole(self, "Zombie", col1)

		if zb.GetWorldSize() >= ZBATTLE_BIGMAP then 
			self.JumpPowerMul = self.JumpPowerMul * 1
			self.SpeedGainClassMul = self.SpeedGainClassMul * 2
			self:SetNWInt("SpeedGainClassMul", self.SpeedGainClassMul)
			self.StaminaExhaustMul = self.StaminaExhaustMul * 0.5
		end
	end

		self:SetModel("models/player/zombie_fast.mdl")

		self:SetSubMaterial()

		if self.SetNetVar then
			self:SetNetVar("Accessories", "")
		end

		Randomize(self)

		for i = 1, self:GetFlexNum() - 1 do
			self:SetFlexWeight(i, 0)
		end

		return
	end

	hook.Run("HG_OnInfection", self)
	-- Randomize(self)

	if CLIENT then
		if lply == self then
			vgui.Create("ZB_ZomLoading")
			-- atlaschat.font:SetString("ZB_ProotOSChat")
		end

		//local ent = hg.GetCurrentCharacter(self)

		if IsValid(self.mdlzom) then
			self.mdlzom:Remove()
		end

		self.mdlzom = ClientsideModel("models/player/zombie_fast.mdl")
		self.mdlzom.GetPlayerColor = function() return self:GetPlayerColor() end
		local mdl = self.mdlzom
		mdl:SetNoDraw(true)

		hg.infecting[self] = CurTime()


		return
	else
		-- self.oldspeed = self:GetRunSpeed()
		-- self:SetRunSpeed(3000)
		self.JumpPowerMul = 1.5
		self.SpeedGainClassMul = 5
		self:SetNWInt("SpeedGainClassMul", self.SpeedGainClassMul)
		self.StaminaExhaustMul = 0.75

		hg.SetArmorRestrictions(self, {all = true})

		if zb and zb.GiveRole then zb.GiveRole(self, "Zombie", col1) end

		for _, v in player.Iterator() do
			if math.random(1, 3) == 1 then
				if v:Alive() and v.PlayerClassName == "zombie" and self:GetPos():Distance(v:GetPos()) < 256 and v != self then
					v:Notify(table.Random(oneofus))
				end
			end
		end
	end

	-- self:SetNWString("PlayerName", rank .. " " .. Appearance.AName)

	hg.Fake(self, nil, true)
	timer.Create("zombie"..self:EntIndex(), 1.6, 1, function()
		if IsValid(self) then
			hg.SavePoses(self)
			hg.FakeUp(self, true, true)

			self:SetModel("models/player/zombie_fast.mdl")

			self:SetSubMaterial()

			if self.SetNetVar then
				self:SetNetVar("Accessories", "")
			end

			Randomize(self)

			for i = 1, self:GetFlexNum() - 1 do
				self:SetFlexWeight(i, 0)
			end

			hg.Fake(self, nil, true)
			hg.ApplyPoses(self)

			hg.organism.Clear( self.organism )

			if self.organism then
				self.oldbloodtype = self.organism.bloodtype
				self.organism.bloodtype = "c-"
			end
		end
	end)
end

--[[
local zombified = 0
local alpha = 0

function CLASS.HUDPaint(self)
	if !self:Alive() then return end
	print("FUCKUFJVFJN FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK")
	local sw, sh = ScrW(), ScrH()
	local carryent = lply.GetNetVar and lply:GetNetVar("carryent") or nil

	zombified = Lerp(FrameTime(), zombified, lply:GetLocalVar("zombified", 0))
	alpha = LerpFT(0.1, alpha, IsValid(carryent) and carryent.organism and carryent.organism.alive and carryent.organism.owner.PlayerClassName != "zombie" and hg.KeyDown(lply, IN_ATTACK) and 255 or 0)

	-- Shadow
	surface.SetFont("CloseCaption_Italic")
	surface.SetTextColor(50, 50, 50, alpha)
	local txt = "Mutilating..."
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(sw * 0.5 - w * 0.5 + 2, sh * 0.75 - h - ScreenScale(5) + 2)
	surface.DrawText(txt)

	-- Fill effect with scissor rect
	render.SetScissorRect(0, sh * 0.75 - (zombified * ScreenScale(20)), sw, sh, true)
		surface.SetFont("CloseCaption_Italic")
		surface.SetTextColor(180, 0, 0, alpha)
		surface.PlaySound("buttons/combine_button5.wav")
		local txt = "Mutilating..."
		local w, h = surface.GetTextSize(txt)
		surface.SetTextPos(sw * 0.5 - w * 0.5, sh * 0.75 - h - ScreenScale(5))
		surface.DrawText(txt)
	render.SetScissorRect(0, 0, 0, 0, false)
end
--]] -- todo: make this fucking shit work

function CLASS.Guilt(self, victim)
    if victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
end

local rnd1 = math.Rand(1, 999)
local rnd2 = math.Rand(1, 999)
local rnd3 = math.Rand(1, 999)
local rnd4 = math.Rand(1, 999)

local amount = 0.4

if CLIENT then
	local scancolor = Color(104, 126, 65)

	local SPHERE_NUMBER_RULES = {[0]=2,[1]=1,[3]=2,[5]=1,[7]=2,[9]=1}

	local function isInSphere(ent, spherePos, radius)
		if not IsValid(ent) then return false end
		local entPos = ent:GetPos()
		return entPos:DistToSqr(spherePos) <= radius * radius
	end

	local ds = 0

	function BorderSphereUnit(color, pos, radius, detail, thickness)
		radius = math.floor(radius)
		thickness = math.floor(thickness or 24)
		detail = math.min(math.floor(detail or 32), 100)

		if thickness >= radius then
			thickness = radius
		end

		local lastDigit = tonumber(string.sub(tostring(radius), -1))
		local rule = SPHERE_NUMBER_RULES[lastDigit]
		if rule == 1 then
			ds = 1
		elseif rule == 2 then
			ds = 0.50
		end

		local view = render.GetViewSetup(true)
		local cam_pos, cam_angle = view.origin, view.angles

		local cam_normal = cam_angle:Forward()

		render.SetStencilEnable(true)

		render.ClearStencil()

		render.SetStencilReferenceValue(0x55)
		render.SetStencilTestMask(0x1C)
		render.SetStencilWriteMask(0x1C)
		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.SetStencilCompareFunction( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )

		render.SetColorMaterial()
		local detailWithDs = detail + ds
		local radiusMinusThickness = radius - thickness

		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilZFailOperation(STENCIL_INVERT)

		local invisibleColor = Color(0, 0, 0, 0)
		render.DrawSphere(pos, -radius, detail, detail, invisibleColor)
		render.DrawSphere(pos, radius, detail, detail, invisibleColor)
		render.DrawSphere(pos, -radiusMinusThickness, detailWithDs, detailWithDs, invisibleColor)
		render.DrawSphere(pos, radiusMinusThickness, detailWithDs, detailWithDs, invisibleColor)

		render.SetStencilZFailOperation(STENCIL_REPLACE)
		render.DrawSphere(pos, radius + 0.25, detailWithDs, detailWithDs, invisibleColor)

		render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
		
		cam.IgnoreZ(true)

		render.SetStencilReferenceValue(1)
		render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal, 10000, 10000, color, cam_angle.roll)

		cam.IgnoreZ(false)

		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.SetStencilCompareFunction( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilTestMask(0xFF)
		render.SetStencilWriteMask(0xFF)
		render.SetStencilReferenceValue(0)

		render.ClearStencil()

		render.SetStencilEnable(false)
	end

	local scanRadius = 0
	local scan = false
	local scanPos = Vector()

	local scanCD = 0

	local foundPrey = {}

	hook.Add("PostDrawTranslucentRenderables", "SmellPrey", function()
		if scan then
			scanRadius = math.Approach(scanRadius, 100000, FrameTime() * 1000)
			BorderSphereUnit(ColorAlpha(scancolor, 255 - (math.min(scanRadius / 30, 255))), scanPos, scanRadius, 32, scanRadius / 30)

			for _, ply in player.Iterator() do
				if ply == lply then continue end

				if isInSphere(ply, scanPos, scanRadius) and !foundPrey[ply] and ply:Alive() then
					local color
					if ply.PlayerClassName != "zombie" then
						local weaponry = ply:GetWeapons()
						local armed = false
						for _, v in ipairs(weaponry) do
							if ishgweapon(v) then
								armed = true
								break
							end
						end

						if armed then
							color = Color(255 - math.min(255, scanRadius / 150), 0 + math.min(255, scanRadius / 500), 0 + math.min(255, scanRadius / 500))
						else
							color = Color(255 - math.min(255, scanRadius / 150), 200 - math.min(255, scanRadius / 150), 0 + math.min(255, scanRadius / 500))
						end
					else
						color = scancolor
					end

					foundPrey[ply] = {
						pos = ply:GetPos(),
						color = color,
						time = CurTime() + 5
					}

					surface.PlaySound("npc/ichthyosaur/water_growl5.wav")
				end
			end
		else
			scanRadius = 0
		end
	end)

	local glow = Material("sprites/light_ignorez")

	hook.Add("HUDPaint", "SmellFindPrey", function()
		if lply.PlayerClassName != "zombie" then return end

		-- PrintTable(foundPrey)

		local scrW, scrH = ScrW(), ScrH()

		for _, v in pairs(foundPrey) do
			local screenPosition = v.pos:ToScreen()

			local marginX, marginY = scrH * .1, scrH * .1
			local x, y = math.Clamp(screenPosition.x, marginX, scrW - marginX), math.Clamp(screenPosition.y, marginY, scrH - marginY)

			local size = 100

			surface.SetDrawColor(ColorAlpha(v.color, math.max(0, (v.time - CurTime()) * 100)))
			surface.SetMaterial(glow)
			surface.DrawTexturedRect(x - size / 2, y - size / 2, size, size)
		end
	end)

	local function smellForPrey()
		if scanCD > CurTime() then
			return
		end

		surface.PlaySound("zbattle/charge.wav")

		scanCD = CurTime() + 20

		timer.Simple(2.5, function()
			scanRadius = 0
			foundPrey = {}
			scanPos = lply:EyePos()

			scan = true

			timer.Simple(5, function()
				fadeGoal = 0
			end)

			timer.Simple(20, function()
				scan = false
				foundPrey = {}

				surface.PlaySound("ambient/voices/squeal1.wav")
			end)

			surface.PlaySound("npc/ichthyosaur/water_growl5.wav")

			for i = 1, 30 do
				timer.Simple(i/60,function()
					ViewPunch(AngleRand(-.3,.3))
				end)
			end
		end)
	end

	hook.Add("radialOptions", "smellprey", function()
		if LocalPlayer():Alive() and LocalPlayer().PlayerClassName == "zombie" then
			hg.radialOptions[#hg.radialOptions + 1] = {smellForPrey, "Echo Locate"}
		end
	end)

	local slime = Material("nature/toxicslime002a")

	hg.infecting = hg.infecting or {}

	local validBones = {
		["ValveBiped.Bip01_Pelvis"] = true,
		["ValveBiped.Bip01_Spine1"] = true,
		["ValveBiped.Bip01_Spine2"] = true,
		["ValveBiped.Bip01_R_Clavicle"] = true,
		["ValveBiped.Bip01_L_Clavicle"] = true,
		["ValveBiped.Bip01_R_UpperArm"] = true,
		["ValveBiped.Bip01_L_UpperArm"] = true,
		["ValveBiped.Bip01_L_Forearm"] = true,
		["ValveBiped.Bip01_L_Hand"] = true,
		["ValveBiped.Bip01_R_Forearm"] = true,
		["ValveBiped.Bip01_R_Hand"] = true,
		["ValveBiped.Bip01_R_Thigh"] = true,
		["ValveBiped.Bip01_R_Calf"] = true,
		["ValveBiped.Bip01_Head1"] = true,
		["ValveBiped.Bip01_Neck1"] = true,
		["ValveBiped.Bip01_L_Thigh"] = true,
		["ValveBiped.Bip01_L_Calf"] = true,
		["ValveBiped.Bip01_L_Foot"] = true,
		["ValveBiped.Bip01_R_Foot"] = true
	}

	function DrawInfection(ent, ply)
		if !hg.infecting[ply] then
			if IsValid(ply.mdlzom) then
				ply.mdlzom:Remove()
			end

			return
		end
		
		local time = hg.infecting[ply]

		if !IsValid(ent) then
			hg.infecting[ply] = nil

			return
		end
		
		local status = math.ease.OutSine(1 - math.Clamp((time - CurTime() + 3) / 3, 0, 1))
		
		if status == 1 then
			hg.infecting[ply] = nil
			
			if IsValid(ply.mdlzom) then
				ply.mdlzom:Remove()
			end

			return
		end
		
		render.SetStencilEnable( true )

		render.ClearStencil()
		render.SetStencilTestMask( 255 )
		render.SetStencilWriteMask( 255 )
		render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilCompareFunction( STENCILOPERATION_KEEP )
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )

		render.SetStencilReferenceValue( 1 )
		render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

		if IsValid(ent) then
			ent:DrawModel()
		end

		render.SetStencilReferenceValue( 2 )

		render.SetMaterial(slime)
		local pos = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation()
		render.DrawSphere(pos, 48 * math.max(status - 0.3, 0), 32, 32, Color(255, 0, 0))
		local pos = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine1")):GetTranslation()
		render.DrawSphere(pos, 48 * math.max(status - 0.4, 0), 32, 32, Color(255, 0, 0))
		local pos = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_L_Foot")):GetTranslation()
		render.DrawSphere(pos, 48 * math.max(status - 0.7, 0), 32, 32, Color(255, 0, 0))
		local pos = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Foot")):GetTranslation()
		render.DrawSphere(pos, 48 * math.max(status - 0.2, 0), 32, 32, Color(255, 0, 0))
		//render.DrawSphere(pos + VectorRand(-16, 16), 64 * status, 32, 32, color_white)

		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.SetStencilReferenceValue( 2 )

		render.DepthRange( 0, 1 )

		if IsValid(ply.mdlzom) then
			local mdl = ply.mdlzom
			mdl:SetPos(ent:GetPos())
			mdl:SetupBones()
			ent:SetupBones()
			//PrintBones(mdl)
			/*for i = 0, mdl:GetBoneCount() - 1 do
				local bon = ent:LookupBone(mdl:GetBoneName(i))
				if !bon then continue end
				local m1 = mdl:GetBoneMatrix(i)
				local m2 = ent:GetBoneMatrix(bon)

				if !m1 or !m2 then continue end
				
				local q1 = Quaternion()
				q1:SetMatrix(m1)

				local q2 = Quaternion()
				q2:SetMatrix(m2)
				local q3 = q1:SLerp(q2, status)

				local newmat = Matrix()
				newmat:SetTranslation(LerpVector(status, m1:GetTranslation(), m2:GetTranslation()))
				newmat:SetAngles(q3:Angle())

				hg.bone_apply_matrix(ent, i, newmat)
				//hg.bone_apply_matrix(mdl, i, newmat)
			end*/
			for i = 0, mdl:GetBoneCount() - 1 do
				local nam = ent:GetBoneName(i)
				if !validBones[nam] then continue end
				local bon = mdl:LookupBone(nam)
				if !bon then continue end
				local m1 = ent:GetBoneMatrix(i)

				hg.bone_apply_matrix(mdl, bon, m1)
			end
			//ent:DrawModel()
			mdl:DrawModel()
		end

		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL )

		ent:DrawModel()
		
		

		render.DepthRange( 0, 1 )
		
		render.SetStencilWriteMask( 0xFF )
		render.SetStencilTestMask( 0xFF )
		render.SetStencilReferenceValue( 0 )
		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.ClearStencil()

		render.SetStencilEnable( false )
	end
end

// stripped from combine playerclass
if CLIENT then
    local pnv_enabled = false
    local next_toggle_time = 0
    local toggle_cooldown = 1
    local transition_time = 1
    local transition_start = 0
    local transitioning = false
    local pnv_light = nil

    local pnv_color_1 = {
        ["$pp_colour_addr"] = 0.1,
        ["$pp_colour_addg"] = 0.07,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0.01,
        ["$pp_colour_contrast"] = 1.5,
        ["$pp_colour_colour"] = 0.3,
        ["$pp_colour_mulr"] = 0.2,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    local function togglePNV()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "zombie" or not ply:Alive() then
            if pnv_enabled then
                pnv_enabled = false
                surface.PlaySound("homigrad/suffocation_free.wav")
                hook.Remove("RenderScreenspaceEffects","PNV_ColorCorrectionZombie")
                if IsValid(pnv_light) then
                    pnv_light:Remove()
                    pnv_light = nil
                end
            end
            return
        end

        pnv_enabled = not pnv_enabled
        transition_start = CurTime()

        if pnv_enabled then
            transitioning = true
            surface.PlaySound("gnisha_dickchoking_5.wav")
            hook.Add("RenderScreenspaceEffects","PNV_ColorCorrectionZombie",function()
                if ply.PlayerClassName ~= "zombie" then return end
                local progress = math.min((CurTime() - transition_start)/transition_time,1)
                local cc = table.Copy(pnv_color_1)
                for k,v in pairs(cc) do
                    cc[k] = v * progress
                end
                DrawColorModify(cc)
                DrawBloom(0.1*progress,1*progress,2*progress,2*progress,1*progress,0.4*progress,1,1,1)
                if progress >= 1 then transitioning = false end
            end)
        else
            transitioning = false
            surface.PlaySound("homigrad/suffocation_free.wav")
            hook.Remove("RenderScreenspaceEffects","PNV_ColorCorrectionZombie")
        end
    end

    hook.Add("RenderScreenspaceEffects","PNV_ColorCorrectionZombie",function()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "zombie" then return end
        if pnv_enabled then
            local cc = pnv_color_1
            DrawColorModify(cc)
            DrawBloom(0.1,0.5,2,2,1,0.4,1,1,1)
        end
    end)

    hook.Add("PreDrawHalos","PNV_LightZombie",function()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "zombie" then return end
        if pnv_enabled then
            if not IsValid(pnv_light) then
                pnv_light = ProjectedTexture()
                pnv_light:SetTexture("effects/flashlight001")
                pnv_light:SetBrightness(2)
                pnv_light:SetEnableShadows(false)
                pnv_light:SetConstantAttenuation(0.02)
                pnv_light:SetNearZ(12)
                pnv_light:SetFOV(70)
            end
            pnv_light:SetPos(ply:EyePos())
            pnv_light:SetAngles(ply:EyeAngles())
            pnv_light:Update()
        elseif IsValid(pnv_light) then
            pnv_light:Remove()
            pnv_light = nil
        end
    end)

    hook.Add("Think","PNV_ThinkZombie",function()
        local ply = LocalPlayer()
        if ply:Alive() and ply.PlayerClassName == "zombie" then
            if input.IsKeyDown(KEY_F) and not gui.IsGameUIVisible() and not IsValid(vgui.GetKeyboardFocus()) and (CurTime() > next_toggle_time) then
                togglePNV()
                next_toggle_time = CurTime() + toggle_cooldown
            end
        end
        if not ply:Alive() and pnv_enabled then togglePNV() end
        if ply.PlayerClassName ~= "zombie" and pnv_enabled then togglePNV() end

        if pnv_enabled and IsValid(pnv_light) then
            pnv_light:SetPos(ply:EyePos())
            pnv_light:SetAngles(ply:EyeAngles())
            pnv_light:Update()
        end
    end)
end