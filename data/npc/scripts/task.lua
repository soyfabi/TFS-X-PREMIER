local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end
function onPlayerCloseChannel(cid) npcHandler:onPlayerCloseChannel(cid) end

npcHandler:addModule(FocusModule:new())

function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end
local player = Player(cid)
local msg = msg:lower()
------------------------------------------------------------------
if npcHandler.topic[cid] == 0 and msg == 'normal' then
	npcHandler:say("�timo. Que task de monstro voc� gostaria de fazer?", cid)
	npcHandler.topic[cid] = 1
elseif npcHandler.topic[cid] == 1 then
	if player:getStorageValue(task_sto_time) < os.time() then
		if player:getStorageValue(task_storage) == -1 then 
			for mon, l in ipairs(task_monsters) do
				if msg == l.name then
					npcHandler:say("Ok, agora voc� est� fazendo a task de {"..l.name:gsub("^%l", string.upper).."},  voc� precisa matar "..l.amount.." deles. Boa sorte!", cid)
					player:setStorageValue(task_storage, mon)
					player:setStorageValue(l.storage, 0)
					npcHandler.topic[cid] = 0
					npcHandler:releaseFocus(cid)
					break
				elseif mon == #task_monsters then
					npcHandler:say("Desculpe, mas n�o temos essa task.", cid)
					npcHandler.topic[cid] = 0
					npcHandler:releaseFocus(cid)
				end
			end
		else
			npcHandler:say("Voc� j� est� fazendo uma task. Voc� pode fazer apenas um de cada vez. Diga {!task} para ver informa��es sobre a sua task atual.", cid)
			npcHandler.topic[cid] = 0
			npcHandler:releaseFocus(cid)
		end
	else
		npcHandler:say("N�o tenho permiss�o para lhe dar nenhuma task porque voc� abandonou a anterior. Espere pelo "..task_time.." horas de puni��o.", cid)
		npcHandler.topic[cid] = 0
		npcHandler:releaseFocus(cid)
	end
elseif npcHandler.topic[cid] == 0 and msg == 'daily' or msg == 'di�ria' then
	if player:getStorageValue(time_daySto) < os.time() then
		npcHandler:say("Lembre-se, � de grande import�ncia que as tasks di�rias sejam realizadas. Agora me diga, qual task de monstro voc� gostaria de fazer?", cid)
		npcHandler.topic[cid] = 2
	else
		npcHandler:say('Voc� concluiu uma tarefa di�ria hoje, espere gastar 24 horas para faz�-lo novamente.', cid)
		npcHandler.topic[cid] = 0
		npcHandler:releaseFocus(cid)
	end
elseif npcHandler.topic[cid] == 2 then
	if player:getStorageValue(task_sto_time) < os.time() then
		if player:getStorageValue(taskd_storage) == -1 then 
			for mon, l in ipairs(task_daily) do 
				if msg == l.name then
					npcHandler:say("Muito bem, agora voc� est� fazendo uma task di�ria {"..l.name:gsub("^%l", string.upper).."}, voc� precisa matar "..l.amount.." deles. Boa sorte!", cid)
					player:setStorageValue(taskd_storage, mon)
					player:setStorageValue(l.storage, 0)
					npcHandler.topic[cid] = 0
					npcHandler:releaseFocus(cid)
					break
				elseif mon == #task_daily then
					npcHandler:say("Desculpe, n�o temos esta task di�ria.", cid)
					npcHandler.topic[cid] = 0
					npcHandler:releaseFocus(cid)
				end
			end
		else
			npcHandler:say("Voc� j� est� fazendo uma task di�ria. Voc� pode fazer apenas um por dia. Diga {!task} para ver informa��es sobre sua task atual.", cid)
			npcHandler.topic[cid] = 0
			npcHandler:releaseFocus(cid)
		end
	else
		npcHandler:say("N�o tenho permiss�o para lhe dar nenhuma task porque voc� abandonou a anterior. Espere pelo "..task_time.." horas de puni��o.", cid)
		npcHandler.topic[cid] = 0
		npcHandler:releaseFocus(cid)
	end
