-- Rough Alternative music mod for SRB2
-- (This really should be a thing in vanilla)
-- Mari0shi


--"API" for if you just wanna patch some songs onto a level without rewriting the header

if not ALTMUSIC then
    rawset(_G, "ALTMUSIC",{})
end

ALTMUSIC.Set = function(mapcode, string)
    local code = mapcode:upper()

    ALTMUSIC[mapcode] = string:lower()
end

--ALTMUSIC.Set("MAPF4", "MP_FOR,MP_WTR")


local splitString = function(string)
    local songs = {}
    for word in string:gmatch('[^,%s]+') do
        table.insert(songs, word)
    end
    return songs
end

local altmusic_transition = false --This will stop that little bit of time where the map's main song plays
local current_mapsong = " "
local current_defsong = " "

addHook("NetVars", function(n)
    altmusic_transition = n($) --Just in case
    current_mapsong = n($)
    current_defsong = n($)
end)

addHook("MapChange", function(mapnum) --Runs before MapLoad
    if mapheaderinfo[mapnum].altmusic then
        altmusic_transition = true --Transitioning!
    end
end)

addHook("IntermissionThinker", do
    current_mapsong = nil --Thanks SRB2!
    current_defsong = nil
end)

addHook("MapLoad", function(mapnum)


    local music
    local allmusic


    if (mapheaderinfo[mapnum].altmusic and mapheaderinfo[mapnum].musname) then --Altmusic?

        music = mapheaderinfo[mapnum].musname..","..mapheaderinfo[mapnum].altmusic --Make one string that has all the songs

    else

        local mapcode = G_BuildMapName(mapnum)

        if ALTMUSIC and rawget(ALTMUSIC, mapcode) and (type(ALTMUSIC[mapcode]) == "string") then --Level header takes priority, but...

            music = ALTMUSIC[mapcode]

            if (mapheaderinfo[mapnum].musname) then
                music = mapheaderinfo[mapnum].musname..","..$
            end

        else --No patch or altmusic line in header?
            if mapheaderinfo[mapnum].musname then
                current_mapsong = nil
                current_defsong = nil
                return
            end
        end
    end

    allmusic = splitString(music) --Parse it

    current_defsong = mapheaderinfo[mapnum].musname
    current_mapsong = allmusic[P_RandomRange(1, #allmusic)] --Set mapmusname randomly (this will account for people joining mid-game)
    altmusic_transition = false --no longer transitioning

    --if consoleplayer.battleconfig_altmusic then
        S_ChangeMusic(current_mapsong) --play the song!
    -- end

    mapmusname = current_mapsong --Just in case!

end)


addHook("MusicChange", function(oldname, newname)
    if altmusic_transition then --Transitioning?
        return true --No new music.
    end

    local validPlayer = (consoleplayer and consoleplayer.realmo and consoleplayer.realmo.valid)
    local validMap = (gamemap and mapheaderinfo[gamemap].musname)

   if validMap and current_mapsong and (current_mapsong != current_defsong) and (newname == current_defsong) then
        return current_mapsong
   end

end)

--CBW_Battle.Console.AddBattleConfig("battleconfig_altmusic", function(player, arg) CBW_Battle.Console.SetYesNo(player, arg, "battleconfig_altmusic", true) end, true)