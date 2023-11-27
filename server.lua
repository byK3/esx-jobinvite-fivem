local invite = {}


function starTimerK3Invite (src)
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

RegisterCommand('invite', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerJob = xPlayer.job.name
    local playerJobGrade = xPlayer.job.grade



    if Config.Jobs[playerJob] and Config.Grades[playerJobGrade] then
        if tonumber(args[1]) ~= source and args[1] ~= nil and args[1] ~= "" and tonumber(args[1]) then
            local target = ESX.GetPlayerFromId(args[1])
            local targetIdentifier = target.identifier
            local targetName = GetPlayerName(args[1])

            if not invite[targetIdentifier] then
                invite[targetIdentifier] = {}
            else
                notify(xPlayer.source, "The player " .. targetName .. " already has a pending invite!")
                return
            end
            if Config.Config.TargetPlayerJobless then
                if target.getJob().name == Config.unemployedJob then
                    notify(target.source , "You have been invited to the job " .. xPlayer.job.label .. " by " .. xPlayer.name .. "!")
                    notify(xPlayer.source, "You have invited " .. targetName .. " to the job " .. xPlayer.job.label .. "!")
                    local data = {
                        sender = xPlayer.identifier,
                        job = xPlayer.job.name,
                        label = xPlayer.job.label,
                    }
                    invite[targetIdentifier] = data                    
                    starTimerK3Invite (target.source)
                else
                    notify(xPlayer.source, "The player " .. target.name .. " is already in a job!")
                end
            else
                notify(target.source, "You have been invited to the job " .. xPlayer.job.label .. " by " .. xPlayer.name .. "!")
                notify(xPlayer.source, "You have invited " .. targetName .. " to the job " .. xPlayer.job.label .. "!")
                local data = {
                    sender = xPlayer.identifier,
                    job = xPlayer.job.name,
                    label = xPlayer.job.label,
                }
                invite[targetIdentifier] = data
                starTimerK3Invite (target.source)
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
    local needJobless = Config.TargetPlayerJobless
    local unemployed = Config.unemployedJob

    if not invite[identifier] then
        notify(xPlayer.source, "You do not have a pending invite!")
        return
    end

    local sender = invite[identifier].sender
    local senderSrc = ESX.GetPlayerFromIdentifier(sender).source
    local job = invite[identifier].job

    if needJobless then
        if xPlayer.getJob().name == unemployed then
            xPlayer.setJob(job, 1)
            notify(xPlayer.source, "You have been hired to the job " .. invite[identifier].label .. "!")
            notify(senderSrc.soure, "The player " .. xPlayer.name .. " has accepted your invite!")
            invite[identifier] = nil
        else
            notify(xPlayer.source, "You are already in a job!")
        end
    else
        xPlayer.setJob(job, 0)
        notify(xPlayer.source, "You have been hired to the job " .. invite[identifier].label .. "!")
        notify(senderSrc.soure, "The player " .. xPlayer.name .. " has accepted your invite!")
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
