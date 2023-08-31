CachedData = {}
CachedData.players = {}

RegisterNetEvent("zyke_killeffects:HandlePedDeath", function(pedNetId)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    local pos = GetEntityCoords(ped)
    Entity(ped).state:set("hasBeenHandled", true, true)

    SendEffect(source, pos)
end)

RegisterNetEvent("baseevents:onPlayerDied", function(_, deathCoords)
    SendEffect(source, vec3(deathCoords[1], deathCoords[2], deathCoords[3]))
end)

function SendEffect(source, pos)
    local effect = FetchSelectedEffect(GetLicense(source))
    TriggerClientEvent("zyke_killeffects:CreateEffect", -1, pos, effect)
end

function InitializePlayer(source)
    local p = promise.new()

    local identifier = GetLicense(source)
    if (identifier == nil) then return print("No license found for player: " .. source .. " (CRITICAL)") end

    CachedData.players[identifier] = {
        license = identifier,
        selectedEffect = nil,
        unlocked = {},
        hasInitialized = false, -- Variable to keep track of state instead of checking database later on to update / fetch
    }

    -- Fetch from database, if there are any saved values, then set them
    MySQL.Async.fetchAll("SELECT * FROM zyke_killeffects WHERE identifier = @identifier", {
        ["@identifier"] = identifier
    }, function(res)
        if (#res > 0) then
            local data = res[1]

            CachedData.players[identifier].selectedEffect = data.selectedEffect or nil
            CachedData.players[identifier].unlocked = json.decode(data.unlocked) or {}
            CachedData.players[identifier].hasInitialized = true

            p:resolve()
        else
            MySQL.Async.execute("INSERT INTO zyke_killeffects (identifier, unlocked, selectedEffect) VALUES (@identifier, @unlocked, @selectedEffect)", {
                ["@identifier"] = identifier,
                ["@unlocked"] = json.encode({}),
                ["@selectedEffect"] = nil,
            }, function()
                CachedData.players[identifier].hasInitialized = true
                p:resolve()
            end)
        end
    end)

    Citizen.Await(p)

    TriggerClientEvent("zyke_killeffects:SyncEffects", source, CachedData.players[identifier].unlocked)
end

function FetchSelectedEffect(identifier)
    local selectedEffect = CachedData.players?[identifier]?.selectedEffect ~= "" and CachedData.players?[identifier]?.selectedEffect
    local chosenEffect = selectedEffect or CachedData.players?[identifier]?.unlocked[1] or Config.Effects?[1]?.particle

    for idx, effect in pairs(Config.Effects) do
        if (effect.particle == chosenEffect) then
            return idx
        end
    end

    return nil
end

function FetchEffectByName(effectName)
    for idx, effect in pairs(Config.Effects) do
        if (effect.particle == effectName) then
            return idx
        end
    end

    return nil
end

function GetLicense(playerId)
    for _, v in pairs(GetPlayerIdentifiers(playerId)) do
        if (string.find(v, "license:")) then
            return v
        end
    end

    return nil
end

RegisterNetEvent("zyke_killeffects:SetSelectedEffect", function(effectName)
    local identifier = GetLicense(source)
    if (identifier == nil) then return end

    local player = CachedData.players[identifier]
    if (player == nil) then return end

    local selectedEffect = FetchEffectByName(effectName)
    if (selectedEffect == nil) then return end

    local unlocked = player.unlocked
    local hasFound = false
    for _, unlockedEffect in pairs(unlocked) do
        if (unlockedEffect == effectName) then
            hasFound = true
            break
        end
    end

    if (hasFound == false) then return end

    MySQL.Async.execute("UPDATE zyke_killeffects SET selectedEffect = @selectedEffect WHERE identifier = @identifier", {
        ["@selectedEffect"] = effectName,
        ["@identifier"] = identifier,
    })

    player.selectedEffect = effectName
end)

RegisterNetEvent("zyke_killeffects:Initialize", function()
    InitializePlayer(source)
end)

AddEventHandler("playerDropped", function()
    local identifier = GetLicense(source)
    if (identifier == nil) then return end

    CachedData.players[identifier] = nil
end)

function UnlockEffect(source, effectName)
    local identifier = GetLicense(source)
    if (identifier == nil) then return end

    local effect
    if (effectName) then
        effect = Config.Effects[FetchEffectByName(effectName)]
    else
        local lockedEffects = GetLockedEffectsForPlayer(identifier)
        if (#lockedEffects == 0) then return end

        effect = lockedEffects[math.random(1, #lockedEffects)]
    end

    if (effect == nil) then return end
    effectName = effect.particle

    local player = CachedData.players[identifier]
    if (player == nil) then return end

    for _, unlockedEffect in pairs(player.unlocked) do
        if (unlockedEffect == effectName) then
            return
        end
    end

    player.unlocked[#player.unlocked+1] = effectName
    MySQL.Async.execute("UPDATE zyke_killeffects SET unlocked = @unlocked WHERE identifier = @identifier", {
        ["@unlocked"] = json.encode(player.unlocked),
        ["@identifier"] = identifier,
    })

    TriggerClientEvent("zyke_killeffects:SyncEffects", source, player.unlocked)
end

exports("UnlockEffect", UnlockEffect)

function GetLockedEffects()
    local lockedEffects = {}

    for _, effect in pairs(Config.Effects) do
        if (effect.unlocked == nil or effect.unlocked == false) then
            lockedEffects[#lockedEffects+1] = effect
        end
    end

    return lockedEffects
end

function GetLockedEffectsForPlayer(identifier)
    local unlocked = CachedData.players[identifier].unlocked
    local lockedEffects = GetLockedEffects()

    for i = #lockedEffects, 1, -1 do
        for _, unlockedEffect in pairs(unlocked) do
            if (lockedEffects[i]?.particle == unlockedEffect) then
                table.remove(lockedEffects, i)
            end
        end
    end

    return lockedEffects
end

RegisterCommand("unlockeffect", function(source, args)
    UnlockEffect(source, args[1])
end, false)