#!/bin/bash

echo "INFO: this file is to go to git, do not try to edit .gitignore directly then."

chmod u+w .gitignore
echo '
ZZ-010 Ghussak - Tweaks/prepare7dtdTNMforReleaseV22.sh
ZZ-010 Ghussak - Tweaks/_NewestSavegamePath.IgnoreOnBackup
ZZ-012 Ghussak - LoadingScreens custom/Config/loadingscreen.xml
ZZ-012 Ghussak - LoadingScreens custom/LoadingScreens/*.jpg
ZZ-012 Ghussak - LoadingScreens custom/LoadingScreens/*.tga
ZZ-015 Ghussak - NPC Raider Ambush POI replacers/Prefabs
ZZ-015 Ghussak - NPC Raider Ambush POI replacers/Prefabs.SkipOnRelease
*/_tmp/*
*/_log/*
*.OLD
*.xcf
' >.gitignore
chmod ugo-w .gitignore

cat .gitignore

ls -l .gitignore

echoc -w -t 60
