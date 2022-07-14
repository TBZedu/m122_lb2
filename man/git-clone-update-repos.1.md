% git-clone-update-repos(1) git-clone-update-repos 0.0.1
% Dillan Conese
% July 2022

# NAME

git-clone-update-repos, Clone or pull git remote repositories.

# SYNOPSIS

**git_clone_update_repos.bash** _[-b BASE-DIRECTORY]_ _[ARGUMENTS]_ _INPUT-FILE_

# DESCRIPTION

**git_clone_update_repos.bash** scans a _BASE-DIRECTORY_ for git repositories and pulls or clones the repositories provided via the input file. In case the input file doesn't contain a local directory, it is going to delete the directory locally.

# BASE-DIRECTORY

The base directory must be a directory on your local machine. Git repositories provided via the input file will be searched within the local directory. If they do not exist, they will be cloned to the base directory.

# INPUT-FILE

The input file must contain one remote git repository url per line. The url must be followed by a local folder name, which the repository will be cloned as.

Example syntax of the input file:

`git_url folder_name`

# OPTIONS

**-v _[(D|I|W|E)]_**
: Verbosity level, if no level provided, _I_ is used.

**-b _DIRECTORY_**
: The base directory.

# EXAMPLES

**git_clone_update_repos.bash ~/classes/class-ap19d.txt**
: Clones all repositories listed in ~/classes/class-ap19d.txt to the current directory.

**git_clone_update_repos.bash -b ~/sources/ ~/classes/class-ap19d.txt**
: Clones all repositories listed in ~/classes/class-ap19d.txt to ~/sources/.

**git_clone_update_repos.bash -v D ~/classes/class-ap19d.txt**
: Shows debugging logs while cloning all repositories listed in ~/classes/class-ap19d.txt to the current directory.

**git_clone_update_repos.bash -v D -b ~/classes/ap/19d/ ~/classes/ap/19d/abgaben.txt**
: Shows debugging logs while cloning all repositories listed in ~/classes/ap/19d/abgaben.txt to ~/sources/ap/19d/.

**git_clone_update_repos.bash -b /tmp/repos/ ~/repos.txt**
: Clones all repositories listed in ~/repos.txt to /tmp/repos/.

# EXIT VALUES

**0**
: Success

**1**
: Invalid or missing arguments

**255**
: Other error

# BUGS

My software has no bugs. It develops random features.
