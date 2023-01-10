#!/bin/bash

#Makes use of https://github.com/lausser/check_nwc_health to list number of working accesspoints
#Written by Pit Wenkin
#Version 1.2
# - Added variables for warning and critical status

accesspoints="0"
community=""
hostname=""
port="161"
warning="1"
critical="10"

usage()
{
        echo "usage: ./check_wc -h [hostname] -c [community] -p [port] -a [accesspoints] -W [warning] -C [critical]"
        echo "options:"
        echo "            -h [hostname]"
        echo "            -c [SNMPv2 community name]	(ex: public)"
        echo "            -p [port]			(default is 161)"
        echo "            -a [accesspoints]		Number of accesspoints which should be online"
        echo "            -W [warning]  Percentage of accesspoints which have to be down to return a warning message"
        echo "            -C [critical] Percentage of accesspoints which have to be down to return a critical message"
        echo ""
        echo "examples: ./check_wc -c private -p 1234 -h nas.intranet"
        echo "          ./check_wc -c private -p 1234 -h nas.intranet -W 5 -C 10"
        exit 3
}

while getopts 2:a:c:p:h:C:W: OPTNAME; do
        case "$OPTNAME" in
        p)      port="$OPTARG";;
        h)      hostname="$OPTARG";;
        c)      community="$OPTARG";;
        a)      accesspoints="$OPTARG";;
        C)      critical="$OPTARG";;
        W)      warning="$OPTARG";;
        esac
done
if [ "$hostname" = "" ] || [ "$community" = "" ] ; then
    usage
else
        output=`/usr/lib/nagios/plugins/check_nwc_health --hostname $hostname --port $port --community $community --mode list-interfaces | grep -o '[0-9]\{6\} ap[0-9]\{1,3\}s0' | wc -l`
        apdown=`expr $output - $accesspoints`
        apup=`expr $accesspoints + $apdown`
        if [ "$output" -ne "1" ] && [ "$apdown" -lt "0" ] ; then
                apdown=${apdown#-}
                hundred=`expr 100 '*' "$apdown"`
                percent=`expr $hundred / $accesspoints`
                percent=${percent%.*}
                if [ "$percent" -gt "$critical" ] ; then
                        echo "CRITICAL - $apdown accesspoints are down / $apup accesspoints are up"
                        exit 2
                else
                        if [ "$percent" -gt "$warning" ] ; then
                                echo "WARNING - $apdown accesspoints are down / $apup accesspoints are up"
                                exit 1
                        fi
                fi
                echo "OK - $apdown accesspoints are down / $apup accesspoints are up"
                exit 0
        fi

        if [ "$apdown" = "0" ] ; then
                echo "OK - $accesspoints accesspoints are up"
                exit 0
        fi

        if [ "$apup" -gt "$accesspoints" ] ; then
                echo "ERROR - More accesspoints visible then should exist / $apup instead of $accesspoints"
                exit 2
        fi

        echo "UNKOWN"
        exit 3
fi
