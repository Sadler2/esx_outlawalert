ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_outlawalert:carJackInProgress')
AddEventHandler('esx_outlawalert:carJackInProgress', function(targetCoords, streetName, vehicleLabel, playerGender, verbalDescription)
	if playerGender == 0 then
		playerGender = _U('male')
	else
		playerGender = _U('female')
	end

	if verbalDescription ~= nil then
		TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('carjack', verbalDescription, vehicleLabel, streetName))
	else
		TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('carjack', playerGender, vehicleLabel, streetName))
	end

	TriggerClientEvent('esx_outlawalert:carJackInProgress', -1, targetCoords)
end)

RegisterServerEvent('esx_outlawalert:combatInProgress')
AddEventHandler('esx_outlawalert:combatInProgress', function(targetCoords, streetName, playerGender, verbalDescription)
	if playerGender == 0 then
		playerGender = _U('male')
	else
		playerGender = _U('female')
	end

	if verbalDescription ~= nil then
		TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('combat', verbalDescription, streetName))
	else
		TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('combat', playerGender, streetName))
	end
	TriggerClientEvent('esx_outlawalert:combatInProgress', -1, targetCoords)
end)

RegisterServerEvent('esx_outlawalert:gunshotInProgress')
AddEventHandler('esx_outlawalert:gunshotInProgress', function(targetCoords, streetName, playerGender, verbalDescription)
	if playerGender == 0 then
		playerGender = _U('male')
	else
		playerGender = _U('female')
	end

	if verbalDescription ~= nil then
		TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('gunshot', verbalDescription, streetName))
	else
		TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('gunshot', playerGender, streetName))
	end

	TriggerClientEvent('esx_outlawalert:gunshotInProgress', -1, targetCoords)
end)

RegisterServerEvent('esx_outlawalert:opencarryInProgress')
AddEventHandler('esx_outlawalert:opencarryInProgress', function(targetCoords, streetName, playerGender, verbalDescription)
	if playerGender == 0 then
		playerGender = _U('male')
	else
		playerGender = _U('female')
	end

	if verbalDescription ~= nil then
		TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('opencarry', verbalDescription, streetName))
	else
		TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('opencarry', playerGender, streetName))
	end

	TriggerClientEvent('esx_outlawalert:opencarryInProgress', -1, targetCoords)
end)


ESX.RegisterServerCallback('esx_outlawalert:isVehicleOwner', function(source, cb, plate)
	local identifier = GetPlayerIdentifier(source, 0)

	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
		['@owner'] = identifier,
		['@plate'] = plate
	}, function(result)
		if result[1] then
			cb(result[1].owner == identifier)
		else
			cb(false)
		end
	end)
end)
