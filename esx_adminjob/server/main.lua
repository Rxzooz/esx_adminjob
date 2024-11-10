ESX = nil
onlinePlayers = {}
local player_have_gift = {}
PE = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_adminjob:getGruop')
AddEventHandler('esx_adminjob:getGruop', function()
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		local Group = xPlayer.getGroup()
		TriggerClientEvent('esx_adminjob:sendGruop', source, Group)
	end
end)

RegisterNetEvent("esx_adminjob:wesamsetcoords")
AddEventHandler("esx_adminjob:wesamsetcoords", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		local xcoords = xPlayer.getCoords(true)
		local xcoords_old = {x = xcoords.x, y = xcoords.y, z = xcoords.z}
		local coordsnew = {x = xcoords.x, y = xcoords.y, z = xcoords.z + 1}
		xPlayer.setCoords(coordsnew)
		Citizen.Wait(1000)
		xPlayer.setCoords(xcoords_old)
	end
end)

RegisterNetEvent("esx_adminjob:addInventoryToPlayer")
AddEventHandler("esx_adminjob:addInventoryToPlayer", function(itemvalue, count, playerid)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerid)
	if xPlayer then
		if xTarget then
			xTarget.addInventoryItem(itemvalue, count)
		else
			xPlayer.showNotification("الاعب غير متصل")
		end
	end
end)

ESX.RegisterServerCallback("esx_adminjob:getItemsFromdatabase", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		local data = MySQL.Sync.fetchAll('SELECT * FROM items')
		cb(data)
	end
end)

RegisterServerEvent('showid:add-id')
AddEventHandler('showid:add-id', function()
    TriggerClientEvent("showid:client:add-id", source, onlinePlayers)
    local topText = "undefined ID"
    local identifiers = GetPlayerIdentifiers(source)
    -- if wesam.which == "steam" then
    --     for k,v in ipairs(identifiers) do
    --         if string.match(v, 'steam:') then
    --             topText = v
    --             break
    --         end
    --     end
    -- elseif wesam.which == "steamv2" then
    --     for k,v in ipairs(identifiers) do
    --         if string.match(v, 'steam:') then
    --             topText = string.sub(v, 7)
    --             break
    --         end
    --     end
    -- elseif wesam.which == "license" then
    --     for k,v in ipairs(identifiers) do
    --         if string.match(v, 'license:') then
    --             topText = v
    --             break
    --         end
    --     end
    -- elseif wesam.which == "licensev2" then
    --     for k,v in ipairs(identifiers) do
    --         if string.match(v, 'license:') then
    --             topText = string.sub(v, 9)
    --             break
    --         end
    --     end
    -- elseif wesam.which == "name" then
    --     topText = GetPlayerName(source)
    -- end
    onlinePlayers[tostring(source)] = GetPlayerName(source)
    TriggerClientEvent("showid:client:add-id", -1, topText, tostring(source))
end)

ESX.RegisterServerCallback('esx_adminjob:checkPlayerisHaveLicCar', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		MySQL.Async.fetchAll('SELECT owner FROM user_licenses WHERE owner = @owner AND type = @type',
		{
			['@owner'] = xPlayer.identifier,
			['@type'] = "drive"
		},
		function(data)
			if data[1] then
				cb(true)
			else
				cb(false)
			end
		end)
	end
end)

ESX.RegisterServerCallback('esx_adminjob:getPlayerverify', function(source, cb, id_player)
	local xPlayers = ESX.GetPlayers()
	local em = {}
	local counter_ambulance = 0
	local counter_police = 0
	local counter_agent = 0
	local counter_mechanic = 0
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer then
			if xPlayer.job.name == "police" then
				if counter_police == 0 then
					counter_police = 1
				elseif counter_police < 0 then
					counter_police = 1
				elseif counter_police >= 1 then
					counter_police = counter_police + 1
				end
				table.insert(em, {label = "موظف في <font color=#0080FF>الشرطة</font> : " .. xPlayer.getName() .. " | ايدي الاعب : " .. xPlayer.source, id = xPlayer.source, job = "police"})
			end
			if xPlayer.job.name == "ambulance" then
				if counter_ambulance == 0 then
					counter_ambulance = 1
				elseif counter_ambulance < 0 then
					counter_ambulance = 1
				elseif counter_ambulance >= 1 then
					counter_ambulance = counter_ambulance + 1
				end
				table.insert(em, {label = "موظف في <font color=#EB3C3C>الأستجابة الطبيه</font> : " .. xPlayer.getName() .. " | ايدي الاعب : " .. xPlayer.source, id = xPlayer.source, job = "ambulance"})
			end
			if xPlayer.job.name == "agent" then
				if counter_agent == 0 then
					counter_agent = 1
				elseif counter_agent < 0 then
					counter_agent = 1
				elseif counter_agent >= 1 then
					counter_agent = counter_agent + 1
				end
				table.insert(em, {label = "موظف في <font color=#00FF00>أمن الحدود</font> : " .. xPlayer.getName() .. " | ايدي الاعب : " .. xPlayer.source, id = xPlayer.source, job = "agent"})
			end
			if xPlayer.job.name == "mechanic" then
				if counter_mechanic == 0 then
					counter_mechanic = 1
				elseif counter_mechanic < 0 then
					counter_mechanic = 1
				elseif counter_mechanic >= 1 then
					counter_mechanic = counter_mechanic + 1
				end
				table.insert(em, {label = "موظف في <font color=#606060>كراج الميكانيك</font> : " .. xPlayer.getName() .. " | ايدي الاعب : " .. xPlayer.source, id = xPlayer.source, job = "mechanic"})
			end
		end
	end
	cb({data = em, counter_mechanic = counter_mechanic, counter_agent = counter_agent, counter_police = counter_police, counter_ambulance = counter_ambulance})
end)

ESX.RegisterServerCallback('esx_adminjob:getPlayeris', function(source, cb, id_player)
	local xPlayer = ESX.GetPlayerFromId(id_player)
	if xPlayer then
		cb({status = true, current = {label = xPlayer.getName() .. ' | ' .. xPlayer.source, value = xPlayer.source, name = xPlayer.getName()}})
	else
		cb({status = false})
	end
end)

RegisterNetEvent('esx_wesam_wesam:send2')
AddEventHandler('esx_wesam_wesam:send2', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		TriggerClientEvent('esx_animation:do2', xPlayer.source)
	end
end)


function AddXpToPlayer(name,message,color)
	local DiscordWebHook = ""

	local embeds = {
		{
			["title"]=message,
			["type"]="rich",
			["color"] =color,
			["footer"]=  {
				["text"]= "الرقابة و التفتيش"
			},
		}
	}

	if message == nil or message == '' then return FALSE end
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

--[[RegisterNetEvent('esx_adminjob:swapToAutoMatic')
AddEventHandler('esx_adminjob:swapToAutoMatic', function()
	TriggerClientEvent('esx_adminjob:givePlayerMenuAfterJoin', -1)
end)--]]

local getOnlinePlayers, onlinePlayers = false, {}
ESX.RegisterServerCallback('esx_admin:getOnlinePlayers', function(source, cb)
	local playerDATA = {}
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		table.insert(playerDATA, {id_player = xPlayer.source})
	end
	cb(playerDATA)
end)

--[[ESX.RegisterServerCallback('esx_admingetcoords', function(source, cb, id_new)
	local xPlayer = ESX.GetPlayerFromId(id_new)
	if xPlayer then
		cb(xPlayer.getCoords(true))
	end
end)--]]

ESX.RegisterServerCallback('getPlayerId:esx', function(source, cb, iden)
	local xPlayers = ESX.GetPlayers()
	local players  = {}
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.identifier == iden then
			cb(xPlayer.source)
		end
	end
end)

function RemoveXPFromPlayer (name,message,color)
	local DiscordWebHook = ""

	local embeds = {
		{
			["title"]=message,
			["type"]="rich",
			["color"] =color,
			["footer"]=  {
				["text"]= "الرقابة و التفتيش"
			},
		}
	}

	if message == nil or message == '' then return FALSE end
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

local Cooldown_count = 0

	local function Cooldown(sec)
		CreateThread(function()
			Cooldown_count = sec
			while Cooldown_count ~= 0 do
				Cooldown_count = Cooldown_count - 1
				Wait(1000)
			end
			Cooldown_count = 0
		end)
	end


RegisterServerEvent('esx_adminjob:msg')
AddEventHandler('esx_adminjob:msg', function(name, message, color)
    AddXpToPlayer(name, message, color)
end)

RegisterNetEvent('esx_adminjob:takelic')
AddEventHandler('esx_adminjob:takelic', function(id_player, reason)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(id_player)
	if xPlayer then
		if xPlayer.job.name == "admin" then
			if xTarget then
				MySQL.Async.fetchAll("DELETE FROM user_licenses WHERE type = @type and owner = @owner",
				{
					['@owner'] = xTarget.identifier,
					['@type'] = "drive",
				})
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "سحب ^3رخصة قيادة ^0 " .. xTarget.getName() .. " ^3بسبب ^0: ^3" .. reason)
				TriggerClientEvent('esx_adminjob:addHaveIIL', xTarget.source)
			end
		end
	end
end)

RegisterCommand('washcar', function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == "admin" or xPlayer.identifier == "06ad5523e658aaa16b8bc47327a34e423d0ce090" then
		TriggerClientEvent('esx_adminjob:wesam:washCar', source)
	else
		TriggerClientEvent('esx:showNotification', source, '<font color=red>صلاحياتك لاتسمح</font>')
	end
end, false, {help = ("wash car")})

RegisterServerEvent('esx_adminjob:send_messag_to_player')
AddEventHandler('esx_adminjob:send_messag_to_player', function(message, PlayerID)
    TriggerClientEvent('esx:showNotification', PlayerID, '<font color=white>رسالة من </font>' .. "<font color=yellow>الرقابة و التفتيش </font><font color=white>الرسالة تقول : </font><font color=yellow>" .. message .. "</font>")
end)

RegisterServerEvent('esx_adminjob:astd3a_ala3b')
AddEventHandler('esx_adminjob:astd3a_ala3b', function(id_player)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(id_player)
	if xPlayer then
		if xPlayer.job.name == "admin" then
			--TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^3 أستدعاء الاعب ^0" .. xTarget.getName() .."^3 عليك التوجه الى الدسكورد الدعم الفني")
    		TriggerClientEvent("esx_misc:controlSystemScaleform_astd3a", xTarget.source)
		end
	end
end)

ESX.RegisterServerCallback('esx_adminjob:jailPlayeroFFline', function(source, cb, identifier_player_jail, time_jail, reason_player, name_player_is, isssAni, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromIdentifier(identifier_player_jail)
	if xPlayer then
		if xPlayer.job.name == "admin" then
			if type == "identifier" then
				if xTarget then
					TriggerClientEvent('esx_adminjob:setPlayerinJailIsOnline', xPlayer.source, xTarget.source, time_jail, reason_player)
					cb(true)
				else
					MySQL.Async.fetchAll('SELECT firstname , lastname FROM users WHERE identifier = @identifier', {
						['@identifier'] = identifier_player_jail,
					}, function(data)
						if data[1] then
							local isNai = false
							local name_player_s = nil
							if data[1].firstname == nil and data[1].lastname == nil then
								isNai = true
							elseif data[1].lastname == nil and data[1].firstname ~= nil then
								isNai = true
							elseif data[1].firstname == nil and data[1].lastname ~= nil then
								isNai = true
							else
								name_player_s = data[1].firstname .. " " .. data[1].lastname
							end
							MySQL.Async.execute('UPDATE users SET jail = @jail WHERE identifier = @identifier', {
								['@identifier'] = identifier_player_jail,
								['@jail'] = tonumber(time_jail)
							}, function (rowsChanged)
								if rowsChanged then
									if isNai then
										TriggerClientEvent('chatMessage', -1, " ⭐ الرقابة والتفتيش " ,  { 198, 40, 40 } ,  "سجن لاعب غير متصل ^3 | " ..  "^0السبب ^3" .. reason_player .. " ^0مدة السجن ^3" .. time_jail .. " ^0شهر")
									else
										TriggerClientEvent('chatMessage', -1, " ⭐ الرقابة والتفتيش " ,  { 198, 40, 40 } ,  "سجن لاعب غير متصل ^3| ^0الاعب ^3" .. name_player_s .. " ^0السبب ^3" .. reason_player .. " ^0مدة السجن ^3" .. time_jail .. " ^0شهر")
									end
									cb(true)
								else
									xPlayer.showNotification("حدث خطاء لم يتم سجن الأعب | تاكد من ادخال المعلومات بشكل صحيح")
								end
							end)
						else
							xPlayer.showNotification("حدث خطاء لم يتم سجن الأعب | تاكد من ادخال المعلومات بشكل صحيح")
						end
					end)
				end
			elseif type == "with_name" then
				MySQL.Async.fetchAll('SELECT identifier FROM users WHERE firstname = @firstname AND lastname = @lastname', {
					['@firstname'] = identifier_player_jail.firstname,
					['@lastname'] = identifier_player_jail.lastname
				}, function(data)
					if data[1] then
						local xTargetNew = ESX.GetPlayerFromId(data[1].identifier)
						if xTargetNew then
							TriggerClientEvent('esx_adminjob:setPlayerinJailIsOnline', xPlayer.source, xTargetNew.source, time_jail, reason_player)
							cb(true)
						else
							MySQL.Async.execute('UPDATE users SET jail = @jail WHERE identifier = @identifier', {
								['@identifier'] = data[1].identifier,
								['@jail'] = tonumber(time_jail)
							}, function (rowsChanged)
								if rowsChanged then
									TriggerClientEvent('chatMessage', -1, " ⭐ الرقابة والتفتيش " ,  { 198, 40, 40 } ,  "سجن لاعب غير متصل ^3| ^0الاعب ^3" .. identifier_player_jail.firstname .. " " .. identifier_player_jail.lastname .. " ^0السبب ^3" .. reason_player .. " ^0مدة السجن ^3" .. time_jail .. " ^0شهر")
									cb(true)
								else
									xPlayer.showNotification("حدث خطاء لم يتم سجن الأعب | تاكد من ادخال المعلومات بشكل صحيح")
								end
							end)
						end
					else
						xPlayer.showNotification("حدث خطاء لم يتم سجن الأعب | تاكد من ادخال المعلومات بشكل صحيح")
					end
				end)
			elseif type == "choice" then
				if xTarget then
					TriggerClientEvent('esx_adminjob:setPlayerinJailIsOnline', xPlayer.source, xTarget.source, time_jail, reason_player)
					cb(true)
				else
					MySQL.Async.execute('UPDATE users SET jail = @jail WHERE identifier = @identifier', {
						['@identifier'] = identifier_player_jail,
						['@jail'] = tonumber(time_jail)
					}, function (rowsChanged)
						if rowsChanged then
							if isssAni then
								TriggerClientEvent('chatMessage', -1, " ⭐ الرقابة والتفتيش " ,  { 198, 40, 40 } ,  "سجن لاعب غير متصل ^3 | " ..  "^0السبب ^3" .. reason_player .. " ^0مدة السجن ^3" .. time_jail .. " ^0شهر")
							else
								TriggerClientEvent('chatMessage', -1, " ⭐ الرقابة والتفتيش " ,  { 198, 40, 40 } ,  "سجن لاعب غير متصل ^3| ^0الاعب ^3" .. name_player_is .. " ^0السبب ^3" .. reason_player .. " ^0مدة السجن ^3" .. time_jail .. " ^0شهر")
							end
							cb(true)
						else
							xPlayer.showNotification("حدث خطاء لم يتم سجن الأعب | تاكد من ادخال المعلومات بشكل صحيح")
						end
					end)
				end
			end
		end
	end
end)

ESX.RegisterServerCallback('esx_adminjob:getAllPlayerFromDataBase', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local player_list = {}
	if xPlayer then
		if xPlayer.job.name == "admin" then
			local data = MySQL.Sync.fetchAll('SELECT * FROM users')
			for i=1, #data, 1 do
				local xPlayer = ESX.GetPlayerFromIdentifier(data[i].identifier)
				if xPlayer then
					--print()
				else
					if data[i].firstname == nil and data[i].lastname == nil then
						table.insert(player_list, {firstname = "غير معروف الأسم الأول", lastname = "غير معروف الأسم الأخير", identifier_player = data[i].identifier, isani = true})
					elseif data[i].lastname == nil and data[i].firstname ~= nil then
						table.insert(player_list, {firstname = data[i].firstname, lastname = "", identifier_player = data[i].identifier, isani = true})
					elseif data[i].firstname == nil and data[i].lastname ~= nil then
						table.insert(player_list, {firstname = "", lastname = data[i].lastname, identifier_player = data[i].identifier, isani = true})
					else
						table.insert(player_list, {firstname = data[i].firstname, lastname = data[i].lastname, identifier_player = data[i].identifier, isani = false})
					end
				end
			end
			cb(player_list)
		end
	end
end)

RegisterCommand('change_type_to_truck', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(118)
	MySQL.Async.execute('UPDATE owned_vehicles SET plate = @plate_new WHERE owner = @owner AND plate = @plate', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = "UQY 563",
		['@plate_new'] = "BAA 238"
	}, function (rowsChanged)
		if rowsChanged then
			print('[+] successfully')
		else
			print('[+] error')
		end
	end)
end, false, {help = ("change type to trucks / 1 id player / 2 plate car or truck")})--]]

