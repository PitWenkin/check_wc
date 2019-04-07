# Check WLAN Controller
Nagios/Icinga script to check availability of access points managed by a wlan controller

Makes use of https://github.com/lausser/check_nwc_health to list number of (non)working accesspoints

# Dependencies:
https://github.com/lausser/check_nwc_health


# Usage:
```
   -h   Hostname to query - (required)
   -c   SNMP read community (default=public)
   -a   Number of accesspoints expected(required)
   -h   Usage help 
```

# Examples:

```
./check_wc -H 192.168.1.1 -C public -a 88
OK - 88 accesspoints are up
```

```
./check_wc -H 192.168.1.1 -C public -a 88
WARNING - 1 accesspoints are down / 87 accesspoints are up
```

```
./check_wc -H 192.168.1.1 -C public -a 88
CRITICAL - 14 accesspoints are down / 74 accesspoints are up
```
