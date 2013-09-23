//General Variables\\
SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 64
SWEP.ViewModel = "models/jaanus/v_drilldo.mdl"
SWEP.WorldModel = "models/jaanus/w_drilldo.mdl"
SWEP.AutoSwitchTo = true
SWEP.Slot = 2
SWEP.HoldType = "Pistol"
SWEP.PrintName = "Weiner"
SWEP.Author = "Tettryn"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.FiresUnderwater = true
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.Category = "Tettryn's SWEPS"
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.ReloadSound = "Weapon_Pistol.Reload"
SWEP.Instructions = "Primary Fire Shoots Dildos"
SWEP.Contact = "Dont Contact Me"
SWEP.Purpose = "Shoot Dildos At People"
SWEP.Base = "weapon_cs_base"
//General Variables\\
	SWEP.ViewModelFlip		= false
//Primary Fire Variables\\
SWEP.Primary.Sound = "Weapon_Pistol.Single"
SWEP.Primary.Damage = 10
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 0
SWEP.Primary.AngVelocity = Angle(0,0,0)
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 64
SWEP.Primary.Spread = 1
SWEP.Primary.Model = "models/xero/cookie/cookie.mdl"
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 2
SWEP.Primary.Delay = .05
SWEP.Primary.Force = 10
//Primary Fire Variables\\

//Secondary Fire Variables\\
SWEP.Secondary.NumberofShots = 1
SWEP.Secondary.Force = 10
SWEP.Secondary.Spread = 0.1
SWEP.Secondary.Sound = "Weapon_Pistol.Single"
SWEP.Secondary.DefaultClip = 32
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Delay = 0.1
SWEP.Secondary.TakeAmmo = 1
SWEP.Secondary.ClipSize = 16
SWEP.Secondary.Damage = 10
//Secondary Fire Variables\\


SWEP.Class = "func_gy_wingun"

//SWEP:Initialize()\\
function SWEP:Initialize()
	util.PrecacheSound(self.Primary.Sound)
	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end
end
//SWEP:Initialize()\\

//SWEP:PrimaryFire()\\
function SWEP:PrimaryAttack()
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self:Throw_Attack (self.Primary.Model, self.Primary.Sound, self.Primary.AngVelocity)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
end
//SWEP:PrimaryFire()\\

//SWEP:SecondaryFire()\\
function SWEP:SecondaryFire()
	return false
end
//SWEP:SecondaryFire()\\

//SWEP:Throw_Attack(Model, Sound, Angle)\\
function SWEP:Throw_Attack (Model, Sound, Angle)
	local tr = self.Owner:GetEyeTrace()
	self.Weapon:EmitSound (Sound)
	self.BaseClass.ShootEffects (self)
	if (!SERVER) then return end
	for x = 1,3 do
		local ent = ents.Create ("prop_physics")
		ent:SetModel (Model)
		ent:SetPos (self.Owner:EyePos() + (self.Owner:GetAimVector() * 16) + Vector(math.Rand(-25,25),math.Rand(-25,25),math.Rand(-25,25)))
		ent:SetAngles (self.Owner:EyeAngles())
		ent:SetOwner(self.Owner)
		ent:SetPhysicsAttacker(self.Owner)
		ent:Spawn()
		timer.Simple(4,function() ent:Remove() end)
		local phys = ent:GetPhysicsObject()
		local shot_length = tr.HitPos:Length()
		phys:ApplyForceCenter (self.Owner:GetAimVector():GetNormalized() * math.pow (shot_length, 7))
		--phys:AddAngleVelocity(Angle)
		cleanup.Add (self.Owner, "props", ent)
		undo.Create ("Thrown model")
		undo.AddEntity (ent)
		undo.SetPlayer (self.Owner)
		undo.Finish()
	end
end
//Throw_Attack(Model, Sound, Angle)\\
