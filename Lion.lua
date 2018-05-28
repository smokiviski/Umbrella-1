local LionAutoUlt = {}
LionAutoUlt.optionEnable = Menu.AddOptionBool({"Hero Specific","Lion"},"AutoUlt", false)

function LionAutoUlt.OnUpdate()
	if not Menu.IsEnabled(LionAutoUlt.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if not myHero then return end
	if not Entity.IsAlive(myHero) or NPC.IsStunned(myHero) or NPC.GetUnitName(myHero) ~= "npc_dota_hero_lion" then return end
	local dagon = NPC.GetAbility(myHero, "lion_finger_of_death")
	if dagon and Ability.IsReady(dagon) and Ability.GetManaCost(dagon) <= NPC.GetMana(myHero) then
        local damageDagon = 0
        if NPC.GetItem(myHero, "item_ultimate_scepter", true) then
            damageDagon = Ability.GetLevelSpecialValueForFloat(dagon, "damage_scepter")
        else
            damageDagon = Ability.GetLevelSpecialValueForFloat(dagon, "damage")
        end
        if Ability.GetLevel(NPC.GetAbility(myHero, "special_bonus_unique_lion_3")) == 1 then
            damageDagon = damageDagon + 200
        end
		for _,hero in pairs(Heroes.GetAll()) do
			if hero ~= nil and hero ~= 0 and NPCs.Contains(hero) and NPC.IsEntityInRange(myHero,hero,Ability.GetCastRange(dagon)) and not Entity.IsSameTeam(hero,myHero) then
				if Entity.IsAlive(hero) and not Entity.IsDormant(hero) and not NPC.IsIllusion(hero) and LionAutoUlt.IsHasGuard(hero) == "nil" then
					local totaldomage = LionAutoUlt.GetDamageDagon(myHero,hero,damageDagon)
					if Entity.GetHealth(hero) <= totaldomage then
						Ability.CastTarget(dagon, hero)
					end
				end
			end
		end
	end
end

function LionAutoUlt.GetDamageDagon(mynpc,target,dmg)
	if not mynpc or not target then return end
	local BuffDmg = 0
	BuffDmg = Hero.GetIntellectTotal(mynpc) * 0.0855
	if NPC.GetItem(mynpc, "item_kaya", true) then 
		BuffDmg = BuffDmg + 10 
	end
	local totaldomage = (dmg * NPC.GetMagicalArmorDamageMultiplier(target)) * (BuffDmg/100+1)
	local mana_shield = NPC.GetAbility(target, "medusa_mana_shield")
	if mana_shield and Ability.GetToggleState(mana_shield) then
			totaldomage = totaldomage * 0.4
	end
	if NPC.HasModifier(target,"modifier_ursa_enrage") then
		totaldomage = totaldomage * 0.2
	end
	local bristleback = NPC.GetAbility(target, "bristleback_bristleback")
	if bristleback and Ability.GetLevel(bristleback) ~= 0 then
		local vectortarget = Entity.GetAbsOrigin(target)
		local vectormy = Entity.GetAbsOrigin(Heroes.GetLocal())
		local taorig = Entity.GetRotation(target):GetYaw()
		local orig = -1 * (LionAutoUlt.Atan2(vectortarget:GetY()-vectormy:GetY(), vectortarget:GetX()-vectormy:GetX())/math.pi*180) + taorig
		if orig < 0 then orig = 360 + orig end
		if 110 < orig and orig < 250 then
			totaldomage = totaldomage
		elseif (70 < orig and orig <= 110) or (250 <= orig and orig < 290) then
			totaldomage = totaldomage * (1 - Ability.GetLevelSpecialValueFor(bristleback,"side_damage_reduction")/100)
		elseif (0 < orig and orig <= 70) or (290 <= orig and orig < 360) then
			totaldomage = totaldomage * (1 - Ability.GetLevelSpecialValueFor(bristleback,"back_damage_reduction")/100)
		end
	end
	return totaldomage
end

function LionAutoUlt.Atan2(y,x)
	if x > 0 then return math.atan(y/x) end
	if x < 0 and y >= 0 then return math.atan(y/x) + math.pi end
	if x < 0 and y < 0 then return math.atan(y/x) - math.pi end
	if x == 0 and y > 0 then return math.pi/2 end
	if x == 0 and y < 0 then return -1*(math.pi/2) end
	if x == 0 and y == 0 then return 0 end
end

function LionAutoUlt.IsHasGuard(npc)
	local guarditis = "nil"
	if NPC.IsLinkensProtected(npc) then guarditis = "Linkens" end
	if NPC.HasModifier(npc,"modifier_item_blade_mail_reflect") then guarditis = "BM" end
	local spell_shield = NPC.GetAbility(npc, "antimage_spell_shield")
	if spell_shield and Ability.IsReady(spell_shield) and (NPC.HasModifier(npc, "modifier_item_ultimate_scepter") or NPC.HasModifier(npc, "modifier_item_ultimate_scepter_consumed")) then
		guarditis = "Lotus"
	end
	if NPC.HasModifier(npc,"modifier_item_lotus_orb_active") then guarditis = "Lotus" end
	if 	NPC.HasState(npc,Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) or 
		NPC.HasState(npc,Enum.ModifierState.MODIFIER_STATE_OUT_OF_GAME) or
		NPC.HasModifier(npc,"modifier_medusa_stone_gaze_stone") or
		NPC.HasModifier(npc,"modifier_winter_wyvern_winters_curse") or
		NPC.HasModifier(npc,"modifier_templar_assassin_refraction_absorb") or
		NPC.HasModifier(npc,"modifier_nyx_assassin_spiked_carapace") or
		NPC.HasModifier(npc,"modifier_abaddon_borrowed_time") or
		NPC.HasModifier(npc,"modifier_item_aeon_disk_buff") or
		NPC.HasModifier(npc,"modifier_special_bonus_spell_block") then
			guarditis = "Immune"
	end
	if NPC.HasModifier(npc,"modifier_legion_commander_duel") then
		local duel = NPC.GetAbility(npc, "legion_commander_duel")
		if duel then
			if NPC.HasModifier(npc, "modifier_item_ultimate_scepter") or NPC.HasModifier(npc, "modifier_item_ultimate_scepter_consumed") then
				guarditis = "Immune"
			end
		else
			for _,hero in pairs(Heroes.GetAll()) do
				if hero ~= nil and hero ~= 0 and NPCs.Contains(hero) and not Entity.IsSameTeam(hero,npc) and NPC.HasModifier(hero,"modifier_legion_commander_duel") then
					local dueltarget = NPC.GetAbility(hero, "legion_commander_duel")
					if dueltarget then
						if NPC.HasModifier(hero, "modifier_item_ultimate_scepter") or NPC.HasModifier(hero, "modifier_item_ultimate_scepter_consumed") then
							guarditis = "Immune"
						end
					end
				end
			end
		end
	end
	local aeon_disk = NPC.GetItem(npc, "item_aeon_disk")
	if aeon_disk and Ability.IsReady(aeon_disk) then guarditis = "Immune" end
	return guarditis
end

return LionAutoUlt
