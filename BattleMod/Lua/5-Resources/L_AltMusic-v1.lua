-- Rough Alternative music mod for SRB2
-- (This really should be a thing in vanilla)
-- Mari0shi


--"API" for if you just wanna patch some songs onto a level without rewriting the header

if not ALTMUSIC then
    rawset(_G, "ALTMUSIC",{})
end

local A = ALTMUSIC

A.Maps = {}

local setMusic = function(mapcode, song, arr)

    local name = mapcode:upper()
    local music = song:lower()

    if not rawget(A.Maps, name) then
        A.Maps[name] = {}
    end

    if not A.Maps[name].songlist then
        A.Maps[name].songlist = {}
    end

    table.insert(A.Maps[name].songlist, music)
    A.Maps[name][music] = arr
end

/*
setMusic("mapw1", "gfz2", { --New altmusic 'gfz2'(Also works if you just put the map's default song)
    pinch = "_super",
    overtime = "bhz",
    matchpoint = "spec5",
    win = "_clear",
    loss = "_gover"
})*/


local splitString = function(string)
    local songs = {}
    for word in string:gmatch('[^,%s]+') do
        table.insert(songs, word)
    end
    return songs
end

local altmusic_transition = false --This will stop that little bit of time where the map's main song plays

A.CurrentMap = {
    pinch = nil,
    overtime = nil,
    matchpoint = nil,
    win = nil,
    loss = nil
}

A.CurrentDefsong = nil

addHook("NetVars", function(n)
    altmusic_transition = n($) --Just in case
    A.CurrentMap = n($)
    A.CurrentDefsong = n($)
end)

addHook("MapChange", function(mapnum) --Runs before MapLoad
    if mapheaderinfo[mapnum].altmusic or rawget(A.Maps, G_BuildMapName(mapnum))then
        altmusic_transition = true --Transitioning!
    end
end)

addHook("IntermissionThinker", do
    if A.CurrentMap then
        A.CurrentMap = {}
    end

    if A.CurrentDefsong then
        A.CurrentDefsong = nil
    end
end)

addHook("MapLoad", function(mapnum)

    local mapcode = G_BuildMapName(mapnum)


    if rawget(A.Maps, mapcode) then
        
        local songtable = A.Maps[mapcode]

        local allsongs = songtable.songlist

        local altsong = allsongs[P_RandomRange(1, #allsongs)] --Pick one, randomly

        A.CurrentDefsong = mapheaderinfo[mapnum].musname
        A.CurrentMap = A.Maps[mapcode][altsong]
        A.CurrentMap.song = altsong

        altmusic_transition = false --no longer transitioning
        S_ChangeMusic(A.CurrentMap.song) --play the song!
    
        mapmusname = A.CurrentMap.song --Just in case!
        
    end

end)


addHook("MusicChange", function(oldname, newname)
    if altmusic_transition then --Transitioning?
        return true --No new music.
    end

    local validPlayer = (consoleplayer and consoleplayer.realmo and consoleplayer.realmo.valid)
    local validMap = (gamemap and mapheaderinfo[gamemap].musname)

   if validMap and A.CurrentMap.song and (A.CurrentMap.song != A.CurrentDefsong) and (newname == A.CurrentDefsong) then
        return A.CurrentMap.song
   end

end)

--CBW_Battle.Console.AddBattleConfig("battleconfig_altmusic", function(player, arg) CBW_Battle.Console.SetYesNo(player, arg, "battleconfig_altmusic", true) end, true)