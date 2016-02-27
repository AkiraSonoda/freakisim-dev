#!/bin/bash 

DevelHome="/Users/opensim/develop"

echo ""
echo "Comparing the Database against the OpenSim.ini Files"
echo ""

# checking the Databse against the OpenSim.ini files
echo "==== check Database ageinst (latest) Metro Distribution OpenSim.ini ========================"
perl checkDatabaseAgainstOpenSimIni.pl "$DevelHome/dereossim/bin/OpenSim.ini" Dereos
echo "==== check Database ageinst (latest) OSgrid Distribution OpenSim.ini ========================"
perl checkDatabaseAgainstOpenSimIni.pl "$DevelHome/osgridsim/bin/OpenSim.ini" OSgrid
echo "==== check Database ageinst (latest) Metro Distribution OpenSim.ini ========================"
perl checkDatabaseAgainstOpenSimIni.pl "$DevelHome/metrosim/bin/OpenSim.ini" Metropolis

# checking the Databse against the Aki OpenSim.ini files
# echo "==== check Database ageinst (latest) OSgrid FreAki OpenSim.ini ========================"
# perl checkDatabaseAgainstAkiOpenSimIni.pl "$DevelHome/freakisim-dev/doc/osgrid/ini/OpenSim.ini" OSgrid
# echo "==== check Database ageinst (latest) Metro FreAki OpenSim.ini ========================"
# perl checkDatabaseAgainstAkiOpenSimIni.pl "$DevelHome/freakisim-dev/doc/metropolis/ini/OpenSim.ini" Metropolis

# comparing the Database the Default ini files
# echo "==== check Database against (latest) Dereos Distribution OpenSimDefaults.ini ========================"
# perl checkDatabaseAgainstDefaultIni.pl "$DevelHome/arribasim-dev/OpenSim/Region/Application/Resources/OpenSimDefaults.ini" "$DevelHome/dereossim/bin/OpenSim.ini" Dereos
# echo "==== check Database ageinst (latest) OSgrid Distribution OpenSimDefaults.ini ========================"
# perl checkDatabaseAgainstDefaultIni.pl "$DevelHome/osgridsim/bin/OpenSimDefaults.ini" "$DevelHome/osgridsim/bin/OpenSim.ini" OSgrid
# echo "==== check Database ageinst (latest) Metro Distribution OpenSimDefaults.ini ========================"
# perl checkDatabaseAgainstDefaultIni.pl "$DevelHome/metrosim/bin/OpenSimDefaults.ini" "$DevelHome/metrosim/bin/OpenSim.ini" Metropolis
# echo "==== check Database ageinst (latest) opensim Distribution OpenSimDefaults.ini ========================"
# perl checkDatabaseAgainstDefaultIni.pl "$DevelHome/opensim/bin/OpenSimDefaults.ini" "$DevelHome/opensim/bin/OpenSim.ini.example" Repo
