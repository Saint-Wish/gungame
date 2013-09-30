--Credits to Willox for this shit, I used his mapvote addon to replace my old shitty system
--Find the facepunch thread here: http://facepunch.com/showthread.php?t=1268353 (but don't bug him if this fucks up, it's probably my edits that did it)

MapVote = {}
MapVote.Config = {}

-- CONFIG (sort of)
    MapVote.Config = {
        MapLimit = 24,
        TimeLimit = 28,
        AllowCurrentMap = false,
    }
-- CONFIG

function MapVote.HasExtraVotePower(ply)
	-- Example that gives admins more voting power
	if ply:IsAdmin() then
		return true
	end

	return false
end


MapVote.CurrentMaps = {}
MapVote.Votes = {}

MapVote.Allow = false

MapVote.UPDATE_VOTE = 1
MapVote.UPDATE_WIN = 3

if SERVER then
    AddCSLuaFile("cl_mapvote.lua")
	print("server")
	
    include("sv_mapvote.lua")
else
    include("cl_mapvote.lua")
	print("client")
end
print("balls")