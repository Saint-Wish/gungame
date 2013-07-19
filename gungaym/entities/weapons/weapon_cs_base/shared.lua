
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then
	SWEP.PrintName			= "null"
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	// This is the font that's used to draw the death icons
	
	surface.CreateFont( "CSKillIcons", {
	font = "csd", 
	size = ScreenScale( 20 ),
	weight = 500,
	antialias = true, 
	additive = true, })
	--surface.CreateFont( "csd", ScreenScale( 60 ), 500, true, true, "CSSelectIcons" )
	

end

SWEP.Author			= "Counter-Strike"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
//SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ZoomFOV				= 70
SWEP.ZoomTime				= .25
SWEP.RunPenalty				= 1.5
SWEP.AimBoost				= .75
SWEP.HeadshotMult 			= 2


function SWEP:SetupDataTables()

	self:DTVar( "Bool", 0, "Ironsight" )

end

function SWEP:OnRestore()
	wepnames = {}
	table.insert(wepnames,(self.PrintName),(self:GetClass()))
end


/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()


	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end
	
	self:SetWeaponHoldType( self.HoldType )
	self.dt.Ironsight = false
	
end


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	--self:SetIronsights( false )
	--self.Owner:SetFOV(0, self.ZoomTime or .5)
end


/*---------------------------------------------------------
IronSight (stolen from m9k)
---------------------------------------------------------*/
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
/*---------------------------------------------------------
IronSight
---------------------------------------------------------*/

/*---------------------------------------------------------
   Think does nothing (jklol)
---------------------------------------------------------*/
function SWEP:Think()	
	self:IronSight()
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	local recoil = self.Primary.Recoil
	local cone = self.Primary.Cone

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	if  self:GetNWBool("reloading") then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	
	
	if self.dt.Ironsight then
		recoil =  recoil * (self.AimBoost or .75)
		cone = cone * (self.AimBoost or .75)
	end
	
	if self.Owner:KeyDown(IN_SPEED) then
		recoil =  recoil * (self.RunPenalty or 1.5)
		cone = cone * (self.RunPenalty or 1.5)
	end
	
	if SERVER then
		self.Owner:SetGod(false)
	end
	
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, recoil, self.Primary.NumShots, cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

/*---------------------------------------------------------
   Name: SWEP:CSShootBullet( )
---------------------------------------------------------*/
function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	iron = ( self.dt.Ironsight )
	if iron then
		cone = cone * 0.9
	end

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= 4									// Show a tracer on every x bullets 
	bullet.Force	= 300									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
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


/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
	--draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	
	// try to fool them into thinking they're playing a Tony Hawks game
	--draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	--draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	
end

local IRONSIGHT_TIME = SWEP.ZoomTime

/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.dt.Ironsight
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end


/*---------------------------------------------------------
	SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights( b )

	self.dt.Ironsight = b

end


SWEP.NextSecondaryAttack = 0

function SWEP:SecondaryAttack()
end

function SWEP:DrawHUD()
	local iron = self.Weapon.dt.Ironsight
	// No crosshair when ironsights is on
	if ( self.dt.Ironsight ) then return end

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

	scale = 15 * self.Primary.Cone

	// Scale the size of the crosshair according to how long ago we fired our weapon
	local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
	
	if self.Owner:KeyDown(IN_SPEED) then
		scale = scale * (self.RunPenalty or 1.5)
	end
	
	surface.SetDrawColor( 0, 255, 0, 255 )
	
	// Draw an awesome crosshair
	local gap =  30 * scale
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )

end


/*---------------------------------------------------------
	onRestore
	Loaded a saved game (or changelevel)
---------------------------------------------------------*/
function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	self:SetIronsights( false )
	
end

function SWEP:OnDrop()
   self:Remove()
end
