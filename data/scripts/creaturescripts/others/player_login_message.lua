local loginMessage = CreatureEvent("loginMessage")
function loginMessage.onLogin(player)
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, string.format("Your last visit in %s: %s.", configManager.getString(configKeys.SERVER_NAME), os.date("%d %b %Y %X", player:getLastLoginSaved())))
	player:sendTextMessage(MESSAGE_EVENT_ORANGE, "Welcome to ".. configManager.getString(configKeys.SERVER_NAME) .."!")
	
	if player:getLevel() <= 50 then
		player:registerEvent("FreeBlessPK") -- Free Bless
	end

	if player:getGuild() then
		player:openChannel(10) -- Guild Leaders Channel
	end
	
	-- Display Balance --
	local balance = player:getBankBalance()
	if balance > 0 then
		local formattedBalance = formatNumber(balance)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your Bank Balance is: $" .. formattedBalance .. " gold coins.")
	end
	
	-- Inbox Notice --
	local inboxItems = player:getInbox():getItemHoldingCount()
	if inboxItems > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Check the inbox, you have "..inboxItems.." item" .. (inboxItems > 1 and "s." or "."))
	end
	
	-- Channels Ids --
	--player:openChannel(2) -- Global Chat
	--player:openChannel(3) -- Loot Channel
	--player:openChannel(4) -- Task Channel
	--player:openChannel(5) -- Death Channel
	--player:openChannel(6) -- Trade Market
	--player:openChannel(12) -- Quest Channel
	--player:openChannel(7) -- Advertising
	--player:openChannel(8) -- Changelog
	--player:openChannel(9) -- Help Channel
	
	print(player:getName() .. " [".. player:getLevel() .."] has logged in.")
    return true
end

loginMessage:register()

local logoutMessage = CreatureEvent("logoutMessage")
function logoutMessage.onLogout(player)
	if nextUseStaminaTime[player:getId()] then
		nextUseStaminaTime[player:getId()] = nil
	end
	
    print(player:getName() .. " [".. player:getLevel() .."] has logged out.")
    return true
end

logoutMessage:register()