RegisterCommand('deletemyallcars', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(79)
	MySQL.Async.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = @owner',
    {
    	['@owner'] = xPlayer.identifier,
    },
    function(data)
		if data[1] ~= nil then
			for i = 1, #data, 1 do
				MySQL.Async.fetchAll("DELETE FROM owned_vehicles WHERE plate = @plate",
				{
					['@plate'] = data[i]["plate"],
				})
			end
		end
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'تم حذف جميع مركباتك')
	end)
end, false, {help = ("delete all your cars")})--]]

RegisterCommand('cccc', function(source, args, user)
	local rsacsac = MySQL.Sync.fetchAll('SELECT * FROM users')
	for i = 1, #rsacsac, 1 do
		MySQL.Sync.execute('UPDATE users SET job = @job WHERE identifier = @identifier', {
			['@job'] = "unemployed",
			['@identifier'] = rsacsac[i].identifier
		})
		Citizen.Wait(1)
	end
end, false, {help = ("delete all your cars")})

RegisterCommand('vcvc', function(source, args, user)
	local rsacsac = MySQL.Sync.fetchAll('SELECT * FROM users')
	for i = 1, #rsacsac, 1 do
		MySQL.Sync.execute('UPDATE users SET job_grade = @job_grade WHERE identifier = @identifier', {
			['@job_grade'] = tonumber(0),
			['@identifier'] = rsacsac[i].identifier
		})
	end
end, false, {help = ("delete all your cars")})--]]

RegisterServerEvent('esx_adminjob:change_name_player')
AddEventHandler('esx_adminjob:change_name_player', function(player_id, first_name, last_name)
	local last_name_before_change = nil
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(player_id)
	if xPlayer.job.name == "admin" then
		if xTarget then
			last_name_before_change = xTarget.getName()
			MySQL.Async.fetchAll("UPDATE users SET firstname = @firstname, lastname = @lastname WHERE identifier = @identifier", { ['@identifier'] = xTarget.identifier, ['@firstname'] = first_name, ['@lastname'] = last_name})
			TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "تم تغيير اسم الاعب ^3" .. last_name_before_change .. "^0 الى ^3" .. first_name .. " " .. last_name)
			TriggerClientEvent('esx:showNotification', source, '<font color=green>تم تغيير اسم الاعب</font>' .. "<font color=yellow> " .. last_name_before_change .. "</font>" .. "<font color=white> الى</font>" .. "<font color=green> " .. first_name .. " " .. last_name .. "</font>")
		else
			TriggerClientEvent('esx:showNotification', source, '<font color=yellow>الاعب غير متصل</font>')
		end
	end
end)

RegisterServerEvent('esx_adminjob:msg1')
AddEventHandler('esx_adminjob:msg1', function(name, message, color)
    RemoveXPFromPlayer(name, message, color)
end)

ESX.RegisterServerCallback('leojob:getPlayerCars', function(source, cb, target)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(target)

	MySQL.Async.fetchAll('SELECT name,plate FROM owned_vehicles WHERE owner = @owner',
    {
    	['@owner'] = xTarget.identifier,
    },
    function(data)
		cb(data)
	end)
end)

ESX.RegisterServerCallback('esx_adminjob:checkJobPlayer', function(source, cb, iden_player)
	local xTarget = ESX.GetPlayerFromIdentifier(iden_player)
	if xTarget then
		cb(xTarget.job.name)
	else
		--TriggerClientEvent('esx:showNotification', source, '<font color=yellow>الاعب غير متصل</font>')
	end
end)

ESX.RegisterServerCallback('esx_adminjob:playersonline', function(source, cb)
	local xPlayers = ESX.GetPlayers()
	local players  = {}

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		table.insert(players, {
			source     = xPlayer.source,
			identifier = xPlayer.identifier,
            name       = xPlayer.name,
			job        = xPlayer.job
		})
	end

	cb(players)
end)

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = "",
        fivem = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
		elseif string.find(id, "fivem") then
            identifiers.fivem = id
        end
    end

    return identifiers
end

function sendToDiscordMain(name,title,message,color, webhook)
	local DiscordWebHook = webhook
 	local embeds = {
	  	{
		  	["title"]=title,
		  	["type"]="rich",
		  	["description"] = message,
		  	["color"] =color,
		  	["footer"]=  {
				["text"]= os.date("%x %X %p"),
		 	},
	  	}
  	}
	if message == nil or message == '' then
		return false
	end
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent("esx:givemoneyLog")
AddEventHandler("esx:givemoneyLog", function(pas,source,sourcetarget,ac,amount)
   	if pas == Config.pawwsordadmin then
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer then
			local xTarget = ESX.GetPlayerFromId(sourcetarget)
			if xTarget then
				local ids = ExtractIdentifiers(source)
				local ids2 = ExtractIdentifiers(sourcetarget)
				local lavoro = xPlayer.job.label
				local grado = xPlayer.job.grade_label
				local lavoro2 = xTarget.job.label
				local grado2 = xTarget.job.grade_label
				_steamID ="**Steam ID:  ** " ..ids.steam..""
				_discordID ="**Discord:  ** <@" ..ids.discord:gsub("discord:", "")..">"
				_identifierID ="**identifier:  ** " ..xPlayer.identifier..""
				_steamID2 ="**Steam ID:  ** " ..ids2.steam..""
				_discordID2 ="**Discord:  ** <@" ..ids2.discord:gsub("discord:", "")..">"
				_identifierID2 ="**identifier:  ** " ..xTarget.identifier..""
				if ac == 'money' then
					ac = 'كاش'
				elseif ac == 'black_money' then
					ac = 'اموال حمراء(قذرة)'
				end
				if amount > 5000 then
					local content_m = xPlayer.getName().." | `"..GetPlayerName(source).."`\n "..lavoro.." - " ..grado.."\n".._steamID.."\n".._identifierID.."\n".._discordID.."\nبإعطاء:"..xTarget.getName().." | `"..GetPlayerName(sourcetarget).."`\n"..lavoro2.." - " ..grado2.."\n".._steamID2.."\n".._identifierID2.."\n".._discordID2.."\n المبلغ: `"..amount.."`\nنوع المال: `"..ac.."`"
					PerformHttpRequest(Config.givemoney, function(err, text, headers) end, 'POST', json.encode({ username = 'تبادل مال بأكثر من 5 ألف', content = content_m .. '@everyone تنبيه !'}), { ['Content-Type'] = 'application/json' })
				end
			end
		end
  	end
end)

RegisterCommand('scoreboard', function(source, args, user)
	local request = args[1]
    local xPlayer = ESX.GetPlayerFromId(source)
	if (xPlayer.job.name == 'admin' and xPlayer.job.grade >= 1) then
    if request ~= nil  and request == 'toggleID' or request == 'screfresh' then
	if Cooldown_count == 0 then
	Cooldown(6)
	TriggerEvent('esx_scoreboard:request_sv', request)
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>يجب الأنتظار</font>. <font color=orange>'..Cooldown_count..' ثانية</font>')
	end
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>خطأ بالمدخلات</font>')
	end
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>صلاحياتك لاتسمح</font>')
	end
end, false, {help = ("scoreboard control")})

