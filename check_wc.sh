#!/bin/bash

#Makes use of https://github.com/lausser/check_nwc_health to list number of working accesspoints
#Written by Pit Wenkin

accesspoints="0"
community=""
hostname=""
port="161"


usage()
{
        echo "usage: ./check_wc -h [hostname] -c [community] -p [port] -a [accesspoints]"
        echo "options:"
        echo "            -h [hostname]"
        echo "            -c [SNMPv2 community name]	(ex: public)"
        echo "            -p [port]			(default is 161)"
        echo "            -a [accesspoints]		Number of accesspoints which should be online"
        echo ""
        echo "examples: ./check_wc -c private -p 1234 -h nas.intranet"  
        exit 3
}

while getopts 2:a:c:p:h: OPTNAME; do
        case "$OPTNAME" in
        p)      port="$OPTARG";;
        h)      hostname="$OPTARG";;
        c)      community="$OPTARG";;
        a)      accesspoints="$OPTARG";;
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
                if [ "$percent" -gt "10" ] ; then
                        echo "CRITCAL - $apdown accesspoints are down / $apup accesspoints are up"
                        exit 2
                fi
                echo "WARNING - $apdown accesspoints are down / $apup accesspoints are up"
                exit 1
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
