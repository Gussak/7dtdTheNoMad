#!/bin/bash

echo "INFO: this file is to go to git, do not try to edit .gitignore directly then."

echo '
ZZ-010 Ghussak - Tweaks/prepare7dtdTNMforReleaseV22.sh
ZZ-010 Ghussak - Tweaks/_NewestSavegamePath.IgnoreOnBackup
ZZ-015 Ghussak - NPC Raider Ambush POI replacers/Prefabs.SkipOnRelease
' >.gitignore

chmod ugo-w .gitignore

ls -l .gitignore
