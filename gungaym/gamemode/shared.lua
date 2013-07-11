GM.Name = "Gun Gaym"
GM.Author = "Ericson777/Shaps"
GM.Email = "s.fuller468@gmail.com"
GM.Website = "" //RIP Goatse.cx

function GM:Initialize()
	self.BaseClass.Initialize( self )
	
end

team.SetUp(0, "Gaymers", Color(0,0,0,255)) --hue
cvars.AddChangeCallback( "gy_rounds", function( convar_name, oldValue, newValue )
	SetGlobalInt("MaxRounds",newValue)
	print(convar_name,oldValue,newValue)
end )
/*
Alright, this is about to get really messy
The following is pretty much going to be all the stuff that happens on kill
*/
function OnKill( victim, weapon, killer )
	local prevlev = killer:GetNWInt("level") --Define the killer's level for convienence
	local wep = weplist[prevlev]
	victim.NextSpawnTime = CurTime() + 4
	victim.DeathTime = CurTime()
	if weapon:GetClass() == "gy_crowbar" then
		RoundEnd(killer)
	end
	
	
	if victim == killer or not IsValid(killer) then --If you kill yourself/Fall to your death (I *think* no wep=fall basically)
		demote(victim)
	else --Else, if someone else killed you
		if (prevlev) > count() and GetGlobalInt("RoundState") == 1 then --If the killer's level is higher than the gun total...
			print("TestDone")
			RoundEnd(killer) --and we're still in round, finish the round
		elseif prevlev <= count() then --Or if it's just a normal kill, give them a level and their guns
			--SendDeathMessage(victim,killer:GetActiveWeapon().Class,killer)
			if killer:GetActiveWeapon().Class == "gy_knife" then
				demote(victim)
			end
			killer:SetNWInt("level",prevlev+1)
			killer:SetNWInt("lifelevel",(killer:GetNWInt("lifelevel")+1))
			timer.Simple(.01,function() killer:GiveWeapons() end)
			--killer:GiveWeapons()
		end
		LevelMsg(killer,(prevlev+1),GetGlobalInt("RoundState")) 
	end
	
	if killer:GetNWInt("lifelevel") == 3 then
		KillStreak(killer)
	end
	
	DeathTicker(victim, weapon, killer)
	
end
hook.Add( "PlayerDeath", "playerDeathTest", OnKill )


--Shamelessly ripped from the base gamemode code
function DeathTicker( Victim, Inflictor, Attacker )
	print(Inflictor:GetClass())
	
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


function KillStreak(ply)
	ply:SetNWInt("lifelevel",0)
	killstreaksound = { "gy/canttouch.wav", "gy/best.wav" }
	ply:EmitSound(((table.Random(killstreaksound))), 500, 100)
	GAMEMODE:SetPlayerSpeed(ply, 550, 550)
	ply:SetJumpPower( 300 )
	ply:SetNWBool("boosted",true)
	local trail = util.SpriteTrail(ply, 0, Color(255,0,0), false, 40, 30, 5.5, 1/(15+1)*0.5, "trails/plasma.vmt")
	timer.Simple(5.5,function() 
		GAMEMODE:SetPlayerSpeed(ply, 210, 350)
		trail:Remove()
		ply:SetJumpPower( 200 )
		ply:SetNWBool("boosted", false)
	end)
end



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

function demote(ply)
	print(ply:GetName().." leveled down")
	local prevlevs = ply:GetNWInt("level")
	if prevlevs > 1 then
		ply:SetNWInt("level", prevlevs - 1)
	end
end
	
	
function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )
    text = string.lower(strText)
    --
    -- I've made this all look more complicated than it is. Here's the easy version
    --
    -- chat.AddText( player, Color( 255, 255, 255 ), ": ", strText )
    --
    
    local tab = {}
    
    if ( bPlayerIsDead ) then
        table.insert( tab, Color( 255, 30, 40 ) )
        table.insert( tab, "*DEAD* " )
    end
    
    if ( bTeamOnly ) then
        table.insert( tab, Color( 30, 160, 40 ) )
        table.insert( tab, "(TEAM) " )
    end
    
    if ( IsValid( player ) ) then
        table.insert( tab, player )
    else
        table.insert( tab, "Console" )
    end
    
    table.insert( tab, Color( 255, 255, 255 ) )
    table.insert( tab, ": "..strText )
    
    chat.AddText( unpack(tab) )


    return true

end

