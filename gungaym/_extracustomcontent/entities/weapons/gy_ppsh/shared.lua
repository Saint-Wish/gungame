

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "The Reaper"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "b"
	SWEP.ViewModelFOV			= 45
	SWEP.ViewModelFlip		= false
	killicon.AddFont( "gy_ak47", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end
SWEP.Class				= "gy_ppsh"
SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_ppsh1941.mdl"
SWEP.WorldModel			= "models/weapons/w_ppsh1941.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound 		= Sound("weapons/ppsh_shoot.wav")
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 19
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.035
SWEP.Primary.ClipSize		= 71
SWEP.Primary.Delay			= 0.034
SWEP.Primary.DefaultClip	= 60
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector (-4.5259, -4.2141, 1.7646)
SWEP.IronSightsAng 		= Vector (0.6244, 0.0186, 0)

SWEP.ZoomFOV	= 70
SWEP.ZoomTime 	= .1
SWEP.RunPenalty		= 1.2
SWEP.AimBoost = .8
SWEP.Spray		= 25