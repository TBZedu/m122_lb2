#!/bin/bash

cwd=`pwd`
cd `dirname $0`	
BINDIR=`pwd`
LOGLEVEL=${LOGLEVEL:-D}
cd $cwd
BASENAME=`basename $0`
LOGFILE=$BINDIR/../var/buc.log
ETCDIR=$BINDIR/../etc
LOGFILE=$BINDIR/../var/git-tools.log

usage() {
  echo 'SYNOPSIS:'                                                              >&2
  echo "    $BASENAME <INPUT_FILE> [-b <BASE_DIRECTORY>] [<ARGUMENTS>]"         >&2
  echo ''                                                                       >&2
  echo 'INPUT_FILE:'                                                            >&2
  echo '    A file containing all git repo urls and folder names.'              >&2
  echo ''                                                                       >&2
  echo 'ARGUMENTS:'                                                             >&2
  echo '    -b BASE_DIRECTORY         A directory containing git repositories.' >&2
  echo '    -v[=LEVEL]                   log verbosity (D|I|W|E), default is D' >&2
  echo ''                                                                       >&2
  echo 'EXIT CODES:'                                                            >&2
  echo '    0   Success'                                                        >&2
  echo '    1   Invalid agruments'                                              >&2
  echo '    2   Missing permissions'                                            >&2
  echo '    255 Other error'                                                    >&2
}

. $BINDIR/git-tools.utils

# Base directory should be the current directory by default.
base_directory=$cwd

while getopts b:h: optvar; do
	case $optvar in
		p) base_directory=${OPTARG} ;;
		v)
      if [[ $2 == "D" || $2 == "I" || $2 == "W" || $2 == "E" ]]; then
        LOGLEVEL=$2
      else
        LOGLEVEL=D
      fi
    ;;
		*) usage && exit 1 ;;
	esac
done

input_dir="$1"
# We can't continue if the input dir is not a file
if [ ! -f "$input_dir" ]; then
  usage && exit 1
fi

# We want to stop if the base directory does not exist.
if [ ! -d "$base_directory" ]; then
  log E "The directory $base_directory does not exist"
  exit 1
fi

cat $input_dir | while read git_url folder_name ; do

  if [ -d $base_directory/$folder_name ]; then
    log I "Repository $folder_name exists already. Pulling..."
    cd $base_directory/$folder_name && git pull
  else
    log I "Cloning $folder_name..."
    git clone $git_url $base_directory/$folder_name
  fi

done

# TODO: Delete folders in base directory that are not a git repository

