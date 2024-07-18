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
setMusic("map01", "gfz2", { --New altmusic 'gfz2'(Also works if you just put the map's default song)
    pinch = "_super",
    overtime = "vsagz",
    matchpoint = "spec1",
    win = "_clear",
    loss = "_gover"
})


setMusic("map01", "gfzol", { --New altmusic 'gfz2'(Also works if you just put the map's default song)
    pinch = "osuper",
    overtime = "bhz",
    matchpoint = "spec2",
    win = "oclear",
    loss = "ogover"
})*/


local splitString = function(string)
    if not string then
        return nil
    end
    local songs = {}
    for word in string:gmatch('[^,%s]+') do
        table.insert(songs, word)
    end
    return songs
end

local altmusic_transition = false --This will stop that little bit of time where the map's main song plays

A.CurrentMap = {
    song = nil,
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

        if not rawget(songtable, mapheaderinfo[mapnum].musname:lower()) then
            table.insert(allsongs, mapheaderinfo[mapnum].musname:lower()) --add default song if not already added
        end

        local altsong = allsongs[P_RandomRange(1, #allsongs)] --Pick one, randomly

        A.CurrentDefsong = mapheaderinfo[mapnum].musname
        A.CurrentMap = A.Maps[mapcode][altsong]
        A.CurrentMap.song = altsong
    else
        local strings = {
            [1] = (splitString(mapheaderinfo[mapnum].altmusic) or {}),
            [2] = (splitString(mapheaderinfo[mapnum].bpinch)),
            [3] = (splitString(mapheaderinfo[mapnum].bwin)),
            [4] = (splitString(mapheaderinfo[mapnum].bloss)),
            [5] = (splitString(mapheaderinfo[mapnum].bovertime)),
            [6] = (splitString(mapheaderinfo[mapnum].bmatchpoint)),
        }
    
        table.insert(strings[1], 1, mapheaderinfo[mapnum].musname)
    
        local index = P_RandomRange(1, #strings[1])
    
        for k, v in ipairs(strings) do
    
            if k == 1 then
                continue
            end
    
            if (v and rawget(v, index) and v[index] != "DEFAULT") then
                v = v[index]
            else
                v = nil
            end
        end
    
    
        A.CurrentMap.song = strings[1][index]

        if rawget(strings, 2) and rawget(strings[2], index) then
            A.CurrentMap.pinch = strings[2][index]
        end

        if rawget(strings, 5) and rawget(strings[5], index) then
            A.CurrentMap.overtime = strings[5][index]
        end

        if rawget(strings, 6) and rawget(strings[6], index) then
            A.CurrentMap.matchpoint = strings[6][index]
        end

        if rawget(strings, 3) and rawget(strings[3], index) then
            A.CurrentMap.win = strings[3][index]
        end

        if rawget(strings, 4) and rawget(strings[4], index) then
            A.CurrentMap.loss = strings[4][index]
        end
        
    end

    altmusic_transition = false --no longer transitioning
    S_ChangeMusic(A.CurrentMap.song) --play the song!

    mapmusname = A.CurrentMap.song --Just in case!

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