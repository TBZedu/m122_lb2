---
title: Betriebsdokumenation
author: Conese Dillan, van Loo Colin
date: 2022-07-08
lastmod: 2022-07-08
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

Den *aktuellsten* Release herunterlanden:

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

TODO(GeneTv): Erzeugen der Input-Files beschreiben

TODO(GeneTv): beschreiben des Scriptaufruf

TODO(GeneTv): beschreiben der erzeugt files/directories (falls solche erzeugt werden)

TODO(GeneTv): Lokation von logfiles und bekannte Fehlermeldungen beschreiben.

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
`-h`) Option. Eine ausführlichere Beschreibung findet sich in der Manpage `man
-l man/git-extract-commits.1` ([Repo-Link](../man/git-extract-commits.1)).

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

Code | Description
--- | ---
0 | Ausführung erfolgreich
1 | Invalide Argumente
2 | Invalide Zugriffsberechtigungen
3 | Konfigurationsparameter fehlen
255 | Anderer Fehler

#### Logfiles

Logs werden nach `var/git-tools.log` ([Repo-Link](../var/)).
