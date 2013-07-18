a = 0
local b = 0
mapvote = {}

function RandomizeWeapons()
	l=count()
	for i = l, 2, -1 do -- backwards
		local r = math.random(i) -- select a random number between 1 and i
		maplist[i], maplist[r] = maplist[r], maplist[i] -- swap the randomly selected item to position i
	end  
end



function changemap()
	if SERVER then
		local num = 1
		local now = game.GetMap()
		
		maps = {}
		for k,v in pairs(file.Find("maps/gg_*.bsp","MOD")) do
			if string.gsub(tostring(v),".bsp","") ~= now then
				maps[num] = v
				num = num + 1
			end
		end
		
		for k,v in pairs(file.Find("maps/*_gy.txt","MOD")) do
			local c = string.gsub(tostring(v),"_gy.txt",".bsp")
			if string.gsub(tostring(v),"_gy.txt","") ~= tostring(now) then
			print(now,v,c,c2)
				maps[num] = c
				num = num + 1
			end
		end
		
		for i = #maps, 2, -1 do -- backwards
			local r = math.random(i) -- select a random number between 1 and i
			maps[i], maps[r] = maps[r], maps[i] -- swap the randomly selected item to position i
		end  
		
		PrintTable(maps)
		print(num)
		for x = 1,math.min(num-1,5) do
			mapvote[maps[x]] = 0
		end
		
		for k,v in pairs(player.GetAll()) do
			--if not v:GetNWBool("voted") then
				v:SetNWBool("voted",false)
				net.Start("maplist")
					net.WriteTable(maps)
				net.Send(v)
			--end
		end
	end
	timer.Simple(7.9,function() sv_mapvotefin() end)
end

function cl_SendChoice()
	if CLIENT then
		b = b + 1
		if b > 1 then return end
		print "hi"
		local maps = net.ReadTable()
		choice = nil
		
		
		local frame = vgui.Create("DFrame")
		frame:SetSize(300,(#maps * 40 + 50))
		frame:SetTitle("Map vote")
		frame:Center()
		frame:MakePopup()
		DermaList = vgui.Create( "DPanelList", frame )
		DermaList:SetPos( 20,40 )
		DermaList:SetSize( 260, 240 )
		DermaList:SetSpacing( 5 ) -- Spacing between items
		DermaList:EnableHorizontal( false ) -- Only vertical items
		DermaList:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
		
		
		for k,v in pairs(maps) do
			button = vgui.Create("DButton")
			button:SetSize(260,35)
			button:SetText(string.gsub(v,".bsp",""))
			button:SetParent(frame)
			button.DoClick = function()
			net.Start("mapback")
				net.WriteString(v)
				net.WriteEntity(LocalPlayer())
			net.SendToServer()
			frame:Close()
			end
			DermaList:AddItem( (button) ) -- Add the item above
		end
	end
end
net.Receive("maplist",cl_SendChoice)


function sv_gotit()
	choice = net.ReadString()
	ply = net.ReadEntity()
	if ply:GetNWBool("voted") then return end
	ply:SetNWBool("voted",true)
	print(choice)
	old = mapvote[choice]
	mapvote[choice] = (old + 1)
	--SetGlobalInt(choice,GetGlobalInt(choice)+1)
	for k,v in pairs(mapvote) do
		if k == choice then
			--v=v+1
			
			--print(k,v)
		end
		--print(k,v)
	end
	--print(GetGlobalInt(choice))
	print(mapvote[choice])
end
net.Receive("mapback",sv_gotit)

function sv_mapvotefin()
	--a = 0
	--b = nil
	for k,v in pairs(mapvote) do
		if v > a then
			a = v
			b = k
		end
	end
	print(a,b)
	if b ~= nil then
		final = string.sub(b,1,-5)
	else
		final = string.sub(table.Random(file.Find("maps/gg_*.bsp","MOD")),1,-5)
	end
	PrintMessage( HUD_PRINTCENTER, "Next map is "..final.."." )
	timer.Simple(5, function() RunConsoleCommand("changelevel",final) end)
end