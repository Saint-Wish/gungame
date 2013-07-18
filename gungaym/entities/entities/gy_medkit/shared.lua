-- Ammo override base

if SERVER then
   AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

-- Override these values
ENT.AmmoType = "Pistol"
ENT.AmmoAmount = 1
ENT.AmmoMax = 10
ENT.Model = Model( "models/items/HealthKit.mdl" )


function ENT:RealInit() end -- bw compat

-- Some subclasses want to do stuff before/after initing (eg. setting color)
-- Using self.BaseClass gave weird problems, so stuff has been moved into a fn
-- Subclasses can easily call this whenever they want to
function ENT:Initialize()
   self:SetModel( self.Model )

   self:PhysicsInit( SOLID_VPHYSICS )
   self:SetMoveType( MOVETYPE_VPHYSICS )
   self:SetSolid( SOLID_BBOX )

   self:SetCollisionGroup( COLLISION_GROUP_WORLD)
   local b = 35
   self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))
   if SERVER then
      self:SetTrigger(true)
   end
	
   self.taken = false
   self.pos = self:GetPos()
   -- this made the ammo get physics'd too early, meaning it would fall
   -- through physics surfaces it was lying on on the client, leading to
   -- inconsistencies
   --	local phys = self.Entity:GetPhysicsObject()
   --	if (phys:IsValid()) then
   --		phys:Wake()
   --	enda
end

-- Pseudo-clone of SDK's UTIL_ItemCanBeTouchedByPlayer
-- aims to prevent picking stuff up through fences and stuff
function ENT:PlayerCanPickup(ply)
   if ply == self:GetOwner() then return false end

   local ent = self.Entity
   local phys = ent:GetPhysicsObject()
   local spos = phys:IsValid() and phys:GetPos() or ent:OBBCenter()
   local epos = ply:GetShootPos() -- equiv to EyePos in SDK

   local tr = util.TraceLine({start=spos, endpos=epos, filter={ply, ent}, mask=MASK_SOLID})

   -- can pickup if trace was not stopped
   return tr.Fraction == 1.0
end


function ENT:Touch(ent)
   if SERVER and self.taken != true then
      if (ent:IsValid() and ent:IsPlayer())  then

         local health = ent:Health()
		 
		 if GetConVar("gy_overheal_enabled"):GetBool() then
			max = GetConVar("gy_overheal_max"):GetInt()
		else
			max = 100
		end
		
         if health < max then
			ent:SetHealth(math.Min(health + 50, max))
			ent:EmitSound("items/smallmedkit1.wav",150,130)
			RespawnMedkit(self.pos)
            self:Remove()
            -- just in case remove does not happen soon enough
            self.taken = true
         end
      end
   end
end

-- Hack to force ammo to physwake
if SERVER then
   function ENT:Think()
      if not self.first_think then
         self:PhysWake()
         self.first_think = true

         -- Immediately unhook the Think, save cycles. The first_think thing is
         -- just there in case it still Thinks somehow in the future.
         self.Think = nil
      end
   end
end

