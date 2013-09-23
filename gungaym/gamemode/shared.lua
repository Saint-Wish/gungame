GM.Name = "Gun Gaym"
GM.Author = "Ericson777/Shaps"
GM.Email = "s.fuller468@gmail.com"
GM.Website = "" //RIP Goatse.cx

ROUND_SPLODE = 1
ROUND_BARREL = 2

function GM:Initialize()
	self.BaseClass.Initialize( self )
	
end

team.SetUp(0,"Gaymers",Color(255, 0, 0))
cvars.AddChangeCallback( "gy_rounds", function( convar_name, oldValue, newValue )
	SetGlobalInt("MaxRounds",newValue)
	print(convar_name,oldValue,newValue)
end )

function LowestLevel(plyignore)
	local low = math.huge
	local count = 0
	
	for k,v in pairs(player.GetAll()) do
		if v ~= plyignore then
			count = count + 1
			local lev = v:GetNWBool("level")
			if lev < low then
				low = lev
			end
		end
	end
	
	print(low,count)
	
	if count > 0 then
		return low
	else
		return 1
	end
end

/*
Alright, this is about to get really messy
The following is pretty much going to be all the stuff that happens on kill
*/
function OnKill( victim, weapon, killer )

	if GetGlobalInt("gy_special_round") == ROUND_SPLODE then --Don't pay attention to this, this will come when I add speshul rounds
		if !((weapon:GetClass() == "gy_crowbar") or (weapon:GetClass() == "gy_knife")) then
			local explode = ents.Create( "env_explosion" ) -- creates the explosion
			explode:SetPos( victim:GetPos() )
			-- this creates the explosion through your self.Owner:GetEyeTrace, which is why I put eyetrace in front
			explode:SetOwner( killer ) -- this sets you as the person who made the explosion
			explode:Spawn() --this actually spawns the explosion
			explode:SetKeyValue( "iMagnitude", GetConVar("gy_splode_mag"):GetInt() ) -- the magnitude
			explode:Fire( "Explode", 0, 0 )
		end
	end

	timer.Simple(.1,function() victim:Extinguish() end)
	local prevlev = killer:GetNWInt("level") --Define the killer's level for convienence
	local wep = weplist[prevlev]
	victim.NextSpawnTime = CurTime() + 4
	victim.DeathTime = CurTime()
	if weapon:GetClass() == "gy_crowbar" then
		RoundEnd(killer)
	end
	
	
	if victim == killer or not IsValid(killer) then --If you kill yourself/Fall to your death (I *think* no wep=fall basically)
		victim:Demote()
	else --Else, if someone else killed you
		if (prevlev) > count() and GetGlobalInt("RoundState") == 1 then --If the killer's level is higher than the gun total...
			print("TestDone")
			RoundEnd(killer) --and we're still in round, finish the round
		elseif prevlev <= count() then --Or if it's just a normal kill, give them a level and their guns
			--SendDeathMessage(victim,killer:GetActiveWeapon().Class,killer)
			if killer:GetActiveWeapon().Class == "gy_knife" then
				victim:Demote()
			end
			killer:SetNWInt("level",prevlev+1)
			killer:SetNWInt("lifelevel",(killer:GetNWInt("lifelevel")+1))
			timer.Simple(.01,function() killer:GiveWeapons() end)
			--killer:GiveWeapons()
		end
		LevelMsg(killer,(prevlev+1),GetGlobalInt("RoundState")) 
	end
	
	if killer:GetNWInt("lifelevel") == 3 then
		killer:KillStreak()
	end
	
	DeathTicker(victim, weapon, killer)
	
end
hook.Add( "PlayerDeath", "playerDeathTest", OnKill )


--Shamelessly ripped from the base gamemode code
function DeathTicker( Victim, Inflictor, Attacker )
	if ( !IsValid( Inflictor ) && IsValid( Attacker ) ) then
		Inflictor = Attacker
	end

	-- Convert the inflictor to the weapon that they're holding if we can.
	-- This can be right or wrong with NPCs since combine can be holding a 
	-- pistol but kill you by hitting you with their arm.
	if ( Inflictor && Inflictor == Attacker && (Inflictor:IsPlayer() || Inflictor:IsNPC()) ) then
	
		Inflictor = Inflictor:GetActiveWeapon()
		if ( !IsValid( Inflictor ) ) then Inflictor = Attacker end
	
	end
	
	if (Attacker == Victim) then
	
		umsg.Start( "PlayerKilledSelf" )
			umsg.Entity( Victim )
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " suicided!\n" )
		
	return end

	if ( Attacker:IsPlayer() ) then
	
		umsg.Start( "PlayerKilledByPlayer" )
		
			umsg.Entity( Victim )
			umsg.String( Inflictor:GetClass() )
			umsg.Entity( Attacker )
		
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " killed " .. Victim:Nick() .. " using " .. Inflictor:GetClass() .. "\n" )
		
	return end
	
	umsg.Start( "PlayerKilled" )
	
		umsg.Entity( Victim )
		umsg.String( Inflictor:GetClass() )
		umsg.String( Attacker:GetClass() )

	umsg.End()
	
	MsgAll( Victim:Nick() .. " was killed by " .. Attacker:GetClass() .. "\n" )
	
end
--hook.Add( "PlayerDeath", "playerDeathTest", DeathTicker )

--Will message the killer his level and stuff
function LevelMsg(killer,level,RoundState)
	local wep = weplist[level]
		
	if wep == nil and (RoundState == 1) then --If you didn't, you must be on knife level, so you get this message
		PrintMessage(HUD_PRINTCENTER, (killer:GetName().." is on knife level!"))
	end
end

function SendDeathMessage(victim,weapon,killer)
	umsg.Start( "DeathNotif" )
		umsg.String (victim:GetName())
		umsg.String (weapon)
		umsg.String (killer:GetName())
	umsg.End()
end
	
function RespawnMedkit(pos)
	timer.Simple(GetConVar("gy_pickup_respawntime"):GetInt() or 25,function()
		local ent = ents.Create("gy_medkit")
		ent:SetPos(pos)
		ent:Spawn()
	end)
end	