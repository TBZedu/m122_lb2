---
title: Betriebsdokumenation
author: Conese Dillan, van Loo Colin
date: 2022-07-08
lastmod: 2022-07-13
---

# Betriebsdokumentation

Erstellt am 08.07.2022.

## Einführungstext

Das `git_clone_update_repos.bash`-Skript stellt sicher das alle in einer
Input-Datei spezifizierten Repositories heruntergelanden und aktuell sind.

Das `git_extract_commits.bash`-Skript liest Commit-Informationen aus diesen
Repositories und schreibt diese in eine CSV-Datei.

## Installationsanleitung für Administratoren

### Installation

Den _aktuellsten_ Release herunterlanden:

```bash
curl -L <release> > git-tools.tar.gz
# or: curl -O <release>
tar -xvf git-tools.tar.gz
cd $EXTRACTED_DIR # replace with path of extracted directory
export PATH="$PATH:$EXTRACTED_DIR/bin"
```

### Konfiguration

Ein Beispiel für eine Konfigurationsdatei findet sich unter `etc/git-tools.env`
([Repo-Link](../etc/git-tools.env))

Der Inhalt wird als Bash-Syntax interpretiert.

## Bediensanleitung Benutzer

### Git Clone/Update Repos

#### Erzeugen des Input-Files

Das Input File muss folgendem Format entsprechen:

```
https://git_url folder_name
https://github.com/torvalds/linux linux_github
https://github.com/google-research/google-research google_research_repo
https://gitlab.com/gitlab-org/gitlab gitlab
```

Der Benutzer muss auf die Repositories Zugriff haben. Es können auch Repositories über SSH geklont werden (username@remote:path_to_repo), solange der User eine korrekte Konfiguration gewährleisten kann.

#### Aufruf des Skriptes

```bash
git_clone_update_repos.bash <INPUT_FILE> [-b <BASE_DIRECTORY>] [<ARGUMENTE>]
```

Flaggen werden in der kurzen Form (-b) mitgegeben. Werden Argumente erwartet, können diese mittels einem Space (-b /home/ubuntu/sources) übergeben werden.

Eine ausführlichere Beschreibung findet sich in der Manpage `man -l man/git-clone-update-repos.1` ([Repo-Link](../man/git-clone-update-repos.1)).

Das base directory für die repositories kann über `-b` mitgegeben werden. Wird das base directory nicht mitgegeben, wird das aktuelle verzeichnis als base directory genutzt.

Verboses Logging kann mittels `-v` aktiviert werden.

#### Exit Codes

Mögliche Fehler können auftreten:

```bash
echo $? # Get last exit code
```

| Code | Description                     |
| ---- | ------------------------------- |
| 0    | Ausführung erfolgreich          |
| 1    | Invalide Argumente              |
| 2    | Invalide Zugriffsberechtigungen |
| 255  | Anderer Fehler                  |

#### Logfiles

Logs werden nach `var/git-tools.log` ([Repo-Link](../var/)).

### Git Extract Commits

#### Repository Directory

Als Input muss dem Skript ein Directory welches Repositories beinhaltet
übergeben werden. Dieses Directory kann z.B. mit dem
git-clone-update-repos-Skript erstellt werden.

Das Directory muss nicht ausschliesslich aus Repositories bestehen, invalide
Subdirectories werden vom Skript ignoriert.

Es werden nur direkte Subdirectories beachtet, das Skript läuft nicht rekursiv.

#### Aufruf des Skriptes

```bash
git_extract_commits.bash <BASE_DIRECTORY> [-o <OUTFILE>] [<ARGUMENTE>]
```

Flaggen haben eine kurze (-o) und eine lange (--output) Form. Eine Ausnahme
bildet `--version` (Version ausgeben) und `-v` (Verbosity).

Werden Argumente erwartet, können diese mittels einem Gleichzeichen
(-o=test.csv) oder einem Space (-o test.csv) getrennt übergeben werden.

Eine Übersicht über erlaubte Argumente ist verfügbar mittels der `--help` (oder
`-h`) Option. Eine ausführlichere Beschreibung findet sich in der Manpage `man -l man/git-extract-commits.1` ([Repo-Link](../man/git-extract-commits.1)).

Verboses Logging kann mittels `-v` aktiviert werden.

#### Erzeugte Dateien

Per Default wird die Output-Datei `commits.csv` ins aktuelle Arbeitsverzeichnis
geschrieben. Ein anderer Pfad und Name lassen sich mittels der `-o` Option
spezifizieren.

Der Output ist eine CSV-Datei, wobei Felder durch Kommas getrennt werden.

Die Datei beginnt immer mit einem Header:

```
Zielverzeichnis,Datum,Commit-Hash,Author
```

#### Exit Codes

Mögliche Fehler können auftreten:

```bash
echo $? # Get last exit code
```

| Code | Description                     |
| ---- | ------------------------------- |
| 0    | Ausführung erfolgreich          |
| 1    | Invalide Argumente              |
| 2    | Invalide Zugriffsberechtigungen |
| 3    | Konfigurationsparameter fehlen  |
| 255  | Anderer Fehler                  |

#### Logfiles

Logs werden nach `var/git-tools.log` ([Repo-Link](../var/)).