--[[
local DiscordWebHook = "https://discord.com/api/webhooks/notnowrio92898123492321529908/tGME5vOQG3t2pzQS1rjnG6cKXw13l9gr55iLeDVHAbRXShx2bgfpXaMtZHa8dyvTPmLZ"

	local embeds = {
		{
			["title"]=title,
			["type"]="rich",
            ["description"] = message,
			["color"] =color,
			["footer"]=  { ["text"]= "حالة الميناء",
            ["icon_url"] = "https://cdn.discordapp.com/attachments/931300530393874482/931302251513909348/7fd04efde345f231.png"},
		}
	}

	if message == nil or message == '' then return FALSE end
	PerformHttpRequest(https://discord.com/api/webhooks/notnowrio92898123492321529908/tGME5vOQG3t2pzQS1rjnG6cKXw13l9gr55iLeDVHAbRXShx2bgfpXaMtZHa8dyvTPmLZ, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
--]]

RegisterNetEvent('esx:ChangeThat')
AddEventHandler('esx:ChangeThat', function(name)
	if name == "location_sell_drugs_1" then
		if not Config.location_sell_drugs_1 then
			if not Config.location_sell_drugs_3 then
				if not Config.location_sell_drugs_2 then
					Config.location_sell_drugs_1 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", true)
				else
					Config.location_sell_drugs_2 = false
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_2", false)
					Citizen.Wait(2000)
					Config.location_sell_drugs_1 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", true)
				end
			else
				Config.location_sell_drugs_3 = false
				TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_3", false)
				Citizen.Wait(2000)
				if not Config.location_sell_drugs_2 then
					Config.location_sell_drugs_1 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", true)
				else
					Config.location_sell_drugs_2 = false
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_2", false)
					Citizen.Wait(2000)
					Config.location_sell_drugs_1 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", true)
				end
			end
		else
			Config.location_sell_drugs_1 = false
			TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", false)
		end
	elseif name == "location_sell_drugs_2" then
		if not Config.location_sell_drugs_2 then
			if not Config.location_sell_drugs_3 then
				if not Config.location_sell_drugs_1 then
					Config.location_sell_drugs_2 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_2", true)
				else
					Config.location_sell_drugs_1 = false
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", false)
					Citizen.Wait(2000)
					Config.location_sell_drugs_2 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_2", true)
				end
			else
				Config.location_sell_drugs_3 = false
				TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_3", false)
				Citizen.Wait(2000)
				if not Config.location_sell_drugs_1 then
					Config.location_sell_drugs_2 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_2", true)
				else
					Config.location_sell_drugs_1 = false
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", false)
					Citizen.Wait(2000)
					Config.location_sell_drugs_2 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_2", true)
				end
			end
		else
			Config.location_sell_drugs_2 = false
			TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_2", false)
		end
	elseif name == "location_sell_drugs_3" then
		if not Config.location_sell_drugs_3 then
			if not Config.location_sell_drugs_2 then
				if not Config.location_sell_drugs_1 then
					Config.location_sell_drugs_3 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_3", true)
				else
					Config.location_sell_drugs_1 = false
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", false)
					Citizen.Wait(2000)
					Config.location_sell_drugs_3 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_3", true)
				end
			else
				Config.location_sell_drugs_2 = false
				TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_2", false)
				Citizen.Wait(2000)
				if not Config.location_sell_drugs_1 then
					Config.location_sell_drugs_3 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_3", true)
				else
					Config.location_sell_drugs_1 = false
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_1", false)
					Citizen.Wait(2000)
					Config.location_sell_drugs_3 = true
					TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_3", true)
				end
			end
		else
			Config.location_sell_drugs_3 = false
			TriggerClientEvent("esx_misc:watermark_promotion", -1, "location_sell_drugs_3", false)
		end
	end
end)

RegisterServerEvent('esx_misc:GetCache')
AddEventHandler('esx_misc:GetCache', function()
    local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('esx_misc:updatePromotionStatus', source, 'location_sell_drugs_1', Config.location_sell_drugs_1)
	TriggerClientEvent('esx_misc:updatePromotionStatus', source, 'location_sell_drugs_2', Config.location_sell_drugs_2)
	TriggerClientEvent('esx_misc:updatePromotionStatus', source, 'location_sell_drugs_3', Config.location_sell_drugs_3)
end)

ESX.RegisterServerCallback('esx_owner_car:getOwnerCar', function(source, cb, plate_from_function)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll("SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate", {
	  ["@owner"] = xPlayer.identifier,
	  ['@plate'] = plate_from_function
	}, function(result)
	  	if result[1] ~= nil then
			cb(true)
		else
			cb(false)
		end
	end)
end)

RegisterNetEvent('esx_misc3:try')
AddEventHandler('esx_misc3:try', function(plate_car_ww)
	local xPlayer = ESX.GetPlayerFromId(source)
	local message = "**لقد قام الاعب** : \n" .. xPlayer.getName() .. "\n\n**رقم الأستيم :** \n" .. xPlayer.identifier .. "\n\n**اسم الأستيم :** \n" .. GetPlayerName(source) .. "\n\n**الوظيفة :** \n" .. xPlayer.job.label .. " - " .. xPlayer.job.grade_label .. "\n\n**ب استخراج المركبة المعرفه ب لوحة**\n" .. plate_car_ww
	local DiscordWebHook = Config.hgz

  	local embeds = {
	  	{
		  	["title"]=  message,
		  	["type"]="rich",
		  	["color"] = 56108,
		  	["footer"]=  {
			  	["text"]= "حجز المركبات",
		 	},
	  	}
  	}
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = "حجز المركبات",embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent('esx_misc3:money_wash')
AddEventHandler('esx_misc3:money_wash', function(black_money)
	local xPlayer = ESX.GetPlayerFromId(source)
	local message = "**لقد قام الاعب** : \n" .. xPlayer.getName() .. "\n\n**رقم الأستيم :** \n" .. xPlayer.identifier .. "\n\n**اسم الأستيم :** \n" .. GetPlayerName(source) .. "\n\n**الوظيفة :** \n" .. xPlayer.job.label .. " - " .. xPlayer.job.grade_label .. "\n\n**ب غسل الأموال : **\n$" .. black_money
	local DiscordWebHook = "https://discord.com/api/webhooks/notnowrio921054489796237611179/IQySvMkDv1IeFveeEQvTNiQ4ez-fXJivs6gTocYEzQFjZQZiZqbnd_-QVJlXjq9WD8Wu"

  	local embeds = {
	  	{
		  	["title"]=  message,
		  	["type"]="rich",
		  	["color"] = 0000,
		  	["footer"]=  {
			  	["text"]= "غسيل الأموال",
		 	},
	  	}
  	}
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = "غسيل الأموال",embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent('esx_misc3:unjailLog')
AddEventHandler('esx_misc3:unjailLog', function(id_player)
	local xTarget = ESX.GetPlayerFromId(id_player)
	local xPlayer = ESX.GetPlayerFromId(source)
	local message = "**لقد قام الاعب** : \n" .. xPlayer.getName() .. "\n\n**رقم الأستيم :** \n" .. xPlayer.identifier .. "\n\n**اسم الأستيم :** \n" .. GetPlayerName(source) .. "\n\n**الوظيفة :** \n" .. xPlayer.job.label .. " - " .. xPlayer.job.grade_label .. "\n\n**ب اعفاء الاعب : **\n" .. xTarget.getName()
	local DiscordWebHook = Config.unjail

  	local embeds = {
	  	{
		  	["title"]=  message,
		  	["type"]="rich",
		  	["color"] = 0000,
		  	["footer"]=  {
			  	["text"]= "اعفاء المسجون",
		 	},
	  	}
  	}
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = "غسيل الأموال",embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent('esx_misc3:jailLog')
AddEventHandler('esx_misc3:jailLog', function(id_player, reason_jail)
	local xTarget = ESX.GetPlayerFromId(id_player)
	local xPlayer = ESX.GetPlayerFromId(source)
	local message = "**لقد قام الاعب** : \n" .. xPlayer.getName() .. "\n\n**رقم الأستيم :** \n" .. xPlayer.identifier .. "\n\n**اسم الأستيم :** \n" .. GetPlayerName(source) .. "\n\n**الوظيفة :** \n" .. xPlayer.job.label .. " - " .. xPlayer.job.grade_label .. "\n\n**ب سجن الاعب : **\n" .. xTarget.getName() .. "\n\n**السبب : **\n" .. reason_jail
	local DiscordWebHook = Config.jail

  	local embeds = {
	  	{
		  	["title"]=  message,
		  	["type"]="rich",
		  	["color"] = 0000,
		  	["footer"]=  {
			  	["text"]= "سجن لاعب",
		 	},
	  	}
  	}
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = "سجن لاعب",embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent('esx_misc3:selldrugs')
AddEventHandler('esx_misc3:selldrugs', function(what_sell)
	local xPlayer = ESX.GetPlayerFromId(source)
	local message = "**لقد قام الاعب** : \n" .. xPlayer.getName() .. "\n\n**رقم الأستيم :** \n" .. xPlayer.identifier .. "\n\n**اسم الأستيم :** \n" .. GetPlayerName(source) .. "\n\n**الوظيفة :** \n" .. xPlayer.job.label .. " - " .. xPlayer.job.grade_label .. "\n\n**ببيع الممنوعات : **\n" .. what_sell
	local DiscordWebHook = "https://discord.com/api/webhooks/notnowrio921081351453001666661/2DkIRbnS2CL4qpO3RH9inyB-0nn60umSmL1zBI1_E933Z7qeFE79XHynwDlSRpog1Rz3"

  	local embeds = {
	  	{
		  	["title"]=  message,
		  	["type"]="rich",
		  	["color"] = 0000,
		  	["footer"]=  {
			  	["text"]= "بيع الممنوعات",
		 	},
	  	}
  	}
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = "بيع الممنوعات",embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)

RegisterNetEvent('esx_misc3:try2')
AddEventHandler('esx_misc3:try2', function(plate_car_ww2)
	local xPlayer = ESX.GetPlayerFromId(source)
	local message = "**لقد قام الاعب** : \n" .. xPlayer.getName() .. "\n\n**رقم الأستيم :** \n" .. xPlayer.identifier .. "\n\n**اسم الأستيم :** \n" .. GetPlayerName(source) .. "\n\n**الوظيفة :** \n" .. xPlayer.job.label .. " - " .. xPlayer.job.grade_label .. "\n\n**ب بحجز المركبة المعرفه ب لوحة**\n" .. plate_car_ww2

  	local embeds = {
	  	{
		  	["title"]=  message,
		  	["type"]="rich",
		  	["color"] = 56108,
		  	["footer"]=  {
			  	["text"]= "قام بحجز مركبة",
		 	},
	  	}
  	}
	PerformHttpRequest(Config.hgz, function(err, text, headers) end, 'POST', json.encode({ username = "حجز المركبات",embeds = embeds}), { ['Content-Type'] = 'application/json' })
end)

ESX.RegisterServerCallback('esx_owner_car:getOwnerCarJob', function(source, cb, plate_from_function)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll("SELECT plate FROM owned_veh_job WHERE plate = @plate AND identifier = @identifier", {
	  ["@plate"] = plate_from_function,
	  ['@identifier'] = xPlayer.identifier
	}, function(result)
	  	if result[1] then
			cb(true)
		else
			cb(false)
		end
	end)
end)

RegisterNetEvent("esx_adminjob:wesam:take:car")
AddEventHandler("esx_adminjob:wesam:take:car", function(id_player, plate_car, name_car, reason)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(id_player)
	if xPlayer then
		if xTarget then
			MySQL.Async.fetchAll("SELECT plate FROM owned_vehicles WHERE plate = @plate AND owner = @owner", {
				["@plate"] = plate_car,
				['@owner'] = xTarget.identifier
			}, function(result)
				if result[1] then
					MySQL.Async.fetchAll("DELETE FROM owned_vehicles WHERE plate = @plate AND owner = @owner", {
						['@plate'] = plate_car,
						['@owner'] = xTarget.identifier
					})
					TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^3مصادرة مركبة من ^0 " .. xTarget.getName() .. "^3 اللوحة ^0" .. plate_car .. " ^3اسم المركبة ^0 " .. name_car .. " ^3السبب ^0 " .. reason)
					TriggerClientEvent("esx_misc:controlSystemScaleform_take_car", xTarget.source, plate_car, reason)
				else
					xPlayer.showNotification("لم يتم العثور على السيارة لمصادرتها")
				end
			end)
		else
			xPlayer.showNotification("حدث خطاء ممكن الشخص غير متصل")
		end
	end
end)

RegisterCommand('id', function(source, args, user)
	local targetid = args[1]
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetid)
	if xPlayer.job.name == 'admin' or xPlayer.getGroup() == "superadmin" then
    if targetid ~= nil then
	local embeds = {
		{
			["title"]= "أستعلام عن: "..xTarget.getName(),
			["type"]="rich",
            ["description"] = "steam name: `"..GetPlayerName(xTarget.source).."`\n `"..GetPlayerIdentifiers(xTarget.source)[1].."` | `"..GetPlayerIdentifiers(xTarget.source)[5].."`\n`"..GetPlayerIdentifiers(xTarget.source)[2].."` | `"..GetPlayerIdentifiers(xTarget.source)[6].."`\nكاش: $`"..xTarget.getAccount("money").money.."`\n[بنك `"..xTarget.getAccount("bank").money.."`]\n[أموال حمراء $`"..xTarget.getAccount("black_money").money.."`]",
			["color"] =color, -- black
			["footer"]=  { ["text"]= ""..GetPlayerIdentifiers(xTarget.source)[5].." | "..GetPlayerIdentifiers(xTarget.source)[1].." | "..GetPlayerName(source).." أستعلام من قبل",
            ["icon_url"] = "https://cdn.discordapp.com/attachments/950654664129523762/966322628287676516/c8921c97bdbba9c6.png"},
		}
	}
    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
            text = "</br><font size=3><p align=right><b>الهوية: <font color=gold>"..xTarget.getName().."</font>"..
			"</br><font size=3><p align=right><b>steam name: <font color=gray>"..GetPlayerName(xTarget.source).."</font>"..
			"</br><font size=3><p align=right><b>وظيفة: <font color=orange>"..xTarget.getJob().label.." - "..xTarget.getJob().grade_label.."</font>"..
			"</br><font size=3><p align=right><b>[كاش: <font color=green>$"..xTarget.getAccount("money").money.."]</font>"..
			"</br><font size=3><p align=right><b>[بنك: <font color=green>$"..xTarget.getAccount("bank").money.."]</font>"..
			"</br><font size=3><p align=right><b>[رقم الأستيم: <font color=green>"..xTarget.identifier.."]</font>"..
			"</br><font size=3><p align=right><b>[اموال حمراء: <font color=red>💴 $"..xTarget.getAccount("black_money").money.."]</font>",
            type = "info",
            queue = "right",
            timeout = 10000,
            layout = "centerright"
        })
	PerformHttpRequest(Config.ast3lam, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>لايوجد لاعب متصل بهاذه الايدي</font>')
	end
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>صلاحياتك لاتسمح</font>')
	end
end, false, {help = ("id")})

RegisterCommand('id', function(source, args, user)
	local targetid = args[1]
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetid)
	if xPlayer.job.name == 'admin' or xPlayer.getGroup() == "superadmin" then
    if targetid ~= nil then
	local embeds = {
		{
			["title"]= "أستعلام عن: "..xTarget.getName(),
			["type"]="rich",
            ["description"] = "steam name: `"..GetPlayerName(xTarget.source).."`\n `"..GetPlayerIdentifiers(xTarget.source)[1].."` | `"..GetPlayerIdentifiers(xTarget.source)[5].."`\n`"..GetPlayerIdentifiers(xTarget.source)[2].."` | `"..GetPlayerIdentifiers(xTarget.source)[6].."`\nكاش: $`"..xTarget.getAccount("money").money.."`\n[بنك `"..xTarget.getAccount("bank").money.."`]\n[أموال حمراء $`"..xTarget.getAccount("black_money").money.."`]",
			["color"] =color, -- black
			["footer"]=  { ["text"]= ""..GetPlayerIdentifiers(xTarget.source)[5].." | "..GetPlayerIdentifiers(xTarget.source)[1].." | "..GetPlayerName(source).." أستعلام من قبل",
            ["icon_url"] = "https://cdn.discordapp.com/attachments/950654664129523762/966322628287676516/c8921c97bdbba9c6.png"},
		}
	}
    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
            text = "</br><font size=3><p align=right><b>الهوية: <font color=gold>"..xTarget.getName().."</font>"..
			"</br><font size=3><p align=right><b>steam name: <font color=gray>"..GetPlayerName(xTarget.source).."</font>"..
			"</br><font size=3><p align=right><b>وظيفة: <font color=orange>"..xTarget.getJob().label.." - "..xTarget.getJob().grade_label.."</font>"..
			"</br><font size=3><p align=right><b>[كاش: <font color=green>$"..xTarget.getAccount("money").money.."]</font>"..
			"</br><font size=3><p align=right><b>[بنك: <font color=green>$"..xTarget.getAccount("bank").money.."]</font>"..
			"</br><font size=3><p align=right><b>[رقم الأستيم: <font color=green>"..xTarget.identifier.."]</font>"..
			"</br><font size=3><p align=right><b>[اموال حمراء: <font color=red>💴 $"..xTarget.getAccount("black_money").money.."]</font>",
            type = "info",
            queue = "right",
            timeout = 10000,
            layout = "centerright"
        })
	PerformHttpRequest(Config.ast3lam, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>لايوجد لاعب متصل بهاذه الايدي</font>')
	end
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>صلاحياتك لاتسمح</font>')
	end
end, false, {help = ("id")})

RegisterCommand('id', function(source, args, user)
	local targetid = args[1]
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetid)
	if xPlayer.job.name == 'admin' or xPlayer.getGroup() == "superadmin" then
    if targetid ~= nil then
	--[[local embeds = {
		{
			["title"]= "أستعلام عن: "..xTarget.getName(),
			["type"]="rich",
            ["description"] = "steam name: `"..GetPlayerName(xTarget.source).."`\n `"..GetPlayerIdentifiers(xTarget.source)[1].."` | `"..GetPlayerIdentifiers(xTarget.source)[5].."`\n`"..GetPlayerIdentifiers(xTarget.source)[2].."` | `"..GetPlayerIdentifiers(xTarget.source)[6].."`\nكاش: $`"..xTarget.getAccount("money").money.."`\n[بنك `"..xTarget.getAccount("bank").money.."`]\n[أموال حمراء $`"..xTarget.getAccount("black_money").money.."`]",
			["color"] =color, -- black
			["footer"]=  { ["text"]= ""..GetPlayerIdentifiers(xTarget.source)[5].." | "..GetPlayerIdentifiers(xTarget.source)[1].." | "..GetPlayerName(source).." أستعلام من قبل",
            ["icon_url"] = "https://cdn.discordapp.com/attachments/950654664129523762/966322628287676516/c8921c97bdbba9c6.png"},
		}
	}--]]
    TriggerClientEvent("pNotify:SendNotification", xPlayer.source, {
            text = "</br><font size=3><p align=right><b>الهوية: <font color=gold>"..xTarget.getName().."</font>"..
			"</br><font size=3><p align=right><b>steam name: <font color=gray>"..GetPlayerName(xTarget.source).."</font>"..
			"</br><font size=3><p align=right><b>وظيفة: <font color=orange>"..xTarget.getJob().label.." - "..xTarget.getJob().grade_label.."</font>"..
			"</br><font size=3><p align=right><b>[كاش: <font color=green>$"..xTarget.getAccount("money").money.."]</font>"..
			"</br><font size=3><p align=right><b>[بنك: <font color=green>$"..xTarget.getAccount("bank").money.."]</font>"..
			"</br><font size=3><p align=right><b>[رقم الأستيم: <font color=green>"..xTarget.identifier.."]</font>"..
			"</br><font size=3><p align=right><b>[اموال حمراء: <font color=red>💴 $"..xTarget.getAccount("black_money").money.."]</font>",
            type = "info",
            queue = "right",
            timeout = 10000,
            layout = "centerright"
        })
	--PerformHttpRequest("https://discord.com/api/webhooks/notnowrio921054495365623201882/yBUxpLse3Y_K0sVZL8HrKiWEIqVXU2ZIMjqAZKWPpW8T5hvG_kXjnslAQYhFV_OgX6pH", function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>لايوجد لاعب متصل بهاذه الايدي</font>')
	end
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>صلاحياتك لاتسمح</font>')
	end
end, false, {help = ("id")})

RegisterCommand('clearchat', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == "admin" then
		TriggerClientEvent('chat:clear', -1)
		local embeds = {
			{
				["title"]= "حذف الشات",
				["type"]="rich",
				["description"] = "الهوية: `"..xPlayer.getName().."` \nsteam name: `"..GetPlayerName(xPlayer.source).."`\n `"..GetPlayerIdentifiers(xPlayer.source)[1].."` | `"..GetPlayerIdentifiers(xPlayer.source)[5].."`\n`"..GetPlayerIdentifiers(xPlayer.source)[2].."`\n وضيفة الإداري الحالية: `"..xPlayer.getJob().label.." - "..xPlayer.getJob().grade_label.."`",
				["color"] =color, -- black
				["footer"]=  { ["text"]= "حذف الشات",
				["icon_url"] = "https://cdn.discordapp.com/attachments/931300530393874482/931302251513909348/7fd04efde345f231.png"},
			}
		}
		PerformHttpRequest(Config.delchat, function(err, text, headers) end, 'POST', json.encode({ username = ('إنعاش إداري لنفسه'),embeds = embeds}), { ['Content-Type'] = 'application/json' })
	end
end, false, {help = ("clear chat all")})

RegisterCommand('reviveme', function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'admin' then
	local embeds = {
		{
			["title"]= "إداري انعش نفسه عن طريق /reviveme",
			["type"]="rich",
            ["description"] = "الهوية: `"..xPlayer.getName().."` \nsteam name: `"..GetPlayerName(xPlayer.source).."`\n `"..GetPlayerIdentifiers(xPlayer.source)[1].."` | `"..GetPlayerIdentifiers(xPlayer.source)[5].."`\n`"..GetPlayerIdentifiers(xPlayer.source)[2].."`\n وضيفة الإداري الحالية: `"..xPlayer.getJob().label.." - "..xPlayer.getJob().grade_label.."`",
			["color"] =color, -- black
			["footer"]=  { ["text"]= "قام إداري بإنعاش نفسه",
            ["icon_url"] = "https://cdn.discordapp.com/attachments/931300530393874482/931302251513909348/7fd04efde345f231.png"},
		}
	}
	TriggerClientEvent('esx_ambulancejob:revive', source, xPlayer.source)
	-- PerformHttpRequest(Config.adminreviveself, function(err, text, headers) end, 'POST', json.encode({ username = ('إنعاش إداري لنفسه'),embeds = embeds}), { ['Content-Type'] = 'application/json' })
	-- PerformHttpRequest("https://discord.com/api/webhooks/notnowrio921054495609152876574/ookA1cZzZO989cjEDWOrt9V81aRGfz-aGvTnmh4DwLwF4oiSbmNjbOqJsoIT9EyV5wAH", function(err, text, headers) end, 'POST', json.encode({ username = ('إنعاش إداري لنفسه'),embeds = embeds}), { ['Content-Type'] = 'application/json' })
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>صلاحياتك لاتسمح</font>')
	end
end, false, {help = ("revive your self")})

RegisterCommand('adminjob', function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
    local jobgrade = 0
	if xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "aplus" or xPlayer.getGroup() == "a" or xPlayer.getGroup() == "modplus" or xPlayer.getGroup() == "mod" then
	if xPlayer.getGroup() == "mod" then
	jobgrade = 1
	elseif xPlayer.getGroup() == "modplus" then
	jobgrade = 2
	elseif xPlayer.getGroup() == "a" then
	jobgrade = 3
	elseif xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "aplus" then
	jobgrade = 3
	elseif xPlayer.getGroup() == "superadmin" then
	jobgrade = 4
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>صلاحياتك لاتسمح</font>')
	return
	end
	xPlayer.setJob('admin', jobgrade)
	TriggerClientEvent('esx:showNotification', source, '<font color=gold>تم إعطائك وظيفة الرقابة و التفتيش الخاصة برتبتك</font>')
	local embeds = {
		{
			["title"]= "إعطاء وظيفة المراقب لنفسه",
			["type"]="rich",
            ["description"] = "الهوية: `"..xPlayer.getName().."` \nsteam name: `"..GetPlayerName(xPlayer.source).."`\n `"..GetPlayerIdentifiers(xPlayer.source)[1].."` | `"..GetPlayerIdentifiers(xPlayer.source)[5].."`\n`"..GetPlayerIdentifiers(xPlayer.source)[2].."`\n وضيفة الإداري الحالية: `"..xPlayer.getJob().label.." - "..xPlayer.getJob().grade_label.."`\n قام بتحويل وظيفته الى الرقابة و التفتيش عبر /adminjob",
			["color"] =color, -- black
			["footer"]=  { ["text"]= "بإعطاء نفسه وظيفة الرقابة و التفتيش",
            ["icon_url"] = "https://cdn.discordapp.com/attachments/931300530393874482/931302251513909348/7fd04efde345f231.png"},
		}
	}
	PerformHttpRequest(Config.giveadminjobforself, function(err, text, headers) end, 'POST', json.encode({ username = ('اعطاء نفسة رتبة المراقب او المنظم'),embeds = embeds}), { ['Content-Type'] = 'application/json' })
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>صلاحياتك لاتسمح</font>')
	end
end, false, {help = ("give adminjob to your self")})

-- server Console commands
--[[
RegisterServerEvent("esx_adminjob:kickall_Console") -- don't work will
AddEventHandler("esx_adminjob:kickall_Console", function(msg, pas)
	local xPlayers	= ESX.GetPlayers()
	if pas == Config.pas then
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if msg ~= nil then
        DropPlayer(xPlayers[i], 'تم فصل جميع اللاعبيبن من السيرفر ربما يكون ريستارت تابع حالة السيرفر\n('..msg..')\nhttps://discord.gg/WM')
		else
		DropPlayer(xPlayers[i], 'تم فصل جميع اللاعبيبن من السيرفر ربما يكون ريستارت تابع حالة السيرفر\nhttps://discord.gg/WM')
		end
		print("^1All players have been kickd from the Server^0")
	end
	else
	print(('esx_adminjob: %s attempted to kick all plaeyrs (not console!)!'):format(xPlayer.identifier))
	end
end)

RegisterCommand('kickall', function(source, args, user)
	if source == 0 then-- if is server Console
	TriggerEvent('esx_adminjob:kickall_Console', args, Config.pas)
	end
end, false)
--]]

RegisterCommand("say", function(source, args, rawCommand)	-- say [message]		only for server console
	if source == 0 then
		if args[1] then
			local message = string.sub(rawCommand, 4)
			--print("^1SERVER Announcement ^0: "..message)
			print("^1console chat Announcement ^0: "..message)
			TriggerClientEvent('chatMessage', -1, "^1 Console" ,  {198, 40, 40} ,  message)
		else
			--print('invalid input')
		end
	end
end, false)
RegisterCommand("coords", function(source, args, rawCommand)	-- /coords		print exact ped location in console/F8
	if source ~= 0 then
		local xPlayer = ESX.GetPlayerFromId(source)
		local heading = GetEntityHeading(GetPlayerPed(source))
		print(GetEntityCoords(GetPlayerPed(source)))
	end
end, false)


RegisterServerEvent('esx_adminjob:Check_me')
AddEventHandler('esx_adminjob:Check_me', function()
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'admin' then
	if xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "aplus" or xPlayer.getGroup() == "a" or xPlayer.getGroup() == "modplus" or xPlayer.getGroup() == "mod" or xPlayer.getGroup() == "s" then
	else
    xPlayer.setJob('unemployed', 0)
	TriggerClientEvent('esx:showNotification', source, 'تم تعينك عاطل بسبب عدم أمتلاك صلاحيات كافية لوظيفة الرقابة و التفتيش')
	end
	end
end)

ESX.RegisterServerCallback('getRankPlayer:getRankPlayerByMenuwesam', function(source, cb, PlayerId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(PlayerId)
	MySQL.Async.fetchAll('SELECT rp_rank FROM users WHERE identifier = @identifier', {
		['@identifier'] = xTarget.identifier
	}, function(result)
		cb(result[1].rp_rank)
	end)
end)


ESX.RegisterServerCallback("esx_dmvschooladmin:addLicenseadmin", function(source, cb,tepe,id_player)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(id_player)
	local name_xPlayer = xPlayer.getName()
	local name_xTarget = xTarget.getName()
	MySQL.Async.execute('INSERT INTO user_licenses (type,owner) VALUES (@type,@owner)', {
		['@type'] = tepe,
		['@owner'] = xTarget.identifier
	}, function ()
		local embeds = {
			{
				["title"]=  message,
				["type"]="rich",
				["description"] = " الاداراي :"..name_xPlayer.. "  قام بأعطاء الاعب:  "..name_xTarget.."  رخصة نوعها :"..tepe,
				["color"] = 56108,
				["footer"]=  {
					["text"]= "قام باعطاء رخصة ",
			   },
			}
		}
		TriggerClientEvent("esx_misc:controlSystemScaleform_rash", xTarget.source)
		PerformHttpRequest(Config.givelicenses, function(err, text, headers) end, 'POST', json.encode({ username = ('اعطاء رخصة '),embeds = embeds}), { ['Content-Type'] = 'application/json' })
	end)
end)
RegisterServerEvent('esx_adminjob:wesamcar')
AddEventHandler('esx_adminjob:wesamcar', function(PlayerId,name,plate,joobbb,model,carprice,carlevel,typeindata)
    local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(PlayerId)
	local name_player = xTarget.getName()
	local name_xPlayer = xPlayer.getName()
	local name_xTarget = xTarget.getName()
	MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, category, name,priceold,levelold, modelname) VALUES (@owner, @plate, @vehicle, @type, @job, @category, @name,@priceold,@levelold, @modelname)', {
		['@owner'] = xTarget.identifier,
		['@plate'] = plate,
		['@vehicle'] = json.encode({model = GetHashKey(model), plate = plate, engineHealth = 1000.0, bodyHealth = 1000.0}),
		['@type'] = typeindata,
		['@job'] = joobbb,
		['@category'] = '1',
		['@name'] = name,
		['@priceold'] = carprice,
		['@levelold'] = carlevel,
		['@modelname'] = model,
	}, function()
		local embeds = {
			{
				["title"]=  message,
				["type"]="rich",
				["description"] = " الاداراي :"..name_xPlayer.. "  قام بأعطاء الاعب:  "..name_xTarget.."  مركبة اسمها :"..name.." ولوحة: "..plate..' للوظيفة : '..joobbb.." سعرها: "..carprice..' خبرتها: '..carlevel,
				["color"] = 56108,
				["footer"]=  {
					["text"]= "قام باعطاء مركبة ",
			   },
			}
		}
		PerformHttpRequest(Config.givevehicle, function(err, text, headers) end, 'POST', json.encode({ username = ('اعطاء مركبة '),embeds = embeds}), { ['Content-Type'] = 'application/json' })

	end)
	TriggerClientEvent("esx_misc:controlSystemScaleform_givecar", xTarget.source,plate)
	TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اعطاء مركبة   ^2" .. name.."^0 لشخص ^3"..name_player.."^0 لوحة : ^3" .. plate)
