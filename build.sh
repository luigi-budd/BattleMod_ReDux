#!/bin/bash
# exporting variables only works if you are the parent shell.
# therefore, building starts from this script.
export PK3_FLAGS_DEF='ZBa'
export PK3_NAME_DEF='BattleMod'
export PK3_VERSION_DEF=9
export PK3_SUBVERSION_DEF=4

export FOLDER_NAME_DEF='BattleMod'
export PK3_EXCLUDE_DEF='.git\|./*.dbs\|./*.backup*' # grep-style exclude
export PK3_RELEASE=0

./builder.sh # After defining the variables, build.
