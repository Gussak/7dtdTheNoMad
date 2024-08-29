#!/bin/bash

echo "INFO: this file is to go to git, do not try to edit .gitignore directly then."

chmod u+w .gitignore
echo '
*/prepare7dtdTNMforReleaseV22.sh
*Ghussak - Tweaks.ArtWorkOnly
*.IgnoreOnBackup
*Ghussak - LoadingScreens custom/Config/loadingscreen.xml
*Ghussak - LoadingScreens custom/LoadingScreens/*.jpg
*Ghussak - LoadingScreens custom/LoadingScreens/*.tga
*Ghussak - NPC Raider Ambush POI replacers/Prefabs
*Ghussak - NPC Raider Ambush POI replacers/Prefabs.SkipOnRelease
*/_tmp/*
*/_log/*
*.OLD
*.old
*.xcf
' >.gitignore
chmod ugo-w .gitignore

cat .gitignore

ls -l .gitignore

echoc -w -t 60
