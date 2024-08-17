function onLogin(player)
	local loginStr = "Bem-vindo ao {" .. configManager.getString(configKeys.SERVER_NAME) .. "}!"
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Por favor escolha sua roupa."
		player:sendOutfitWindow()
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_BLUE_LIGHT, loginStr)
		end

		loginStr = string.format("Sua última visita foi em {%s}.", os.date("%a %b %d %X %Y", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_BLUE_LIGHT, loginStr)
	
	-- Events
	player:registerEvent("PlayerDeath")
	player:registerEvent("DropLoot")
	return true
end