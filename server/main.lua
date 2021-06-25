ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand("report", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    --local args = table.concat(args, " ") 
   
    if (#args > 0) then
        TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] Your report has been submitted')

            MySQL.Async.fetchScalar('SELECT COUNT(1) FROM labrp_reports', {}, function(result)
            local maxnumber = tonumber(result)+1

            local reportreason = ""
            for x=1,#args do
                reportreason = reportreason .. " " .. args[x]
            end

            MySQL.Async.execute("INSERT into labrp_reports (reportnumber, identifier, state, reason, closereason) VALUES (@reportnumber,@identifier,@state,@reason,@closereason)", {
                ['@reportnumber'] = maxnumber,
                ['@identifier'] = xPlayer.getIdentifier(),
                ['@state'] = "open", 
                ['@reason'] = reportreason,
                ['@closereason'] = ""
                })
            end)
            if xPlayer.getGroup() == "admin" then
                TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] ^1^*A NEW REPORT HAS BEEN SUBMITTED. ')
        end
    else
        TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] Ensure you follow the format for a report » /report <Reason>')
    end
end)

RegisterCommand("openreports", function(source, args)
    if source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getGroup() == "admin" then
            MySQL.Async.fetchAll("SELECT reportnumber,identifier,reason FROM labrp_reports WHERE state = @state ORDER BY reportnumber",{['@state'] = "open"},function(result)
                if(#result > 0) then
                    for x=1,#result do
                        local id = result[x].identifier
                        MySQL.Async.fetchAll("SELECT firstname,lastname FROM users WHERE identifier = @id",{['@id'] = id},function(result2)
                            
                            TriggerClientEvent("chat:addMessage", xPlayer.source, "^*Report ID: (^1" .. result[x].reportnumber ..   "^0) | Report By:^1 " .. result2[1].firstname .. " " .. result2[1].lastname .. "^0 | ^0^*Reason: ^1" .. result[x].reason)


                        end)
                    end
                else
                    TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] There are no open reports')
                end
            end)
        else 
            TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] You do not have permission to execute that command')
        end
    end
end)

RegisterCommand("closereport", function(source, args, rawCommand)
    if source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getGroup() == "admin" then
            local reportnumber = args[1]
            local closereason = ""
            for x=2,#args do
                closereason = closereason .. " " .. args[x]
            end
            MySQL.Async.fetchAll("SELECT state FROM labrp_reports WHERE reportnumber = @reportnumber", {['@reportnumber'] = reportnumber}, function(result)
                if(result[1].state ~= "closed") then
                    if (#args > 1) then
                        MySQL.Async.execute("UPDATE labrp_reports SET state = @state, closereason = @closereason WHERE reportnumber = @reportnumber", 
                        {
                            ['@reportnumber'] = reportnumber,
                            ['@state'] = "closed",
                            ['@closereason'] = closereason
                        })
                        TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] You have closed the report ^1ID ' .. reportnumber .. ' ^0for the reason: ^1' .. closereason)
                    else
                        TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] Please enter a reason to close the report' )
                    end
                else
                    TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] This report is already closed' )
                end
            end)
        else
            TriggerClientEvent("chat:addMessage", xPlayer.source, '[^1Report^0] You do not have permission to execute that command')
        end
    end
end)