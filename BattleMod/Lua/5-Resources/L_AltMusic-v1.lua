-- Rough Alternative music mod for SRB2
-- (This really should be a thing in vanilla)
-- Mari0shi


local splitString = function(string)
    local songs = {}
    for word in string:gmatch('[^,%s]+') do
        table.insert(songs, word)
    end
    return songs
end

local altmusic_transition = false --This will stop that little bit of time where the map's main song plays

addHook("NetVars", function(n)
    altmusic_transition = n($) --Just in case
end)

addHook("MapChange", function(mapnum) --Runs before MapLoad
    if mapheaderinfo[mapnum].altmusic and consoleplayer.battleconfig_altmusic then
        altmusic_transition = true --Transitioning!
    end
end)

addHook("MapLoad", function(mapnum)

    if mapheaderinfo[mapnum].altmusic and consoleplayer.battleconfig_altmusic then --Altmusic?

        local music = mapheaderinfo[mapnum].musname..","..mapheaderinfo[mapnum].altmusic --Make one string that has all the songs
        
        local allmusic = splitString(music) --Parse it

        mapmusname = allmusic[P_RandomRange(1, #allmusic)] --Set mapmusname randomly (this will account for people joining mid-game)
        altmusic_transition = false --no longer transitioning
        S_ChangeMusic(mapmusname) --play the song!

    end

end)


addHook("MusicChange", function(oldname, newname)
    if altmusic_transition and consoleplayer.battleconfig_altmusic then --Transitioning?
        return true --No new music.
    end
end)