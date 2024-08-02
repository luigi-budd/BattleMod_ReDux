-- Rough Alternative music mod for SRB2
-- (This really should be a thing in vanilla)
-- Mari0shi


--"API" for if you just wanna patch some songs onto a level without rewriting the header

if not ALTMUSIC then
    rawset(_G, "ALTMUSIC",{})
end

local A = ALTMUSIC

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
local running_command = false
local played_once = false
local lastmap = {}
--local already_ran = false

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
    running_command = n($)
    played_once = n($)
    lastmap = n($)
    --already_ran = n($)
    A.CurrentMap = n($)
    A.CurrentDefsong = n($)
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

addHook("HUD", function(v, player)
    --v.drawString(0, 0, "{"..(lastmap[1] or "nil")..","..(lastmap[2] or "nil").."}", V_SNAPTORIGHT|V_PERPLAYER|V_ALLOWLOWERCASE|V_50TRANS)
    if consoleplayer.already_ran then
        --print(true)
        if A.CurrentMap and A.CurrentMap.song and (A.CurrentMap.song != mapheaderinfo[gamemap].musname) then
            play(A.CurrentMap.song)
            --print(true)
        end
        consoleplayer.already_ran = false
    end

    --print(lastmap and #lastmap)
end, "titlecard")

addHook("MapChange", function(mapnum) --Runs before MapLoad
    if mapheaderinfo[mapnum].altmusic or rawget(A, G_BuildMapName(mapnum):lower())then
        altmusic_transition = (mapheaderinfo[mapnum].musname)
        --already_ran = false
    end



    if lastmap and (#lastmap == 3) then
        lastmap[3] = nil
    end

    table.insert(lastmap, 1, mapnum)

    A.CurrentMap = {}
    A.CurrentDefsong = nil
    
    local mapcode = G_BuildMapName(mapnum):lower()  
    
    if rawget(A, mapcode) then
        --Hey so we're gonna sort this on the server then send it to everyone via a command, thanks pairs()!
        --A.songlist = nil
        --altmusic_transition = true
        if isserver and not(running_command) then
            COM_BufInsertText(server, "_altmsort "..mapcode.." "..mapnum)
            running_command = true
        end
    else

        --altmusic_transition = true

        local music       = mapheaderinfo[mapnum].musname
        local altmusic    = mapheaderinfo[mapnum].altmusic or music
        local bpinch      = mapheaderinfo[mapnum].bpinch
        local bwin        = mapheaderinfo[mapnum].bwin
        local bloss       = mapheaderinfo[mapnum].bloss
        local bovertime   = mapheaderinfo[mapnum].bovertime
        local bmatchpoint = mapheaderinfo[mapnum].bmatchpoint

        local choices = {music, altmusic}
    
        local song = choices[P_RandomRange(1, #choices)]

        --print(bpinch)
    
    
        A.CurrentMap = {
            song = song,
            pinch = bpinch,
            win = bwin,
            loss = bloss,
            overtime = bovertime,
            matchpoint = bmatchpoint
        }

        A.CurrentDefsong = music

       -- already_ran = true

    end


end)

addHook("IntermissionThinker", clearvars)

COM_AddCommand("_altmsort", function(player, mapcode, mapnum)
    if player != server then
        return
    end

    --running_command = true

    local songtable = ALTMUSIC[mapcode]

    local songlist = {}

    for k, v in pairs(songtable) do
        table.insert(songlist, k)
    end

    if not(rawget(songtable, mapheaderinfo[mapnum].musname:upper())) then
        --table.insert(songlist, mapheaderinfo[mapnum].musname:upper()) --add default song if not already added
    end

    local altsong = songlist[P_RandomRange(1, #songlist)] --Pick one, randomly

    A.CurrentDefsong = mapheaderinfo[mapnum].musname:lower()
    A.CurrentMap = (rawget(songtable, altsong) and songtable[altsong]) or {}
    A.CurrentMap.song = altsong

    --print(A.CurrentMap.pinch)

    --print(A.CurrentDefsong)
    --print(A.CurrentMap)
    --print(A.CurrentMap.song)
    running_command = false
    consoleplayer.already_ran = true
end, COM_ADMIN)



addHook("MusicChange", function(oldname, newname)

    local validPlayer = (consoleplayer and consoleplayer.realmo and consoleplayer.realmo.valid)
    local validMap = (gamemap and mapheaderinfo[gamemap].musname)

    local function newsong()
        if validMap and A.CurrentMap.song and (A.CurrentMap.song != A.CurrentDefsong) and (newname == A.CurrentDefsong) then
            return A.CurrentMap.song
        end
    end

    local altmusic = newsong()

    local function transmask()
        --if altmusic_transition then --Transitioning?
            S_StopMusic()
            --return true --No new music.
        --end
    end

    if newname and altmusic_transition and ((newname == altmusic_transition) and (lastmap and rawget(lastmap, 1) and mapheaderinfo[lastmap[1]].musname != newname)) then
        transmask()
        return altmusic or true
    end

    if altmusic then
        return altmusic
    end

  

end)

--CBW_Battle.Console.AddBattleConfig("battleconfig_altmusic", function(player, arg) CBW_Battle.Console.SetYesNo(player, arg, "battleconfig_altmusic", true) end, true)