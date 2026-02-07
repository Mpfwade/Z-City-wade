hook.Add("Org Think", "regenerationzombie", function(owner, org, timeValue)
	if not owner:IsPlayer() or not owner:Alive() then return end
	if owner.PlayerClassName != "zombie" then return end
	//if org.heartstop then return end

	org.blood = math.Approach(org.blood, 5000, timeValue * 60)

	for i, wound in pairs(org.wounds) do
		wound[1] = math.max(wound[1] - timeValue * 0.6,0)
	end
	
	for i, wound in pairs(org.arterialwounds) do
		wound[1] = math.max(wound[1] - timeValue * 0.6,0)
	end
	
	org.internalBleed = math.max(org.internalBleed - timeValue * 0.6, 0)
	
	local regen = timeValue / 60

	org.lleg = math.max(org.lleg - regen, 0)
	org.rleg = math.max(org.rleg - regen, 0)
	org.rarm = math.max(org.rarm - regen, 0)
	org.larm = math.max(org.larm - regen, 0)
	org.chest = math.max(org.chest - regen, 0)
	org.pelvis = math.max(org.pelvis - regen, 0)
	org.spine1 = math.max(org.spine1 - regen, 0)
	org.spine2 = math.max(org.spine2 - regen, 0)
	org.spine3 = math.max(org.spine3 - regen, 0)
	org.skull = math.max(org.skull - regen, 0)

	org.llegdislocation = false
	org.rlegdislocation = false
	org.rarmdislocation = false
	org.larmdislocation = false
	org.jawdislocation = false

	org.liver = math.max(org.liver - regen, 0)
	org.intestines = math.max(org.intestines - regen, 0)
	org.heart = math.max(org.heart - regen, 0)
	org.stomach = math.max(org.stomach - regen, 0)
	org.lungsR[1] = math.max(org.lungsR[1] - regen, 0)
	org.lungsL[1] = math.max(org.lungsL[1] - regen, 0)
	org.lungsR[2] = math.max(org.lungsR[2] - regen, 0)
	org.lungsL[2] = math.max(org.lungsL[2] - regen, 0)
	org.brain = math.max(org.brain - regen * 0.1, 0)

	org.hungry = 0
end)

hook.Add("PlayerDeath", "ZombieDeathSound", function(ply)
	if ply.PlayerClassName == "zombie" then
		ply:EmitSound("ambient/creatures/town_zombie_call1.wav")
	end
end)

local zom_pain = {
	"npc/fast_zombie/wake1.wav",
	"npc/fast_zombie/car_scream1.wav",
	"npc/fast_zombie/fz_scream1.wav",
	"npc/fast_zombie/fz_alert_close1.wav",
	"npc/antlion_grub/agrub_alert1.wav",
	"npc/antlion_grub/agrub_alert2.wav",
	"npc/antlion_grub/agrub_alert3.wav",
	"npc/barnacle/neck_snap1.wav",
	"npc/barnacle/neck_snap2.wav",
	"npc/zombie/zombie_die3.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain6.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_idle2.wav",
	"npc/zombie/zombie_die1.wav",
}

local zomspeak_phrases = {
	"breathing/agonalbreathing_1.wav",
	"breathing/agonalbreathing_2.wav",
	"breathing/agonalbreathing_3.wav",
	"breathing/agonalbreathing_4.wav",
	"breathing/agonalbreathing_5.wav",
	"breathing/agonalbreathing_6.wav",
	"breathing/agonalbreathing_7.wav",
	"breathing/agonalbreathing_8.wav",
	"breathing/agonalbreathing_9.wav",
	"npc/fast_zombie/wake1.wav",
	"npc/antlion_grub/agrub_alert1.wav",
	"npc/antlion_grub/agrub_alert2.wav",
	"npc/antlion_grub/agrub_alert3.wav",
	"npc/barnacle/neck_snap1.wav",
	"npc/barnacle/neck_snap2.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain6.wav",
	"npc/zombie/zombie_voice_idle6.wav",
}

hook.Add("HG_ReplacePhrase", "ZomPhrases", function(ent, phrase, muffed, pitch)
	if ent.PlayerClassName == "zombie" then
		local inpain = ent.organism.pain > 60
		local phr = (inpain and zom_pain[math.random(#zom_pain)] or zomspeak_phrases[math.random(#zomspeak_phrases)])

		return ent, phr, muffed, pitch
	end
end)

hook.Add("HG_ReplaceBurnPhrase", "ZomBurnPhrases", function(ply, phrase)
	if ply.PlayerClassName == "zombie" then
		return ply, zom_pain[math.random(#zom_pain)]
	end
end)

hook.Add("Org Think", "ItHurtsfrfr",function(owner, org, timeValue)
	if owner.PlayerClassName != "zombie" then return end

	if (owner.lastPainSoundCD or 0) < CurTime() and !org.otrub and org.pain >= 30 and math.random(1, 50) == 1 then
		local phrase = table.Random(zom_pain)

		local muffed = owner.armors["face"] == "mask2"

		owner:EmitSound(phrase, muffed and 65 or 75,owner.VoicePitch or 100,1,CHAN_AUTO,0, pitch and 56 or muffed and 16 or 0)

		owner.lastPainSoundCD = CurTime() + math.Rand(10, 25)
		owner.lastPhr = phrase
	end
end)

hook.Add("PlayerCanPickupWeapon", "ZomWeapons", function(ply, wep)
	if ply.PlayerClassName != "zombie" or (ply.PlayerClassName == "zombie" and IsValid(wep) and wep:GetClass() == "weapon_hands_sh") then
		return true
	else
		return false
	end
end)