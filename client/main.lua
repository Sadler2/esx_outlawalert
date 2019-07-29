ESX = nil

local timing, isPlayerWhitelisted = math.ceil(Config.Timer * 60000), false
local streetName, playerGender

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

	TriggerEvent('skinchanger:getSkin', function(skin)
		playerGender = skin.sex
	end)

	isPlayerWhitelisted = refreshPlayerWhitelisted()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

	isPlayerWhitelisted = refreshPlayerWhitelisted()
end)

RegisterNetEvent('esx_outlawalert:outlawNotify')
AddEventHandler('esx_outlawalert:outlawNotify', function(alert)
	if isPlayerWhitelisted then
		ESX.ShowNotification(alert)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)

		if NetworkIsSessionStarted() then
			DecorRegister('isOutlaw', 3)
			DecorSetInt(PlayerPedId(), 'isOutlaw', 1)

			return
		end
	end
end)

-- Gets the player's current street.
-- Aaalso get the current player gender
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)

		local playerCoords = GetEntityCoords(PlayerPedId())
		streetName,_ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
		streetName = GetStreetNameFromHashKey(streetName)
	end
end)

AddEventHandler('skinchanger:loadSkin', function(character)
	playerGender = character.sex
end)

function refreshPlayerWhitelisted()
	if not ESX.PlayerData then
		return false
	end

	if not ESX.PlayerData.job then
		return false
	end

	for k,v in ipairs(Config.WhitelistedCops) do
		if v == ESX.PlayerData.job.name then
			return true
		end
	end

	return false
end

RegisterNetEvent('esx_outlawalert:carJackInProgress')
AddEventHandler('esx_outlawalert:carJackInProgress', function(targetCoords)
	if isPlayerWhitelisted then
		if Config.CarJackingAlert then
			local alpha = 250
			local thiefBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.BlipJackingRadius)

			SetBlipHighDetail(thiefBlip, true)
			SetBlipColour(thiefBlip, 1)
			SetBlipAlpha(thiefBlip, alpha)
			SetBlipAsShortRange(thiefBlip, true)

			while alpha ~= 0 do
				Citizen.Wait(Config.BlipJackingTime * 4)
				alpha = alpha - 1
				SetBlipAlpha(thiefBlip, alpha)

				if alpha == 0 then
					RemoveBlip(thiefBlip)
					return
				end
			end

		end
	end
end)

RegisterNetEvent('esx_outlawalert:gunshotInProgress')
AddEventHandler('esx_outlawalert:gunshotInProgress', function(targetCoords)
	if isPlayerWhitelisted and Config.GunshotAlert then
		local alpha = 250
		local gunshotBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.BlipGunRadius)

		SetBlipHighDetail(gunshotBlip, true)
		SetBlipColour(gunshotBlip, 1)
		SetBlipAlpha(gunshotBlip, alpha)
		SetBlipAsShortRange(gunshotBlip, true)

		while alpha ~= 0 do
			Citizen.Wait(Config.BlipGunTime * 4)
			alpha = alpha - 1
			SetBlipAlpha(gunshotBlip, alpha)

			if alpha == 0 then
				RemoveBlip(gunshotBlip)
				return
			end
		end
	end
end)

RegisterNetEvent('esx_outlawalert:combatInProgress')
AddEventHandler('esx_outlawalert:combatInProgress', function(targetCoords)
	if isPlayerWhitelisted and Config.MeleeAlert then
		local alpha = 250
		local meleeBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.BlipMeleeRadius)

		SetBlipHighDetail(meleeBlip, true)
		SetBlipColour(meleeBlip, 17)
		SetBlipAlpha(meleeBlip, alpha)
		SetBlipAsShortRange(meleeBlip, true)

		while alpha ~= 0 do
			Citizen.Wait(Config.BlipMeleeTime * 4)
			alpha = alpha - 1
			SetBlipAlpha(meleeBlip, alpha)

			if alpha == 0 then
				RemoveBlip(meleeBlip)
				return
			end
		end
	end
end)

