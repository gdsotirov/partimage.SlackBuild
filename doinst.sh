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

# Inform the user to create partimage account
echo "******************************** Important ********************************"
echo "NOTE: If you want to use the daemon, you need to add its user like this:"
echo "  # useradd -c \"Partition Image daemon\" -g root -u $partuid -d /tmp -s /bin/false $partuser"
echo "And then change your configuration files permissions:"
echo "  # chown $partuser:root /$partconfdir"
echo "  # chown $partuser:root /$partconfdir/partimagedusers"
echo "  # chown $partuser:root /$partdatadir"
echo "******************************** Important ******************************"

# Handle the partimage configuration files
config etc/rc.d/rc.partimaged.new
config ${partconfdir}/partimagedusers.new

# The partimag user must own the configuration directory and the users file
chown daemon:root ${partconfdir}
chown daemon:root ${partconfdir}/partimagedusers
chmod 600 ${partconfdir}/partimagedusers

# The partimag user must own the dataspool directory
chown daemon:root ${partdatadir}
chmod 600 ${partdatadir}

