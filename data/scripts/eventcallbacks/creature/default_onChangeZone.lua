local event = Event()

local exhaust = {}

function event.onChangeZone(self, fromZone, toZone)
    if not self or not self:isPlayer() then
        return false
    end
	
	-- Remove Summons on PZ --
	if self:getSummons() then
		if toZone == ZONE_PROTECTION then
			local summons = self:getSummons()
            for _, summon in ipairs(summons) do
				summon:getPosition():sendMagicEffect(CONST_ME_POFF)
                summon:remove()
            end
		end
	end
	
	local playerId = self:getId()
    local currentTime = os.time()
    if exhaust[playerId] and exhaust[playerId] > currentTime then
        return false
    end
	-- Blessing Protect --
	if not self:hasBlessing(5) then
		if not self:getGroup():getAccess() then
			if toZone == ZONE_NORMAL then
				if self:getSlotItem(CONST_SLOT_NECKLACE) and self:getSlotItem(CONST_SLOT_NECKLACE):getId() == 3057 then
					return false
				end
				
				if self:getBankBalance() > 10000 then
					self:popupFYI("[PROTECT BLESS]\n\nBe careful you have NO Bless.\nTo buy bless use the command: !bless\nor you could lose everything, or use an Amulet of loss.\nIn the bank you have:\n[$"..formatNumber(self:getBankBalance()).." gold coins].")
				else
					self:popupFYI("[PROTECT BLESS]\n\nBe careful you have NO Bless.\nTo buy bless use the command: !bless\nor you could lose everything, or use an Amulet of loss.")
				end
				exhaust[playerId] = currentTime + 30
			end
			return false
		end
	end
    return false
end

event:register(-1)