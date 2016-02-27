#!/usr/bin/perl
#
# THIS SOFTWARE IS PROVIDED BY THE DEVELOPERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Aendere einen ParameterWert in einem ini-file bsp OpenSim.ini
#
# @param filename Der Dateiname
# @param sectionName Die Section in der ein neuer Eintrag hinzugefuegt werden soll
# @param paramName der name des Parameter dessen Wert geaendert werden soll
# @param replaceVal der neue Wert
#
# Es wird davon ausgegangen dass die Section im Ini-file existiert [sectionname]
#
# (c) Akira Sonoda, 2010
# Version 2.1
#

# use strict;
use Config::IniFiles;

my $numArgs = $#ARGV + 1;

if( $numArgs != 3 ) {
   die("Usage: perl dpatch.pl [filename] [sectionName] [paramName]");
}

my $INIFILE = $ARGV[0];
my $section = $ARGV[1];
my $parameter = $ARGV[2];

my $cfg = new Config::IniFiles( -file => $INIFILE );
$cfg->delval( $section, $parameter);
$cfg->RewriteConfig();

exit(0);

