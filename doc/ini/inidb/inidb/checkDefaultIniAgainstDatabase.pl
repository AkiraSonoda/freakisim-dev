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
# checkDefaultIniAgainstDatabase
# 
# checks a given OpenSim ini File e.g. OpenSim.ini, OpenSimDefaults.ini
# against the opensim_ini database and reports differences to the console.
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


my $dbh = DBI->connect('DBI:mysql:opensim_ini', 'opensim', 'opensim'
	           ) || die "Could not connect to database: $DBI::errstr";

# Print the Header Line
print "ini_section;ini_parameter;database_value;ini_value;Comment\n";				

my $cfg = Config::IniFiles->new( -file => $filepath );
my $inicfg = Config::IniFiles->new( -file => $inipath );


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
	my $sql;
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

		my ($aki_dereos_value, $aki_metro_value, $aki_osgrid_value, $aki_enabled, $metro_value, $metro_enabled, $opensim_value, $opensim_enabled_default, $osgrid_value, $osgrid_enabled, $dereos_value, $dereos_enabled) = undef;
		
		if ($grid eq "metropolis") {
			$sql = qq'SELECT metro_value, metro_enabled, opensim_value, opensim_enabled_default FROM ini WHERE ini_section="$section" AND ini_parameter="$parameter"';
            $sth = $dbh->prepare($sql)or die "Cannot prepare: " . $dbh->errstr();
            $sth->execute() or die "Cannot execute: " . $sth->errstr();
            ($metro_value,$metro_enabled,$opensim_value,$opensim_enabled_default) = $sth->fetchrow_array();
            
            if( (defined $metro_enabled) && ($metro_enabled == true) && ($metro_value ne $ini_value) ) {
                if( !checkValue($section,$parameter,$metro_value) ) {
                    print "$section;$parameter;$metro_value;$ini_value;metro_different_values\n";
                }
            } elsif ( (defined $metro_enabled) && ($metro_enabled == true) && ($metro_value eq $ini_value) ) {
            } elsif ( (defined $opensim_enabled_default) && ($opensim_enabled_default == true) && ($opensim_value ne $ini_value) ) {
                print "$section;$parameter;$opensim_value;$ini_value;different_values\n";       
            } elsif ( (defined $opensim_enabled_default) && ($opensim_enabled_default == true) && ($opensim_value eq $ini_value) ) {
            } elsif ( (defined $opensim_enabled_default) && ($opensim_enabled_default == false) ) {
                print "$section;$parameter;--;$ini_value;disabled in database\n";              
            } else {
                print "$section;$parameter;--;$ini_value;not found in database\n";            	
            }
            
		} elsif ($grid eq "osgrid") {
			$sql = qq'SELECT osgrid_value, osgrid_enabled, opensim_value, opensim_enabled_default FROM ini WHERE ini_section="$section" AND ini_parameter="$parameter"';			
            $sth = $dbh->prepare($sql)or die "Cannot prepare: " . $dbh->errstr();
            $sth->execute() or die "Cannot execute: " . $sth->errstr();
            ($osgrid_value,$osgrid_enabled,$opensim_value,$opensim_enabled_default) = $sth->fetchrow_array();
            
            if ((defined $osgrid_enabled) && ($osgrid_enabled == true) && ($osgrid_value ne $ini_value) ) {
                if( !checkValue($section,$parameter,$osgrid_value) ) {
                    print "$section;$parameter;$osgrid_value;$ini_value;osgrid_different_values\n";
                }
            } elsif ((defined $osgrid_enabled) && ($osgrid_enabled == true) && ($osgrid_value eq $ini_value) ) {
            } elsif ((defined $opensim_enabled_default) && ($opensim_enabled_default == true) && ($opensim_value ne $ini_value) ) {
                print "$section;$parameter;$opensim_value;$ini_value;opensim_different_values\n";       
            } elsif ((defined $opensim_enabled_default) && ($opensim_enabled_default == true) && ($opensim_value eq $ini_value) ) {
            } elsif ( (defined $opensim_enabled_default) && ($opensim_enabled_default == false) ) {
                print "$section;$parameter;--;$ini_value;disabled in database\n";              
            } else {
                print "$section;$parameter;--;$ini_value;not found in database\n";              
            }

        } elsif ($grid eq "dereos") {
            $sql = qq'SELECT dereos_value, dereos_enabled, opensim_value, opensim_enabled_default FROM ini WHERE ini_section="$section" AND ini_parameter="$parameter"';            
            $sth = $dbh->prepare($sql)or die "Cannot prepare: " . $dbh->errstr();
            $sth->execute() or die "Cannot execute: " . $sth->errstr();
            ($dereos_value,$dereos_enabled,$opensim_value,$opensim_enabled_default) = $sth->fetchrow_array();
            
            if ((defined $dereos_enabled) && ($dereos_enabled == true) && ($dereos_value ne $ini_value) ) {
            	if( !checkValue($section,$parameter,$dereos_value) ) {
                    print "$section;$parameter;$dereos_value;$ini_value;dereos_different_values\n";
            	}
            } elsif ( (defined $dereos_enabled) && ($dereos_enabled == true) && ($dereos_value eq $ini_value) ) {
            } elsif ( (defined $opensim_enabled_default) && ($opensim_enabled_default == true) && ($opensim_value ne $ini_value) ) {
                print "$section;$parameter;$opensim_value;$ini_value;opensim_different_values\n";       
            } elsif ( (defined $opensim_enabled_default) && ($opensim_enabled_default == true) && ($opensim_value eq $ini_value) ) {
            } elsif ( (defined $opensim_enabled_default) && ($opensim_enabled_default == false) ) {
                print "$section;$parameter;--;$ini_value;disabled in database\n";              
            } else {
                print "$section;$parameter;--;$ini_value;not found in database\n";              
            }
            
		} elsif ($grid eq "repo") {
			$sql = qq'SELECT opensim_value, opensim_enabled_default FROM ini WHERE ini_section="$section" AND ini_parameter="$parameter"';
			$sth = $dbh->prepare($sql)or die "Cannot prepare: " . $dbh->errstr();
            $sth->execute() or die "Cannot execute: " . $sth->errstr();
            ($opensim_value,$opensim_enabled_default) = $sth->fetchrow_array();
            
            if((defined $opensim_enabled_default) && ($opensim_enabled_default == true) && ($opensim_value ne $ini_value) ) {
                print "$section;$parameter;$opensim_value;$ini_value;different Values - possibly overwritten\n";
            } elsif( (defined $opensim_enabled_default) && ($opensim_enabled_default == true) && ($opensim_value eq $ini_value) ) {
            } elsif( (defined $opensim_enabled_default) && ($opensim_enabled_default == false) ) {
                print "$section;$parameter;--;$ini_value;disabled in database\n";              
            } else {
                print "$section;$parameter;--;$ini_value;not found in database\n";              
            }
			
		}
		
		
    }
}

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
	print "Usage: checkDefaultIniAgainstDatabase INIFILE OPENSIMINIFILE GRID\n\n";
	print "Checks a given INIFILE of type OpenSimDefault.ini of a given GRID or Source-Repository against the ini database and reports differences to the console\n";
    print "Checks as well if a value in the Database is different from the Value if it is overwritten by the corresponding OpenSim.ini";
	print "Valid INIFILES are: \n";
	print "  - OpenSimDefaults.ini\n";
    print "Valid OPENSIMINIFILES are: \n";
    print "  - OpenSim.ini\n";
	print "Valid GRIDs are: \n";
	print "  - OSgrid\n";
	print "  - Metropolis\n";
    print "  - Dereos\n";
	print "  - Repo\n";
}	
	









