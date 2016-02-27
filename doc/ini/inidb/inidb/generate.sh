#!/bin/bash 

DevelHome="/Users/opensim/src"

# generating Metro OpenSim.ini
perl generateOpenSimIni.pl "$DevelHome/freakisim-dev/doc/metropolis/ini/OpenSim.ini" Metropolis

# generating OSgrid OpenSim.ini
perl generateOpenSimIni.pl "$DevelHome/freakisim-dev/doc/osgrid/ini/OpenSim.ini" OSgrid

# generating Dereos OpenSim.ini
perl generateOpenSimIni.pl "$DevelHome/freakisim-dev/doc/dereos/ini/OpenSim.ini" Dereos

echo "OpenSim.ini generated for OSgrid, Dereos and Metropolis "