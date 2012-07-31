#!/bin/sh
#
# simple script that will:
#  - run g2n
#  - check for changes in configs,
#  - copy them to nagios config dir
#  - restart nagios
#
APP_PATH=$(readlink -f "$(dirname $0)/..")

cd $APP_PATH

G2N_OUTPUT_DIR=$(ruby -Ilib bin/g2n --conf output_path | cut -d: -f2)
NAGIOS_CFG_DIR=/etc/nagios3/host.d/g2n

# Parse parameters
while [ $# -gt 0 ]; do
  case "$1" in
    --nagios-dir) shift
    NAGIOS_CFG_DIR=$1
    ;;

    --g2n-ouput-dir) shift
    G2N_OUTPUT_DIR=$1
    ;;

    *)  echo "Unknown argument: $1"
    exit $NAGIOS_STATE
    ;;
    esac

    shift
done

# Remove trailing slash if present
G2N_OUTPUT_DIR=${G2N_OUTPUT_DIR%/}
NAGIOS_CFG_DIR=${NAGIOS_CFG_DIR%/}

# run g2n
echo "Running g2n..."
ruby -Ilib bin/g2n

[ -z "$(rsync --dry-run --delete-after --itemize-changes --checksum -r $G2N_OUTPUT_DIR/* $NAGIOS_CFG_DIR/)" ]  && {
  echo "No changes were found, exiting..."
  exit
}

# Run the script only as root user
[ $(id -u) -ne 0 ] && {
  echo "Changes were found, but script couldn't perform actions unless you run it as root user"
  exit 1
}

echo "Changes to configs were found, copying & restarting"
rsync --delete-after -qcr $G2N_OUTPUT_DIR/* $NAGIOS_CFG_DIR/
service nagios3 restart
