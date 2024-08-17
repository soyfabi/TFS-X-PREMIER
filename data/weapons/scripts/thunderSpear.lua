local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENCHANTEDSPEAR)
combat:setParameter(COMBAT_PARAM_BLOCKARMOR, true)
combat:setFormula(COMBAT_FORMULA_SKILL, 0, 0, 1, 0)

function onUseWeapon(player, variant)
	if not combat:execute(player, variant) then
		return false
	end

	player:addDamageCondition(Creature(variant:getNumber()), CONDITION_DAZZLED, DAMAGELIST_LOGARITHMIC_DAMAGE, 15, 10, 5)
	return true
end
