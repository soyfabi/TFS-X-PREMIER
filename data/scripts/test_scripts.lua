local ac = Action()

function ac.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:say("Tescheck!")
	return true
end

ac:id(4839)
ac:register()