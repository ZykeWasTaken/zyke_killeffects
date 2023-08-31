local fetchedClosePedsTimer = 0
local closePeds = {}
local availableEffects = {}

CreateThread(function()
    while (true) do
        local sleep = 100
        local ply = PlayerPedId()
        local plyPos = GetEntityCoords(ply)

        for _, ped in pairs(closePeds) do
            local isDead = IsPedDeadOrDying(ped, true) == 1
            local doesExist = DoesEntityExist(ped) == 1
            local sourceOfDeath = GetPedSourceOfDeath(ped)
            local hasBeenHandled = Entity(ped).state.hasBeenHandled
            local shouldHandle = doesExist and isDead and not hasBeenHandled and sourceOfDeath == ply

            if (shouldHandle) then
                local pedNetId = NetworkGetNetworkIdFromEntity(ped)

                TriggerServerEvent("zyke_killeffects:HandlePedDeath", pedNetId)
            end
        end

        if (fetchedClosePedsTimer < GetGameTimer()) then
            closePeds = GetClosestPeds(plyPos, 400.0)
            fetchedClosePedsTimer = GetGameTimer() + 500
        end

        Wait(sleep)
    end
end)

function GetClosestPeds(plyPos, radius)
    local peds = {}

    for _, ped in ipairs(GetGamePool('CPed')) do
        local pedPos = GetEntityCoords(ped)
        local distance = #(plyPos - pedPos)
        local isAPed = IsPedAPlayer(ped) == false

        if ((isAPed) and (distance < radius)) then
            local isAlive = not IsPedDeadOrDying(ped, 1)

            if (isAlive) then
                peds[#peds+1] = ped
            end
        end
    end

    return peds
end

RegisterNetEvent("zyke_killeffects:CreateEffect", function(pos, effectIdx)
    local particles = {}
    local effect = Config.Effects[effectIdx]
    local dst = #(GetEntityCoords(PlayerPedId()) - pos)
    if (dst > 300.0) then return end

    local _, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, true)
    local groundPos = vec3(pos.x, pos.y, groundZ)

    RequestNamedPtfxAsset(effect.dict)
    while (not HasNamedPtfxAssetLoaded(effect.dict)) do Wait(0) end

    for i = 1, effect.amount do
        Wait(0)
        SetPtfxAssetNextCall(effect.dict)
        particles[#particles+1] = StartParticleFxLoopedAtCoord(effect.particle, groundPos.x, groundPos.y, groundPos.z, 0.0, 0.0, 0.0, effect.size, false, false, false, false)
    end

    Wait(1500)

    for i = #particles, 1, -1 do
        StopParticleFxLooped(particles[i], false)
        particles[i] = nil
    end
end)

CreateThread(function()
    while (true) do
        Wait(100)

        if (NetworkIsSessionStarted()) then
            TriggerServerEvent("zyke_killeffects:Initialize")

            return
        end
    end
end)

RegisterCommand("selecteffect", function()
    local formattedEffects = {}

    local function insertEffect(effectData)
        table.insert(formattedEffects, {
            label = effectData.label,
            value = effectData.particle,
        })
    end

    for _, effectData in pairs(Config.Effects) do
        for _, effectName in pairs(availableEffects) do
            if (effectName == effectData.particle) then
                insertEffect(effectData)
            end
        end

        if (effectData.unlocked) then
            insertEffect(effectData)
        end
    end

    local res = lib.inputDialog("Select Effect", {
        {label =  "Effect", name = "effect", type = "select", options = formattedEffects, default = 1, icon = "fa-fire"},
    })

    local chosen = res?[1]
    if (chosen) then
        TriggerServerEvent("zyke_killeffects:SetSelectedEffect", chosen)
    end
end, false)

RegisterNetEvent("zyke_killeffects:SyncEffects", function(effects)
    availableEffects = effects
end)

function Draw3DText(coords, text, scale, rgba)
    local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    rgba = rgba or {}

    SetTextScale(scale or 0.3, scale or 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(rgba.r or 255, rgba.g or 255, rgba.b or 255, rgba.a or 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end