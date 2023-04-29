#PREPARE_RELEASE:REVIEWED:OK
egrep ".cvar.[$.a-zA-Z0-9_]*..........." "Config/Localization.txt" -o |sort -u |egrep -v ")}"
