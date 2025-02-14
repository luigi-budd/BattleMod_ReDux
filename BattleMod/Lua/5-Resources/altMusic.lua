--AltMusic Take 2, by Mari0shi


rawset(_G, "M06_ALTMUSIC", {})
rawset(_G, "M06_ALTMUSICNET", {})

local debug = CV_RegisterVar({
    name = "altmusic_debug",
    defaultvalue = "Off",
    value = 0,
    flags = CV_NETVAR,
    PossibleValue = CV_OnOff
})

local function dprint(string)
    if not(debug.value) then return end
    print(string)
end

--https://gist.github.com/akornatskyy/63100a3e6a971fd13456b6db104fb65b
local function split_with_comma(str)
    local fields = {}
    for field in str:gmatch('([^,]+)') do
        fields[#fields+1] = field
    end
    return fields
end

M06_ALTMUSICNET.MAPMUS = "spec1"
M06_ALTMUSICNET.WINMUS = "chpass"
M06_ALTMUSICNET.LOSSMUS = "chfail"
M06_ALTMUSICNET.PINCHMUS = "_pinch"
M06_ALTMUSICNET.OVERTIMEMUS = "_ovrtm"

local function getMapSongs(map)

    local musname = (mapheaderinfo[map].musname):lower()
    local allsongs = {musname}

    if mapheaderinfo[map].altmusic then
        for _, song in ipairs(split_with_comma(mapheaderinfo[map].altmusic)) do
            table.insert(allsongs, song:lower())
        end
    end

    return ({
        songs = allsongs,
        win = (mapheaderinfo[map].bwin and (mapheaderinfo[map].bwin):lower()) or nil,
        loss = (mapheaderinfo[map].bloss and (mapheaderinfo[map].bloss):lower()) or nil,
        pinch = (mapheaderinfo[map].pinch and (mapheaderinfo[map].pinch):lower()) or nil,
        overtime = (mapheaderinfo[map].bwin and (mapheaderinfo[map].bwin):lower()) or nil
    })
end

--MapChange
M06_ALTMUSIC.function_MapChange = function(mapnum)
    local musictable = getMapSongs(mapnum)

    M06_ALTMUSICNET.MAPMUS = musictable.songs[P_RandomRange(1, #musictable.songs)]
    M06_ALTMUSICNET.WINMUS = musictable.win
    M06_ALTMUSICNET.LOSSMUS = musictable.loss
    M06_ALTMUSICNET.PINCHMUS = musictable.pinch
    M06_ALTMUSICNET.OVERTIMEMUS = musictable.overtime
    dprint("M06_ALTMUSICNET.MAPMUS = "..(M06_ALTMUSICNET.MAPMUS or "nil").."\n"..
          "M06_ALTMUSICNET.WINMUS = "..(M06_ALTMUSICNET.WINMUS or "nil").."\n"..
          "M06_ALTMUSICNET.LOSSMUS = "..(M06_ALTMUSICNET.LOSSMUS or "nil").."\n"..
          "M06_ALTMUSICNET.PINCHMUS = "..(M06_ALTMUSICNET.PINCHMUS or "nil").."\n"..
          "M06_ALTMUSICNET.OVERTIMEMUS = "..(M06_ALTMUSICNET.OVERTIMEMUS or "nil")
    )
end

--MusicChange
M06_ALTMUSIC.function_MusicChange = function(oldname, newname, mflags, looping, position, prefadems, fadeinms)


    --General Map Music
    local playingMapMusic = (newname == mapheaderinfo[gamemap].musname)
    if playingMapMusic and M06_ALTMUSICNET.MAPMUS and (mapheaderinfo[gamemap].musname ~= M06_ALTMUSICNET.MAPMUS) then 
        return M06_ALTMUSICNET.MAPMUS, mflags, looping, position, prefadems, fadeinms
    end

    --Win Music
    local playingWinMusic = (newname == "CHPASS")
    if playingWinMusic and M06_ALTMUSICNET.WINMUS and (M06_ALTMUSICNET.WINMUS ~= "CHPASS") then
        return M06_ALTMUSICNET.WINMUS, 0, false
    end

    --Loss Music
    local playingLossMusic = (newname == "CHFAIL")
    if playingLossMusic and M06_ALTMUSICNET.LOSSMUS and (M06_ALTMUSICNET.LOSSMUS ~= "CHFAIL") then
        return M06_ALTMUSICNET.LOSSMUS, 0, false
    end

    --Pinch Music
    local playingPinchMusic = (newname == "_PINCH")
    if playingPinchMusic and M06_ALTMUSICNET.PINCHMUS and (M06_ALTMUSICNET.PINCHMUS ~= "_PINCH") then
        return M06_ALTMUSICNET.PINCHMUS, mflags, looping, position, prefadems, fadeinms
    end

    --Overtime Music
    local playingOvertimeMusic = (newname == "_OVRTM")
    if playingOvertimeMusic and M06_ALTMUSICNET.OVERTIMEMUS and (M06_ALTMUSICNET.OVERTIMEMUS ~= "_OVRTM") then
        return M06_ALTMUSICNET.OVERTIMEMUS, mflags, looping, position, prefadems, fadeinms
    end
end

M06_ALTMUSIC.function_NetVars = function(n)
    M06_ALTMUSICNET.MAPMUS = n($)
    M06_ALTMUSICNET.WINMUS = n($)
    M06_ALTMUSICNET.LOSSMUS = n($)
    M06_ALTMUSICNET.PINCHMUS = n($)
    M06_ALTMUSICNET.OVERTIMEMUS = n($)
end

addHook("MapChange", M06_ALTMUSIC.function_MapChange)
addHook("MusicChange", M06_ALTMUSIC.function_MusicChange)
addHook("NetVars", M06_ALTMUSIC.function_NetVars)
