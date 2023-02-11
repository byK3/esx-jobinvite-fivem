invite = {}


RegisterCommand('invite', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerJob = xPlayer.job.name
    local playerJobGrade = xPlayer.job.grade
    local target = ESX.GetPlayerFromId(args[1])
    local targetName = GetPlayerName(args[1])

    if Config.Jobs[playerJob] and Config.Grades[playerJobGrade] then
        if tonumber(args[1]) ~= source and args[1] ~= nil and args[1] ~= "" and tonumber(args[1]) then
            if target.getJob().name == Config.unemployedJob then
                notify(args[1] , "You have been invited to the job " .. xPlayer.job.label .. " by " .. xPlayer.name .. "!")
                notify(source, "You have invited " .. targetName .. " to the job " .. xPlayer.job.label .. "!")
                invite[args[1]] = {xPlayer.job.name, xPlayer.identifier}
            else
                notify(source, "The player " .. target.name .. " is already in a job!")
            end
        else
            notify(source, "Invalid player ID!")
        end
    else
        notify(source, "You are not allowed to invite players to your job!")
    end
end, false)


RegisterCommand('accept', function(source, args, rawCommand)
    if source and tonumber(source) ~= nil and tonumber(source) > 0 then
        local sender = ESX.GetPlayerFromId(source)
        if source then
            local data = invite[tostring(source)]
            
            if data then
                local job = data[1]
                local grade = 1
                local identifier = data[2]
                local inviter = ESX.GetPlayerFromIdentifier(identifier)

                sender.setJob(job, grade)
                invite[tostring(source)] = nil
                notify(source, "You have joined the faction " .. job .. "!")
                notify(inviter.source, "The player " .. sender.name .. " has joined your faction!")
            else
                notify(source, "You have no pending invites!")
            end
        end
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
                ["text"] = "© 2023 - " .. os.date("%Y") .. " | " .. "made by:  byK#7147",
            },
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "LOG", embeds = embed}), { ['Content-Type'] = 'application/json' })
end
