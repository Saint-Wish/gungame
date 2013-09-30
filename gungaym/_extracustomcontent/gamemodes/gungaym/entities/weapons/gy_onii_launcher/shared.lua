-- Variables that are used on both client and server
SWEP.Class = ("gy_onii_launcher") -- must be the name of your swep but NO CAPITALS!
SWEP.Category				= "M9K Specialties" // Stolen from m9k specialties, shut up
SWEP.Author				= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.PrintName				= "Onii Launcher~"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 2				-- Slot in the weapon selection menu
SWEP.SlotPos				= 3			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight				= 30			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "shotgun"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_m79_grenadelauncher.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/w_m79_grenadelauncher.mdl"	-- Weapon world model
SWEP.ShowWorldModel			= false
SWEP.Crosshair = true

SWEP.Base				= "bobs_shotty_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater = false

SWEP.Primary.Sound			= Sound("weapon/oniboom.wav")		-- Script that calls the primary fire sound
SWEP.Primary.RPM			= 60			-- This is in Rounds Per Minute
SWEP.Primary.ClipSize			= 1		-- Size of a clip
SWEP.Primary.DefaultClip		= 2	-- Bullets you start with
SWEP.Primary.KickUp				= 0.3		-- Maximum up recoil (rise)
SWEP.Primary.KickDown			= 0.3		-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 0.3		-- Maximum up recoil (stock)
SWEP.Primary.Automatic			= false		-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= "smg1"				

SWEP.Secondary.IronFOV			= 60		-- How much you 'zoom' in. Less is more! 	
SWEP.Primary.Round 			= ("m9k_launched_m79")	--NAME OF ENTITY GOES HERE
SWEP.data 				= {}				--The starting firemode
SWEP.data.ironsights			= 1

SWEP.ShellTime			= .5

SWEP.ZoomFOV = 80
SWEP.ZoomTime = .03

