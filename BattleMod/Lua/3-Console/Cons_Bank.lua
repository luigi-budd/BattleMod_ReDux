local CV = CBW_Battle.Console

CV.ChaosRing_StartSpawnBuffer = CV_RegisterVar({
    name = "chaosring_startspawnbuffer",
    defaultvalue = 25,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
        print("Chaos Rings will start spawning in Ring Rally after "..cv.value.." seconds.")
    end
})

CV.ChaosRing_SpawnBuffer = CV_RegisterVar({
    name = "chaosring_spawnbuffer",
    defaultvalue = 10,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
        print("Chaos Rings will spawn in Ring Rally every "..cv.value.." seconds.")
    end
})

CV.ChaosRing_WinTime = CV_RegisterVar({
    name = "chaosring_wintime",
    defaultvalue = 3,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Collecting all 6 Chaos Rings will result in victory after "..cv.value.." seconds.")
		end
    end
})

CV.ChaosRing_CaptureTime = CV_RegisterVar({
    name = "chaosring_capturetime",
    defaultvalue = 2,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Chaos Rings will now take "..cv.value.." seconds to capture.")
		end
    end
})

CV.ChaosRing_StealTime = CV_RegisterVar({
    name = "chaosring_stealtime",
    defaultvalue = 3,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Chaos Rings will now take "..cv.value.." seconds to steal.")
		end
    end
})

CV.ChaosRing_InvulnTime = CV_RegisterVar({
    name = "chaosring_invulntime",
    defaultvalue = 15,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Chaos Rings will be protected from theft for "..cv.value.." seconds after capture.")
		end
    end
})

CV.ChaosRing_CaptureScore = CV_RegisterVar({
    name = "chaosring_capturescore",
    defaultvalue = 50,
    flags = CV_NETVAR|CV_CALL,
    PossibleValue = CV_Natural,
    func = function(cv)
		if cv.value == cv.defaultvalue then return end
		if cv.value > 0 then
       		print("Capturing a Chaos Ring will award your team "..cv.value.." points.")
		end
    end
})

CV.CV.ChaosRing_Debug = CV_RegisterVar({
    name = "CV.ChaosRing_Debug",
    defaultvalue = "Off",
    value = 0,
    flags = CV_NETVAR,
    PossibleValue = CV_OnOff
})