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
# checkDatabaseAgainstDefaultIni
# 
# checks all Database Records against a given ini-File
# 

use strict;
use Config::IniFiles;
use constant { true => 1, false => 0 };
use DBI;

# Prototypes
sub trim($);
sub usage();
sub checkValue($ $ $);

if ($#ARGV != 2 ) {
    usage();
    exit;
}

my $filepath = $ARGV[0];
my $inipath = $ARGV[1];
my $grid = lc($ARGV[2]);


if( !($grid eq "osgrid" || $grid eq "metropolis" || $grid eq "dereos" || $grid eq "repo" ) ) {
    usage();
    exit;
}



my $cfg = Config::IniFiles->new( -file => $filepath);
my $inicfg = Config::IniFiles->new( -file => $inipath );

my $dbh = DBI->connect('DBI:mysql:opensim_ini', 'opensim', 'opensim'
	           ) || die "Could not connect to database: $DBI::errstr";
# (insert query examples here...)

my $sql = qq`SELECT * FROM ini`;
my $sth = $dbh->prepare($sql) or die "Cannot prepare: " . $dbh->errstr();
$sth->execute() or die "Cannot execute: " . $sth->errstr();
my @row;
my @fields;

# Print the Header Line
print "ini_section;ini_parameter;database_value;ini_value;Comment\n";				

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

	
	
	if ($opensim_enabled_default == true) {
		my $ini_value = $cfg->val($ini_section, $ini_parameter);
		if (defined $ini_value){
			if ($ini_value =~ m/(.*)\;/) {
				$ini_value = trim($1);
			} else {
				$ini_value = trim($ini_value);
			}
            ## we only check the enabled parameters
            if($grid eq "metropolis") {
                if ($metro_enabled == true && $ini_value ne $metro_value) {
                    if( !checkValue($ini_section,$ini_parameter,$metro_value) ) {
                        print "$ini_section;$ini_parameter;$metro_value;$ini_value;metro_different_values\n";
                    }
                } elsif ($opensim_enabled_default == true && $ini_value ne $opensim_value) {
                    print "$ini_section;$ini_parameter;$opensim_value;$ini_value;different_values - opensim-default-setting\n";                                   
                }
            } elsif ($grid eq "osgrid") {
                if ($osgrid_enabled == true && $ini_value ne $osgrid_value) {
                    print "$ini_section;$ini_parameter;$osgrid_value;$ini_value;different_values - osgrid-setting\n";                                 
                } elsif ($opensim_enabled_default == true && $ini_value ne $opensim_value) {
                    print "$ini_section;$ini_parameter;$opensim_value;$ini_value;different_values - opensim-default-setting\n";                                   
                }
            } elsif ($grid eq "dereos") {
                if ($dereos_enabled == true && $ini_value ne $dereos_value) {
                    print "$ini_section;$ini_parameter;$osgrid_value;$ini_value;different_values - dereos-setting\n";                                 
                } elsif ($opensim_enabled_default == true && $ini_value ne $opensim_value) {
                    print "$ini_section;$ini_parameter;$opensim_value;$ini_value;different_values - opensim-default-setting\n";                                   
                }
            } elsif ($grid eq "repo") {
                if ($opensim_enabled_default == true && $ini_value ne $opensim_value) {
                    print "$ini_section;$ini_parameter;$opensim_value;$ini_value;different_values - opensim-default-setting\n";                                   
                }
            }
			
		} else {
  			print "$ini_section;$ini_parameter;$opensim_value;--;Section/Parameter not found in ini-file\n";		  							
		}
	} 
}

$sth->finish();
$dbh->disconnect();

# Perl trim function to remove whitespace from the start and end of the string
sub trim($) {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub checkValue($ $ $) {
    my $section = shift;
    my $parameter = shift;
    my $value = shift;

    my $ini_value = $inicfg->val($section, $parameter);
    if (defined $ini_value){
        if ($ini_value =~ m/(.*)\;/) {
            $ini_value = trim($1);
        } else {
            $ini_value = trim($ini_value);
        }
        if ($ini_value eq $value) {
            return(true);
        }
    } 
    return(false);
}



# Prints usage
sub usage() {
    print "\n";
    print "Usage: checkDatabaseAgainstDefaultIni INIFILE GRID\n\n";
    print "Checks a given INIFILE of type OpenSimDefault.ini of a given GRID or Source-Repository against the ini database and reports differences to the console\n";
    print "Valid INIFILES are: \n";
    print "  - OpenSimDefaults.ini\n";
    print "Valid GRIDs are: \n";
    print "  - OSgrid\n";
    print "  - Metropolis\n";
    print "  - Dereos\n";
    print "  - Repo\n";
}   
    
