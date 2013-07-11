t = {}
t.i = {}
keel = false
ded = false
sui = false

killgun = {"mutilated", "killed", "broke", "ventilated", "murdered", "destroyed" }
killknife = { "shanked", "stabbed", "cut", "cut up", "sliced" }
suicide = { "You couldn't take the heat", "You offed yourself", "You commited suicide", "You killed yourself", "Mistakes were made" }


--Right off the bat, I'm terrible with HUD's, so enjoy lots of text instead of a nice pretty bunch of health/ammo bars
--jk to the above, thanks Cowabanga for your mock HUD <3
function InitializeFonts()


surface.CreateFont( "healthindicator",
{
font      = "Tahoma",
size      = 30,
weight    = 500
}
)

surface.CreateFont( "lvlindicator",
{
font      = "Tahoma",
size      = 28,
weight    = 500
}
)

surface.CreateFont( "reservedammo",
{
font      = "Tahoma",
size      = 60,
weight    = 500
}
)

surface.CreateFont( "remainingammo",
{
font      = "Tahoma",
size      = 98,
weight    = 500
}
)

surface.CreateFont( "currentweapon",
{
font      = "Tahoma",
size      = 52,
weight    = 500
}
)

surface.CreateFont( "nextweapon",
{
font      = "Tahoma",
size      = 36,
weight    = 500
})
end


function GM:HUDPaint()

	hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
	hook.Run( "DrawDeathNotice", 0.85, 0.04 )

end

function cl_randlist()
	for k,v in pairs(weapons.GetList()) do
		if v.Class ~= nil then
			table.insert(t,k,(v.Class))
			table.insert(t.i,k,v.PrintName)
		end
	end
end

function cl_ReceiveList()
	randlist = net.ReadTable()
	for k,v in pairs(randlist) do
		print (k,v)
	end
	cl_randlist()
end
net.Receive("wepcl",cl_ReceiveList)

function cl_PrevNextWeps(level)
	nextwep = randlist[level+1]
	for l,p in pairs(t) do
	
		if nextwep == p then
			for k,v in pairs(t.i) do
				if l == k then
					nextname = v
				end
			end
		end
	end
end

function DrawHUD()

	hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
	hook.Run( "DrawDeathNotice", 0.85, 0.04 )
	ply = LocalPlayer()
	local round = GetGlobalInt("round")
	health = ply:Health()
	level = ply:GetNWInt("level")
	if ply:Alive() then
	
		if GetConVarNumber("gy_nextwep_enabled") == 1 then
			if lasttime == nil or lasttime < CurTime() - (GetConVarNumber("gy_nextwep_delay")) then
				lasttime = CurTime()
				cl_PrevNextWeps(level)
			end
			if nextname ~= nil and level == count() then
				draw.SimpleTextOutlined("Crowbar","nextweapon", ScrW()/1.215, ScrH() /1.046, Color(161,161,161), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(74,74,74))
			elseif nextname ~= nil and level < count() then
				draw.SimpleTextOutlined((nextname),"nextweapon", ScrW()/1.215, ScrH() /1.046, Color(161,161,161), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(74,74,74))
			end
		end
		
		if IsValid(ply:GetActiveWeapon()) then
			local mag_left = ply:GetActiveWeapon():Clip1() //How much ammunition you have inside the cusrrent magazine
			local mag_extra = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType()) //How much ammunition you have outside the current magazine
			
			name = ply:GetActiveWeapon().PrintName
			draw.SimpleTextOutlined((name) ,"currentweapon", ScrW()/1.215, ScrH()/1.08, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP,1.5, Color(74,74,74))
			

			
			if level < count() + 1 then
				draw.SimpleTextOutlined(("Level: "..level.."/"..count()) ,"lvlindicator", ScrW()/9.9, ScrH() /1.1, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(74,74,74))
			end
			
			--if prevname ~= nil and level ~= 1 then
				--draw.SimpleText((prevname) ,"prevwep", ScrW()-350, ScrH() - 180, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			--end
			
			if mag_left ~= -1 then
				draw.SimpleTextOutlined((mag_left) ,"remainingammo", ScrW()/1.145, ScrH() - 41, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1.5, Color(74,74,74))
				draw.SimpleTextOutlined(("/"..mag_extra) ,"reservedammo", ScrW()/1.145, ScrH() - 50, Color(161,161,161), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(74,74,74))
			end
			--draw.RoundedBox(10, ScrW()/15, ScrH() - 100, 250, 50, Color(100,25,25,200))
			draw.RoundedBox(2, ScrW()/9.9, ScrH() / 1.1, 300, 30, Color(106,17,17))
			draw.RoundedBox(2, ScrW()/9.9, ScrH() / 1.1, LocalPlayer():Health()*3, 30, Color(33,107,33))
			draw.SimpleTextOutlined((health) ,"healthindicator", ScrW()/3.92, ScrH() / 1.069, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP,1,Color(74,74,74))
			
		end
	end
	
	if lastertime == nil or lastertime < CurTime() - 4 then
		lastertime = CurTime()
		local round = GetGlobalInt("round")
		maxrounds = GetGlobalInt("MaxRounds")
	end
		
	draw.SimpleTextOutlined(("Round "..round.."/"..maxrounds) ,"reservedammo", ScrW()/10, ScrH()/1.015, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP,1,Color(74,74,74))
end

hook.Add("HUDPaint","DrawHUD",DrawHUD)

function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery","CHudAmmo","CHudSecondaryAmmo"})do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "HideOldHud", hidehud)
