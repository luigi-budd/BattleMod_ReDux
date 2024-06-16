#!/bin/bash
# exporting variables only works if you are the parent shell.
# therefore, building starts from this script.
export PK3_FLAGS_DEF='ZBa'
export PK3_NAME_DEF='BattleMod'
export PK3_VERSION_DEF=10
export PK3_SUBVERSION_DEF=0

export FOLDER_NAME_DEF='BattleMod'
export PK3_EXCLUDE_DEF='.git\|./*.dbs\|./*.backup*' # grep-style exclude
export PK3_RELEASE=0

# Thanks, Golden!
# If a release flag is specified, set the release flag on.
if [[ "$*" == *"release"* ]]; then
	PK3_RELEASE=1
fi

testCmd() {
	if ! command -v $@ &> /dev/null
	then
	    echo "$@ could not be found, please install the required package."
	    exit
	fi
}

# We need to ensure these commands exist
testCmd "zip";
testCmd "ln";
testCmd "xargs";

PK3_FLAGS=${PK3_FLAGS:-$PK3_FLAGS_DEF}
PK3_VERSION=${PK3_VERSION:-$PK3_VERSION_DEF}
PK3_SUBVERSION=${PK3_SUBVERSION:-$PK3_SUBVERSION_DEF}
PK3_NAME=${PK3_NAME:-$PK3_NAME_DEF}
FOLDER_NAME=${FOLDER_NAME:-$FOLDER_NAME_DEF}

PK3_BUILDDATA_DATE=$(date +"%-m/%-d/%Y")
PK3_BUILDDATA_TIME=$(date +"%l:%M:%S %p")
PK3_BUILDDATA_BRANCH=$(git rev-parse --abbrev-ref HEAD)
PK3_BUILDDATA_COMMIT=$(git rev-parse --short HEAD)

if [ -z "${PK3_EXCLUDE+x}" ]; then # if no exist
	declare -n PK3_EXCLUDE=PK3_EXCLUDE_DEF # refer to PK3_EXCLUDE_DEF
fi

PK3_FULLNAME="$PK3_FLAGS"_"$PK3_NAME"-v"$PK3_VERSION"_"$PK3_SUBVERSION"
PK3_LATESTNAME="$PK3_FLAGS"_"$PK3_NAME"-latest

if [[ "$*" == *"cleanbuilds"* ]]; then
	shopt -s extglob

	# Clean files that aren't .gitignore that contain +, but don't contain the current commit hash.
	FILES_TO_RM=$(find builds -type f ! -name "*.gitignore*" -name "*+*" ! -name "*$PK3_BUILDDATA_COMMIT*")

	if [ "$FILES_TO_RM" != "" ]; then
		rm $FILES_TO_RM
	fi

	# Clean files that aren't .bak
	FILES_TO_RM=$(find builds -type f ! -name "*.bak*")

	if [ "$FILES_TO_RM" != "" ]; then
		rm $FILES_TO_RM
	fi

	# Clean files that aren't .gitignore that don't match our current version.
	FILES_TO_RM=$(find builds -type f ! -name "*.gitignore*" ! -name "*$PK3_VERSION*")

	if [ "$FILES_TO_RM" != "" ]; then
		rm $FILES_TO_RM
	fi

	exit # Don't create pk3
fi

if [[ $PK3_RELEASE != 1 ]]; then
	if [[ "$*" == *"testbuild"* ]]; then
		PK3_FULLNAME="$PK3_FULLNAME"-test_"$PK3_BUILDDATA_COMMIT"
	else
		PK3_TIME=$(date +"%m.%d.%y-%H.%M.%S")

		PK3_METADATA="$PK3_BUILDDATA_COMMIT"_"$PK3_TIME"
		PK3_FULLNAME="$PK3_FULLNAME"+"$PK3_METADATA"
	fi
fi

# Let's jump inside the folder
cd $FOLDER_NAME

# create version info lua file
echo "\
CBW_Battle.VersionNumber = $PK3_VERSION
CBW_Battle.VersionSub = $PK3_SUBVERSION
CBW_Battle.VersionPublic = $PK3_RELEASE
CBW_Battle.VersionDate = \"""$PK3_BUILDDATA_DATE""\"
CBW_Battle.VersionTime = \"""$PK3_BUILDDATA_TIME""\"
CBW_Battle.VersionBranch = \"""$PK3_BUILDDATA_BRANCH""\"
CBW_Battle.VersionCommit = \"""$PK3_BUILDDATA_COMMIT""\""> ../$FOLDER_NAME/Lua/1-Init/Init_VersionInfo.lua

# make builds dir if it doesn't exist
if [ ! -d "../builds" ]; then
	mkdir ../builds
fi

# rev: Let's use linux pipes to get everything we need
find . -type f  									| # 1. We only want files.
grep -v $PK3_EXCLUDE_DEF 							| # 2. Let's exclude things we don't need.
sort -f 											| # 3. Sort everything. ORDER MATTERS!
eval "xargs -d '\n' zip -FSry ../builds/$PK3_FULLNAME.pk3"     # 4. Put everything into a zip
# xargs -d : This only works on GNU xargs!!

# Let's jump out of the folder
cd ..

# create syn link
ln -sf builds/$PK3_FULLNAME.pk3 $PK3_LATESTNAME.pk3

echo "Build is located at builds/$PK3_FULLNAME.pk3"
