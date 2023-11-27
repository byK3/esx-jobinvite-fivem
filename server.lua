local invite = {}


function startTimerK3Invite (src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier

    SetTimeout(Config.InviteTime * 1000, function()
        if invite[identifier] then
            local jobLabel = invite[identifier].label
            invite[identifier] = nil
            notify(xPlayer.source, "Your invite for: " .. jobLabel .. " has expired!")
        end
    end)
end


function sendInviteK3 (sender, target)
    local xPlayer = ESX.GetPlayerFromId(sender)
    local xTarget = ESX.GetPlayerFromId(target)
    local xIdentifier = xTarget.identifier

    if invite[xIdentifier] then
        local jobLabel = invite[xIdentifier].label
        notify(xPlayer.source, "The player has already a pending invite")
        return
    end

    notify(xTarget.source, "You have been invited to the job " .. xPlayer.job.label .. " by " .. xPlayer.name .. "!")
    notify(xPlayer.source, "You have invited " .. xTarget.name .. " to the job " .. xPlayer.job.label .. "!")


    local data = {
        sender = xPlayer.identifier,
        job = xPlayer.job.name,
        label = xPlayer.job.label,
    }

    invite[xIdentifier] = data

    startTimerK3Invite (xTarget.source)

end

RegisterCommand('invite', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerJob = xPlayer.job.name
    local playerJobGrade = xPlayer.job.grade



    if Config.Jobs[playerJob] and Config.Grades[playerJobGrade] then
        if tonumber(args[1]) ~= source and args[1] ~= nil and args[1] ~= "" and tonumber(args[1]) then
            local target = ESX.GetPlayerFromId(args[1])
            local targetIdentifier = target.identifier
            if Config.Config.TargetPlayerJobless then
                if target.getJob().name == Config.unemployedJob then
                    sendInviteK3 (xPlayer.source, target.source)
                else
                    notify(xPlayer.source, "The player " .. target.name .. " is already in a job!")
                end
            else
                sendInviteK3 (xPlayer.source, target.source)
            end
        else
            notify(xPlayer.source, "Invalid player ID!")
        end
    else
        notify(xPlayer.source, "You are not allowed to invite players to your job!")
    end
end, false)



RegisterCommand('accept', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local inviteData = invite[identifier]

    if not inviteData then
        notify(xPlayer.source, "You don't have any pending invites!")
        return
    end

    local senderPlayer = ESX.GetPlayerFromIdentifier(inviteData.sender)
    if not senderPlayer then
        notify(xPlayer.source, "The player who invited you is not online anymore!")
        invite[identifier] = nil
        return
    end

    if Config.TargetPlayerJobless and xPlayer.getJob().name ~= Config.unemployedJob then
        notify(xPlayer.source, "You are already in a job - you can't accept this invite!")
        invite[identifier] = nil
    else
        xPlayer.setJob(inviteData.job, 0)
        notify(xPlayer.source, "You have been hired for the job " .. inviteData.label .. "!")
        notify(senderPlayer.source, "The player " .. xPlayer.name .. " has accepted your invite!")
        invite[identifier] = nil
    end
end, false)






SendToDiscord = function(color, name, message)

    -- exmaple:  SendToDiscord(16711680, "JOB INVITE", "The Player ".. GetPlayerName(source) .." has invited ".. GetPlayerName(args[1]) .." to the job ".. xPlayer.job.label .."!

    embed = {
        { -- color red = 16711680, color green = 65280, color blue = 255, color yellow = 16776960, color purple = 16711935, color orange = 16744192, color white = 16777215
            ["color"] = color,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "© 2023 - " .. os.date("%Y") .. " | " .. "made by:  byK3",
            },
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "LOG", embeds = embed}), { ['Content-Type'] = 'application/json' })
end
