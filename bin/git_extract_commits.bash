#!/usr/bin/env bash

VERSION=0.0.2
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
    echo 'SYNOPSIS:'                                                              >&2
    echo "    $BASENAME <BASE_DIRECTORY> [-o <OUTPUT_FILE>] [<ARGUMENTS>]"        >&2
    echo ''                                                                       >&2
    echo 'BASE_DIRECTORY:'                                                        >&2
    echo '    A directory containing git repositories.'                           >&2
    echo ''                                                                       >&2
    echo 'OUTPUT_FILE:'                                                           >&2
    echo '    Location for the output file.'                                      >&2
    echo ''                                                                       >&2
    echo 'ARGUMENTS:'                                                             >&2
    echo '    -h|--help                    print this help and exit'              >&2
    echo '    --version                    print version and exit'                >&2
    echo '    --config=FILE                supply a custom config file location'  >&2
    echo '    -o=FILE|--output=FILE output file location'                         >&2
    echo '    -v[=LEVEL]|--verbose[=LEVEL] log verbosity (D|I|W|E), default is D' >&2
    echo ''                                                                       >&2
    echo 'EXIT CODES:'                                                            >&2
    echo '    0   Success'                                                        >&2
    echo '    1   Invalid agruments'                                              >&2
    echo '    2   Missing permissions'                                            >&2
    echo '    3   Missing configuration file'                                     >&2
    echo '    255 Other error'                                                    >&2
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

# Parse command-line parameters
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

if [ -n "$log_level" ]; then
    LOGLEVEL=$log_level
fi

# Source configuration
if [ -r "$config_file" ]; then
    . $config_file
    log D "config loaded from" $(realpath $config_file)
else
    log D "loading config from default strategy..."
    load_config
fi

# NOTE(cvl): Log level might be overwritten by config, but parameter should
# have precedence.
if [[ -z "$log_level" && -n "$LOG_LEVEL" ]]; then
    LOGLEVEL=$LOG_LEVEL
fi

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
