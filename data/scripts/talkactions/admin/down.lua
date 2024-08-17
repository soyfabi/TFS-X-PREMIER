local talk = TalkAction("/down")
function talk.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local position = player:getPosition()
	position.z = position.z + 1
	player:teleportTo(position)
	return false
end

talk:register()
