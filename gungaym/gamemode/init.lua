AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "wepgen.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "mapchange.lua" )
AddCSLuaFile( "cl_deathnotices.lua" )
AddCSLuaFile( "cl_hudpickup.lua" )
include("resources.lua")
include("shared.lua")
include("entdel.lua")
include("mapchange.lua")
include("player.lua")
include("wepgen.lua")
include("rounds.lua")


RandomizeWeapons()

function GM:Initialize( )
	ClearEnts()
	killstreaksound = { "gy/canttouch.wav", "gy/best.wav"}
	SetGlobalInt("round",0)
	RoundStart()
	--timer.Simple(1,function() ClearEnts() end)
	util.AddNetworkString("wepcl")
	util.AddNetworkString("maplist")
	util.AddNetworkString("mapback")
	SetGlobalInt("RoundState", 1)
	models = {
	"models/player/gasmask.mdl",
	"models/player/leet.mdl",
	"models/player/Phoenix.mdl",
	"models/player/riot.mdl"
	}
	CreateConVar("gy_rounds", 5,{FCVAR_NOTIFY,FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "Determines how many rounds there are per map")
	
	CreateConVar("gy_overheal_enabled", 1,{FCVAR_NOTIFY,FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "Picking up medkits can heal above 100 HP (see 'gy_overheal_max')")
	
	CreateConVar("gy_overheal_max", 200,{FCVAR_NOTIFY,FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "Max health you can get from medkits if overheal is enabled")
	
	CreateConVar("gy_overheal_decay", 1,{FCVAR_NOTIFY,FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "How much overheal you lose per second")
	
	CreateConVar("gy_pickup_respawntime", 25, {FCVAR_NOTIFY,FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "Determines how many seconds it takes for pickups to respawn")
		
	SetGlobalInt("MaxRounds", GetConVarNumber("gy_rounds"))
end

hook.Add("InitPostEntity", "StartupEntSetup", ClearEnts)

function GM:IsSpawnpointSuitable( pl, spawnpointent, bMakeSuitable )

	local Pos = spawnpointent:GetPos()
	
	-- Note that we're searching the default hull size here for a player in the way of our spawning.
	-- This seems pretty rough, seeing as our player's hull could be different.. but it should do the job
	-- (HL2DM kills everything within a 128 unit radius)
	local Ents = ents.FindInBox( Pos + Vector( -16, -16, 0 ), Pos + Vector( 16, 16, 64 ) )
	
	if ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) then return true end
	
	local Blockers = 0
	
	for k, v in pairs( Ents ) do
		if ( IsValid( v ) && v:GetClass() == "player" && v:Alive() ) then
		
			Blockers = Blockers + 1
			
			if ( bMakeSuitable ) then
				v:Kill()
			end
			
		end
	end
	
	if ( bMakeSuitable ) then return true end
	if ( Blockers > 0 ) then return false end
	return true

end

function GM:PlayerSelectSpawn(ply)
	--PrintTable(ents.FindByClass("info_player_deathmatch"))
	local spawns = ents.FindByClass("info_player_deathmatch")
	local spawn = table.Random(spawns)
	if not spawn then
		ErrorNoHalt("There are no info_player_deathmatch spawns! Did ClearEnts run!?")
	else
		GAMEMODE:IsSpawnpointSuitable( ply, spawn, true )
		return spawn
	end
end

function GM:PlayerConnect( name, ip )
	PrintMessage( HUD_PRINTTALK, name.. " has joined the game." )
end

function GM:PlayerInitialSpawn( ply )
	PrintMessage( HUD_PRINTTALK, ply:GetName().. " has spawned." )
	ply:PrintMessage(HUD_PRINTTALK, "Welcome to Gun Gaym by Shaps!") // Don't you dare take this out
	ply:SetNWInt("level",LowestLevel(ply))
	--ply:SetGamemodeTeam( 0 )
	ply:SetModel(table.Random(models))
	net.Start("wepcl")
		net.WriteTable(weplist)
	net.Send(ply)
	ply:SetNWInt("wins", 0)
	CreateClientConVar( "gy_nextwep_enabled", "1", true, false )
	CreateClientConVar( "gy_nextwep_delay", ".4", true, false )
	concommand.Add("gy_print_weplist",(function(ply,cmd,args)
	net.Start("wepcl")
		net.WriteTable(weplist)
	net.Send(ply)
	end))
	ply:SetNWBool("voted",false)
end

function GM:PlayerAuthed( ply, steamID, uniqueID )
	print("Player "..ply:Nick().." has authed.")
end

function GM:PlayerDisconnected(ply)
	PrintMessage( HUD_PRINTTALK, ply:GetName() .. " has left the server." )
end

function GM:PlayerSpawn( ply )
	ply:SetGod(true)
	
	local EyeAng = ply:EyeAngles()
	ply:SetEyeAngles(Angle(EyeAng:__index("p"),EyeAng:__index("y"),0)) --Correct slanted views
	
	local RS = GetGlobalInt("RoundState")
	if RS ~= 2 then
		ply:SetNWInt("lifelevel",0)
		ply:GiveWeapons()
		if wep ~= nil then
			GAMEMODE:SetPlayerSpeed(ply, 210, 350)
		else
			GAMEMODE:SetPlayerSpeed(ply, 250, 480) --Crowbar
		end
		ply:SetNWBool("boosted", false)
		ply:SetJumpPower( 200 )
		
		ply:GodEnable()
		timer.Simple(1.5,function() ply:SetGod(false) end) --Spawn protection, maybe disable on shoot?
	end
end

function GM:PlayerDeath( Victim, Inflictor, Attacker )
end	

function ScaleDamage( ply, hitgroup, dmginfo )
	// More damage if we're shot in the head
		if ply:Crouching() then
			math.ceil(dmginfo:ScaleDamage( 0.75 ))
		end
		if ( hitgroup == HITGROUP_HEAD ) then
			math.ceil(dmginfo:ScaleDamage( ply:GetActiveWeapon().HeadshotMult or 2 ))
			if math.ceil(dmginfo:GetDamage() * 2 ) > ply:Health() then
				dmginfo:GetAttacker():EmitSound("gy/boomhead.wav", 290, 100)
				 dmginfo:SetDamageForce(dmginfo:GetDamageForce()*100000) --woosh
			end
		end
end
 
hook.Add("ScalePlayerDamage","ScaleDamage",ScaleDamage)