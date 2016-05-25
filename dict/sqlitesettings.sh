#!/bin/bash

_help()
{
  echo "$0 {command}"
  echo
  echo '  where {command} is'
  echo '       save: saves current SQLiteStudo configuration to a 7z'
  echo '       restore: Overwrites configuration from 7z'
  echo ' '
  exit
}

function save {
	7z u sqlite3settings.7z ~/.config/sqlitestudio/settings3
}

function restore {
	7z e sqlite3settings.7z -o$HOME/.config/sqlitestudio/
}

if [ -z "$1" ]; then
  _help
elif [ "$1" == "save" ]; then
  save
elif [ "$1" == "restore" ]; then
  restore
elif [ "$1" == "--help" ]; then
  _help
else
  echo "** $1 is not a valid option."
  echo
  _help
fi
exit
