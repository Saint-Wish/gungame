SWEP.Category				= "Cole3017"
SWEP.PrintName 				= "Garter .44" 
SWEP.Author		                	= "cole3017"
SWEP.Purpose				= "Shooting and killing. At least i hope so."
SWEP.MuzzleAttachment			= 3
SWEP.ShellEjectAttachment			= 1
SWEP.HoldType 				= "pistol"
SWEP.ViewModelFlip	                = false
SWEP.ViewModelFOV		= 80
SWEP.WeaponDeploySpeed                  = 0.8
SWEP.Base 				= "weapon_cs_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 			= true
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.IconLetter			= "g"
SWEP.FiresUnderwater = false
SWEP.ViewModel 				= "models/weapons/v_pist_python.mdl"
SWEP.WorldModel 				= "models/weapons/w_pist_deagle.mdl"
SWEP.Primary.Cone		        = 0.01

SWEP.Primary.Sound 			= "weapons/python/python-1.wav"
SWEP.Primary.Recoil				= 7
SWEP.Primary.Damage 			= 75
SWEP.Primary.NumShots 			= 1
SWEP.Primary.ClipSize 			= 6
SWEP.Primary.Delay 			= 0.45
SWEP.Primary.DefaultClip 			= 12
SWEP.Primary.Automatic 			= false
SWEP.Primary.Ammo 			= "smg1"
SWEP.Primary.Tracer	= 0
SWEP.Primary.Force      = 17
SWEP.ViewModelFlip	= true
SWEP.Class			= "weapon_python"


SWEP.IronSightsPos = Vector(2.289, 0, 0.768)
SWEP.IronSightsAng = Vector(0.843, 0.013, 0)






function SWEP:Deploy()

self.Weapon:EmitSound("hl2_base_sounds/draw.wav")
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	
	self.Reloadaftershoot = CurTime() + 1
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	return true
end


	
