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
# checkDatabaseAgainstAkiOpenSimIni 
# 
# checks all Database Records against a given ini-File
# 

use strict;
use Config::IniFiles;
use constant { true => 1, false => 0, global_disable => -1 };
use DBI;

# Prototypes
sub trim($);
sub usage();
sub checkValue($ $ $);

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

my $cfg = Config::IniFiles->new( -file => $filepath);
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


    if((defined $aki_enabled) && ($aki_enabled != global_disable) ) {
		if($grid eq "osgrid") {
			if ((defined $aki_enabled) && $aki_enabled == true) {
				checkValue($ini_section, $ini_parameter, $aki_osgrid_value);			
			} elsif ($osgrid_enabled == true) {
				checkValue($ini_section, $ini_parameter, $osgrid_value);			
			} elsif ($opensim_enabled_default == true) {
			    checkValue($ini_section, $ini_parameter, $opensim_value);						
			} else {
				# print "$ini_section;$ini_parameter;$opensim_value;--;not_enabled\n";									
			}
		} elsif($grid eq "metropolis") {
			if ((defined $aki_enabled) && $aki_enabled == true ) {
				checkValue($ini_section, $ini_parameter, $aki_metro_value);			
			} elsif ($metro_enabled == true) {
				checkValue($ini_section, $ini_parameter, $metro_value);			
			} elsif ($opensim_enabled_default == true) {
				checkValue($ini_section, $ini_parameter, $opensim_value);						
			} else {
				# print "$ini_section;$ini_parameter;$opensim_value;--;not_enabled\n";									
			}		
	    } elsif($grid eq "dereos") {
	        if ((defined $aki_enabled) && $aki_enabled == true ) {
	            checkValue($ini_section, $ini_parameter, $aki_dereos_value);         
	        } elsif ($dereos_enabled == true) {
	            checkValue($ini_section, $ini_parameter, $dereos_value);         
	        } elsif ($opensim_enabled_default == true) {
	            checkValue($ini_section, $ini_parameter, $opensim_value);                     
	        } else {
	            # print "$ini_section;$ini_parameter;$opensim_value;--;not_enabled\n";                                  
	        }       
		}
    }

}

$sth->finish();
$dbh->disconnect();

sub checkValue($ $ $) {
    my $section = shift;
    my $parameter = shift;
    my $value = shift;

    my $ini_value = $cfg->val($section, $parameter);
    if (defined $ini_value){
        if ($ini_value =~ m/(.*)\;/) {
            $ini_value = trim($1);
        } else {
            $ini_value = trim($ini_value);
        }
        if ($ini_value ne $value) {
                print "$section;$parameter;$value;$ini_value;different_values\n";               
        }
    } else {
        print "$section;$parameter;$value;--;Section/Parameter not found in ini-file\n";                                    
    }
    
}

# Prints usage
sub usage() {
    print "\n";
    print "Usage: checkDatabaseAgainstOpenAkiSimIni INIFILE GRID\n\n";
    print "Checks a given INIFILE of a given GRID against the ini database and the akisim settings and reports differences to the console\n";
    print "Valid INIFILES are: \n";
    print "  - OpenSim.ini\n";
    print "Valid GRID are: \n";
    print "  - OSgrid\n";
    print "  - Metropolis\n";
    print "  - Dereos\n";
}   




# Perl trim function to remove whitespace from the start and end of the string
sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}