#!/bin/sh
# Maintenance dereos_example
/home/opensim/bin/osbackup dereos_example ExampleUser backup@sabai.dyndns.org OpenSim.log
/home/opensim/bin/dereos_arriba_install dereos_example
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/OpenSim.ini Startup PIDFile \"/tmp/dereos_example.pid\"
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/OpenSim.ini Startup crash_dir \"/home/opensim/crashes/dereos_example\"
# Network
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/OpenSim.ini Network http_listener_port 9001
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/OpenSim.ini Network ExternalHostNameForLSL soong.dyndns.org
# Map
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/OpenSim.ini Map GenerateMaptiles false
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/OpenSim.ini Map MapImageModule \"MapImageModule\"
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/OpenSim.ini Map MaptileStaticUUID \"cdc02612-2664-4d81-b049-5f7b8d21dcc8\"
#
# perl /home/opensim/bin/apatch.pl /home/opensim/dereos_example/bin/config-include/GridCommon.ini AuthorizationService Region_Dereos_Plaza \"DisallowForeigners\"
perl /home/opensim/bin/apatch.pl /home/opensim/dereos_example/bin/config-include/GridCommon.ini DatabaseService StorageProvider \"OpenSim.Data.MySQL.dll\"
perl /home/opensim/bin/apatch.pl /home/opensim/dereos_example/bin/config-include/GridCommon.ini DatabaseService ConnectionString "\"Data Source=localhost;Database=dereos_example;User ID=opensim;Password=example;\""
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/config-include/FlotsamCache.ini AssetCache CacheDirectory /home/opensim/cache/dereos_example/assetcache
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/config-include/FlotsamCache.ini AssetCache FileCacheTimeout 0
perl /home/opensim/bin/cpatch.pl /home/opensim/dereos_example/bin/config-include/FlotsamCache.ini AssetCache FileCleanupTimer 0

