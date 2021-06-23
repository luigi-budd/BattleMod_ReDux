## BattleMod - Created by CobaltBW
For full credits, see `BattleMod\Credits.txt`.
### How to build
- [Install MSYS2](https://www.msys2.org/)
- Install the zip package in MSYS2 using `pacman -S zip`
- Optional: Create a batch file that runs build.sh. (Make sure the directory to msys2 is correct on your machine)
`C:\msys64\msys2_shell.cmd -mingw32 -here build.sh`
- Optional: Create a batch file that can be used to easily test in-game (Make sure the directory to msys2 is correct on your machine)
`cd "[PATH TO SRB2]"
Start "" srb2win.exe -file "[PATH TO THIS REPO]\ZBa_BattleMod-latest.pk3" -server -warp b0 -gametype 8 +battledebug 8 +restrictskinchange off +battle_preround 0`
After that, simply run the two batch files in order to quickly run and test the mod.