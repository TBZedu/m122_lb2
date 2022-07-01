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

usage() {
    echo $'Until I write this, you\'re on your own' >&2
}

version() {
    echo "git_extract_commits.bash v$VERSION"
}

# Source common functions
. $BINDIR/git-tools.utils

# Source configuration
load_config

# Parse input directory
basedir=
if [ -d "$1" ]; then
    basedir=$(realpath "$1")
    shift
else
    echo "Invalid BASE_DIRECTORY specified, first argument must be a valid directory path." >&2
    exit 1
fi

# Create or truncate outfile
outfile=$(realpath commits.csv)
truncate -s0 $outfile

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
        log W "Skipping: $d; Not a Git Repository"
        continue
    fi
    # Format log like "Repo-Name,YYYYMMDD,Commit-Hash,Author-Name"
    # m122_lb2,20220701,becb412ae979cb3e958f5bd1749d6fb3dd10c2fc,Colin van Loo
    gitlog=$(git log --date="format:%Y%m%d" --pretty="format:$(basename $(git rev-parse --show-toplevel)),%ad,%H,%an")
    cd $CWD
    echo $gitlog >> $outfile
done

