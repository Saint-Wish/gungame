local ply = FindMetaTable("Player")

local teams = {}
teams[0] = {name = "Gaymers"}

function ply:KillStreak()
	self:SetNWInt("lifelevel",0)
	local sound = table.Random(killstreaksound)
	self:EmitSound(sound,300,100)
	GAMEMODE:SetPlayerSpeed(self, 550, 550)
	self:SetJumpPower( 300 )
	self:SetNWBool("boosted",true)
	local trail = util.SpriteTrail(self, 0, Color(255,0,0), false, 40, 30, 5.5, 1/(15+1)*0.5, "trails/plasma.vmt")
	timer.Simple(5.5,function() 
		GAMEMODE:SetPlayerSpeed(self, 210, 350)
		trail:Remove()
		self:SetJumpPower( 200 )
		self:SetNWBool("boosted", false)
	end)
end

function ply:SetGamemodeTeam( n )
	if not teams[n] then return false end
	self:SetTeam( n )
	--self:GiveWeapons()
	return true
end

function ply:Demote()
	print(self:GetName().." leveled down")
	local prevlevs = self:GetNWInt("level")
	if prevlevs > 1 then
		self:SetNWInt("level", prevlevs - 1)
	end
end

function ply:SetGod(b)
	if b == true then
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:SetColor( Color(255, 255, 255, 100) )
		self:GodEnable()
	elseif b == false then
		self:SetColor( Color(255, 255, 255, 255) )
		self:GodDisable()
	end
end

function ply:GiveWeapons()
	self:StripWeapons()
	
	local y = self:GetNWInt("level")
	local weppast = weplist[y-1]
	local wep = weplist[y]
	local wepnext = weplist[y+1]
	
	if wep ~= nil then
		self:Give(wep)
		self:Give("gy_knife")
		self:Give("func_gy_trans")
		self:SelectWeapon("func_gy_trans") --For whatever reason, if I don't swap to another weapon and then...
		self:SetAmmo(weapons.Get(wep).Primary.ClipSize * 2, "smg1",true)
		timer.Simple(.01,function() self:SelectWeapon(wep);self:StripWeapon("func_gy_trans") end) --...swap to the new weapon, the new weapon doesn't do the draw anim
	else
		self:Give("gy_crowbar")
		self:Give("func_gy_trans") --I made a silent transitive weapon to avoid the SHING of the knife's draw sound
		self:SelectWeapon("func_gy_trans") 
		timer.Simple(.01,function() self:SelectWeapon("gy_crowbar");self:StripWeapon("func_gy_trans") end)
	end
end 

function GM:GetFallDamage( ply, speed )
	return speed/20 --Top of GM13's Flatgrass deals about 39 damage
end

function GM:PlayerDeathThink( pl )

	if (  pl.NextSpawnTime && pl.NextSpawnTime > CurTime() ) or (GetGlobalInt("RoundState") == 2) then return end

	if ( pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) || pl:KeyPressed( IN_JUMP ) ) then
	
		pl:Spawn()
		
	end
	
end

local time = CurTime()

function OverhealDecay()
	if CurTime() > (time) then
		time = CurTime() + (1 / (GetConVar("gy_overheal_decay"):GetInt() or 1))
		for k,v in pairs(player.GetAll()) do
			local hp = v:Health()
			if hp > 100 then
				v:SetHealth(hp - 1)
			end
		end
	end
end

hook.Add("Tick", "OverhealDecayHook", OverhealDecay)