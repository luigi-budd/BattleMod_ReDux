# SRB2 Battle - Created by CobaltBW
[View full credits](https://gitlab.com/Krabs_Is_A_/battlemod/-/blob/master/Credits.md)

[View full patch notes](https://gitlab.com/Krabs_Is_A_/battlemod/-/blob/master/PatchNotes.txt)

## How to build
### Windows
- [Install MSYS2](https://www.msys2.org/)
- Install the zip package in MSYS2 using `pacman -S zip`
- You can build the pk3 by running build.sh in the msys2 shell
- Optional: Create a batch file that runs build.sh. (Make sure the directory to msys2 is correct on your machine)
```
C:\msys64\msys2_shell.cmd -mingw32 -here build.sh
```
- Optional: Create a batch file that can be used to easily test in-game (Make sure the directory to msys2 is correct on your machine)
```
cd "[PATH TO SRB2]"
Start "" srb2win.exe -file "[PATH TO THIS REPO]\ZBa_BattleMod-latest.pk3" -server -warp b0 -gametype 8 +battledebug 8 +restrictskinchange off +battle_preround 0
```


After that, simply run the two batch files in order to quickly run and test the mod. The build script will automatically ignore any zone builder temporary files such as `.dbs`, and it will automatically declare version number variables based on the values in `defaults.sh`!

### Linux
- Make sure to install the `zip` package for your linux distribution.
- Arch linux: `sudo pacman -S zip`
- You can build the pk3 by running `linux_build.sh` in the current directory (via a terminal/etc.)
- (NOTE: `linux_build.sh` is merely both `build.sh` and `defaults.sh` combined into one)
- Optional: Similarly to above, you can create a script to quickly test in-game:
```
srb2 -file [PATH TO THIS REPO]/ZBa_BattleMod-latest.pk3 -server -warp b0 -gametype 8 +battledebug 8 +restrictskinchange off +battle_preround 0
```

If there are any permission issues, simply do `chmod +x [SCRIPT NAME HERE]` and then do `./[SCRIPT NAME HERE]` to run the script.


## About defaults.sh (how to create a release)
In order to make a public release, edit defaults.sh:
- PK3_VERSION_DEF		major version number
- PK3_SUBVERSION_DEF	minor version number
- PK3_RELEASE			if set to 1, the pk3 will be built for public release. If set to 0, the pk3 will be built as a developer build, with git info in the top right corner of the HUD.
