-- Rough Alternative music mod for SRB2
-- (This really should be a thing in vanilla)
-- Mari0shi


--"API" for if you just wanna patch some songs onto a level without rewriting the header

if not ALTMUSIC then
    rawset(_G, "ALTMUSIC",{})
end

ALTMUSIC.Functions = {}


local A = ALTMUSIC
local B = CBW_Battle

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
A.already_ran = false
A.block_restoremusic = false

local already_ran = A.already_ran

local preround = false

local block_restoremusic = A.block_restoremusic

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

A.Functions.PlayerJoin = function(playernum)
    if consoleplayer and consoleplayer.jointime < 1 then
        mapmusname = " "
        already_ran = true
    end
end
addHook("PlayerJoin", A.Functions.PlayerJoin)

local function clearvars()
    if A.CurrentMap then
        A.CurrentMap = {}
    end

    if A.CurrentDefsong then
        A.CurrentDefsong = nil
    end
    altmusic_transition = false
    block_restoremusic = false
end

local function play(song)
    altmusic_transition = false --no longer transitioning

    if (consoleplayer) and not(B.Exiting) then
        S_ChangeMusic(song) --play the song!

        --print(true)
        mapmusname = song --Just in case!
    end
end

A.Functions.ThinkFrame = function()

    if (A.CurrentMap.song == A.CurrentMap.preround) then
        if (leveltime == ((CV_FindVar("hidetime").value-3)*TICRATE)) then
            S_FadeOutStopMusic(MUSICRATE*3)
        end
        if not(B.PreRoundWait()) then
            A.CurrentMap.song = A.CurrentMap.musname
            already_ran = true
        end
    end

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
end
addHook("ThinkFrame", A.Functions.ThinkFrame)

A.Functions.PlayerQuit = function(player)
    if player == consoleplayer then
        A.CurrentMap = {}
        A.CurrentDefSong = nil
        already_ran = true
    end
end
addHook("PlayerQuit", A.Functions.PlayerQuit)

A.Functions.MapChange = function(mapnum) --Runs before MapLoad

    A.CurrentMap = {}
    A.CurrentDefSong = nil
    altmusic_transition = true
    block_restoremusic = false


    if (mapheaderinfo[mapnum].altmusic or mapheaderinfo[mapnum].bpreround) or rawget(A, G_BuildMapName(mapnum):lower())then
        A.CurrentDefSong = mapheaderinfo[mapnum].musname
    else
        altmusic_transition = false
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

        local hasdef = false
    
        for k, v in ipairs(songlist) do
            if (v:upper() == mapheaderinfo[mapnum].musname:upper()) then
                hasdef = true
                break
            end
        end

        if not(hasdef) then
            table.insert(songlist, mapheaderinfo[mapnum].musname:upper())
        end

        local songtable = ALTMUSIC[mapcode]

        local altsong = songlist[P_RandomRange(1, #songlist)] --Pick one, randomly
    
        local currentmap = (rawget(songtable, altsong) and songtable[altsong]) or {}

        if (type(currentmap) ~= "table") then
            currentmap = {
                musname = altsong
            }
        end

        A.CurrentMap = currentmap
        A.CurrentMap.musname = altsong
        A.CurrentMap.song = A.CurrentMap.preround or A.CurrentMap.musname

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
        local preround    = mapheaderinfo[mapnum].bpreround


        local choices = (altmusic and {music, altmusic}) or {music}
    
        local song = choices[P_RandomRange(1, #choices)]


        A.CurrentMap = {
            musname = song,
            pinch = bpinch,
            win = CHPASS,
            loss = bloss,
            overtime = bovertime,
            matchpoint = bmatchpoint,
            preround = bpreround
        }

        A.CurrentDefsong = music
        A.CurrentMap.song = A.CurrentMap.preround or A.CurrentMap.musname
        play((S_MusicExists(A.CurrentMap.song) and A.CurrentMap.song) or (gamemap and mapheaderinfo[gamemap].musname))
        already_ran = true
    end


end

addHook("MapChange", A.Functions.MapChange)


addHook("IntermissionThinker", clearvars)

A.Functions.MusicChange = function(oldname, newname)

    if (not(consoleplayer) and (gamestate == GS_LEVEL) and not(titlemapinaction)) then
        altmusic_transition = true
        S_StopMusic()
        return true
    end

    local win = (A and A.CurrentMap and A.CurrentMap.win)
    local loss = (A and A.CurrentMap and A.CurrentMap.loss)

    if (block_restoremusic) then
        return true
    end


    if win and (newname == "CHPASS") then
        block_restoremusic = true
        return win, nil, false
    end

    if loss and (newname == "CHFAIL") then
        block_restoremusic = true
        return loss, nil, false
    end

end
addHook("MusicChange", A.Functions.MusicChange)