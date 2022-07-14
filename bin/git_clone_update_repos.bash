#!/bin/bash

cwd=`pwd`
cd `dirname $0`	
BINDIR=`pwd`
LOGLEVEL=${LOGLEVEL:-I}
cd $cwd
BASENAME=`basename $0`
LOGFILE=$BINDIR/../var/buc.log
ETCDIR=$BINDIR/../etc
LOGFILE=$BINDIR/../var/git-tools.log

usage() {
  echo 'SYNOPSIS:'                                                              >&2
  echo "    $BASENAME [-b <BASE_DIRECTORY>] [<ARGUMENTS>] <INPUT_FILE>"         >&2
  echo ''                                                                       >&2
  echo 'INPUT_FILE:'                                                            >&2
  echo '    A file containing all git repo urls and folder names.'              >&2
  echo ''                                                                       >&2
  echo 'ARGUMENTS:'                                                             >&2
  echo '    -b BASE_DIRECTORY         A directory containing git repositories.' >&2
  echo '    -v LEVEL                     log verbosity (D|I|W|E), default is D' >&2
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

while getopts b:v: optvar; do
	case $optvar in
		b) base_directory=${OPTARG} ;;
		v)
      if [[ $OPTARG == "D" || $OPTARG == "I" || $OPTARG == "W" || $OPTARG == "E" ]]; then
        LOGLEVEL=$OPTARG
      else
        LOGLEVEL=D
      fi
      ;;
    :)
      log E "$0: Please provide an argument to -$OPTARG."
      exit 1
      ;;
		*) usage && exit 1 ;;
	esac
done
shift $((OPTIND-1))

input_file="$1"
# We can't continue if the input dir is not a file
log D "Using input file $input_file"
if [ ! -f "$input_file" ]; then
  usage && exit 1
fi

# We want to stop if the base directory does not exist.
if [ ! -d "$base_directory" ]; then
  log E "The directory $base_directory does not exist"
  exit 1
fi

log I "Using $base_directory as a bsae directory"

cat $input_file | while read git_url folder_name ; do

  if [ -d $base_directory/$folder_name ]; then
    log I "Repository $folder_name exists already. Pulling..."
    cd $base_directory/$folder_name && git pull
  else
    log I "Cloning $folder_name as $folder_name..."
    git clone $git_url $base_directory/$folder_name
  fi

done

for folder in `ls $base_directory`; do

  # We want to delete folder that are not within our input file. The 2 spaces are intentional!
  if [[ -d $base_directory/$folder && -z "$(grep  $folder $input_file)" ]]; then
    log I "The folder $folder is not contained within the input file. Deleting $base_directory/$folder..."
    rm -rf $base_directory/$folder
  fi
done