end)



ESX.RegisterServerCallback("esx_dmvschooladmin:removeLicenseadmin", function(source, cb,type,id_player)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(id_player)
	local name_xPlayer = xPlayer.getName()
	local name_xTarget = xTarget.getName()

	MySQL.Async.execute("DELETE FROM user_licenses WHERE owner = @owner AND type = @type", {
		['@type'] = type,
		['@owner'] = xTarget.identifier
	}, function ()
		local embeds = {
			{
				["title"]=  message,
				["type"]="rich",
				["description"] = " الاداراي :"..name_xPlayer.. "  قام بسحب   رخصة نوعها :"..type.." للاعب "..name_xTarget,
				["color"] = 15548997,
				["footer"]=  {
					["text"]= "قام بسحب رخصة ",
			   },
			}
		}
		PerformHttpRequest(Config.removelicense, function(err, text, headers) end, 'POST', json.encode({ username = ('سحب رخصة '),embeds = embeds}), { ['Content-Type'] = 'application/json' })

	end)
	TriggerClientEvent("esx_misc:controlSystemScaleform_removelicsen", xTarget.source)
	TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "سحب رخصة   ^2^0  ^3"..name_player.."^0 لمخالفة النظام العام^3")

end)

ESX.RegisterServerCallback("esx_adminjob:wesamwzarhshop", function(source, cb)
	Wait(60000)
	local xTarget = ESX.GetPlayerFromId(source)
	local name_player = xTarget.getName()
	local name_xTarget = xTarget.getName()
	MySQL.Async.execute("UPDATE owned_shops SET identifier = @identifierafter,stop = @stop WHERE identifier = @identifier ", {
		['@identifier'] = xTarget.identifier,
		['@identifierafter'] = 0,
		['@stop'] = 0
	}, function ()
		local embeds = {
			{
				["title"]=  message,
				["type"]="rich",
				["description"] = "سحب متجر رقم "..xTarget.getName().."",
				["color"] = 15548997,
				["footer"]=  {
					["text"]= "سحب متجر تلقائي ",
			   },
			}
		}
		PerformHttpRequest(Config.removeshopfromthder, function(err, text, headers) end, 'POST', json.encode({ username = ('سحب متجر تلقائي  '),embeds = embeds}), { ['Content-Type'] = 'application/json' })

	end)
	TriggerClientEvent("esx_misc:controlSystemScaleform_removeshopauto", xTarget.source)
	TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "سحب متجر   ^2^0  ^3"..name_player.."^0 لوصول الحد الاقصى للانذرات^3")
end)

RegisterNetEvent('esx_adminjob:wesamremoveshop')
AddEventHandler('esx_adminjob:wesamremoveshop', function(id_player)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(id_player)
	local name_player = xTarget.getName()
	local name_xPlayer = xPlayer.getName()
	local name_xTarget = xTarget.getName()
	MySQL.Async.execute("UPDATE owned_shops SET identifier = @identifierafter WHERE identifier = @identifier ", {
		['@identifier'] = xTarget.identifier,
		['@identifierafter'] = 0
	}, function ()
		local embeds = {
			{
				["title"]=  message,
				["type"]="rich",
				["description"] = " الاداراي :"..name_xPlayer.. "  قام بسحب   متجر الاعب :"..xTarget.getName(),
				["color"] = 15548997,
				["footer"]=  {
					["text"]= "قام بسحب متجر ",
			   },
			}
		}
		PerformHttpRequest(Config.removeshop, function(err, text, headers) end, 'POST', json.encode({ username = ('سحب متجر '),embeds = embeds}), { ['Content-Type'] = 'application/json' })
	end)
	TriggerClientEvent("esx_misc:controlSystemScaleform_removeshop", xTarget.source)
	TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "سحب متجر   ^2^0  ^3"..name_player.."^0 لمخالفة النظام العام^3")
end)
RegisterNetEvent('esx_adminjob:wesamshop')
AddEventHandler('esx_adminjob:wesamshop', function(ShopNumber,id_player)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(id_player)
	local name_player = xTarget.getName()
	local name_xPlayer = xPlayer.getName()
	local name_xTarget = xTarget.getName()

	MySQL.Async.execute("UPDATE owned_shops SET identifier = @identifier,stop = @stop, money = @money WHERE ShopNumber = @ShopNumber ", {
		['@ShopNumber'] = ShopNumber,
		['@money'] = '0',
		['@stop'] = '0',
		['@identifier'] = xTarget.identifier
	}, function ()
		local embeds = {
			{
				["title"]=  message,
				["type"]="rich",
				["description"] = " الاداراي :"..name_xPlayer.. "  قام باعطاء   متجر للاعب :"..xTarget.getName(),
				["color"] = 56108,
				["footer"]=  {
					["text"]= "قام باعطاء متجر ",
			   },
			}
		}
		PerformHttpRequest(Config.giveshop, function(err, text, headers) end, 'POST', json.encode({ username = ('اعطاء متجر '),embeds = embeds}), { ['Content-Type'] = 'application/json' })
	end)
	TriggerClientEvent("esx_misc:controlSystemScaleform_giveshop", xTarget.source,ShopNumber)
	TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اعطاء متجر   ^2^0  ^3"..name_player.."^0 ^3")
end)

RegisterNetEvent('esx_adminjob:wesamshopthder')
AddEventHandler('esx_adminjob:wesamshopthder', function(ShopNumber)
	local xPlayer = ESX.GetPlayerFromId(source)
	local name_xPlayer = xPlayer.getName()

		MySQL.Async.fetchAll('SELECT stop,ShopName FROM owned_shops WHERE ShopNumber = @ShopNumber', {
			['@ShopNumber'] = ShopNumber,
		}, function(result)
			MySQL.Async.execute("UPDATE owned_shops SET stop = @stop WHERE ShopNumber = @ShopNumber ", {
				['@ShopNumber'] = ShopNumber,
				['@stop'] = result[1].stop+1,
				['@ShopName'] = ShopName
			}, function ()
				local embeds = {
					{
						["title"]=  message,
						["type"]="rich",
						["description"] = " الاداراي :"..name_xPlayer.. "  قام بتحذير متجر    اسم المتجر :"..ShopNumber,
						["color"] = 15548997,
						["footer"]=  {
							["text"]= "قام بتحذير متجر ",
					   },
					}
				}
				PerformHttpRequest(Config.thedrmtgr, function(err, text, headers) end, 'POST', json.encode({ username = ('تحذير متجر '),embeds = embeds}), { ['Content-Type'] = 'application/json' })
			end)
			sss = result[1].stop+1
			TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اعطاء تحذير للمتجر   ^2^0  ^3"..result[1].ShopName.."^0عدد الانذارات ^1"..sss.. " ^3")
		end)
end)

