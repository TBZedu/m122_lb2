% git-extract-commits(1) git-extract-commits 0.0.2
% Colin van Loo
% July 2022

# NAME

git-extract-commits, Collect Git commits information.

# SYNOPSIS

**git_extract_commits.bash** *BASE-DIRECTORY* *[-o OUTPUT-FILE]* *[ARGUMENTS]*

# DESCRIPTION

**git_extract_commits.bash** scans a *BASE-DIRECTORY* for git repositories and
collects information about the commit history into a CSV *OUTPUT-FILE*.

If the **-h|--help** or **--version** flags are set, the program will
immediately exit after printing the help or version information. (Depending on
which flag is encountered first.)

# BASE-DIRECTORY

The base directory must be a directory containing multiple git repositories as
subdirectories. Git repositories are only searched one level deep. Directories
not containing a `.git` (or whatever is returned by `git rev-parse --git-dir`),
are ignored.

# OUTPUT-FILE

Collected commit information is stored in CSV format, per default into
`commits.csv`. A custom file location and name can be specified by setting the
**-o** flag.

The CSV has the following format:

`Zielverzeichnis,Datum,Commit-Hash,Author`

Always with this first line as the header.

# OPTIONS

**-h**, **--help**
: Display help information and exit immediately.

**--version**
: Display version and exit immediately.

**--config *FILE***
: Read configuration from *FILE*.

**-v *[(D|I|W|E)]***, **--verbose *[(D|I|W|E)]***
: Verbosity level, if no level provided, *D* is used.

**-o *FILE***, **--output *FILE***
: Write output to *FILE*.

# EXAMPLES

**git_extract_commits.bash -h**
: Display help and exit.

**git_extract_commits.bash --version**
: Display version and exit.

**git_extract_commits.bash ~/code**
: Collect commit information from all repositories located in *~/code*.

**git_extract_commits.bash ~/code -v**
: Enable debug mode, verbose logging.

**git_extract_commits.bash ~/code -o /tmp/data.csv**
: Save commit data to */tmp/data.csv*.

# EXIT VALUES

**0**
: Success

**1**
: Invalid or missing arguments

**255**
: Other error

# BUGS

My software has no bugs. It develops random features.
