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
local running_command = false
local played_once = false
local already_ran = false
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
    --altmusic_transition = n($) --Just in case
    --running_command = n($)
    played_once = n($)
    lastmap = n($)
    --already_ran = n($)
    A.CurrentMap = n($)
    A.CurrentDefsong = n($)
    A.songpos = n($)
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
    --print(tostring(A.CurrentMap and A.CurrentMap.song).."|"..tostring(already_ran).."|"..mapmusname.."|"..tostring(consoleplayer and consoleplayer.jointime))
    if already_ran then
        --print(true)
        if A.CurrentMap and A.CurrentMap.song then
            play((S_MusicExists(A.CurrentMap.song) and A.CurrentMap.song) or (gamemap and mapheaderinfo[gamemap].musname))
            --print(true)
        end
        already_ran = false
        return
    end
end)

/*addHook("HUD", function(v, player)
    local string = "{"
    for k, v in ipairs(lastmap) do
        if k == #lastmap then
            string = $..v.."}"
        else
            string = $..v..","
        end
    end

    v.drawString(320,8, string, V_SNAPTOTOP|V_SNAPTORIGHT|V_PERPLAYER|V_ALLOWLOWERCASE|V_50TRANS)
end, "game")*/

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


    if mapheaderinfo[mapnum].altmusic or rawget(A, G_BuildMapName(mapnum):lower())then
        altmusic_transition = true
        A.CurrentDefSong = mapheaderinfo[mapnum].musname
    end



    if lastmap and (#lastmap == 3) then
        lastmap[3] = nil
    end

    table.insert(lastmap, 1, mapnum)
    
    local mapcode = G_BuildMapName(mapnum):lower()  
    
    if rawget(A, mapcode) then
        --Hey so we're gonna sort this on the server then send it to everyone via a command, thanks pairs()!
        --A.songlist = nil
        --altmusic_transition = true
        if isserver and not(running_command) then

            local songlist = {}

            local songarg = " "

            for k, v in pairs(ALTMUSIC[mapcode]) do
                table.insert(songlist, k)
            end
        
            if not(rawget(ALTMUSIC[mapcode], mapheaderinfo[mapnum].musname:upper())) then
                table.insert(songlist, mapheaderinfo[mapnum].musname:upper()) --add default song if not already added
            end

            for k, v in ipairs(songlist) do
                songarg = $..v.." "
            end

            local command = "_altmsort "..mapcode.." "..mapnum..songarg

            COM_BufInsertText(server, command)
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

COM_AddCommand("_altmsort", function(player, mapcode, mapnum, ...)
    if player != server then
        return
    end

    local songlist = {...}

    local printie = "_altmsort '"..mapcode.."' '"..mapnum.."'"

    --running_command = true

    local songtable = ALTMUSIC[mapcode]

    

    local altsong = songlist[P_RandomRange(1, #songlist)] --Pick one, randomly

    A.CurrentMap = (rawget(songtable, altsong) and songtable[altsong]) or {}
    A.CurrentMap.song = altsong

    --print(A.CurrentMap.pinch)

    --print(A.CurrentDefsong)
    --print(A.CurrentMap)
    --print(A.CurrentMap.song)
    running_command = false
    already_ran = true
end, COM_ADMIN)

local B = CBW_Battle

addHook("MusicChange", function(oldname, newname)

    if (gamestate != GS_LEVEL)
    or (B.Overtime)
    or (B.Pinch)
    or (B.MatchPoint) then
        return nil
    end

    if not(consoleplayer) and (gamestate == GS_LEVEL) and not(titlemapinaction) then
        altmusic_transition = true
        S_StopMusic()
        return true
    end

    local validPlayer = (consoleplayer and consoleplayer.realmo and consoleplayer.realmo.valid)
    local validMap = (altmusic_transition)

    local altmusic

    altmusic = $ or newsong()

    local function transmask()
        --if altmusic_transition then --Transitioning?
            S_StopMusic()
            --return true --No new music.
        --end
    end

    if altmusic_transition and (newname == A.CurrentDefSong) and not(A.CurrentMap and A.CurrentMap.song) then
        transmask()
        if altmusic then
            altmusic_transition = false
            return altmusic
        else
            return true
        end
        --return altmusic or true
    end

    if altmusic then
        return altmusic
    end

  

end)

--CBW_Battle.Console.AddBattleConfig("battleconfig_altmusic", function(player, arg) CBW_Battle.Console.SetYesNo(player, arg, "battleconfig_altmusic", true) end, true)