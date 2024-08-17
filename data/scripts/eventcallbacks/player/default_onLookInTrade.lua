local event = Event()
event.onLookInTrade = function(self, partner, item, distance, description)
	local description = "You see " .. item:getDescription(distance)
	return description
end

event:register()