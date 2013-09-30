	

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "33rd's Bane"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.IconLetter			= "i"
	SWEP.ViewModelFlip		= false
	SWEP.ViewModelFOV		= 80
	
	killicon.AddFont( "gy_g3", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end
SWEP.Class				= "gy_aa12"
SWEP.HoldType			= "smg"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel                = "models/weapons/v_kfaa12.mdl"
SWEP.WorldModel               = "models/weapons/w_shot_usas12.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound            = Sound ( "Weapons/aa12/Fire.wav" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 1 --Explosion does all the damage
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= .2
SWEP.Primary.DefaultClip	= 40
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ZoomFOV	       = 80
SWEP.ZoomTime          = 0.3
SWEP.IronSightsPos = Vector (-4.0206, -1.5313, 1.901)
SWEP.IronSightsAng = Vector (0.823, -0.0165, 0)

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= 1									// Show a tracer on every x bullets 
	bullet.Force	= 3000								// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	bullet.Callback = function(att, tr, dmginfo)
		if CLIENT then return end
		local explode = ents.Create( "env_explosion" ) -- creates the explosion
		explode:SetPos( tr.HitPos )
		-- this creates the explosion through your self.Owner:GetEyeTrace, which is why I put eyetrace in front
		explode:SetOwner( self.Owner ) -- this sets you as the person who made the explosion
		explode:Spawn() --this actually spawns the explosion
		explode:SetKeyValue( "iRadiusOverride", 155 ) -- the radius
		explode:SetKeyValue( "iMagnitude", 25 ) -- the magnitude
		
		explode:Fire( "Explode", 0, 0 )
	end
	
	self.Owner:FireBullets( bullet )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	
	end

end
