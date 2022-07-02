#!/usr/bin/env bash

VERSION=0.0.1
LOGLEVEL=${LOGLEVEL:-W}
PARAMLINE="$BASENAME $@"             # invocation
CWD=$(pwd)                           # current working directory
cd $(dirname $0)
BINDIR=$(pwd)                        # script location
cd $CWD
BASENAME=$(basename $0)              # script name
TMPDIR=/tmp/$BASENAME.$$             # temporary directory
ETCDIR=$BINDIR/../etc                # config directory
LOGFILE=$BINDIR/../var/git-tools.log # logfile

# Create log file and parent dirs if it doesn't exist.
if [ ! -f $LOGFILE ]; then
    mkdir -p $(dirname $LOGFILE)
    LOGFILE=$(realpath $LOGFILE)
fi

usage() {
    echo $'Until I write this, you\'re on your own' >&2
}

version() {
    echo "git_extract_commits.bash v$VERSION"
}

# Source common functions
. $BINDIR/git-tools.utils

# Parse input directory
basedir=
if [ -d "$1" ]; then
    basedir=$(realpath "$1")
    shift
fi

# TODO: Parse command line parameters
config_file=
out_file=
log_level=
for i in "$@"; do
    case $i in
        -h|--help)
            usage
            exit 0
            ;;
        --version)
            version
            exit 0
            ;;
        --config=*)
            config_file="${i#*=}"
            shift ;;
        --config)
            config_file="$2"
            shift ;;
        --output=*)
            out_file="${i#*=}"
            shift ;;
        --output|-o)
            out_file="$2"
            shift ;;
        --verbose=*|-v=*)
            log_level="${i#*=}"
            shift ;;
        --verbose|-v)
            if [[ "$2" == "D" || "$2" == "I" || "$2" == "W" || "$2" == "E" ]]; then
                log_level="$2"
            else
                log_level=D
            fi
            shift ;;
        *) shift ;;
    esac
done

set_log_level() {
    if [ -n "$log_level" ]; then
        LOGLEVEL=$log_level
    fi
}

# Source configuration
set_log_level
if [ -r "$config_file" ]; then
    . $config_file
    log D "config loaded from" $(realpath $config_file)
else
    log D "loading config from default strategy..."
    load_config
fi
set_log_level

log D "invoked:" $PARAMLINE
log D "version:" $(version)

# Validate base directory
if [ ! -d "$basedir" ]; then
    echo "Invalid BASE_DIRECTORY specified, first argument must be a valid directory path." >&2
    exit 1
fi

# Create or truncate outfile
outfile=
if [ -n "$out_file" ]; then
    outfile=$out_file
    log D "outfile passed as param" $outfile
else
    outfile=${EXTRACT_OUTPUT:-"commits.csv"}
    log D "outfile from config or default" $outfile
fi

# NOTE(cvl): "[...] all but the last component must exist."
outfile=$(realpath $outfile)

if [ -w $outfile ]; then
    case $OVERWRITE in
        "Yes") truncate -s0 $outfile ;;
        "Ask")
            read -p "Outfile exists, overwrite? [Y|n] " overwrite_answer
            if [[ "$overwrite_answer" == "y" || -z "$overwrite_answer" ]]; then
                truncate -s0 $outfile
            else
                log E "not overwriting outfile"
                exit 255
            fi
            ;;
        "No")
            log E "not overwriting outfile"
            exit 255
            ;;
    esac
fi

# `is_git_dir` checks whether a directory is a valid git repository.
is_git_dir() {
    if [ -d .git ]; then
        echo .git;
    elif dir=$(git rev-parse --git-dir 2>/dev/null); then
        echo $dir;
    else
        echo "";
    fi
}

# NOTE(cvl): Iterate through all (`*`) directories (`/`).
for d in "$basedir/"*/; do
    cd $d
    if [ -z is_git_dir ]; then
        log I "skipping: $d; not a git repository"
        continue
    else
        log D "found repository in $d"
    fi
    # Get repository's directory name
    gitname=$(basename $(git rev-parse --show-toplevel))
    # Format log like "Repo-Name,YYYYMMDD,Commit-Hash,Author-Name"
    # m122_lb2,20220701,becb412ae979cb3e958f5bd1749d6fb3dd10c2fc,Colin van Loo
    gitlog=$(git log --date="format:%Y%m%d" --pretty="format:$gitname,%ad,%H,%an")
    cd $CWD
    # NOTE(cvl): Must be quoted to preserve line breaks.
    echo "$gitlog" >> $outfile
done

# Finish
log D "logs written to $LOGFILE"
log I "outfile written to $outfile"
echo "------------------------------------------------------------------------"\
    >> $LOGFILE
exit 0