elseif msg == 'receive' or msg == 'receber' then
	if npcHandler.topic[cid] == 0 then
		npcHandler:say("Que tipo de task voc� terminou, {normal} ou {di�ria} ?", cid)
		npcHandler.topic[cid] = 3
	end
elseif npcHandler.topic[cid] == 3 then
	if msgcontains(msg, 'normal') then
	local ret_t = getTaskInfos(player)
		if ret_t then
			if player:getStorageValue(ret_t.storage) == ret_t.amount then
				local pt1 = ret_t.pointsTask[1]
				local pt2 = ret_t.pointsTask[2]
				local txt = 'Obrigado por concluir a task, seus pr�mios s�o: '..(pt1 > 1 and pt1..' task points' or pt1 <= 1 and pt1..' task point')..' and '..(pt2 > 1 and pt2..' rank points' or pt2 <= 1 and pt2..' rank point')..', '
				if #getItemsFromTable(ret_t.items) > 0 then
					txt = txt..'al�m de ganhar: '..getItemsFromTable(ret_t.items)..', '
				for g = 1, #ret_t.items do
					player:addItem(ret_t.items[g].id, ret_t.items[g].count)
				end
				end

				local exp = ret_t.exp
				if exp > 0 then
					txt = txt..'Eu tamb�m te darei '..exp..' de experi�ncia, '
					player:addExperience(exp)
				end

				taskPoints_add(player, pt1)
				taskRank_add(player, pt2)
				player:setStorageValue(ret_t.storage, -1)
				player:setStorageValue(task_storage, -1)
				npcHandler:say(txt..'obrigada novamente e at� a pr�xima!', cid)
				npcHandler.topic[cid] = 0
				npcHandler:releaseFocus(cid)
			else
				npcHandler:say('Voc� ainda n�o concluiu sua task atual. Voc� o receber� quando terminar.', cid)
				npcHandler.topic[cid] = 0
				npcHandler:releaseFocus(cid)
			end
		else
			npcHandler:say("Voc� n�o est� fazendo nenhuma task.", cid)
			npcHandler.topic[cid] = 0
			npcHandler:releaseFocus(cid)
		end
	elseif npcHandler.topic[cid] == 3 and msg == 'daily' or msg == 'di�ria' then
		if player:getStorageValue(time_daySto)-os.time() <= 0 then
		local ret_td = getTaskDailyInfo(player)
			if ret_td then
				if getTaskDailyInfo(player) then
					if player:getStorageValue(getTaskDailyInfo(player).storage) == getTaskDailyInfo(player).amount then
					local pt1 = getTaskDailyInfo(player).pointsTask[1]
					local pt2 = getTaskDailyInfo(player).pointsTask[2]
					local txt = 'Obrigado por concluir a task, seus pr�mios s�o: '..(pt1 > 1 and pt1..' task points' or pt1 <= 1 and pt1..' task point')..' e '..(pt2 > 1 and pt2..' rank points' or pt2 <= 1 and pt2..' rank point')..', '
						if #getTaskDailyInfo(player).items > 0 then
							txt = txt..'al�m de ganhar: '..getItemsFromTable(getTaskDailyInfo(player).items)..', '
						for g = 1, #getTaskDailyInfo(player).items do
							player:addItem(getTaskDailyInfo(player).items[g].id, getTaskDailyInfo(player).items[g].count)
						end
						end
						local exp = getTaskDailyInfo(player).exp
						if exp > 0 then
							txt = txt..'Eu tamb�m te darei '..exp..' experi�ncia, '
							player:addExperience(exp)
						end
						npcHandler:say(txt..' obrigada novamente e at� a pr�xima!', cid)
						taskPoints_add(player, pt1)
						taskRank_add(player, pt2)
						player:setStorageValue(getTaskDailyInfo(player).storage, -1)
						player:setStorageValue(taskd_storage, -1)
						player:setStorageValue(time_daySto, 1*60*60*24+os.time())
						npcHandler.topic[cid] = 0
						npcHandler:releaseFocus(cid)
					else
						npcHandler:say('Voc� ainda n�o concluiu sua task atual. Voc� o receber� quando terminar.', cid)
						npcHandler.topic[cid] = 0
						npcHandler:releaseFocus(cid)
					end
				else
					npcHandler:say("Voc� n�o est� fazendo nenhuma task.", cid)
					npcHandler.topic[cid] = 0
					npcHandler:releaseFocus(cid)
				end
			end
		else
			npcHandler:say("Voc� fez uma task di�ria, aguarde 24 horas para fazer outra novamente.", cid)
			npcHandler.topic[cid] = 0
			npcHandler:releaseFocus(cid)
		end
	end

