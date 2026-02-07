-- brainnsssss the zombies theyre commmingggg

local function check(self, ent, ply)
	if not ply:ZCTools_GetAccess() then return false end
	if ( !IsValid( ent ) ) then return false end
	if ( ent:IsPlayer() ) then return true end
	local pEnt = hg.RagdollOwner( ent )
	if ( ent:IsRagdoll() ) and pEnt and pEnt:IsPlayer() and pEnt:Alive() then return true end
end

properties.Add( "zombify", {
	MenuLabel = "Zombify", -- Name to display on the context menu
	Order = 10.5, -- The order to display this property relative to other properties
	MenuIcon = "vgui/achievements/hl2_beat_cemetery_bw", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		if not self:Filter(ent, ply) then return end
		ent = hg.RagdollOwner(ent) or ent

		hg.Zombify(ent)
	end
} )

if CLIENT then -- also vibecoded ts lol
    local sw = ScrW()
    local sh = ScrH()
    local blood = Color(180, 0, 0)
    local darkRed = Color(120, 20, 20)
    
    surface.CreateFont("ZB_ZombieFloatingText", {
        font = "Arial",
        size = ScreenScale(15),
        extended = true,
        weight = 900,
    })
    
    surface.CreateFont("ZB_ZombieFloatingSmall", {
        font = "Arial",
        size = ScreenScale(8),
        extended = true,
        weight = 700,
    })
    
    -- Floating hunger text
    local floatingTexts = {}
    local lastTextSpawn = 0
    
    -- Blood smears (persistent)
    local bloodSmears = {}
    local lastSmearSpawn = 0
    
    local hungerPhrases = {
        "HUNGRY...",
        "FEED...",
        "FLESH...",
        "MEAT...",
        "BLOOD...",
        "CONSUME...",
        "DEVOUR...",
        "BITE...",
        "TEAR...",
        "CARVE...",
        "GRAAAHHH...",
        "NEED... FOOD...",
        "SO HUNGRY...",
        "MUST EAT...",
        "CRAVING...",
        "STARVING..."
    }
    
    hook.Add("RenderScreenspaceEffects", "zombot", function()
        if LocalPlayer().PlayerClassName != "zombie" then
            if IsValid(hg.matrix) then
                hg.matrix:Close()
            end
            floatingTexts = {}
            bloodSmears = {}
            return
        end
        
        local org = LocalPlayer().organism
        
        -- Show matrix when unconscious
        if org.otrub and !IsValid(hg.matrix) then
            vgui.Create("ZB_Matrix")
        elseif !org.otrub and IsValid(hg.matrix) then
            hg.matrix:Close()
        end
        
        -- Red overlay (zombie vision)
        local hungerLevel = math.Clamp((5000 - org.blood) / 5000, 0, 1)
        local visionIntensity = 0.15 + (hungerLevel * 0.25) -- Gets redder when hungry
        
        -- Pulsing effect based on hunger
        local pulse = math.abs(math.sin(CurTime() * (0.5 + hungerLevel * 2)))
        visionIntensity = visionIntensity + (pulse * hungerLevel * 0.1)
        
        -- Red tint for zombie vision
        DrawColorModify({
            ["$pp_colour_addr"] = visionIntensity,
            ["$pp_colour_addg"] = -visionIntensity * 0.1,
            ["$pp_colour_addb"] = -visionIntensity * 0.1,
            ["$pp_colour_brightness"] = -0.1,
            ["$pp_colour_contrast"] = 1.1,
            ["$pp_colour_colour"] = 0.2,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })
        
        -- Vignette effect (darker edges)
        local vignetteAlpha = 50 + (hungerLevel * 100)
        render.UpdateScreenEffectTexture()
        
        -- Draw red vignette
        surface.SetDrawColor(80, 0, 0, vignetteAlpha * pulse)
        -- Top
        local vignetteHeight = sh * 0.2
        for i = 0, vignetteHeight do
            local alpha = (vignetteHeight - i) / vignetteHeight * vignetteAlpha
            surface.SetDrawColor(60, 0, 0, alpha)
            surface.DrawRect(0, i, sw, 1)
        end
        -- Bottom
        for i = 0, vignetteHeight do
            local alpha = (vignetteHeight - i) / vignetteHeight * vignetteAlpha
            surface.SetDrawColor(60, 0, 0, alpha)
            surface.DrawRect(0, sh - i, sw, 1)
        end
        
        -- Spawn blood smears
        if CurTime() - lastSmearSpawn > 5 then
            local newSmear = {
                x = math.random(0, sw),
                y = math.random(0, sh),
                width = math.random(100, 400),
                height = math.random(5, 30),
                angle = math.random(-45, 45),
                alpha = math.random(10, 20),
                drips = {}
            }
            
            -- Add drips to smear
            local numDrips = math.random(2, 6)
            for i = 1, numDrips do
                table.insert(newSmear.drips, {
                    x = math.random(0, newSmear.width),
                    length = math.random(20, 100),
                    width = math.random(2, 6),
                    alpha = math.random(20, 60)
                })
            end
            
            table.insert(bloodSmears, newSmear)
            lastSmearSpawn = CurTime()
            
            -- Limit number of smears
            if #bloodSmears > 8 then
                table.remove(bloodSmears, 1)
            end
        end
        
        -- Draw blood smears
        for _, smear in ipairs(bloodSmears) do
            -- Main smear
            surface.SetDrawColor(100, 0, 0, smear.alpha)
            
            -- Rotate and draw smear
            local centerX = smear.x + smear.width / 2
            local centerY = smear.y + smear.height / 2
            
            -- Draw main smear body with irregular edges
            for i = 0, smear.height do
                local widthVar = math.sin(i / smear.height * math.pi) -- Makes it wider in middle
                local currentWidth = smear.width * widthVar
                local offset = math.random(-3, 3) -- Irregular edges
                surface.DrawRect(smear.x + offset, smear.y + i, currentWidth, 1)
            end
            
            -- Draw drips
            for _, drip in ipairs(smear.drips) do
                surface.SetDrawColor(80, 0, 0, drip.alpha)
                local dripX = smear.x + drip.x
                local dripY = smear.y + smear.height
                
                -- Draw drip as tapering line
                for i = 0, drip.length do
                    local taper = 1 - (i / drip.length)
                    local currentWidth = drip.width * taper
                    surface.DrawRect(dripX - currentWidth / 2, dripY + i, currentWidth, 1)
                end
            end
        end
        
        if IsValid(hg.zomload) and hg.zomload.alpha >= 255 then return end
        
        -- Spawn floating text
        local spawnRate = math.Clamp(2 - hungerLevel * 1.5, 0.3, 2) -- Spawn faster when hungry
        if CurTime() - lastTextSpawn > spawnRate then
            local newText = {
                text = table.Random(hungerPhrases),
                x = math.random(sw * 0.1, sw * 0.9),
                y = sh + 50, -- Start below screen
                targetY = math.random(sh * 0.2, sh * 0.8),
                speed = math.random(30, 80),
                alpha = 0,
                maxAlpha = math.random(150, 255),
                life = 0,
                maxLife = math.random(3, 6),
                shake = math.random(2, 8),
                drift = math.random(-20, 20),
                size = math.random(1, 2) == 1 and "ZB_ZombieFloatingText" or "ZB_ZombieFloatingSmall"
            }
            table.insert(floatingTexts, newText)
            lastTextSpawn = CurTime()
        end
        
        -- Update and draw floating texts
        for i = #floatingTexts, 1, -1 do
            local txt = floatingTexts[i]
            txt.life = txt.life + FrameTime()
            
            -- Move upward
            txt.y = txt.y - txt.speed * FrameTime()
            
            -- Drift sideways
            txt.x = txt.x + math.sin(txt.life * 2) * txt.drift * FrameTime()
            
            -- Fade in and out
            if txt.life < 0.5 then
                txt.alpha = (txt.life / 0.5) * txt.maxAlpha
            elseif txt.life > txt.maxLife - 1 then
                txt.alpha = ((txt.maxLife - txt.life) / 1) * txt.maxAlpha
            else
                txt.alpha = txt.maxAlpha
            end
            
            -- Remove if life expired
            if txt.life > txt.maxLife then
                table.remove(floatingTexts, i)
            else
                -- Draw with shake
                local shakeX = math.random(-txt.shake, txt.shake)
                local shakeY = math.random(-txt.shake, txt.shake)
                
                -- Shadow
                draw.SimpleText(txt.text, txt.size, txt.x + shakeX + 3, txt.y + shakeY + 3, ColorAlpha(color_black, txt.alpha * 0.8), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Main text
                local textColor = Color(
                    Lerp(hungerLevel, 180, 255),
                    Lerp(hungerLevel, 40, 0),
                    Lerp(hungerLevel, 40, 0)
                )
                draw.SimpleText(txt.text, txt.size, txt.x + shakeX, txt.y + shakeY, ColorAlpha(textColor, txt.alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Occasional glitch
                if math.random(1, 10) > 8 then
                    draw.SimpleText(txt.text, txt.size, txt.x + shakeX + math.random(-3, 3), txt.y + shakeY, ColorAlpha(textColor, txt.alpha * 0.5), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
        
        -- Brain damage effects
        if org.brain > 0.3 then
            local brainPulse = math.abs(math.sin(CurTime() * 5))
            DrawMotionBlur(0.2 * org.brain, 0.8, 0.02)
            
            -- Distortion text
            if math.random(1, 30) == 1 then
                local glitchText = table.Random({"IT HURTS", "PAIN", "GAHH", "HELP"})
                draw.SimpleText(glitchText, "ZB_ZombieFloatingSmall", math.random(0, sw), math.random(0, sh), ColorAlpha(blood, 200 * brainPulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        
        -- Critical blood loss - screen flashes
        if org.blood < 1000 then
            local flashAlpha = math.abs(math.sin(CurTime() * 6)) * 150
            surface.SetDrawColor(180, 0, 0, flashAlpha)
            surface.DrawRect(0, 0, sw, sh)
        end
    end)
end