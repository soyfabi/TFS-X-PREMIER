config = {
        quests = {
            [46571] = {
                name = { active = false, value = "do Crusader Helmet."},
                rewards = {
                    {id = 2497, count = 1},
                },
                level = { active = false, min = 150,},
                storage = { active = true, key = 91143,},
                effect = { active = false, effectWin = 30,},
            },
            [46572] = {
                name = { active = false, value = "do Crusader Helmet."},
                rewards = {
                    {id = 9693, count = 1},
                },
                level = { active = false, min = 150,},
                storage = { active = true, key = 91146,},
                effect = { active = true, effectWin = 30,},
            },
            [46573] = {
                name = { active = false, value = "do Crusader Helmet."},
                rewards = {
                    {id = 9971, count = 20},
                },
                level = { active = false, min = 150,},
                storage = { active = true, key = 91147,},
                effect = { active = true, effectWin = 30,},
            },
        },
    messages = {
        notExist = "Essa quest n�o existe.",
        win = "Voc� fez a quest %s.",
        notWin = "Voc� j� fez essa quest.",
        level = "Voc� precisa de level %d ou maior para fazer essa quest.",
    },
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local choose = config.quests[item.actionid]

    if not choose then
        player:sendCancelMessage(config.messages.notExist)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    if choose.level.active and player:getLevel() < choose.level.min then
        player:sendCancelMessage(config.messages.level:format(choose.level.min))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    if choose.storage.active and player:getStorageValue(choose.storage.key) >= 0 then
        player:sendCancelMessage(config.messages.notWin)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return true
    end

    for i = 1, #choose.rewards do
        player:addItem(choose.rewards[i].id, choose.rewards[i].count)
    end

    player:setStorageValue(choose.storage.key, 1)

    if choose.effect.active then
        player:getPosition():sendMagicEffect(choose.effectWin)
    end

    if choose.name.active then
        player:sendCancelMessage(config.messages.win:format(choose.name.value))
    end

    return true
end