
function CreateSpawn(ent)
	pos = ent:GetPos()
	local spawn = ents.Create("info_player_deathmatch")
	spawn:SetPos(pos)
end
------------------------
------HL2DM Stuff-------
------------------------
hl2dments = {
	"item_ammo_pistol",
	"item_box_buckshot",
	"item_ammo_smg1",
	"item_ammo_357",
	"item_ammo_357_large",
	"item_ammo_revolver",
	"item_ammo_ar2",
	"item_ammo_ar2_large",
	"item_ammo_smg1_grenade",
	"item_battery",
	"item_healthkit",
	"item_suitcharger",
	"item_ammo_ar2_altfire",
	"item_rpg_round",
	"item_ammo_crossbow",
	"item_healthvial",
	"item_healthcharger",
	"item_ammo_crate",
	"item_item_crate",
	"weapon_smg1",
	"weapon_shotgun",
	"weapon_ar2",
	"weapon_357",
	"weapon_crossbow",
	"weapon_rpg",
	"weapon_slam",
	"weapon_frag",
	"weapon_crowbar"
}

function HL2DMEnts()
	for k,v in pairs(ents.GetAll()) do
		for j,c in pairs(hl2dments) do
			if v:GetClass() == c then
				v:Remove()
			end
		end
	end
end

------------------------
-------CS:S Stuff-------
------------------------
spawnents = {
	"info_player_terrorist",
	"info_player_counterterrorist",
	"info_player_start",
	"info_player_allies", 
	"info_player_axis",
	"info_player_combine",
	"info_player_rebel"
}

function MiscSpawnEnts()
	for k,v in pairs(ents.GetAll()) do
		for j,c in pairs(spawnents) do
			if v:GetClass() == c then
				CreateSpawn(v)
				v:Remove()
			end
		end
	end
end

------------------------
--------TF2 Stuff-------
------------------------
tf2ents = {
	"info_player_teamspawn",
	"team_control_point",
	"item_ammopack_full",
	"item_ammopack_medium",
	"item_ammopack_small",
	"item_healthkit_full",
	"item_healthkit_medium",
	"item_healthkit_small",
	"item_teamflag"
}

function TF2Ents()
	for k,v in pairs(ents.GetAll()) do
		for j,c in pairs(tf2ents) do
			if v:GetClass() == c then
				CreateSpawn(v)
				v:Remove()
			end
		end
	end
end


-- The following code was liberated from TTT, thanks BadKing!

local function CreateImportedEnt(cls, pos, ang, kv)
	if not cls or not pos or not ang or not kv then return false end

	local ent = ents.Create(cls)
	if not IsValid(ent) then return false end
	ent:SetPos(pos)
	ent:SetAngles(ang)

	for k,v in pairs(kv) do
		ent:SetKeyValue(k, v)
	end

	ent:Spawn()

	ent:PhysWake()
	print(ent:GetClass(),ent:GetPos())
	return true
end

function CanImportEntities(map)
	if not tostring(map) then return false end

	local fname = "maps/" .. map .. "_gy.txt"

	return file.Exists(fname, "GAME")
end

local function ImportSettings(map)
	if not CanImportEntities(map) then return end

	local fname = "maps/" .. map .. "_gy.txt"
	local buf = file.Read(fname, "GAME")

	local settings = {}

	local lines = string.Explode("\n", buf)
	for k, line in pairs(lines) do
		if string.match(line, "^setting") then
			--print(line)
			local key, val = string.match(line, "^setting:\t(%w*) ([0-9]*)")
			val = tonumber(val)

			if key and val then
				settings[key] = val
			else
				ErrorNoHalt("Invalid setting line " .. k .. " in " .. fname .. "\n")
			end
		end
	end

	return settings
end
local classremap = {
   gy_playerspawn = "info_player_deathmatch"
};
function ImportEntities(map)
	if not CanImportEntities(map) then return end

	local fname = "maps/" .. map .. "_gy.txt"

	local buf = file.Read(fname, "GAME")
	local lines = string.Explode("\n", buf)
	local num = 0
	for k, line in ipairs(lines) do
		if (not string.match(line, "^#")) and (not string.match(line, "^setting")) and line != "" and string.byte(line) != 0 then
			local data = string.Explode("\t", line)

			local fail = true -- pessimism

			if data[2] and data[3] then
				local cls = data[1]
				local ang = nil
				local pos = nil

				local posraw = string.Explode(" ", data[2])
				pos = Vector(tonumber(posraw[1]), tonumber(posraw[2]), tonumber(posraw[3]))

				local angraw = string.Explode(" ", data[3])
				ang = Angle(tonumber(angraw[1]), tonumber(angraw[2]), tonumber(angraw[3]))

				-- Random weapons have a useful keyval
				local kv = {}
				if data[4] then
					local kvraw = string.Explode(" ", data[4])
					local key = kvraw[1]
					local val = tonumber(kvraw[2])

					if key and val then
						kv[key] = val
					end
				end

				-- Some dummy ents remap to different, real entity names
				cls = classremap[cls] or cls

				fail = not CreateImportedEnt(cls, pos, ang, kv)
			end

			if fail then
				ErrorNoHalt("Invalid line " .. k .. " in " .. fname .. "\n")
			else
				num = num + 1
			end
		end
	end

	MsgN("Spawned " .. num .. " entities found in script.")

	return true
end


function ProcessImportScript(map)
	MsgN("Weapon/ammo placement script found, attempting import...")

	MsgN("Reading settings from script...")
	local settings = ImportSettings(map)

	if tobool(settings.replacespawns) then
		MsgN("Removing existing player spawns")
		RemoveSpawnEntities()
	end

	MsgN("Removing existing weapons/ammo")
	RemoveWeaponEntities()

	MsgN("Importing entities...")
	/*local result = ImportEntities(map)
	if result then
		MsgN("Weapon placement script import successful!")
	else
		ErrorNoHalt("Weapon placement script import failed!\n")
	end*/
end


function ClearEnts()
	game.CleanUpMap() 
	ImportEntities(game.GetMap())
	HL2DMEnts()
	MiscSpawnEnts()
	TF2Ents()
end