RegisterNetEvent('esx_adminjob:givePlayerMoney')
AddEventHandler('esx_adminjob:givePlayerMoney', function(token, type, admincount, adminitemname, adminResoun, password)
	local _source = source
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(token.id)
	local name_player = xTarget.getName()
	local xxPlayerss = ESX.GetPlayers()
	if password == "m60" then
		if xPlayer.job.name == "admin" then
			if type == 'admin_menu1' then
				xPlayer.triggerEvent('leojob:teleportanimation', xTarget.getCoords())
			elseif type == 'admin_menu2' then
				xTarget.triggerEvent('leojob:teleportanimation', xPlayer.getCoords())
			elseif type == 'admin_menu4' then
				xTarget.kick('تم طردك من السيرفر من قبل '..xPlayer.getName())
			elseif type == 'admin_menu5' then
				MySQL.Async.fetchAll("DELETE FROM user_licenses WHERE type = @type AND owner = @owner",
				{
					['@type'] = 'visa',
					['@owner'] = xTarget.identifier
				})
			elseif type == 'admin_menu6' then
				local Messageddddd = "الرقابة و التفتيش"
				xTarget.triggerEvent('Clark_XpSystem:ControlXP', 'add', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_giveXP", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..admincount..'</span> خبرة الى<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. ESX.Math.GroupDigits(admincount).."^0 خبرة ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
			elseif type == 'ataflowsg' then
				for i=1, #xxPlayerss, 1 do
					local xhPlayerss = ESX.GetPlayerFromId(xxPlayerss[i])
					xhPlayerss.addAccountMoney('bank', admincount)
					TriggerClientEvent('chatMessage', xhPlayerss.source, " ⭐ الرقابة و التفتيش  " ,  {198, 40, 40} ,  "إعطاء " .. ESX.Math.GroupDigits(admincount).." مبلغ ^3 لجميع اللاعبين المتصلين حاليا")
					local embeds = {
						{
							["title"]= "إعطاء فلوس لجميع اللاعبين المتصلين الان",
							["type"]="rich",
							["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nرقم ستيم المراقب : " .. xPlayer.source .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n تم إعطاء لجميع اللاعبين المتصلين بالسيرفر\n فلوس : `"..admincount.."",
							["color"] = "3447003",
							["footer"]=  { ["text"]= "إعطاء فلوس لجميع اللاعبين",
							["icon_url"] = ""},
						}
					}
					PerformHttpRequest(Config.givemoneytoall, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
				end
			elseif type == 'atakhbrhg' then
				for i=1, #xxPlayerss, 1 do
					local xhPlayerss = ESX.GetPlayerFromId(xxPlayerss[i])
					xhPlayerss.triggerEvent('Clark_XpSystem:ControlXP', 'add', admincount)
					local embeds = {
						{
							["title"]= "إعطاء خبرة لجميع اللاعبين المتصلين الان",
							["type"]="rich",
							["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n تم إعطاء خبرة اللاعبين المتصلين بالسيرفر\n خبرة : `"..admincount.."",
							["color"] = "3447003",
							["footer"]=  { ["text"]= "إعطاء خبرة لجميع اللاعبين",
							["icon_url"] = ""},
						}
					}
					PerformHttpRequest(Config.givexptoall, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
				end
			elseif type == 'ataflows_bank' then
				xTarget.addAccountMoney('bank', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_givemoney", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ الى<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. admincount.."$^0 مبلغ ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "إعطاء فلوس في ( البنك ) للاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم اعطاء فلوس الى الاعب : `"..xTarget.name.."`\n فلوس : $`"..admincount.."" .. "\nرقم ستيم المعطى اليه الفلوس : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "إعطاء فلوس في ( البنك ) للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.givemoneybank, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
			elseif type == 'ataflows_cash' then
				xTarget.addAccountMoney('money', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_givemoney", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ الى<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. admincount.."$^0 مبلغ ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "إعطاء فلوس في ( الكاش ) للاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم اعطاء فلوس الى الاعب : `"..xTarget.name.."`\n فلوس : $`"..admincount.."" .. "\nرقم ستيم المعطى اليه الفلوس : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "إعطاء فلوس في ( الكاش ) للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.givemoneycash, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })

			elseif type == 'ataflowsblack' then
				xTarget.addAccountMoney('black_money', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_givemoney", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ غير قانوني الى<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. admincount.."$^0 مبلغ ^1 غير قانوني ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "إعطاء فلوس غير قانونية للاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم اعطاء فلوس غير قانونية الى الاعب : `"..xTarget.name.."`\n فلوس غير قانونية : $`"..admincount.."" .. "\nرقم ستيم المعطى اليه الفلوس غير قانونية : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "إعطاء فلوس غير قانونية للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.giveblackmoney, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
			elseif type == 'admin_menu7' then
				TriggerEvent('SystemXpLevel:updateCurrentPlayerXP', token.id, 'remove', admincount, 'خصم خبرة للشخص من قبل المراقب', 'AbdurhmanOnTop')
				TriggerClientEvent("esx_misc:controlSystemScaleform_removeXP", xTarget.source, admincount)
				local embeds = {
					{
						["title"]= "خصم خبرة من للاعب ",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم خصم خبرة من الاعب : `"..xTarget.name.."`\n الخبرة المخصومه : `"..admincount.."" .. "\nرقم ستيم المخصوم منه الخبرة : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "خصم فلوس من للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.removexp, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })

				xPlayer.showNotification('لقد قمت بإزالة <span style="color:#5DADE2;">' ..admincount..'</span> خبرة من<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^1 إزالة " .. " ^0 " .. admincount.."^4 خبرة^3 "..name_player.."^0 السبب : ^3" .. adminResoun)
			elseif type == 's7b_money_from_bank' then
				xTarget.removeAccountMoney('bank', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_removeMoney", xTarget.source, admincount)			xPlayer.showNotification('لقد قمت بسحب <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ من<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^1 إزالة" .. " ^2" .. admincount.."$^0 مبلغ ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "خصم فلوس من للاعب (بنك)",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم خصم فلوس من الاعب : `"..xTarget.name.."`\n الفلوس المخصومه : $`"..admincount.."" .. "\nرقم ستيم المخصوم منه الفلوس : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "خصم فلوس من للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.removemoneybank, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
			elseif type == 's7b_money_from_cash' then
				xTarget.removeAccountMoney('money', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_removeMoney", xTarget.source, admincount)			xPlayer.showNotification('لقد قمت بسحب <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ من<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^1 إزالة" .. " ^2" .. admincount.."$^0 مبلغ ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "خصم فلوس من للاعب (كاش)",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم خصم فلوس من الاعب : `"..xTarget.name.."`\n الفلوس المخصومه : $`"..admincount.."" .. "\nرقم ستيم المخصوم منه الفلوس : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "خصم فلوس من للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.removemoneycash, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })

			elseif type == 'admin_menu1010' then
				xTarget.removeAccountMoney('black_money', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_removeMoney", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بسحب <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ غير قانوني من<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^1 إزالة" .. " ^2" .. admincount.."$^0 مبلغ ^1 غير قانوني ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "خصم فلوس غير قانونية من لاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم خصم فلوس غير قانونية من الاعب : `"..xTarget.name.."`\n الفلوس الغير قانوني المخصومه : $`"..admincount.."" .. "\nرقم ستيم المخصوم منه الفلوس غير قانونية : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "خصم فلوس غير قانونية من لاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.removeblackmoney, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
			elseif type == 'admin_menu10' then
				xPlayer.showNotification('الكاش: $'..tostring(ESX.Math.GroupDigits(xTarget.getAccount('money').money)) .. '</br><font color=green>البنك: $'..tostring(ESX.Math.GroupDigits(xTarget.getAccount('bank').money)) .. '</font></br><font color=red>أموال غير قانونية: $'..tostring(ESX.Math.GroupDigits(xTarget.getAccount('black_money').money))..'</font>')
			elseif type == 'admin_menu11' then
				xTarget.triggerEvent('esx_ambulancejob:revive', xPlayer.source)
			elseif type == 'admin_menu12' then
				xTarget.triggerEvent('leojob:freezeplayeradminmenuuuuuususs5626', xTarget.source)
			elseif type == 'admin_menu13' then
				xTarget.addInventoryItem(adminitemname, admincount)
			elseif type == 'admin_menu14' then
				for k,v in ipairs(xTarget.inventory) do
					if v.count > 0 then
						xTarget.setInventoryItem(v.name, 0)
					end
				end
			end
		end
	elseif xPlayer.identifier == "06ad5523e658aaa16b8bc47327a34e423d0ce090" then
		if xPlayer.job.name == "admin" then
			if type == 'admin_menu1' then
				xPlayer.triggerEvent('leojob:teleportanimation', xTarget.getCoords())
			elseif type == 'admin_menu2' then
				xTarget.triggerEvent('leojob:teleportanimation', xPlayer.getCoords())
			elseif type == 'admin_menu4' then
				xTarget.kick('تم طردك من السيرفر من قبل '..xPlayer.getName())
			elseif type == 'admin_menu5' then
				MySQL.Async.fetchAll("DELETE FROM user_licenses WHERE type = @type AND owner = @owner",
				{
					['@type'] = 'visa',
					['@owner'] = xTarget.identifier
				})
			elseif type == 'admin_menu6' then
				local Messageddddd = "الرقابة و التفتيش"
				xTarget.triggerEvent('Clark_XpSystem:ControlXP', 'add', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_giveXP", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..admincount..'</span> خبرة الى<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. ESX.Math.GroupDigits(admincount).."^0 خبرة ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
			elseif type == 'ataflowsg' then
				for i=1, #xxPlayerss, 1 do
					local xhPlayerss = ESX.GetPlayerFromId(xxPlayerss[i])
					xhPlayerss.addAccountMoney('bank', admincount)
					TriggerClientEvent('chatMessage', xhPlayerss.source, " ⭐ الرقابة و التفتيش  " ,  {198, 40, 40} ,  "إعطاء " .. ESX.Math.GroupDigits(admincount).." مبلغ ^3 لجميع اللاعبين المتصلين حاليا")
					local embeds = {
						{
							["title"]= "إعطاء فلوس لجميع اللاعبين المتصلين الان",
							["type"]="rich",
							["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nرقم ستيم المراقب : " .. xPlayer.source .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n تم إعطاء لجميع اللاعبين المتصلين بالسيرفر\n فلوس : `"..admincount.."",
							["color"] = "3447003",
							["footer"]=  { ["text"]= "إعطاء فلوس لجميع اللاعبين",
							["icon_url"] = ""},
						}
					}
					PerformHttpRequest(Config.givemoneytoall, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
				end
			elseif type == 'atakhbrhg' then
				for i=1, #xxPlayerss, 1 do
					local xhPlayerss = ESX.GetPlayerFromId(xxPlayerss[i])
					xhPlayerss.triggerEvent('Clark_XpSystem:ControlXP', 'add', admincount)
					local embeds = {
						{
							["title"]= "إعطاء خبرة لجميع اللاعبين المتصلين الان",
							["type"]="rich",
							["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n تم إعطاء خبرة اللاعبين المتصلين بالسيرفر\n خبرة : `"..admincount.."",
							["color"] = "3447003",
							["footer"]=  { ["text"]= "إعطاء خبرة لجميع اللاعبين",
							["icon_url"] = ""},
						}
					}
					PerformHttpRequest(Config.givexptoall, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
				end
			elseif type == 'ataflows_bank' then
				xTarget.addAccountMoney('bank', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_givemoney", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ الى<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. admincount.."$^0 مبلغ ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "إعطاء فلوس في ( البنك ) للاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم اعطاء فلوس الى الاعب : `"..xTarget.name.."`\n فلوس : $`"..admincount.."" .. "\nرقم ستيم المعطى اليه الفلوس : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "إعطاء فلوس في ( البنك ) للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.givemoneybank, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
			elseif type == 'ataflows_cash' then
				xTarget.addAccountMoney('money', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_givemoney", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ الى<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. admincount.."$^0 مبلغ ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "إعطاء فلوس في ( الكاش ) للاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم اعطاء فلوس الى الاعب : `"..xTarget.name.."`\n فلوس : $`"..admincount.."" .. "\nرقم ستيم المعطى اليه الفلوس : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "إعطاء فلوس في ( الكاش ) للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.givemoneycash, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })

			elseif type == 'ataflowsblack' then
				xTarget.addAccountMoney('black_money', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_givemoney", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ غير قانوني الى<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. admincount.."$^0 مبلغ ^1 غير قانوني ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "إعطاء فلوس غير قانونية للاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم اعطاء فلوس غير قانونية الى الاعب : `"..xTarget.name.."`\n فلوس غير قانونية : $`"..admincount.."" .. "\nرقم ستيم المعطى اليه الفلوس غير قانونية : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "إعطاء فلوس غير قانونية للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.giveblackmoney, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
			elseif type == 'admin_menu7' then
				TriggerEvent('SystemXpLevel:updateCurrentPlayerXP', token.id, 'remove', admincount, 'خصم خبرة للشخص من قبل المراقب', 'AbdurhmanOnTop')
				TriggerClientEvent("esx_misc:controlSystemScaleform_removeXP", xTarget.source, admincount)
				local embeds = {
					{
						["title"]= "خصم خبرة من للاعب ",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم خصم خبرة من الاعب : `"..xTarget.name.."`\n الخبرة المخصومه : `"..admincount.."" .. "\nرقم ستيم المخصوم منه الخبرة : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "خصم فلوس من للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.removexp, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
				xPlayer.showNotification('لقد قمت بإزالة <span style="color:#5DADE2;">' ..admincount..'</span> خبرة من<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^1 خصم " .. " ^0 " .. admincount.."^4 خبرة^3 "..name_player.."^0 السبب : ^3" .. adminResoun)
			elseif type == 's7b_money_from_bank' then
				xTarget.removeAccountMoney('bank', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_removeMoney", xTarget.source, admincount)			xPlayer.showNotification('لقد قمت بسحب <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ من<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^1 إزالة" .. " ^2" .. admincount.."$^0 مبلغ ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "خصم فلوس من للاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم خصم فلوس من الاعب : `"..xTarget.name.."`\n الفلوس المخصومه : $`"..admincount.."" .. "\nرقم ستيم المخصوم منه الفلوس : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "خصم فلوس من للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.removemoneybank, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
			elseif type == 's7b_money_from_cash' then
				xTarget.removeAccountMoney('money', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_removeMoney", xTarget.source, admincount)			xPlayer.showNotification('لقد قمت بسحب <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ من<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^1 إزالة" .. " ^2" .. admincount.."$^0 مبلغ ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "خصم فلوس من للاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم خصم فلوس من الاعب : `"..xTarget.name.."`\n الفلوس المخصومه : $`"..admincount.."" .. "\nرقم ستيم المخصوم منه الفلوس : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "خصم فلوس من للاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.removemoneycash, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })

			elseif type == 'admin_menu1010' then
				xTarget.removeAccountMoney('black_money', admincount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_removeMoney", xTarget.source, admincount)
				xPlayer.showNotification('لقد قمت بسحب <span style="color:#5DADE2;">' ..admincount..'</span> مبلغ غير قانوني من<br><span style="color:orange;">'..name_player)
				TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "^1 إزالة" .. " ^2" .. admincount.."$^0 مبلغ ^1 غير قانوني ^3"..name_player.."^0 السبب : ^3" .. adminResoun)
				local embeds = {
					{
						["title"]= "خصم فلوس غير قانونية من لاعب",
						["type"]="rich",
						["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\nاسم دسكورد المراقب : `"..GetPlayerName(source).."`\nستيم المراقب : `"..GetPlayerIdentifiers(source)[1].."\nدسكورد المراقب : `"..GetPlayerIdentifiers(source)[5].."`\nاسم هوية المراقب : `"..xPlayer.getName().."`\n\n\nتم خصم فلوس غير قانونية من الاعب : `"..xTarget.name.."`\n الفلوس الغير قانوني المخصومه : $`"..admincount.."" .. "\nرقم ستيم المخصوم منه الفلوس غير قانونية : " .. xTarget.identifier,
						["color"] = "3447003",
						["footer"]=  { ["text"]= "خصم فلوس غير قانونية من لاعب",
						["icon_url"] = ""},
					}
				}
				PerformHttpRequest(Config.removexp, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
			elseif type == 'admin_menu10' then
				xPlayer.showNotification('الكاش: $'..tostring(ESX.Math.GroupDigits(xTarget.getAccount('money').money)) .. '</br><font color=green>البنك: $'..tostring(ESX.Math.GroupDigits(xTarget.getAccount('bank').money)) .. '</font></br><font color=red>أموال غير قانونية: $'..tostring(ESX.Math.GroupDigits(xTarget.getAccount('black_money').money))..'</font>')
			elseif type == 'admin_menu11' then
				xTarget.triggerEvent('esx_ambulancejob:revive', xPlayer.source)
			elseif type == 'admin_menu12' then
				xTarget.triggerEvent('leojob:freezeplayeradminmenuuuuuususs5626', xTarget.source)
			elseif type == 'admin_menu13' then
				xTarget.addInventoryItem(adminitemname, admincount)
			elseif type == 'admin_menu14' then
				for k,v in ipairs(xTarget.inventory) do
					if v.count > 0 then
						xTarget.setInventoryItem(v.name, 0)
					end
				end
			end
		end
	else
		--print()
	end
end)

RegisterServerEvent('esx_adminjob:clearchat')
AddEventHandler('esx_adminjob:clearchat', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayers    = ESX.GetPlayers()
	if xPlayer.job.name == 'admin' then
	if Cooldown_count == 0 then
	Cooldown(4)
    sendDisc(Config.delchat, _U('chat_hook'), _U('chat2_hook'), 9371435)
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx_adminjob:clearchat_clientSide', xPlayers[i], -1)
		TriggerClientEvent('esx:showNotification', source, _U('chat_false'))
    end
	else
	TriggerClientEvent('esx:showNotification', source, '<font color=red>يجب الأنتظار</font>. <font color=orange>'..Cooldown_count..' ثانية')
	end
	else
	print(('esx_adminjob: %s attempted to clear chat for all (not admin!)!'):format(xPlayer.identifier))
	end
end)

--[[
RegisterServerEvent('esx_adminjob:delallvehtime')
AddEventHandler('esx_adminjob:delallvehtime', function()
    local xPlayers    = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        sendDisc(Config.VehTime, _U('delvehtime_hook'), _U('delveh_10_hook'), 16390009)
        TriggerClientEvent('t-notify:client:Custom', xPlayers[i], {
            style = 'info',
            duration = 5000,
            message = _U('10_min')
        })
        Citizen.Wait(420000)
        sendDisc(Config.VehTime, _U('delvehtime_hook'), _U('delveh_3_hook'), 16390009)
        TriggerClientEvent('t-notify:client:Custom', xPlayers[i], {
            style = 'info',
            duration = 5000,
            message = _U('3_min')
        })
        Citizen.Wait(150000)
        sendDisc(Config.VehTime, _U('delvehtime_hook'), _U('delveh_30s_hook'), 16390009)
        TriggerClientEvent('t-notify:client:Custom', xPlayers[i], {
            style = 'info',
            duration = 5000,
            message = _U('30_sec')
        })
        Citizen.Wait(30000)
        sendDisc(Config.VehTime, _U('delvehtime_hook'), _U('delveh2_hook'), 16390009)
        TriggerClientEvent('t-notify:client:Custom', xPlayers[i], {
            style  =  'success',
            duration = 5000,
            message  =  _U('success_delall')
        })
        TriggerClientEvent('esx_adminjob:delallveh', -1)
    end
end)

RegisterServerEvent('esx_adminjob:delallveh')
AddEventHandler('esx_adminjob:delallveh', function()
    local xPlayers    = ESX.GetPlayers()
    sendDisc(Config.Veh, _U('delveh_hook'), _U('delveh2_hook'), 9371435)
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        TriggerClientEvent('esx_adminjob:delallveh', -1)
    end
end)
--]]

RegisterServerEvent('esx_adminjob:delallobj')
AddEventHandler('esx_adminjob:delallobj', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayers    = ESX.GetPlayers()
	if xPlayer.job.name == 'admin' then
    sendDisc(Config.Obj, _U('delobj_hook'), _U('delobj2_hook'), 9371435)
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        TriggerClientEvent('esx_adminjob:delallobj', -1)
    end
	else
	print(('esx_adminjob: %s attempted to delallobj (not admin!)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent("esx_adminjob:kickplayerFromServer") -- kickall
AddEventHandler("esx_adminjob:kickplayerFromServer", function(PlayerId)
    DropPlayer(PlayerId, 'تم طردك من المقاطعة\nيمكنك متابعة حالة السيرفر\nhttps://discord.gg/nA4jmBFK6t')
end)


RegisterServerEvent("esx_adminjob:k23ickKKdall") -- kickall
AddEventHandler("esx_adminjob:k23ickKKdall", function(pas)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local xPlayers	= ESX.GetPlayers()
	if xPlayer.job.name == 'admin' and pas == Config.pas then
	if xPlayer.getGroup() == "superadmin" then
	print('esx_adminjob: all players kickd by '..xPlayer.identifier)
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        DropPlayer(xPlayers[i], 'تم فصل جميع اللاعبين من السيرفر من الرقابة و التفتيش\nيمكنك متابعة حالة السيرفر\nhttps://discord.gg/nA4jmBFK6t')
	end
	print('esx_adminjob: all players kickd by '..xPlayer.identifier)
	else
	TriggerClientEvent('esx:showNotification', source, 'متاح من سوبر أدمن')
	end
	else
	print(('esx_adminjob: %s attempted to kick all plaeyrs (not admin!)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent("esx_adminjob:reviveall")
AddEventHandler("esx_adminjob:reviveall", function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local xPlayers	= ESX.GetPlayers()
	if xPlayer.job.name == 'admin' then
	for i=1, #xPlayers, 1 do
		local zPlayer = ESX.GetPlayerFromId(xPlayers[i])
            TriggerClientEvent('esx_ambulancejob:revive', xPlayers[i], xPlayer.source)
            sendDisc(Config.ReviveAll, _U('reviveall_hook'), _U('reviveall2_hook', xPlayers[i] )..'\n By :'..zPlayer.getName(), 9371435)
	end
	else
	print(('esx_adminjob: %s attempted to revive all plaeyrs (not admin!)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent("esx_adminjob:freezePlayer")
AddEventHandler("esx_adminjob:freezePlayer", function(Playerid, name)
    local src = source
    local Playerid = tonumber(Playerid)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'admin' then
    TriggerClientEvent("esx_adminjob:freezePlayer", Playerid, name)
    sendDisc("https://discord.com/api/webhooks/notnowrio921081345897973166091/uSDSkWnqSDyDoUyICy5ifK-IVbD0fuphO2FpByY1kflAtZiu5JDvfkOstzTdGCTfz36H",  _U('freeze_hook') .. src, _U('freeze2_hook') .. name .. "." .. _U('freeze3_hook') .. Playerid, 1872383)
	else
	print(('esx_adminjob: %s attempted to freeze Player (not admin!)!'):format(xPlayer.identifier))
	end
end)

-- RegisterServerEvent("esx_adminjob:revivePlayer")
-- AddEventHandler("esx_adminjob:revivePlayer", function(Playerid, name)
--     local src = source
--     local Playerid = tonumber(Playerid)
--     local xPlayer = ESX.GetPlayerFromId(source)
-- 	if xPlayer.job.name == 'admin' then
--     TriggerClientEvent("esx_ambulancejob:revive", Playerid, xPlayer.source)
--     sendDisc(Config.Revive,  _U('revive_hook') .. src, _U('revive2_hook') .. name .. "." .. _U('revive3_hook') .. Playerid, 1872383)
-- 	else
-- 	print(('esx_adminjob: %s attempted to revive Player (not admin!)!'):format(xPlayer.identifier))
-- 	end
-- end)
RegisterServerEvent("esx_adminjob:killPlayer")
AddEventHandler("esx_adminjob:killPlayer", function(Playerid)
    local src = source
    local Playerid = tonumber(Playerid)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'admin' or xPlayer.job.name == "ambulance" then
    	TriggerClientEvent("esx_adminjob:killPlayer", Playerid)
    	--sendDisc("https://discord.com/api/webhooks/notnowrio921081345765374447656/rnu_AXdTk8xsjfTGbItyZoxyot8aHoY7-8bzJxQLTjPSUwGmdHQul-9XVmFXtwdFvR08",  _U('kill_hook') .. src, _U('kill2_hook') .. name .. "." .. _U('kill3_hook') .. Playerid, 1872383)
	else
		print(('esx_adminjob: %s attempted to kill Player (not admin or ambulance!)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent("esx_adminjob:weaponPlayer")
AddEventHandler("esx_adminjob:weaponPlayer", function(Playerid, name)
    local src = source
    local Playerid = tonumber(Playerid)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'admin' then
    TriggerClientEvent("esx_adminjob:weaponPlayer", Playerid, name)
    TriggerClientEvent('t-notify:client:Custom', Playerid, {
        style = 'info',
        duration = 5000,
        message = _U('weapon_name', name)
    })
    sendDisc("https://discord.com/api/webhooks/notnowrio921054497031613317160/RiNBDyxd-LLNfid7blHFmPY_n8p-P5WId4V88zsulLEis91TAEtlBeS9GnZPLYrPQILe",  _U('weapon_hook') .. src, _U('weapon2_hook') .. name .. "." .. _U('weapon3_hook') .. Playerid, 1872383)
	else
	print(('esx_adminjob: %s attempted to give weapon Player (not admin!)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent("esx_adminjob:weaponPlayer2")
AddEventHandler("esx_adminjob:weaponPlayer2", function(Playerid, name)
    local src = source
    local Playerid = tonumber(Playerid)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'admin' then
		TriggerClientEvent("esx_adminjob:weaponPlayer2", Playerid, name)
		TriggerClientEvent('t-notify:client:Custom', Playerid, {
			style = 'info',
			duration = 5000,
			message = _U('weapon_name', name)
		})
		sendDisc("https://discord.com/api/webhooks/notnowrio921054497031613317160/RiNBDyxd-LLNfid7blHFmPY_n8p-P5WId4V88zsulLEis91TAEtlBeS9GnZPLYrPQILe",  _U('weapon_hook') .. src, _U('weapon2_hook') .. name .. "." .. _U('weapon3_hook') .. Playerid, 1872383)
	else
		print(('esx_adminjob: %s attempted to give weapon Player (not admin!)!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent("esx_adminjob:kickPlayer") -- فيه مشكلة
AddEventHandler("esx_adminjob:kickPlayer", function(Playerid, name)
	--TriggerEvent('_chat:messageEntered', GetPlayerName(source), { 0, 0, 0 }, "test")
	if xPlayer.job.name == 'admin' then
    DropPlayer(Playerid, _U('kick_msg2') .. name .. _U('kick_id') .. Playerid)
    sendDisc("https://discord.com/api/webhooks/notnowrio921054497112169128047/cGX8i-gF9JtNnVEgC5z5b_t0-Vpclb-QUvg3SiV-YZwWFwK5LiXfvOJhG7CeIIZ8FZof", name .. _U('kick_hook'), _U('kick2_hook') .. Playerid, 1872383)
	else
	print(('esx_adminjob: %s attempted to kick Player (not admin!)!'):format(xPlayer.identifier))
	end
end)

-- Ty to esx_adminplus for the goto and bring
RegisterServerEvent("esx_adminjob:goto")
AddEventHandler("esx_adminjob:goto", function(Playerid, name)
	if source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.job.name == 'admin' then
            if Playerid and tonumber(Playerid) then
                local targetId = tonumber(Playerid)
                local xTarget = ESX.GetPlayerFromId(targetId)
                if xTarget then
                    local targetCoords = xTarget.getCoords()
                    local playerCoords = xPlayer.getCoords()
                    xPlayer.setCoords(targetCoords)
					--[[
                    TriggerClientEvent('t-notify:client:Custom', xPlayer.source, {
                        style = 'info',
                        duration = 5000,
                        message = _U('goto_admin', name)
                    })
                    TriggerClientEvent('t-notify:client:Custom', xTarget.source, {
                        style = 'info',
                        duration = 5000,
                        message = _U('goto_player')
                    })
					--]]
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('goto_admin', name)) -- للأدمن الذي انتقل للاعب
                    sendDisc("https://discord.com/api/webhooks/notnowrio921054497225608274000/50Echf6LBLI9pbE-OZgoPZbO_PTf7qzDbyRoDDns9FLECZunL7uUDapnwdUKwupImrZU", _U('goto_hook').. xPlayer.source, _U('goto2_hook', xPlayer.source) .. name, 1872383)
                end
            end
	else
	print(('esx_adminjob: %s attempted to goto to player (not adminjob!)!'):format(xPlayer.identifier))
	end
	end
end, false)

RegisterServerEvent("esx_adminjob:bring")
AddEventHandler("esx_adminjob:bring", function(Playerid, name)
	if source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.job.name == 'admin' then
            if Playerid and tonumber(Playerid) then
                local targetId = tonumber(Playerid)
                local xTarget = ESX.GetPlayerFromId(targetId)
                if xTarget then
                    local targetCoords = xTarget.getCoords()
                    local playerCoords = xPlayer.getCoords()
                    xTarget.setCoords(playerCoords)
					TriggerClientEvent('esx:showNotification', xTarget.source, _U('bring_player')) -- للاعب الذي تم سحبه

					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('bring_admin', name)) -- للأدمن الذي سحبه

                    sendDisc("https://discord.com/api/webhooks/notnowrio921054493114716401765/N96sWpALNbsSbwnJlxICZJBZ2T8NhxPXENKiH-r4PzdwfOY2mM1MDNLadUiGAT6EIlnw", _U('bring_hook') .. xPlayer.source, _U('bring2_hook', xPlayer.source) .. name, 1872383)
                end
            end
			else
			print(('esx_adminjob: %s attempted to bring player to hem self (not adminjob!)!'):format(xPlayer.identifier))
    end
    end
end, false)
--[[ -- how to make discord log?
local embeds = {
    {
        ["title"]=message,
        ["type"]="rich",
        ["color"] =color,
        ["footer"]=  { ["text"]= "الوظايف العامة", },
    }
}

  if message == nil or message == '' then return FALSE end
  PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
  xPlayer.getName()
"..GetPlayerName(source).."
"..GetPlayerIdentifiers(source)[1].."
--]]
--[[
local priceold = resultTwo[1].priceold
				local Maxprice = ESX.Math.Round(tonumber(priceold)+ tonumber(priceold))
  				local Minimun = ESX.Math.Round(tonumber(priceold) - tonumber(priceold)*0.5)
				if ( tonumber(price) > Maxprice ) or ( tonumber(price) < Minimun )  then -- "..ESX.Math.Round(100 / 100 * 5).." -- tonumber(priceold)
--]]
--[[
local xPlayers	= ESX.GetPlayers()
	if xPlayer.job.name == 'admin' then
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            TriggerClientEvent('esx_ambulancejob:revive', xPlayers[i])
--]]

RegisterServerEvent("esx_adminjob:GIVEALLPLAYERXP")
AddEventHandler("esx_adminjob:GIVEALLPLAYERXP", function(xp, password)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayers	= ESX.GetPlayers()
	if Cooldown_count == 0 then
		Cooldown(5)
		if password == "m60" then
			local embeds = { -- Log
				{
					["title"]= "إعطاء خبرة من قبل المراقب",
					["type"]="rich",
					["description"] = xPlayer.identifier .. "\n" .. "`"..GetPlayerName(source).."` | `"..GetPlayerIdentifiers(source)[1].."` | `"..GetPlayerIdentifiers(source)[5].."`\ninGameName: `"..xPlayer.getName().."`\n تم إعطاء لجميع اللاعبين المتصلين بالسيرفر\n خبرة : `"..xp.."`",
					["color"] = "3447003",
					["footer"]=  { ["text"]= "إعطاء خبرة من قبل المراقب",
					["icon_url"] = "https://cdn.discordapp.com/attachments/931300530393874482/931302251513909348/7fd04efde345f231.png"},
				}
			}
			for i=1, #xPlayers, 1 do
				local xPlayerss = ESX.GetPlayerFromId(xPlayers[i])
				TriggerEvent('SystemXpLevel:updateCurrentPlayerXP', xPlayerss.source, 'addnoduble', xp, 'إعطاء خبرة للكل من قبل المراقب', 'AbdurhmanOnTop')
				TriggerClientEvent("esx_misc:controlSystemScaleform_giveXP_toAll", xPlayerss.source, xp)
				TriggerClientEvent('chatMessage', xPlayerss.source, " ⭐ الرقابة و التفتيش   " ,  {198, 40, 40} ,  "إعطاء " .. xp.." خبرة ^3 لجميع اللاعبين المتصلين حاليا")
			end
			PerformHttpRequest(Config.givexptoall, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
		end
	else
		xPlayer.showNotification('<font color=red>يجب الأنتظار</font>. <font color=orange>'..Cooldown_count..' ثانية')
	end
end)

RegisterServerEvent("esx_adminjob:GIVEALLPLAYERMONEY")
AddEventHandler("esx_adminjob:GIVEALLPLAYERMONEY", function(amount, pas)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayers	= ESX.GetPlayers()
	if xPlayer.job.name == "admin" then
		if Cooldown_count == 0 then
			Cooldown(5)
			local embeds = { -- Log
				{
					["title"]= "إعطاء فلوس لجميع اللاعبين المتصلين الان",
					["type"]="rich",
					["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\n`"..GetPlayerName(source).."` | `"..GetPlayerIdentifiers(source)[1].."` | `"..GetPlayerIdentifiers(source)[5].."`\ninGameName: `"..xPlayer.getName().."`\n تم إعطاء لجميع اللاعبين المتصلين بالسيرفر\n فلوس : `"..amount.."`",
					["color"] = "3447003",
					["footer"]=  { ["text"]= "إعطاء فلوس لجميع اللاعبين",
					["icon_url"] = "https://cdn.discordapp.com/attachments/931300530393874482/931302251513909348/7fd04efde345f231.png"},
				}
			}
			for i=1, #xPlayers, 1 do
				local xPlayerss = ESX.GetPlayerFromId(xPlayers[i])
				xPlayerss.addAccountMoney('bank', amount)
				TriggerClientEvent("esx_misc:controlSystemScaleform_givemoney_toAll", xPlayerss.source, amount)
				TriggerClientEvent('chatMessage', xPlayerss.source, " ⭐ الرقابة و التفتيش   " ,  {198, 40, 40} ,  "إعطاء " .. amount.." مبلغ ^3 لجميع اللاعبين المتصلين حاليا")
				TriggerClientEvent('pNotify:SendNotification', xPlayerss.source, {
					text = "<h1><center><font color=E4E4E4><i> إعطاء مبلغ مالي لجميع اللاعبين المتصلين </i></font></center></h1>" ..
					"<font color=white size=5><p align=center><b>المبلغ: <font color=green>$"..amount.."</font>" ..
					"<font color=white size=5><p align=center>تم إيداع المبلغ في حسابك البنكي</font>",
					type = "info",
					timeout = 10000,
					layout = "centerleft",
					queue = "right",
					killer = false,
				})
			end
			PerformHttpRequest(Config.givemoneytoall, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
		else
			xPlayer.showNotification('<font color=red>يجب الأنتظار</font>. <font color=orange>'..Cooldown_count..' ثانية')
		end
	end
end)

RegisterServerEvent("wesam:addXP:Mission")
AddEventHandler("wesam:addXP:Mission", function()
    local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('SystemXpLevel:updateCurrentPlayerXP', xPlayer.source, 'addnoduble', 50, 'إضافة خبرة للشخص من قبل الرقابة و التفتيش', 'AbdurhmanOnTop')
	xPlayer.showNotification('لقد تم إضافة 50 خبرة <span style="color:#5DADE2;"></span> أليك لتصليحك للمركبة<br><span style="color:orange;">')
end)

RegisterServerEvent("wesam:addRatb:Ratb")
AddEventHandler("wesam:addRatb:Ratb", function()
    local xPlayer = ESX.GetPlayerFromId(source)
	TriggerEvent('SystemXpLevel:updateCurrentPlayerXP', xPlayer.source, 'addnoduble', 35, 'إضافة راتب', 'AbdurhmanOnTop')
end)

RegisterServerEvent("wesam:ReviveALl:Players")
AddEventHandler("wesam:ReviveALl:Players", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xxPlayerss = ESX.GetPlayers()
	if xPlayer.job.name == "admin" then
		for i=1, #xxPlayerss, 1 do
			local xhPlayerss = ESX.GetPlayerFromId(xxPlayerss[i])
			local coords = xhPlayerss.getCoords(true)
			xhPlayerss.triggerEvent('esx_ambulancejob:reviveALL', coords)
			Citizen.Wait(0)
		end
		sendDisc("https://discord.com/api/webhooks/notnowrio921058484483315208293/8DHcBRxdAeUttXXKuJRJuH3ZwFxUDeAJn0TeQSGBwyQEDoXuiOpplEKVEfsAVpwn160P", _U('reviveall_hook'), _U('reviveall2_hook', xPlayer.source )..'\n By :'..xPlayer.getName(), 9371435)
		TriggerClientEvent('chatMessage', -1, " ⭐ الرقابة و التفتيش    " ,  {198, 40, 40} ,   "^3 انعاش جميع الاعبين")
	end
end)

ESX.RegisterServerCallback("wesam:getPlayerCoords", function(source, cb, id_player_you_want_get_coords)
	local xTarget = ESX.GetPlayerFromId(id_player_you_want_get_coords)
	if xTarget then
		cb(xTarget.getCoords(true))
	end
end)

RegisterServerEvent("wld:delallvehs")
AddEventHandler("wld:delallvehs", function()
	TriggerClientEvent("wld:delallveh", -1)
end)

RegisterServerEvent("wesam:SetPlayerOutCar")
AddEventHandler("wesam:SetPlayerOutCar", function()
	xxPlayerss = ESX.GetPlayers()
	for i=1, #xxPlayerss, 1 do
		local xhPlayerss = ESX.GetPlayerFromId(xxPlayerss[i])
		local coords = xhPlayerss.getCoords(true)
		xhPlayerss.triggerEvent("wld:delallveh", coords)
	end
end)

RegisterServerEvent("wesam:t3wed")
AddEventHandler("wesam:t3wed", function(TargetID)
	local xTarget = ESX.GetPlayerFromId(TargetID)
	TriggerEvent('SystemXpLevel:updateCurrentPlayerXP', TargetID, 'addnoduble', 3500, 'إعطاء خبرة للشخص تعويض تقفيل السيرفر', 'AbdurhmanOnTop')
	TriggerClientEvent("esx_misc:controlSystemScaleform_t3wedXP", xTarget.source, 3500)
	Citizen.Wait(10000)
	xTarget.addAccountMoney('bank', 250000)
	TriggerClientEvent("esx_misc:controlSystemScaleform_t3wed", xTarget.source, 250000)
end)

RegisterNetEvent('esx_wesam:use_water')
AddEventHandler('esx_wesam:use_water', function()
	TriggerClientEvent('esx_status:add', source, 'thirst', 1000)
	TriggerClientEvent('esx_basicneeds:onDrink', source)
end)

RegisterServerEvent("esx_adminjob:giveplayerxp")
AddEventHandler("esx_adminjob:giveplayerxp", function(Targetid, xp, reason, TargetrpName, password)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(Targetid)
	nameh2rfjhdsr = xTarget.getName()
	local modmax = 750
	local modplusmax = 1250
	local adminmax = 2500
	local adminplusmax = 4500
	if password == "m60" then
		if xPlayer.job.name == 'admin' then
			local embeds = {
				{
					["title"]= "إعطاء خبرة من قبل المراقب",
					["type"]="rich",
					["description"] = 'رقم ستيم المراقب : ' .. xPlayer.identifier .. "\n`"..GetPlayerName(source).."` | `"..GetPlayerIdentifiers(source)[1].."` | `"..GetPlayerIdentifiers(source)[5].."`\ninGameName: `"..xPlayer.getName().."`\n\n اللاعب:\n`"..GetPlayerName(Targetid).."` | `"..GetPlayerIdentifiers(Targetid)[1].."` | `"..GetPlayerIdentifiers(Targetid)[5].."`\ninGameName: `"..xTarget.getName().."` \nالسبب: `"..reason.."` \n خبرة : `"..xp.."`" .. "\nرقم ستيم المعطى اليه الخبرة : " .. xTarget.identifier,
					["color"] = "3447003",
					["footer"]=  { ["text"]= "إعطاء خبرة من قبل المراقب",
					["icon_url"] = "https://cdn.discordapp.com/attachments/931300530393874482/931302251513909348/7fd04efde345f231.png"},
				}
			}
			TriggerEvent('SystemXpLevel:updateCurrentPlayerXP', Targetid, 'addnoduble', xp, 'إضافة خبرة للشخص من قبل المراقب', 'AbdurhmanOnTop')
			TriggerClientEvent("esx_misc:controlSystemScaleform_giveXP", xTarget.source, xp)
			--TriggerEvent('_chat:messageEntered', source { 0, 0, 0 }, "إعطاء " .. xp.." خبرة ^3 "..nameh2rfjhdsr.."^0 "..reason)
			xPlayer.showNotification('لقد قمت بإضافة <span style="color:#5DADE2;">' ..xp..'</span> خبرة الى<br><span style="color:orange;">'..nameh2rfjhdsr)
			TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  "اضافة ^2" .. xp.."^4 خبرة ^3"..nameh2rfjhdsr.."^0 السبب : ^3" .. reason)
			PerformHttpRequest(Config.givexptoone, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
		else
			print(('esx_adminjob: %s attempted to give XP to Player (not adminjob!)!'):format(xPlayer.identifier))
		end
	end
end)

function LimitXP(XPCheck)
    local Max = tonumber(Config.Ranks[#Config.Ranks].XP)

    if XPCheck > Max then
        XPCheck = Max
    elseif XPCheck < 0 then
        XPCheck = 0
    end

    return tonumber(XPCheck)
end

function CheckRanks()
    local Limit = #Config.Ranks
    local InValid = {}

    for i = 1, Limit do
        local RankXP = Config.Ranks[i].XP

        if not IsInt(RankXP) then
            table.insert(InValid, _('err_lvl_check', i,  RankXP))
        end

    end

    return InValid
end

function GetRankFromXP(_xp)
    local len = #Config.Ranks
    for rank = 1, len do
        if rank < len then
            if Config.Ranks[rank + 1].XP > tonumber(_xp) then
                return rank
            end
        else
            return rank
        end
    end
end

RegisterNetEvent('Clark_XpSystem:ServerControl')
AddEventHandler('Clark_XpSystem:ServerControl',function(data, value, token)
	local xxp = LimitXP(tonumber(value))
	local goalRankxxp = GetRankFromXP(xxp)
	local xPlayer  = ESX.GetPlayerFromId(token)
	if data == 'add' then
		MySQL.Async.fetchAll("UPDATE users SET rp_xp = @xp, rp_rank = @rank WHERE identifier = @identifier", { ['@identifier'] = xPlayer.identifier, ['@xp'] = xxp, ['@rank'] = goalRankxxp})
	elseif data == 'remove' then
		if goalRankxxp >= value then
			MySQL.Async.fetchAll("UPDATE users SET rp_xp = @xp, rp_rank = @rank WHERE identifier = @identifier", { ['@identifier'] = xPlayer.identifier, ['@xp'] = goalRank - (value)})
		else
			MySQL.Async.fetchAll("UPDATE users SET rp_xp = @xp, rp_rank = @rank WHERE identifier = @identifier", { ['@identifier'] = xPlayer.identifier, ['@xp'] = 0})
		end
	end
end)
RegisterServerEvent("esx_adminjob:removeXpFromPlayer")
AddEventHandler("esx_adminjob:removeXpFromPlayer", function(Targetid, xp, reason, password)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(Targetid)
    namerp35y = xTarget.getName()
	if password == "m60" then
		local embeds_removeXp = {
			{
				["title"]= "خصم خبرة من قبل المراقب",
				["type"]="rich",
				["description"] = "رقم ستيم المراقب : " .. xPlayer.identifier .. "\n`"..GetPlayerName(source).."` | `"..GetPlayerIdentifiers(source)[1].."` | `"..GetPlayerIdentifiers(source)[5].."`\ninGameName: `"..xPlayer.getName().."`\n\n اللاعب:\n`"..GetPlayerName(Targetid).."` | `"..GetPlayerIdentifiers(Targetid)[1].."` | `"..GetPlayerIdentifiers(Targetid)[5].."`\ninGameName: `"..xTarget.getName().."` \nالسبب: `"..reason.."` \n خبرة : `"..xp.."`" .. "\nرقم ستيم المخصوم منه الخبرة : " .. xTarget.identifier,
				["color"] = "15158332",
				["footer"]=  { ["text"]= "خصم خبرة من قبل المراقب",
				["icon_url"] = "https://cdn.discordapp.com/attachments/931300530393874482/931302251513909348/7fd04efde345f231.png"},
			}
		}
		TriggerEvent('SystemXpLevel:updateCurrentPlayerXP', Targetid, 'remove', xp, 'خصم خبرة للشخص من قبل المراقب', 'AbdurhmanOnTop')
		TriggerClientEvent("esx_misc:controlSystemScaleform_removeXP", xTarget.source, xp)
		TriggerClientEvent('chatMessage', -1, " ⭐الرقابة و التفتيش   " ,  {198, 40, 40} ,  " ^1إزالة ^0" .. xp.."^4 خبرة^3 "..xTarget.getName().."^0 السبب : ^3" .. reason)
		xPlayer.showNotification('لقد قمت ب خصم <span style="color:red;">' ..xp..'</span> خبرة من</span><br><span style="color:orange;">'..namerp35y)
		PerformHttpRequest(Config.removexp, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds_removeXp}), { ['Content-Type'] = 'application/json' })
	end
end)

RegisterServerEvent("esx_adminjob:sendcoordsToDiscord")
AddEventHandler("esx_adminjob:sendcoordsToDiscord", function(coords, heading)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'admin' then
	local embeds = { -- Log
    {
        ["title"]= "`"..coords.."` heading: `"..heading.."`",
        ["type"]="rich",
        ["footer"]=  { ["text"]= "من قبل "..GetPlayerName(source),
		["icon_url"] = "https://cdn.discordapp.com/attachments/950654664129523762/966322628287676516/c8921c97bdbba9c6.png"},
    }
    }
   PerformHttpRequest("https://discord.com/api/webhooks/notnowrio921081344050583580763/zr_91LObMJztt6hPp3URo95fI5RIyzOnBpbuFUVYHuxSQHEs61XvbE47STrllJGVzJPx", function(err, text, headers) end, 'POST', json.encode({ username = 'أحداثيات مرسلة',embeds = embeds}), { ['Content-Type'] = 'application/json' })
   xPlayer.showNotification('تم إرسال الإحداثيات للديسكورد')
	else
	print(('esx_adminjob: %s attempted to sendcoords To Discord (not adminjob!)!'):format(xPlayer.identifier))
	end
end)

--AddEventHandler('playerDropped', function()
  --  local name = GetPlayerName(source)
   -- local endp = GetPlayerEndpoint(source)
  --  sendDisc(webhook, name .. _U('leave_hook'), Config.EndP, _U('leave2_hook') .. endp, 16769280)
--end)

function sendDisc (webhook, name, message, color)
    local webhook   = webhook
    local avatar     = Config.Avatar
    local embeds = {
        {
            ["title"]           = "الرقابة و التفتيش",
            ["color"]           = color,
            ["description"]     = message, name,
            ["footer"]          = {
            ["text"]            = "",
            ["icon_url"]        = Config.Icon,
           },
        }
    }

    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds, avatar_url = avatar}), { ['Content-Type'] = 'application/json' })
end


if Config.EnableESXService then
	if Config.MaxInService ~= -1 then
		TriggerEvent('esx_service:activateService', 'admin', Config.MaxInService)
	end
end

TriggerEvent('esx_phone:registerNumber', 'admin', _U('alert_admin'), true, true)
TriggerEvent('esx_society:registerSociety', 'admin', 'admin', 'society_admin', 'society_admin', 'society_admin', {type = 'public'})

RegisterServerEvent('wesam-showid:add-id')
AddEventHandler('wesam-showid:add-id', function()
    TriggerClientEvent("wesam-showid:client:add-id", source, onlinePlayers)
    local topText = "undefined " .. wesam.which
    local identifiers = GetPlayerIdentifiers(source)
    if wesam.which == "steam" then
        for k,v in ipairs(identifiers) do
            if string.match(v, 'steam:') then
                topText = v
                break
            end
        end
    elseif wesam.which == "steamv2" then
        for k,v in ipairs(identifiers) do
            if string.match(v, 'steam:') then
                topText = string.sub(v, 7)
                break
            end
        end
    elseif wesam.which == "license" then
        for k,v in ipairs(identifiers) do
            if string.match(v, 'license:') then
                topText = v
                break
            end
        end
    elseif wesam.which == "licensev2" then
        for k,v in ipairs(identifiers) do
            if string.match(v, 'license:') then
                topText = string.sub(v, 9)
                break
            end
        end
    elseif wesam.which == "name" then
        topText = GetPlayerName(source)
    end
    onlinePlayers[tostring(source)] = topText
    TriggerClientEvent("wesam-showid:client:add-id", -1, topText, tostring(source))
end)
RegisterNetEvent("esx_adminjob:wesamsetfalse")
AddEventHandler("esx_adminjob:wesamsetfalse", function()
	TriggerClientEvent("esx_misc:watermark_promotion", -1, 'TpAutoMatic', false)
end)
AddEventHandler('playerDropped', function(reason)
    onlinePlayers[tostring(source)] = nil
end)


RegisterServerEvent("wesam:NotifyPlayer")
AddEventHandler("wesam:NotifyPlayer", function(PlayerExact , xp, reason)

    local xPlayer = ESX.GetPlayerFromId(PlayerExact)
    local user = xPlayer.getName()
    local rpname = user
	TriggerClientEvent('chatMessage', -1, _U('r8abh') ,  {198, 40, 40} ,  _U('r8abhgive')..rpname.._U('changecolor')..xp.._U('xp').. _U('reasonxp')..reason)

end)

RegisterServerEvent("esx_adminjob:message")
AddEventHandler("esx_adminjob:message", function(PlayerExact , xp, reason)

    local xPlayer = ESX.GetPlayerFromId(PlayerExact)
    local user = xPlayer.getName()
    local rpname = user
	TriggerClientEvent('chatMessage', -1, _U('r8abh') ,  {198, 40, 40} ,  "^0 تم سحب التأشيرة من اللاعب ^3 "..rpname.."^0 وسجنه الى^3 ".."^3 غاية حصوله على التأشيرة مجددا ".. "^0 السبب : ^3 "..reason)

end)

RegisterServerEvent("wesam:NotifyPlayerRemove")
AddEventHandler("wesam:NotifyPlayerRemove", function(PlayerExact , xp, reason)

    local xPlayer = ESX.GetPlayerFromId(PlayerExact)
    local user = xPlayer.getName()
    local rpname = user
	TriggerClientEvent('chatMessage', -1, _U('r8abh') ,  {198, 40, 40} ,  "^0 تم إزالة من اللاعب ^3 "..rpname.."^0 "..xp.."^3 خبرة ".. "^0 السبب : ^3 "..reason)

end)

RegisterNetEvent('esx_adminjob:confiscatePlayerItem')
AddEventHandler('esx_adminjob:confiscatePlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	if sourceXPlayer.job.name ~= 'admin' then
		print(('esx_policejob: %s attempted to confiscate!'):format(sourceXPlayer.identifier))
		return
	end

	if itemType == 'item_standard' then
		local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		-- does the target player have enough in their inventory?
		if targetItem.count > 0 and targetItem.count <= amount then

			-- can the player carry the said amount of x item?
			if sourceXPlayer.canCarryItem(itemName, sourceItem.count) then
				targetXPlayer.removeInventoryItem(itemName, amount)
				sourceXPlayer.addInventoryItem   (itemName, amount)
				TriggerClientEvent("pNotify:SendNotification", sourceXPlayer.source, {
					text = "</br><font size=3><p align=right><b><font color=yellow>مصادرة</font>"..
					"</br><font size=3><p align=right><b>هوية الشخص: <font color=gold>"..targetXPlayer.name.."</font>"..
					"</br><font size=3><p align=right><b>الغرض المصادر: <font color=gold>"..sourceItem.label.."</font>"..
					"</br><font size=3><p align=right><b>الكمية المصادرة: <font color=orange>"..amount.."</font>",
					type = "info",
					queue = "right",
					timeout = 60000,
					layout = "centerright"
				})
				TriggerClientEvent("pNotify:SendNotification", targetXPlayer.source, {
					text = "</br><font size=3><p align=right><b><font color=yellow>مصادرة</font>"..
					"</br><font size=3><p align=right><b>هوية الشخص: <font color=gold>"..sourceXPlayer.name.."</font>"..
					"</br><font size=3><p align=right><b>الغرض المصادر: <font color=gold>"..sourceItem.label.."</font>"..
					"</br><font size=3><p align=right><b>الكمية المصادرة: <font color=orange>"..amount.."</font>",
					type = "info",
					queue = "right",
					timeout = 60000,
					layout = "centerright"
				})
				--[[sourceXPlayer.showNotification(_U('you_confiscated', amount, sourceItem.label, targetXPlayer.name))
				targetXPlayer.showNotification(_U('got_confiscated', amount, sourceItem.label, sourceXPlayer.name))--]]
			else
				sourceXPlayer.showNotification(_U('quantity_invalid'))
			end
		else
			sourceXPlayer.showNotification(_U('quantity_invalid'))
		end

	elseif itemType == 'item_account' then
		local targetAccount = targetXPlayer.getAccount(itemName)

		-- does the target player have enough money?
		if targetAccount.money >= amount then
			targetXPlayer.removeAccountMoney(itemName, amount)
			sourceXPlayer.addAccountMoney   (itemName, amount)
			TriggerClientEvent("pNotify:SendNotification", sourceXPlayer.source, {
				text = "</br><font size=3><p align=right><b><font color=yellow>مصادرة</font>"..
				"</br><font size=3><p align=right><b>هوية الشخص: <font color=gold>"..targetXPlayer.name.."</font>"..
				"</br><font size=3><p align=right><b>المصادر: <font color=red>مبلغ غير قانوني</font>"..
				"</br><font size=3><p align=right><b>المبلغ المصادر: <font color=orange>$"..amount.."</font>",
				type = "info",
				queue = "right",
				timeout = 60000,
				layout = "centerright"
			})
			TriggerClientEvent("pNotify:SendNotification", targetXPlayer.source, {
				text = "</br><font size=3><p align=right><b><font color=yellow>مصادرة</font>"..
				"</br><font size=3><p align=right><b>هوية الشخص: <font color=gold>"..targetXPlayer.name.."</font>"..
				"</br><font size=3><p align=right><b>المصادر: <font color=red>مبلغ غير قانوني</font>"..
				"</br><font size=3><p align=right><b>المبلغ المصادر: <font color=orange>$"..amount.."</font>",
				type = "info",
				queue = "right",
				timeout = 60000,
				layout = "centerright"
			})
			--[[sourceXPlayer.showNotification(_U('you_confiscated_account', amount, itemName, targetXPlayer.name))
			targetXPlayer.showNotification(_U('got_confiscated_account', amount, itemName, sourceXPlayer.name))--]]
		else
			sourceXPlayer.showNotification(_U('quantity_invalid'))
		end

	elseif itemType == 'item_weapon' then
		if amount == nil then amount = 0 end

		-- does the target player have weapon?
		if targetXPlayer.hasWeapon(itemName) then
			targetXPlayer.removeWeapon(itemName, amount)
			sourceXPlayer.addWeapon   (itemName, amount)
			TriggerClientEvent("pNotify:SendNotification", sourceXPlayer.source, {
				text = "</br><font size=3><p align=right><b><font color=yellow>مصادرة</font>"..
				"</br><font size=3><p align=right><b>هوية الشخص: <font color=gold>"..targetXPlayer.name.."</font>"..
				"</br><font size=3><p align=right><b>السلاح المصادر: <font color=gold>"..ESX.GetWeaponLabel(itemName).."</font>",
				type = "info",
				queue = "right",
				timeout = 60000,
				layout = "centerright"
			})
			TriggerClientEvent("pNotify:SendNotification", targetXPlayer.source, {
				text = "</br><font size=3><p align=right><b><font color=yellow>مصادرة</font>"..
				"</br><font size=3><p align=right><b>هوية الشخص: <font color=gold>"..sourceXPlayer.name.."</font>"..
				"</br><font size=3><p align=right><b>السلاح المصادر: <font color=gold>"..ESX.GetWeaponLabel(itemName).."</font>",
				type = "info",
				queue = "right",
				timeout = 60000,
				layout = "centerright"
			})
			--[[sourceXPlayer.showNotification(_U('you_confiscated_weapon', ESX.GetWeaponLabel(itemName), targetXPlayer.name, amount))
			targetXPlayer.showNotification(_U('got_confiscated_weapon', ESX.GetWeaponLabel(itemName), amount, sourceXPlayer.name))--]]
		else
			sourceXPlayer.showNotification(_U('quantity_invalid'))
		end
	end
end)

RegisterNetEvent('esx_adminjob:handcuff')
AddEventHandler('esx_adminjob:handcuff', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'admin' then
		TriggerClientEvent('esx_adminjob:handcuff', target)
	else
		print(('esx_adminjob: %s attempted to handcuff a player (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_adminjob:drag')
AddEventHandler('esx_adminjob:drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'admin' then
		TriggerClientEvent('esx_adminjob:drag', target, source)
	else
		print(('esx_adminjob: %s attempted to drag (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_adminjob:putInVehicle')
AddEventHandler('esx_adminjob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'admin' then
		TriggerClientEvent('esx_adminjob:putInVehicle', target)
	else
		print(('esx_adminjob: %s attempted to put in vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_adminjob:OutVehicle')
AddEventHandler('esx_adminjob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'admin' then
		TriggerClientEvent('esx_adminjob:OutVehicle', target)
	else
		print(('esx_adminjob: %s attempted to drag out from vehicle (not cop)!'):format(xPlayer.identifier))
	end
end)

RegisterNetEvent('esx_adminjob:getStockItem')
AddEventHandler('esx_adminjob:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_admin', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then

			-- can the player carry the said amount of x item?
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				xPlayer.showNotification(_U('have_withdrawn', count, inventoryItem.name))
			else
				xPlayer.showNotification(_U('quantity_invalid'))
			end
		else
			xPlayer.showNotification(_U('quantity_invalid'))
		end
	end)
end)

RegisterNetEvent('esx_adminjob:putStockItems')
AddEventHandler('esx_adminjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_admin', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			xPlayer.showNotification(_U('have_deposited', count, inventoryItem.name))
		else
			xPlayer.showNotification(_U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('esx_adminjob:getOtherPlayerData', function(source, cb, target, notify)
	local xPlayer = ESX.GetPlayerFromId(target)

	if notify then
		xPlayer.showNotification(_U('being_searched'))
	end

	if xPlayer then
		local data = {
			name = xPlayer.getName(),
			job = xPlayer.job.label,
			grade = xPlayer.job.grade_label,
			inventory = xPlayer.getInventory(),
			accounts = xPlayer.getAccounts(),
			weapons = xPlayer.getLoadout()
		}

		if Config.EnableESXIdentity then
			data.dob = xPlayer.get('dateofbirth')
			data.height = xPlayer.get('height')

			if xPlayer.get('sex') == 'm' then data.sex = 'male' else data.sex = 'female' end
		end

		TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)
			if status then
				data.drunk = ESX.Math.Round(status.percent)
			end
		end)

		TriggerEvent('esx_license:getLicenses', target, function(licenses)
			data.licenses = licenses
			cb(data)
		end)
	end
end)

ESX.RegisterServerCallback('esx_adminjob:getOtherPlayerVisa', function(source, cb, target, notify)
	local xPlayer = ESX.GetPlayerFromId(target)

	if notify then
		xPlayer.showNotification(_U('being_searched'))
	end

	if xPlayer then
		local data = {
			name = xPlayer.getName(),
			job = xPlayer.job.label,
			grade = xPlayer.job.grade_label,
			inventory = xPlayer.getInventory(),
			accounts = xPlayer.getAccounts(),
			weapons = xPlayer.getLoadout()
		}

		if Config.EnableLicenses then
			TriggerEvent('esx_license:getLicensesVisa', target, function(licenses)
				data.licenses = licenses
				cb(data)
			end)
		else
			cb(data)
		end
	end
end)

ESX.RegisterServerCallback('esx_adminjob:getFineList', function(source, cb, category)
	MySQL.Async.fetchAll('SELECT id, label, amount, category FROM fine_types WHERE category = @category', {
		['@category'] = category
	}, function(fines)
		cb(fines)
	end)
end)


ESX.RegisterServerCallback('VehicleShops:TakeFunds', function(source, cb, how_many_is_wnat)
  	local xPlayer = ESX.GetPlayerFromId(source)
  	MySQL.Async.fetchAll('SELECT funds FROM vehicle_shops WHERE owner = @owner', {
	  	["@owner"] = xPlayer.identifier,
	}, function(result)
		if how_many_is_wnat > result[1].funds then
			cb(false)
		else
			MySQL.Async.fetchAll('UPDATE vehicle_shops SET funds = @funds_new WHERE owner = @owner', {["@owner"] = xPlayer.identifier,['@funds_new'] = result[1].funds - how_many_is_wnat})
			xPlayer.addAccountMoney('bank', how_many_is_wnat)
			cb(true)
		end
	end)
end)

ESX.RegisterServerCallback('esx_wesam:check_money', function(source, cb, how_many_is_wnat)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT funds FROM vehicle_shops WHERE owner = @owner', {
		["@owner"] = xPlayer.identifier,
	  }, function(result)
		if result[1] ~= nil then
			cb(result[1].funds)
	  	end
	end)
  end)

ESX.RegisterServerCallback('esx_adminjob:getVehicleInfos', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		local retrivedInfo = {plate = plate}

		if result[1] then
			local xPlayer = ESX.GetPlayerFromIdentifier(result[1].owner)

			-- is the owner online?
			if xPlayer then
				retrivedInfo.owner = xPlayer.getName()
				cb(retrivedInfo)
			elseif Config.EnableESXIdentity then
				MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier',  {
					['@identifier'] = result[1].owner
				}, function(result2)
					if result2[1] then
						retrivedInfo.owner = ('%s %s'):format(result2[1].firstname, result2[1].lastname)
						cb(retrivedInfo)
					else
						cb(retrivedInfo)
					end
				end)
			else
				cb(retrivedInfo)
			end
		else
			cb(retrivedInfo)
		end
	end)
end)

ESX.RegisterServerCallback('esx_adminjob:getArmoryWeapons', function(source, cb)
	TriggerEvent('esx_datastore:getSharedDataStore', 'society_admin', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		cb(weapons)
	end)
end)

ESX.RegisterServerCallback('esx_adminjob:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)
	local xPlayer = ESX.GetPlayerFromId(source)

	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_admin', function(store)
		local weapons = store.get('weapons') or {}
		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('esx_adminjob:removeArmoryWeapon', function(source, cb, weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 500)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_admin', function(store)
		local weapons = store.get('weapons') or {}

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name = weaponName,
				count = 0
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('esx_adminjob:buyWeapon', function(source, cb, weaponName, type, componentNum)
	local xPlayer = ESX.GetPlayerFromId(source)
	local authorizedWeapons, selectedWeapon = Config.AuthorizedWeapons[xPlayer.job.grade_name]

	for k,v in ipairs(authorizedWeapons) do
		if v.weapon == weaponName then
			selectedWeapon = v
			break
		end
	end

	if not selectedWeapon then
		print(('esx_adminjob: %s attempted to buy an invalid weapon.'):format(xPlayer.identifier))
		cb(false)
	else
		-- Weapon
		if type == 1 then
			if xPlayer.getMoney() >= selectedWeapon.price then
				xPlayer.removeMoney(selectedWeapon.price)
				xPlayer.addWeapon(weaponName, 100)

				cb(true)
			else
				cb(false)
			end

		-- Weapon Component
		elseif type == 2 then
			local price = selectedWeapon.components[componentNum]
			local weaponNum, weapon = ESX.GetWeapon(weaponName)
			local component = weapon.components[componentNum]

			if component then
				if xPlayer.getMoney() >= price then
					xPlayer.removeMoney(price)
					xPlayer.addWeaponComponent(weaponName, component.name)

					cb(true)
				else
					cb(false)
				end
			else
				print(('esx_adminjob: %s attempted to buy an invalid weapon component.'):format(xPlayer.identifier))
				cb(false)
			end
		end
	end
end)

ESX.RegisterServerCallback('esx_adminjob:buyJobVehicle', function(source, cb, vehicleProps, type, name)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		print(('esx_adminjob: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
		cb(false)
	else
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price)

			MySQL.Async.execute('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`, name) VALUES (@owner, @vehicle, @plate, @type, @job, @stored, @name)', {
				['@owner'] = xPlayer.identifier,
				['@vehicle'] = json.encode(vehicleProps),
				['@plate'] = vehicleProps.plate,
				['@type'] = type,
				['@job'] = xPlayer.job.name,
				['@stored'] = true,
				['@name'] = name
			}, function (rowsChanged)
				cb(true)
			end)
		else
			cb(false)
		end
	end
end)

ESX.RegisterServerCallback('esx_adminjob:storeNearbyVehicle', function(source, cb, nearbyVehicles)
	local xPlayer = ESX.GetPlayerFromId(source)
	local foundPlate, foundNum

	for k,v in ipairs(nearbyVehicles) do
		local result = MySQL.Sync.fetchAll('SELECT plate FROM owned_vehicles WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = v.plate,
			['@job'] = xPlayer.job.name
		})

		if result[1] then
			foundPlate, foundNum = result[1].plate, k
			break
		end
	end

	if not foundPlate then
		cb(false)
	else
		MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = true WHERE owner = @owner AND plate = @plate AND job = @job', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = foundPlate,
			['@job'] = xPlayer.job.name
		}, function (rowsChanged)
			if rowsChanged == 0 then
				print(('esx_adminjob: %s has exploited the garage!'):format(xPlayer.identifier))
				cb(false)
			else
				cb(true, foundNum)
			end
		end)
	end
end)

function getPriceFromHash(vehicleHash, jobGrade, type)
	local vehicles = Config.AuthorizedVehicles[type][jobGrade]

	for k,v in ipairs(vehicles) do
		if GetHashKey(v.model) == vehicleHash then
			return v.price
		end
	end

	return 0
end

ESX.RegisterServerCallback('esx_adminjob:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_admin', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('esx_adminjob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

AddEventHandler('playerDropped', function()
	-- Save the source in case we lose it (which happens a lot)
	local playerId = source

	-- Did the player ever join?
	if playerId then
		local xPlayer = ESX.GetPlayerFromId(playerId)

		-- Is it worth telling all clients to refresh?
		if xPlayer and xPlayer.job.name == 'admin' then
			Citizen.Wait(5000)
			TriggerClientEvent('esx_adminjob:updateBlip', -1)
		end
	end
end)

RegisterNetEvent('esx_adminjob:spawned')
AddEventHandler('esx_adminjob:spawned', function()
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer and xPlayer.job.name == 'admin' then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_adminjob:updateBlip', -1)
	end
end)

RegisterNetEvent('esx_adminjob:forceBlip')
AddEventHandler('esx_adminjob:forceBlip', function()
	TriggerClientEvent('esx_adminjob:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_adminjob:updateBlip', -1)
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_phone:removeNumber', 'admin')
	end
end)