elseif msg == 'abandon' or msg == 'abandonar' then
	if npcHandler.topic[cid] == 0 then
		npcHandler:say("Aff, que tipo de task voc� deseja sair, {normal} ou {di�ria}?", cid)
		npcHandler.topic[cid] = 4
	end
elseif npcHandler.topic[cid] == 4 and msgcontains(msg, 'normal') then
	local ret_t = getTaskInfos(player)
	if ret_t then
		npcHandler:say('Infelizmente esta situa��o, tinha f� que voc� me traria essa task, mas eu estava errada. Como puni��o ser� '..task_time..' horas sem poder executar nenhuma task.', cid)
		player:setStorageValue(task_sto_time, os.time()+task_time*60*60)
		player:setStorageValue(ret_t.storage, -1)
		player:setStorageValue(task_storage, -1)
		npcHandler.topic[cid] = 0
		npcHandler:releaseFocus(cid)
	else
		npcHandler:say("Voc� n�o est� fazendo nenhuma task para poder abandon�-la.", cid)
		npcHandler.topic[cid] = 0
		npcHandler:releaseFocus(cid)
	end
elseif npcHandler.topic[cid] == 4 and msg == 'daily' or msg == 'di�ria' then
	local ret_td = getTaskDailyInfo(player)
	if ret_td then
		npcHandler:say('nfelizmente esta situa��o, tinha f� que voc� me traria essa task, mas eu estava errado. Como puni��o ser� '..task_time..' horas sem poder fazer nenhuma task.', cid)
		player:setStorageValue(task_sto_time, os.time()+task_time*60*60)
		player:setStorageValue(ret_td.storage, -1)
		player:setStorageValue(taskd_storage, -1)
		npcHandler.topic[cid] = 0
		npcHandler:releaseFocus(cid)
	else
		npcHandler:say("Voc� n�o est� executando nenhuma task di�ria para poder abandon�-la.", cid)
		npcHandler.topic[cid] = 0
		npcHandler:releaseFocus(cid)
	end
elseif msg == "normal task list" or msg == "lista de task normal" then
	local text = "----**| -> Tasks Normais <- |**----\n\n"
		for _, d in pairs(task_monsters) do
			text = text .."------ [*] "..d.name.." [*] ------ \n[+] Quantidade [+] -> ["..(player:getStorageValue(d.storage) + 1).."/"..d.amount.."]:\n[+] Pr�mios [+] -> "..(#d.items > 1 and getItemsFromTable(d.items).." - " or "")..""..d.exp.." experience \n\n"
		end

		player:showTextDialog(1949, "" .. text)
		npcHandler:say("Aqui est� a lista de tasks normais.", cid)
elseif msg == "daily task list" or msg == "lista de task di�ria" then
	local text = "----**| -> Tasks Di�rias <- |**----\n\n"
		for _, d in pairs(task_daily) do
			text = text .."------ [*] "..d.name.." [*] ------ \n[+] Quantidade [+] -> ["..(player:getStorageValue(d.storage) + 1).."/"..d.amount.."]:\n[+] Pr�mios [+] -> "..(#d.items > 1 and getItemsFromTable(d.items).." - " or "")..""..d.exp.." experience \n\n"
		end

		player:showTextDialog(1949, "" .. text)
		npcHandler:say("Aqui est� a lista de tasks di�rias.", cid)
end
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)