SWEP.Primary.NumShots	= 1		-- How many bullets to shoot per trigger pull
SWEP.Primary.Damage		= 30	-- Base damage per bullet
SWEP.Primary.Spread		= .025	-- Define from-the-hip accuracy (1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = .015 -- Ironsight accuracy, should be the same for shotguns

-- Enter iron sight info and bone mod info below
SWEP.IronSightsPos = Vector(-4.633, -7.651, 2.108)
SWEP.IronSightsAng = Vector(1.294, 0.15, 0)
SWEP.pos = Vector(-4.633, -7.651, 2.108)
SWEP.ang = Vector(1.294, 0.15, 0)
SWEP.SightsPos = Vector(-4.633, -7.651, 2.108)
SWEP.SightsAng = Vector(1.294, 0.15, 0)
SWEP.RunSightsPos = Vector(3.279, -5.574, 0)
SWEP.RunSightsAng = Vector(-1.721, 49.917, 0)

function SWEP:IronSight()
	local speed1 = 0
	local speed2 = 0

	if self.Owner:GetNWBool("boosted") then
		speed1 = 550
		speed2 = 550
	else
		speed1 = 210
		speed2 = 350
	end
	
	
	if self.Owner:KeyPressed(IN_ATTACK2) and not (self.Weapon:GetNWBool("Reloading")) and (!self.Owner:KeyDown(IN_RELOAD) or (self.Weapon:Clip1() ~= self.Primary.ClipSize)) then
		self:SetIronsights(true)
		self.Owner:SetFOV(self.ZoomFOV or 80, self.ZoomTime or .03)
		GAMEMODE:SetPlayerSpeed(self.Owner, speed1, speed1)
	elseif ((self.Owner:KeyDown(IN_RELOAD) and (self.Weapon:Clip1() ~= self.Primary.ClipSize)) or (self.Weapon:Clip1() <= 0)) and (self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0) then
		self:SetIronsights( false )
		self.Owner:SetFOV(0, self.ZoomTime or .03)
	elseif self.Owner:KeyDown(IN_SPEED) and not self.Owner:KeyDown(IN_ATTACK2) then
		GAMEMODE:SetPlayerSpeed(self.Owner, speed1, speed2)
	elseif self.Owner:KeyPressed(IN_ATTACK2) and !self.Owner:KeyDown(IN_SPEED) then 
		self:SetIronsights(true)
		self.Owner:SetFOV(self.ZoomFOV or 80, self.ZoomTime or .03)
	end

	
	if self.Owner:KeyReleased(IN_ATTACK2) then
		self.Crosshair = true
		self:SetIronsights(false)
		self.Owner:SetFOV(0, self.ZoomTime or .03)
		GAMEMODE:SetPlayerSpeed(self.Owner, speed1, speed2)
		if CLIENT then return end
	end
		if self.Owner:KeyDown(IN_ATTACK2) then
			self.SwayScale 	= 0.1
			self.BobScale 	= 0.1
		else
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
end

function SWEP:SetupDataTables()

	self:DTVar( "Bool", 0, "Ironsight" )

end
function SWEP:DrawHUD()
	local iron = self.Weapon.dt.Ironsight
	if ( !self.Crosshair ) then return end
	// No crosshair when ironsights is on

	local x, y

	// If we're drawing the local player, draw the crosshair where they're aiming,
	// instead of in the center of the screen.
	if ( self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer() ) then

		local tr = util.GetPlayerTrace( self.Owner )
//		tr.mask = ( CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_GRATE|CONTENTS_AUX )
		local trace = util.TraceLine( tr )
		
		local coords = trace.HitPos:ToScreen()
		x, y = coords.x, coords.y

	else
		x, y = ScrW() / 2.0, ScrH() / 2.0
	end

	scale = 10 * self.Primary.Cone

	// Scale the size of the crosshair according to how long ago we fired our weapon
	local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
	
	surface.SetDrawColor( 0, 255, 0, 255 )
	
	// Draw an awesome crosshair
	local gap =  0 * scale
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	//surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
	self.DrawCrosshair = false
end

function SWEP:Reload()

	if not IsValid(self) then return end
	if not IsValid(self.Owner) then return end
	if not self.Owner:IsPlayer() then return end
	if self.Owner:GetAmmoCount("smg1") < 1 then return end

	local maxcap = self.Primary.ClipSize
	local spaceavail = self.Weapon:Clip1()
	local shellz = (maxcap) - (spaceavail) + 1

	if (timer.Exists("ShotgunReload")) or self.NextReload > CurTime() or maxcap == spaceavail then return end
	
	if self.Owner:IsPlayer() then 

		self.Weapon:SetNextPrimaryFire(CurTime() + 1.7) -- wait one second before you can shoot again
		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START) -- sending start reload anim
		self.Owner:SetAnimation( PLAYER_RELOAD )
		
		self.NextReload = CurTime() + 1
	
		if (SERVER) then
			self.Owner:SetFOV( 0, 0.15 )
			self:SetIronsights(false)
		end
	
		if SERVER and self.Owner:Alive() then
			local timerName = "ShotgunReload_" ..  self.Owner:UniqueID()
			timer.Create(timerName, 
			self.ShellTime, 
			shellz,
			function()
			self:InsertShell() end)
		end
	
	elseif self.Owner:IsNPC() then
		self.Weapon:DefaultReload(ACT_VM_RELOAD) 
	end
	
end

function SWEP:InsertShell()

	if not IsValid(self) then return end
	if not IsValid(self.Owner) then return end
	if not self.Owner:IsPlayer() then return end
	
	local timerName = "ShotgunReload_" ..  self.Owner:UniqueID()
	if self.Owner:Alive() then
		local curwep = self.Owner:GetActiveWeapon()

		if (self.Weapon:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
		-- if clip is full or ammo is out, then...
			self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH) -- send the pump anim
			timer.Destroy(timerName) -- kill the timer
		elseif (self.Weapon:Clip1() <= self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) >= 0) then
			self.InsertingShell = true
			self.Owner:RemoveAmmo(1, self.Primary.Ammo, false) -- out of the frying pan
			self.Weapon:SetClip1(self.Weapon:Clip1() + 1) --  into the fire
		end
	else
		timer.Destroy(timerName) -- kill the timer
	end
	
end
function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		if !self.Owner:KeyDown(IN_RELOAD) then
		self:FireRocket()
		if SERVER then
			self.Owner:SetGod(false)
		end
		self.Weapon:EmitSound(self.Primary.Sound)
		self.Weapon:TakePrimaryAmmo(1)
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		local fx 		= EffectData()
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Owner:MuzzleFlash()
		self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
	else self:Reload()
	end
	end
	
end

function SWEP:FireRocket()
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = self.Owner:GetShootPos() + side * 6 + up * -5

	if SERVER then
	local rocket = ents.Create(self.Primary.Round)
	if !rocket:IsValid() then return false end
	rocket:SetAngles(aim:Angle()+Angle(90,0,0))
	rocket:SetPos(pos)
	rocket:SetOwner(self.Owner)
	rocket:Spawn()
	rocket:Activate()
	end
end