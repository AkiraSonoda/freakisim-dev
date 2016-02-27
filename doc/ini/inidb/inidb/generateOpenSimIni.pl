# 
# Copyright (C) 2013 Akira Sonoda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Only those files marked to be under the GNU General Public License are
# under this license other parts of the source archive are under other
# licenses. Please check those files seperately.
#
# generateOpenSimIni
# 
# checks all Database Records against a given ini-File
# 

use strict;
use Config::IniFiles;
use constant { true => 1, false => 0, global_disable => -1 };
use DBI;

sub trim($);

# Prints usage
sub usage() {
    print "\n";
    print "Usage: generateOpenSimIni INIFILE GRID\n\n";
    print "generates an INIFILE for a given Path and a given GRID according to the database rules\n";
    print "Valid INIFILES are: \n";
    print "  - OpenSim.ini\n";
    print "Valid GRID are: \n";
    print "  - OSgrid\n";
    print "  - Metropolis\n";
    print "  - Dereos\n";
}   


if ($#ARGV != 1 ) {
	usage();
	exit;
}

my $filepath = $ARGV[0];
my $grid = lc($ARGV[1]);

if( !($grid eq "osgrid" || $grid eq "metropolis" || $grid eq "dereos") ) {
	usage();
	exit;
}

my $cfg = Config::IniFiles->new();
my $dbh = DBI->connect('DBI:mysql:opensim_ini', 'opensim', 'opensim'
	           ) || die "Could not connect to database: $DBI::errstr";
# (insert query examples here...)

my $sql = qq`SELECT * FROM ini`;
my $sth = $dbh->prepare($sql) or die "Cannot prepare: " . $dbh->errstr();
$sth->execute() or die "Cannot execute: " . $sth->errstr();
my @row;
my @fields;

# Print the Header Line
print "ini_section;ini_parameter;opensim_value;ini_value;Comment\n";				

while(@row = $sth->fetchrow_array()) {
  	my @record = @row;
  	push(@fields, \@record);
	my $ini_section = $row[0];
	my $ini_parameter = $row[1];
	my $opensim_value = $row[2];
	my $opensim_enabled_default = $row[3];
	my $opensim_enabled = $row[4];
	my $aki_dereos_value = $row[5];
    my $aki_metro_value = $row[6];
    my $aki_osgrid_value = $row[7];
	my $aki_enabled = $row[8];
	my $osgrid_value = $row[9];
	my $osgrid_enabled = $row[10];
	my $metro_value = $row[11];
	my $metro_enabled = $row[12];
    my $dereos_value = $row[13];
    my $dereos_enabled = $row[14];


    if($aki_enabled != global_disable) {
		if($grid eq "osgrid") {
			if ($aki_enabled == true) {
				$cfg->newval( $ini_section, $ini_parameter, $aki_osgrid_value );
			} elsif ($osgrid_enabled == true) {
				$cfg->newval( $ini_section, $ini_parameter, $osgrid_value );
			} elsif ($opensim_enabled_default == true) {
				$cfg->newval( $ini_section, $ini_parameter, $opensim_value );
			} 
		} elsif($grid eq "metropolis") {
			if ($aki_enabled == true) {
				$cfg->newval( $ini_section, $ini_parameter, $aki_metro_value );
			} elsif ($metro_enabled == true) {
				$cfg->newval( $ini_section, $ini_parameter, $metro_value );
			} elsif ($opensim_enabled_default == true) {
				$cfg->newval( $ini_section, $ini_parameter, $opensim_value );
			} 		
	    } elsif($grid eq "dereos") {
	        if ($aki_enabled == true) {
	            $cfg->newval( $ini_section, $ini_parameter, $aki_dereos_value );
	        } elsif ($dereos_enabled == true) {
	            $cfg->newval( $ini_section, $ini_parameter, $dereos_value );
	        } elsif ($opensim_enabled_default == true) {
	            $cfg->newval( $ini_section, $ini_parameter, $opensim_value );
	        }       
		}
    }
}

$sth->finish();
$dbh->disconnect();

$cfg->SetFileName( $filepath );
$cfg->RewriteConfig();
$cfg->WriteConfig( $filepath );

