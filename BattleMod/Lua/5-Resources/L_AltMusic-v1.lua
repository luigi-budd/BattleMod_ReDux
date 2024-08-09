-- Rough Alternative music mod for SRB2
-- (This really should be a thing in vanilla)
-- Mari0shi


--"API" for if you just wanna patch some songs onto a level without rewriting the header

if not ALTMUSIC then
    rawset(_G, "ALTMUSIC",{})
end


local A = ALTMUSIC

local function newsong()
    if A.CurrentMap.song and (A.CurrentMap.song != A.CurrentDefsong) and (newname == A.CurrentDefsong) then
        return (S_MusicExists(A.CurrentMap.song) and A.CurrentMap.song) or A.CurrentDefsong
    end
end

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
local already_ran = false

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
    A.CurrentMap = n($)
    A.CurrentDefsong = n($)
end)

addHook("PlayerJoin", function(playernum)
    if consoleplayer.jointime < 1 then
        mapmusname = " "
        already_ran = true
    end
end)

local function clearvars()
    if A.CurrentMap then
        A.CurrentMap = {}
    end

    if A.CurrentDefsong then
        A.CurrentDefsong = nil
    end
    altmusic_transition = false
end

local function play(song)
    altmusic_transition = false --no longer transitioning

    S_ChangeMusic(song) --play the song!

    mapmusname = song --Just in case!
end

addHook("ThinkFrame", do
    for player in players.iterate do
        if player.quittime > 0 then
            player.altmusic_rjto = true
        end

        if (player.quittime == 0) and player.altmusic_rjto then
            if player == consoleplayer then
                mapmusname = " "
                already_ran = true
            end
            player.altmusic_rjto = nil
        end
    end
    
    if already_ran then
        --print(true)
        if A.CurrentMap and A.CurrentMap.song then
            play((S_MusicExists(A.CurrentMap.song) and A.CurrentMap.song) or (gamemap and mapheaderinfo[gamemap].musname))
        end
        already_ran = false
        return
    end
end)

addHook("PlayerQuit", function(player)
    if player == consoleplayer then
        A.CurrentMap = {}
        A.CurrentDefSong = nil
        already_ran = true
    end
end)

addHook("MapChange", function(mapnum) --Runs before MapLoad

    A.CurrentMap = {}
    A.CurrentDefSong = nil
    altmusic_transition = false


    if mapheaderinfo[mapnum].altmusic or rawget(A, G_BuildMapName(mapnum):lower())then
        altmusic_transition = true
        A.CurrentDefSong = mapheaderinfo[mapnum].musname
    end

    local mapcode = G_BuildMapName(mapnum):lower()  
    
    if rawget(A, mapcode) then

        local songlist = {}

        for k, v in pairs(ALTMUSIC[mapcode]) do
            table.insert(songlist, k) --List of keys (desynched)
        end

        local function sort_alphabetical(a, b)
            return a:lower() < b:lower()
        end

        table.sort(songlist, sort_alphabetical)

    
        if not(rawget(ALTMUSIC[mapcode], mapheaderinfo[mapnum].musname:upper())) then
            table.insert(songlist, mapheaderinfo[mapnum].musname:upper()) --add default song if not already added
        end

        local songtable = ALTMUSIC[mapcode]

        local altsong = songlist[P_RandomRange(1, #songlist)] --Pick one, randomly
    
        A.CurrentMap = (rawget(songtable, altsong) and songtable[altsong]) or {}
        A.CurrentMap.musname = altsong
        A.CurrentMap.song = A.CurrentMap.musname

        play((S_MusicExists(A.CurrentMap.song) and A.CurrentMap.song) or (gamemap and mapheaderinfo[gamemap].musname))
    
        already_ran = true
    else

        local music       = mapheaderinfo[mapnum].musname
        local altmusic    = mapheaderinfo[mapnum].altmusic or music
        local bpinch      = mapheaderinfo[mapnum].bpinch
        local bwin        = mapheaderinfo[mapnum].bwin
        local bloss       = mapheaderinfo[mapnum].bloss
        local bovertime   = mapheaderinfo[mapnum].bovertime
        local bmatchpoint = mapheaderinfo[mapnum].bmatchpoint

        local choices = {music, altmusic}
    
        local song = choices[P_RandomRange(1, #choices)]

    
        A.CurrentMap = {
            musname = song,
            pinch = bpinch,
            win = bwin,
            loss = bloss,
            overtime = bovertime,
            matchpoint = bmatchpoint
        }

        A.CurrentDefsong = music
        A.CurrentMap.song = A.CurrentMap.musname
        play((S_MusicExists(A.CurrentMap.song) and A.CurrentMap.song) or (gamemap and mapheaderinfo[gamemap].musname))
    end


end)

addHook("IntermissionThinker", clearvars)

addHook("MusicChange", function(oldname, newname)

    if (gamestate != GS_LEVEL) then
        return nil
    end

    if not(consoleplayer) and (gamestate == GS_LEVEL) and not(titlemapinaction) then
        altmusic_transition = true
        S_StopMusic()
        return true
    end

end)