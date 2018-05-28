local AutoDisabler2 = {}
AutoDisabler2.optionEnable = Menu.AddOptionBool({"Utility","AutoDisabler2"},"Enabled", false)
AutoDisabler2.LionHex = Menu.AddOptionBool({"Utility","AutoDisabler2"},"LionHex", false)
AutoDisabler2.ShadowShamanHex = Menu.AddOptionBool({"Utility","AutoDisabler2"},"ShadowShamanHex", false)
AutoDisabler2.itemOrchid = Menu.AddOptionBool({"Utility","AutoDisabler2"},"Orchid", false)
AutoDisabler2.itemMegaOrchid = Menu.AddOptionBool({"Utility","AutoDisabler2"},"Bloodthorn", false)
AutoDisabler2.itemHex = Menu.AddOptionBool({"Utility","AutoDisabler2"},"Scythe Of Vyse", false)
AutoDisabler2.anims = {"ravage_anim","cast4_black_hole_anim","polarity_anim","chronosphere_anim","cast_doom_anim","legion_commander_duel_anim","cast4_primal_roar_anim","cast_guardianAngel_anim","cast5_Overgrowth_anim","sand_king_epicast_anim","luna_eclipse_anim","cast4_gyroshell_cast_short","cast4_sirenSong_anim","mk_cast_fur_army_cp","cast_ulti_anim","sunder","demon_sunder","cast_ulti_anim","cast5_handofgod_anim","fiends_grip_cast_anim","freezing_field_anim_10s"}

function AutoDisabler2.OnUnitAnimation(animation)
	if not Menu.IsEnabled(AutoDisabler2.optionEnable) then return end
	local myHero = Heroes.GetLocal()
    --if Entity.IsHero(animation.unit) then
    --    Log.Write(NPC.GetUnitName(animation.unit))
    --    Log.Write(animation.sequenceName)
    --end
    if animation.unit ~= nil and animation.unit ~= 0 and NPCs.Contains(animation.unit) and not Entity.IsSameTeam(animation.unit,myHero) and Entity.IsHero(animation.unit) and not NPC.IsIllusion(animation.unit) then
        for _,v in pairs(AutoDisabler2.anims) do
            if v == animation.sequenceName then
                local dis = NPC.GetAbility(myHero, "lion_voodoo")
                if dis and Ability.IsReady(dis) and Ability.GetManaCost(dis) <= NPC.GetMana(myHero) and NPC.IsEntityInRange(myHero,animation.unit,Ability.GetCastRange(dis)) and Menu.IsEnabled(AutoDisabler2.LionHex) then
                    if Ability.GetLevel(NPC.GetAbility(myHero, "special_bonus_unique_lion_4")) == 1 then
                        Ability.CastPosition(dis, Entity.GetAbsOrigin(animation.unit))
                    else
                        Ability.CastTarget(dis, animation.unit)
                    end
                    return
                end
                dis = NPC.GetAbility(myHero, "shadow_shaman_voodoo")
                if dis and Ability.IsReady(dis) and Ability.GetManaCost(dis) <= NPC.GetMana(myHero) and NPC.IsEntityInRange(myHero,animation.unit,Ability.GetCastRange(dis)) and Menu.IsEnabled(AutoDisabler2.ShadowShamanHex) then
                    Ability.CastTarget(dis, animation.unit)
                    return
                end
                dis = NPC.GetItem(myHero, "item_orchid", true)
                if dis and Ability.IsReady(dis) and Ability.GetManaCost(dis) <= NPC.GetMana(myHero) and NPC.IsEntityInRange(myHero,animation.unit,Ability.GetCastRange(dis))  and Menu.IsEnabled(AutoDisabler2.itemOrchid) then
                    Ability.CastTarget(dis, animation.unit)
                    return
                end
                dis = NPC.GetItem(myHero, "item_bloodthorn", true)
                if dis and Ability.IsReady(dis) and Ability.GetManaCost(dis) <= NPC.GetMana(myHero) and NPC.IsEntityInRange(myHero,animation.unit,Ability.GetCastRange(dis))  and Menu.IsEnabled(AutoDisabler2.itemMegaOrchid) then
                    Ability.CastTarget(dis, animation.unit)
                    return
                end
                dis = NPC.GetItem(myHero, "item_sheepstick", true)
                if dis and Ability.IsReady(dis) and Ability.GetManaCost(dis) <= NPC.GetMana(myHero) and NPC.IsEntityInRange(myHero,animation.unit,Ability.GetCastRange(dis))  and Menu.IsEnabled(AutoDisabler2.itemHex) then
                    Ability.CastTarget(dis, animation.unit)
                    return
                end
                break
            end
        end
    end
end

return AutoDisabler2
