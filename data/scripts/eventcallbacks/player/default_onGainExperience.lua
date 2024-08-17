local soulCondition = Condition(CONDITION_SOUL, CONDITIONID_DEFAULT)
soulCondition:setTicks(4 * 60 * 1000)
soulCondition:setParameter(CONDITION_PARAM_SOULGAIN, 1)

local function useStamina(self)
	local staminaMinutes = self:getStamina()
	if staminaMinutes == 0 then
		return
	end

	local playerId = self:getId()
	if not nextUseStaminaTime[playerId] then
		nextUseStaminaTime[playerId] = 0
	end

	local currentTime = os.time()
	local timePassed = currentTime - nextUseStaminaTime[playerId]
	if timePassed <= 0 then
		return
	end

	if timePassed > 60 then
		if staminaMinutes > 2 then
			staminaMinutes = staminaMinutes - 2
		else
			staminaMinutes = 0
		end
		nextUseStaminaTime[playerId] = currentTime + 120
	else
		staminaMinutes = staminaMinutes - 1
		nextUseStaminaTime[playerId] = currentTime + 60
	end
	self:setStamina(staminaMinutes)
end

local event = Event()
event.onGainExperience = function(self, source, exp, rawExp, sendText)

	if not source or source:isPlayer() then
		return exp
	end

	--[[if not source:isMonster() then
		return false
	end
	
	-- Monster Level --
	if source:isMonster() then
        local bonusExperience = source:getMonsterLevel() * 0.03
        if source:getMonsterLevel() > 0 and bonusExperience > 1 then
            exp = exp * bonusExperience
        end
    end]]

	-- Soul regeneration
	local vocation = self:getVocation()
	if self:getSoul() < vocation:getMaxSoul() and exp >= self:getLevel() then
		soulCondition:setParameter(CONDITION_PARAM_SOULTICKS, vocation:getSoulGainTicks() * 1000)
		self:addCondition(soulCondition)
	end
	
	-- Apply experience stage multiplier
	exp = exp * Game.getExperienceStage(self:getLevel())
	
	-- Stamina modifier
	if configManager.getBoolean(configKeys.STAMINA_SYSTEM) then
		useStamina(self)

		local staminaMinutes = self:getStamina()
		if staminaMinutes > 2340 then
			exp = exp * 1.5
		elseif staminaMinutes <= 840 then
			exp = exp * 0.5
		end
	end
	
	return exp
end

event:register()

local message = Event()

local expTracker = {}

function message.onGainExperience(self, source, exp, rawExp, sendText)
    if sendText and exp ~= 0 then
        local monsterName = source:getName()
        local playerId = self:getGuid()
		
        if not expTracker[playerId] then
            expTracker[playerId] = {}
        end
        if not expTracker[playerId][monsterName] then
            expTracker[playerId][monsterName] = { totalExp = 0, count = 0, timer = 0 }
        end
		
        expTracker[playerId][monsterName].totalExp = expTracker[playerId][monsterName].totalExp + exp
        expTracker[playerId][monsterName].count = expTracker[playerId][monsterName].count + 1
        expTracker[playerId][monsterName].timer = os.time()

        addEvent(function()
            if os.time() - expTracker[playerId][monsterName].timer >= 1 then
                local expValue = expTracker[playerId][monsterName].totalExp
                local count = expTracker[playerId][monsterName].count
				
                if expValue > 0 then
                    local expString = expValue .. (expValue ~= 1 and " experience points" or " experience point")
					
                    local message = "You gained " .. expString .. " for killing " 
                    if count > 1 then
                        message = message .. count .. " " .. monsterName .. "s."
                    else
                        message = message .. monsterName .. "."
                    end
					
                    self:sendTextMessage(MESSAGE_STATUS_DEFAULT, message)
                    Game.sendAnimatedText(tostring(expValue), self:getPosition(), 215)
					
                    local spectators = Game.getSpectators(self:getPosition(), false, true)
                    for _, spectator in ipairs(spectators) do
                        if spectator ~= self then
                            spectator:sendTextMessage(MESSAGE_STATUS_DEFAULT, self:getName() .. " gained " .. expString .. " for killing " .. (count > 1 and count .. " " or "") .. monsterName .. (count > 1 and "s" or "") .. ".")
                        end
                    end
                end
				
                expTracker[playerId][monsterName].totalExp = 0
                expTracker[playerId][monsterName].count = 0
            end
        end, 1000)
    end
    return exp
end

message:register(math.huge)