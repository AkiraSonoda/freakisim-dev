#!/bin/bash 

DevelHome="/Users/opensim/develop"

echo ""
echo "Comparing the OpenSim Default-Ini Files against the database"
echo ""

# checking the default ini files against the Database
echo "==== check arribasim-dev (Dereos) OpenSimDefaults.ini against Database ========================"
perl checkDefaultIniAgainstDatabase.pl "$DevelHome/arribasim-dev/OpenSim/Region/Application/Resources/OpenSimDefaults.ini" "$DevelHome/dereossim/bin/OpenSim.ini" Dereos
echo "==== check (latest) OSgrid Distribution OpenSimDefaults.ini against Database ========================"
perl checkDefaultIniAgainstDatabase.pl "$DevelHome/osgridsim/bin/OpenSimDefaults.ini" "$DevelHome/osgridsim/bin/OpenSim.ini" OSgrid
echo "==== check (latest) Metro Distribution OpenSimDefaults.ini against Database ========================"
perl checkDefaultIniAgainstDatabase.pl "$DevelHome/metrosim/bin/OpenSimDefaults.ini" "$DevelHome/metrosim/bin/OpenSim.ini" Metropolis
echo "==== check opensim (GIT) OpenSimDefaults.ini against Database ========================"
perl checkDefaultIniAgainstDatabase.pl "$DevelHome/opensim/bin/OpenSimDefaults.ini" "$DevelHome/opensim/bin/OpenSim.ini.example" Repo

echo ""
echo "Comparing the OpenSim.ini Files against the database"
echo ""

# checking the OpenSim.ini files against the Database
echo "==== check (latest) Dereos Distribution OpenSim.ini against Database ========================"
perl checkOpenSimIniAgainstDatabase.pl "$DevelHome/dereossim/bin/OpenSim.ini" Dereos
echo "==== check (latest) OSgrid Distribution OpenSim.ini against Database ========================"
perl checkOpenSimIniAgainstDatabase.pl "$DevelHome/osgridsim/bin/OpenSim.ini" OSgrid
echo "==== check (latest) Metro Distribution OpenSim.ini against Database ========================"
perl checkOpenSimIniAgainstDatabase.pl "$DevelHome/metrosim/bin/OpenSim.ini" Metropolis

echo ""
echo "Comparing the Aki OpenSim.ini Files against the database"
echo ""

# checking the Aki OpenSim.ini files against the Database
echo "==== check (latest) Dereos FreAki OpenSim.ini against Database ========================"
perl checkAkiOpenSimIniAgainstDatabase.pl "$DevelHome/freakisim-dev/doc/dereos/ini/OpenSim.ini" Dereos
echo "==== check (lstest) OSgrid FreAki OpenSim.ini against Database ========================"
perl checkAkiOpenSimIniAgainstDatabase.pl "$DevelHome/freakisim-dev/doc/osgrid/ini/OpenSim.ini" OSgrid
echo "==== check (latest) Metro FreAki OpenSim.ini against Database ========================"
perl checkAkiOpenSimIniAgainstDatabase.pl "$DevelHome/freakisim-dev/doc/metropolis/ini/OpenSim.ini" Metropolis
