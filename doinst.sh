# Handle the incoming configuration files:
config() {
  for infile in $1; do
    NEW="$infile"
    OLD="`dirname $NEW`/`basename $NEW .new`"
    # If there's no config file by that name, mv it over:
    if [ ! -r $OLD ]; then
      mv $NEW $OLD
    elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then
      # toss the redundant copy
      rm $NEW
    fi
    # Otherwise, leave the .new copy for the admin to consider...
  done
}

partuid=77
partuser=partimag
partconfdir="etc/partimaged"
partdatadir="var/spool/partimaged"

# Create the partimage account
if ! grep $partuser etc/passwd  > /dev/null 2>&1
then
  useradd -c "Partition Image daemon" -g root -u $partuid -d /tmp -s /bin/false $partuser
  res=$?
  if [ $res -ne 0 ]
  then
    echo "User with UID $partuid already exists! You'll have to delete it and add a $partuser user manually!"
  echo "Run this command: \"useradd -c 'Partition Image daemon' -u UID -g root -d /tmp -s /bin/false $partuser\""
  echo "And select a free value for UID that is below 500 (check /etc/passwd)"
  fi
fi

# Handle the partimage configuration files
config etc/rc.d/rc.partimaged.new
config ${partconfdir}/partimagedusers.new

# The partimag user must own the configuration directory and the users file
chown ${partuser}:root ${partconfdir}
chown ${partuser}:root ${partconfdir}/partimagedusers
chmod 600 ${partconfdir}/partimagedusers

# The partimag user must own the dataspool directory
chown ${partuser}:root ${partdatadir}
chmod 600 ${partdatadir}

