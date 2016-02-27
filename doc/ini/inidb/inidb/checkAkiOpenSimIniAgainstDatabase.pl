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
# checkAkiOpenSimIniAgainstDatabase 
# 
# checks a given OpenSim.ini File e.g. OpenSim.ini, database and reports differences to the console.
# 

use strict;
use Config::IniFiles;

use constant { true => 1, false => 0, global_disable => -1 };

use DBI;

# Prototypes
sub trim($);
sub usage();
sub compareValues($ $ $ $);


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

my $dbh = DBI->connect('DBI:mysql:opensim_ini', 'opensim', 'opensim'
	           ) || die "Could not connect to database: $DBI::errstr";

# Print the Header Line
print "ini_section;ini_parameter;opensim_value;ini_value;Comment\n";				

my $cfg = Config::IniFiles->new( -file => $filepath );

my @sections=$cfg->Sections();

foreach my $section (@sections) {
    #Retreives all parameters in the section
    my @params = $cfg->Parameters($section);
    #For each parameter in a particular compare the value with the value stored in the database
    findInDatabase ($section,@params);
}

sub findInDatabase {
    my $section = shift @_;
	my @parameters = @_;
	my $sth;
    foreach my $parameter (@parameters) {
        chomp($parameter);
        chomp($section);
		#This below statement is not printing out the values.
		my $ini_value = $cfg->val($section, $parameter);
		if ($ini_value =~ m/(.*)\;/) {
			$ini_value = trim($1);
		} else {
			$ini_value = trim($ini_value);
		}
				
		my $sql = qq'SELECT opensim_value, opensim_enabled_default, aki_dereos_value, aki_metro_value, aki_osgrid_value, aki_enabled, osgrid_value, osgrid_enabled, metro_value, metro_enabled, dereos_value, dereos_enabled  FROM ini WHERE ini_section="$section" AND ini_parameter="$parameter"';
		$sth = $dbh->prepare($sql)or die "Cannot prepare: " . $dbh->errstr();
		$sth->execute() or die "Cannot execute: " . $sth->errstr();
		my($opensim_value,$opensim_enabled_default, $aki_dereos_value, $aki_metro_value, $aki_osgrid_value, $aki_enabled, $osgrid_value, $osgrid_enabled, $metro_value, $metro_enabled, $dereos_value, $dereos_enabled) = $sth->fetchrow_array();
		
        if( !($aki_enabled == global_disable) ) {
			if($grid eq "osgrid") {
				if ($aki_enabled == true) {
					compareValues($section,$parameter,$aki_osgrid_value,$ini_value);
				} elsif ($osgrid_enabled == true) {
					compareValues($section,$parameter,$osgrid_value,$ini_value);
				} elsif($opensim_enabled_default == true) {
					compareValues($section,$parameter,$opensim_value,$ini_value);				
				} else {
					print "$section;$parameter;$opensim_value;$ini_value;not_enabled\n";						
				}
			} elsif ($grid eq "metropolis") {
				if ($aki_enabled == true) {
					compareValues($section,$parameter,$aki_metro_value,$ini_value);
				} elsif ($metro_enabled == true) {
					compareValues($section,$parameter,$metro_value,$ini_value);
				} elsif($opensim_enabled_default == true) {
					compareValues($section,$parameter,$opensim_value,$ini_value);				
				} else {
					print "$section;$parameter;$opensim_value;$ini_value;not_enabled\n";						
				}			
	        } elsif ($grid eq "dereos") {
	            if ($aki_enabled == true) {
	                compareValues($section,$parameter,$aki_dereos_value,$ini_value);
	            } elsif ($dereos_enabled == true) {
	                compareValues($section,$parameter,$dereos_value,$ini_value);
	            } elsif($opensim_enabled_default == true) {
	                compareValues($section,$parameter,$opensim_value,$ini_value);               
	            } else {
	                print "$section;$parameter;$opensim_value;$ini_value;not_enabled\n";                        
	            }           
			}
        } else {
            print "$section;$parameter;--;$ini_value;globally_disabled\n";                                	
        }
    }
}

$dbh->disconnect();

# Subroutine to compare two values and report differences
sub compareValues($ $ $ $) {
    my $section = shift;
    my $parameter = shift;
    my $db_value = shift;
    my $file_value = shift;

    if(defined $db_value) {
        if($db_value ne $file_value) {
            print "$section;$parameter;$db_value;$file_value;different_values\n";       
        }
    } else {
            print "$section;$parameter;--;$file_value;not found in database\n";                     
    }
}



# Perl trim function to remove whitespace from the start and end of the string
sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

# Prints usage
sub usage() {
    print "\n";
    print "Usage: checkIOpenSimIniAgainstDatabase INIFILE GRID\n\n";
    print "Checks a given INIFILE of akisim type ( Defaults and OpenSim.ini combined ) \n";
    print "of a given GRID against the ini database and reports differences to the console\n";
    print "Valid INIFILES are: \n";
    print "  - OpenSim.ini\n";
    print "Valid GRID are: \n";
    print "  - OSgrid\n";
    print "  - Metropolis\n";
    print "  - Dereos\n";
}   




