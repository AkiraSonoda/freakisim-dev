#!/bin/sh
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
# (c) Akira Sonoda 2009
# 
# OWNERID = name des archiv owners
OWNERID=$1
# BACKUPSERVER = name des Servers auf dem die zweite Sicherung erfolgt
BACKUPSERVER=$2

# Wohin sollen die Backups gesichert werden?
BDIR="/home/opensim/backup/iar"

# Nun erstellen wir eine Variable mit dem aktuellen Datum im Format: YYYYMMDDHHMMSS
NEWDIR="`/bin/date +"%Y%m%d%H%M%S"`"
 
#Wir kreieren ein neues Verzeichnis im "backup" ordner
mkdir $BDIR/$NEWDIR

# Verschieben der zuvor erstellten Backup Files in das entsprechende neue directory
mv $BDIR/*.iar $BDIR/$NEWDIR

#Erstelle ein tar.gz file des Backups
cd $BDIR
tar cfz iar_$OWNERID$NEWDIR.tar.gz $NEWDIR

#Verschlüssle das eben erstellte tar.gz file
gpg -e -r $OWNERID iar_$OWNERID$NEWDIR.tar.gz

#Sende das Versclüsselte File an den Backup Server
# scp $SCREENID$NEWDIR.tar.gz.gpg osbackup@suai.nine.ch:$SCREENID$NEWDIR.tar.gz.gpg
scp iar_$OWNERID$NEWDIR.tar.gz.gpg $BACKUPSERVER:iar_$OWNERID$NEWDIR.tar.gz.gpg

#Räume auf
rm iar_$OWNERID$NEWDIR.tar.gz
rm iar_$OWNERID$NEWDIR.tar.gz.gpg

# Backup erledigt
