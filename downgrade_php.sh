#!/bin/bash -
#===============================================================================
#
#          FILE: downgrade_php.sh
#
#         USAGE: ./downgrade_php.sh
#
#   DESCRIPTION: removes old php packages and install new version
#                WARNING: configs will be purged!
#
#       OPTIONS: PHP_OLD PHP_NEW
#        AUTHOR: Jörg Stewig (nightmare@rising-gods.de)
#
#===============================================================================

set -o nounset                              # Treat unset variables as an error

function usage
{
    echo -e "\nusage: $0 PHP_OLD PHP_NEW [$0 5.5.7-1~dotdeb.1 5.4.23-1~dotdeb.1]"
    echo -e "list available PHP Versions: apt-cache showpkg php5\n"
}

# check parameter count
if [ "$#" -ne 2 ]; then
usage
exit 1
fi

OLD_PHP_VERSION=$1
NEW_PHP_VERSION=$2
STAT_FILE='/tmp/php_downgrade'

dpkg -l | grep php | grep -w $OLD_PHP_VERSION | awk '{print $2}' > $STAT_FILE
apt-get remove --purge `dpkg -l | grep php | grep -w $OLD_PHP_VERSION | awk '{print $2}' | xargs`
apt-get install `cat $STAT_FILE | xargs -I {} -n 1 echo "{}=$NEW_PHP_VERSION"`

echo -e "\nHold Packages? [y/n] \n"
char=''
read -n 1 char

case "$char" in
'y')
apt-mark hold `aptitude -F%p --disable-columns search ~U`
echo -e "Unhold packages with: apt-mark unhold `aptitude -F%p --disable-columns search ~U`"
;;

'n')
echo -e "Hold packages with: apt-mark hold `aptitude -F%p --disable-columns search ~U`"
;;

*)
echo -e "done\n"
;;

esac    # --- end of case ---