RegisterNetEvent('esx_outlawalert:opencarryInProgress')
AddEventHandler('esx_outlawalert:opencarryInProgress', function(targetCoords)
	if isPlayerWhitelisted and Config.MeleeAlert then
		local alpha = 150
		local meleeBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.BlipMeleeRadius)

		SetBlipHighDetail(meleeBlip, true)
		SetBlipColour(meleeBlip, 5)
		SetBlipAlpha(meleeBlip, alpha)
		SetBlipAsShortRange(meleeBlip, true)

		while alpha ~= 0 do
			Citizen.Wait(Config.BlipMeleeTime * 0.5)
			alpha = alpha - 1
			SetBlipAlpha(meleeBlip, alpha)

			if alpha == 0 then
				RemoveBlip(meleeBlip)
				return
			end
		end
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)

		if DecorGetInt(PlayerPedId(), 'isOutlaw') == 2 then
			Citizen.Wait(timing)
			DecorSetInt(PlayerPedId(), 'isOutlaw', 1)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)

		-- is jackin'
		if (IsPedTryingToEnterALockedVehicle(playerPed) or IsPedJacking(playerPed)) and Config.CarJackingAlert then

			Citizen.Wait(3000)
			local vehicle = GetVehiclePedIsIn(playerPed, true)

			if vehicle and ((isPlayerWhitelisted and Config.ShowCopsMisbehave) or not isPlayerWhitelisted) then
				local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

				ESX.TriggerServerCallback('esx_outlawalert:isVehicleOwner', function(owner)
					if not owner then
						local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
						vehicleLabel = GetLabelText(vehicleLabel)

						local witness = getWitness(60,10)
						if witness then
							DecorSetInt(playerPed, 'isOutlaw', 2)

							if exports.esx_skin["getSkinDescription"] ~= nil then
								TriggerEvent('skinchanger:getSkin', function(skin)
									local desc = exports.esx_skin:getSkinDescription(skin)
									local descText = exports.esx_skin:skinDescriptionToText(desc)

									TriggerServerEvent('esx_outlawalert:carJackInProgress', {
										x = ESX.Math.Round(playerCoords.x, 1),
										y = ESX.Math.Round(playerCoords.y, 1),
										z = ESX.Math.Round(playerCoords.z, 1)
									}, streetName, vehicleLabel, playerGender, descText)
								end)
							else
								TriggerServerEvent('esx_outlawalert:carJackInProgress', {
									x = ESX.Math.Round(playerCoords.x, 1),
									y = ESX.Math.Round(playerCoords.y, 1),
									z = ESX.Math.Round(playerCoords.z, 1)
								}, streetName, vehicleLabel, playerGender, nil)
							end
						end
					end
				end, plate)
			end

		elseif IsPedInMeleeCombat(playerPed) and GetTimeSincePlayerHitPed(playerPed) < 1000 and Config.MeleeAlert then

			Citizen.Wait(3000)
			local witness = getWitness(10,3)

			if witness and (isPlayerWhitelisted and Config.ShowCopsMisbehave) or not isPlayerWhitelisted then

				if exports.esx_skin["getSkinDescription"] ~= nil then
					TriggerEvent('skinchanger:getSkin', function(skin)
						local desc = exports.esx_skin:getSkinDescription(skin)
						local descText = exports.esx_skin:skinDescriptionToText(desc)

						DecorSetInt(playerPed, 'isOutlaw', 2)

						TriggerServerEvent('esx_outlawalert:combatInProgress', {
							x = ESX.Math.Round(playerCoords.x, 1),
							y = ESX.Math.Round(playerCoords.y, 1),
							z = ESX.Math.Round(playerCoords.z, 1)
						}, streetName, playerGender, descText)
					end)
				else
						TriggerServerEvent('esx_outlawalert:combatInProgress', {
							x = ESX.Math.Round(playerCoords.x, 1),
							y = ESX.Math.Round(playerCoords.y, 1),
							z = ESX.Math.Round(playerCoords.z, 1)
						}, streetName, playerGender, nil)
				end

			end

		elseif IsPedShooting(playerPed) and Config.GunshotAlert then

			Citizen.Wait(10000)
			local hearDistance = 60
			if IsPedCurrentWeaponSilenced(playerPed) then hearDistance = 10 end -- does not actually work, because IsPedShooting already skips silencers at least for pistols
			local witness = getWitness(30,hearDistance)

			if witness and (isPlayerWhitelisted and Config.ShowCopsMisbehave) or not isPlayerWhitelisted then

				if exports.esx_skin["getSkinDescription"] ~= nil then
					TriggerEvent('skinchanger:getSkin', function(skin)
						local desc = exports.esx_skin:getSkinDescription(skin)
						local descText = exports.esx_skin:skinDescriptionToText(desc)
						DecorSetInt(playerPed, 'isOutlaw', 2)

						TriggerServerEvent('esx_outlawalert:gunshotInProgress', {
							x = ESX.Math.Round(playerCoords.x, 1),
							y = ESX.Math.Round(playerCoords.y, 1),
							z = ESX.Math.Round(playerCoords.z, 1)
						}, streetName, playerGender, descText)
					end)
				else
						TriggerServerEvent('esx_outlawalert:gunshotInProgress', {
							x = ESX.Math.Round(playerCoords.x, 1),
							y = ESX.Math.Round(playerCoords.y, 1),
							z = ESX.Math.Round(playerCoords.z, 1)
						}, streetName, playerGender, nil)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)

		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		local playerVehicle  = GetVehiclePedIsIn(playerPed, false)

		if playerVehicle == 0 and IsPedArmed(playerPed, 6) then
			local witness = exports.test:getWitness(40,0)

			if witness and (isPlayerWhitelisted and Config.ShowCopsMisbehave) or not isPlayerWhitelisted then

				if exports.esx_skin["getSkinDescription"] ~= nil then
					TriggerEvent('skinchanger:getSkin', function(skin)
						local desc = exports.esx_skin:getSkinDescription(skin)
						local descText = exports.esx_skin:skinDescriptionToText(desc)
						DecorSetInt(playerPed, 'isOutlaw', 2)

						TriggerServerEvent('esx_outlawalert:opencarryInProgress', {
							x = ESX.Math.Round(playerCoords.x, 1),
							y = ESX.Math.Round(playerCoords.y, 1),
							z = ESX.Math.Round(playerCoords.z, 1)
						}, streetName, playerGender, descText)
					end)
				else
						TriggerServerEvent('esx_outlawalert:opencarryInProgress', {
							x = ESX.Math.Round(playerCoords.x, 1),
							y = ESX.Math.Round(playerCoords.y, 1),
							z = ESX.Math.Round(playerCoords.z, 1)
						}, streetName, playerGender, nil)
				end
			end
		end
	end
end)
