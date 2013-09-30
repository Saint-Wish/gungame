/* ROUND STATES
0 = Pre-round freeze
1 = In round
2 = Post round (The winner is slaughtering everyone)
3 = End of the game?
*/

function SpecialRound()
	if GetConVar("gy_special_rounds"):GetInt() == 0 then return end
	local rounds = {ROUND_SPLODE,ROUND_BARREL}
	local roll = math.Rand(1,2) --1/2 chance
	local selection = 0
	
	if roll == 1 then
		selection = table.Random(rounds)
		print("Special round! Code "..selection)
	end
	
	SetGlobalInt("gy_special_round",selection)
end

function RoundStart()
	--ImportEntities(game.GetMap())
	SetGlobalInt("RoundState", 0)
	ClearEnts()
	round = GetGlobalInt("round")
	SetGlobalInt("round", round+1)
	RandomizeWeapons()
	SpecialRound()
	/*local SR_go = math.random(1,1)
	if SR_go == 1 then
		SpecialRandom()
		print("Special Round!")
		--for k,v in pairs(SpecialRound) do
			--print(k,v)
		--end
	end*/
	
	for k,v in pairs(player.GetAll()) do
		net.Start("wepcl")
			net.WriteTable(weplist)
		net.Send(v)
		v:SetNWInt("level",1)
		v:Spawn()
		v:Lock()
		
		if CLIENT then
			v:cl_PrevNextWeps(level)
		end
		
		timer.Simple(2,function()
			v:UnLock() --Unfreeze
			SetGlobalInt("RoundState",1)--Start the round
		end)
	end
end

function RoundEnd(winner)
	SetGlobalInt("MaxRounds", GetConVarNumber("gy_rounds"))
	local maxround = GetGlobalInt("MaxRounds")
	local round = GetGlobalInt("round")
	for k,v in pairs(player.GetAll()) do
		if v ~= winner then
			v:StripWeapons()
		end
	end
	winner:Give("func_gy_wingun")
	winner:SelectWeapon("func_gy_wingun")
	SetGlobalInt("RoundState", 2)
	
	PrintMessage(HUD_PRINTCENTER, (winner:GetName().." won the round!"))

	if round >= maxround then
		timer.Simple(1, function() MapVote.Start(10, false, 12, {"gg_","dm_"}) end)
	else
		timer.Simple(8,function() RoundStart() end)
	end
end