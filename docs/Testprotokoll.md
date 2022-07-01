Skript 1

| Testfall | Testbeschreibung | Testdaten | erwartetes Testresultat | erhaltenes Testresultat | Tester | Testdatum und Teststatus |
|  - | - | - | - | - | - | - |
| Erstmaliger Aufruf | Das Skript soll mit einem input file aufgerufen werden, in welchem nur verfügbare Git-URLs sind. Diese sollen in ein noch nicht existierendes Verzeichnis geklont werden:<pre>git_clone_update_repos.bash repolist.txt /tmp/myrepos</pre> | repolist.txt mit folgendem Inhalt:<pre>https://gitlab.com/armindoerzbachtbz/m122_praxisarbeit Armin_Doerzbach<br>https://gitlab.com/wapdc/InfoSearch/Project-2017 Hans_Meier_Peter_Mueller</pre> | Verzeichnis wird erstellt und alle Repos werden darin geklont | | | |


Skript 2: `git_extract_commits.bash`

| Testfall | Testbeschreibung | Testdaten | erwartetes Testresultat | erhaltenes Testresultat | Tester | Testdatum und Teststatus |
|  - | - | - | - | - | - | - |
| Erstmaliger Aufruf | Das Skript soll mit einem Verzeichnis als parameter aufgerufen werden in welchem 2 Repos sind:<pre> git_extract_commits.bash /tmp/myrepos -o /tmp/commits.csv</pre> | Verzeichnis mit den GIT-Repos die mit dem Skript 1 geklont wurden:<pre>/tmp/myrepos</pre> | Alle Repos aus `/tmp/myrepos` werden gelesen und ein File `/tmp/commits.csv` erstellt mit allen Commits beider Repos | | | |
| Spezifizieren eigener Konfigurationsdatei | Dem Skript wird beim Aufruf ein Pfad zur Konfigurationsdatei übergeben: <pre>git_extract_commits.bash /tmp/myrepos -o /tmp/commits.csv --config custom.conf</pre> | Verzeichnis der mit dem ersten Skript geklonten Repositories, sowohl einer Konfigurationsdatei `custom.conf`, welche bestimmte Optionen überschreibt. | Die Konfigurationsparameter werden aus dem `custom.conf`-file gelesen und verwendet. | | | |
| Aufruf ohne Konfigurationsdatei, auch nicht in Standard-Directories (e.g. `$XDG_CONFIG_HOME`) | Es existieren keine Konfigurationsdateien. Das Skript wird normal aufgerufen: <pre>git_extract_commits.bash /tmp/myrepos -o /tmp/commits.csv</pre> | Das `/tmp/myrepos` erstellt von Skript 1. | Standardwerte werden verwendet. | | | |
| Aufruf ohne spezifizierter Output-Datei | Dem Skript wird beim Aufruf kein Output-File angegeben: <pre>git_extract_commits.bash /tmp/myrepos</pre> | Das `/tmp/myrepos` file, erstellt vom ersten Skript. | Als Output-File wird `commits.csv` im aktuellen Pfad abgelegt, oder wie spezifiziert in `$EXTRACT_OUTPUT`, wenn gesetzt. | | | |
| Aufruf des Skriptes ohne spezifiziertem `BASE_DIRECTORY` als erster Parameter. | Dem Skript wird beim Aufruf kein `BASE_DIRECTORY` als erster Parameter übergeben: <pre>git_extract_commits.bash -o /tmp/commits.csv /tmp/myrepos</pre> | | Eine Fehlermeldung wird ausgegeben, "Invalid BASE_DIRECTORY specified. Please provide a valid path as first argument.". Darauf hin wird die Ausführung sofort beendet. | | | |
| Ausführen des Skriptes im Debug-Mode. | Das Skript wird im Debug-Mode ausgeführt: <pre>git_extract_commits.bash /tmp/myrepos -v D</pre> | Das `/tmp/myrepos` file, erstellt vom ersten Skript. | Das Skript logt viele Details fürs Debugging. | | | |
