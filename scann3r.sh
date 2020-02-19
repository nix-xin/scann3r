#!/bin/bash
#===============================================================================
#
#          FILE:  scann3r.sh
# 
#         USAGE:  ./scann3r.sh 
# 
#   DESCRIPTION:  An automated discovery script for conducting simple scanning techniques using nmap
#                 and autorecon.
# 
#       OPTIONS:  No Options required. Just execute the program and follow the instructions in the menu.
#  REQUIREMENTS:  bash, autorecon, and nmap
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Luciano Avendano, CISSP 
#       COMPANY:  
#       VERSION:  1.3
#       CREATED:  04/22/2018 07:17:35 PM PDT
#      REVISION:  ---
#===============================================================================

#set -x

# Set some gl0bal variables
home=$HOME
work=$home/data
phost="$work/live-hosts.txt"

hr="============================================================================"
sip='sort -n -u -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4'


#===============================================================================

banner(){
echo
echo -e "\x1B[1;96m
                            _____
  ___  ___ __ _ _ __  _ __ |___ / _ __
 / __|/ __/ _  |  _ \|  _ \  |_ \|  __|
 \__ \ (_| (_| | | | | | | |___) | |
 |___/\___\__,_|_| |_|_| |_|____/|_|

A lighweight pentesting network discovery tool.                                    
By Luciano Avendano

Inspired by Lee Bairds DISCOVER tool.\x1B[0m"

echo
}

#===============================================================================

error(){
echo
echo -e "\x1B[1;31m$hr\x1B[0m"
echo
echo -e "\x1B[1;31m                *** Invalid choice or entry. ***\x1B[0m"
echo
echo -e "\x1B[1;31m$hr\x1B[0m"

}

#===============================================================================

generateTargets(){
clear
banner

echo -e "\x1B[1;34mSCANNING\x1B[0m"
echo
echo "1.  LAN ARP Scan"
echo "2.  Ping sweep"
echo "3.  Previous menu"
echo
echo -n "Choice: "
read choice

case $choice in
     1) arpscan;;
     2) pingSweep;;
     3) main;;
     *) error;;
esac
}

#====================================================================================

arpscan(){

     echo
     echo -n "Interface to scan: "
     read interface

     echo
     echo -n "IP Range to scan: "
     read range

     # Check for no answer
     if [[ -z $interface ]] || [[ -z $range ]]; then
          error
     fi

     arp-scan --interface=$interface $range | egrep -v '(arp-scan|Interface|packets|Polycom)' | awk '{print $1}' | $sip | sed '/^$/d' > $home/data/hosts-arp.txt

     echo $hr
     echo
     echo "***Scan complete.***"
     echo
     echo
     printf 'The new report is located at \x1B[1;33m%s\x1B[0m\n' $home/data/hosts-arp.txt
     echo
     echo

showMenu

}

#===================================================================================

pingSweep(){
clear
banner

echo -e "\x1B[1;34mType of input:\x1B[0m"
echo
echo "1.  List containing IPs"
echo "2.  Manual"
echo
echo -n "Choice: "
read choice

case $choice in
     1)
     filePath

     echo
     echo "Running an Nmap ping sweep for live hosts using $location."
     nmap -sn -PS -PE --stats-every 10s -iL $location > tmp
     ;;

     2)
     echo
     echo -n "Enter your targets: "
     read manual

     # Check for no answer
     if [[ -z $manual ]]; then
          error
     fi

     echo
     echo "Running an Nmap ping sweep for live hosts using manual entries."
     nmap -sn -PS -PE --stats-every 10s $manual -oG tmp
     ;;

     *) error;;
esac

# cat tmp | grep 'report' | awk '{print $6}' | tr -d '()' > tmp2

# Use the grepable tmp file to pull out the hosts that are up
grep "Up" tmp  | cut -d" " -f2 > tmp2
mv tmp2 $phost
rm tmp

echo
echo $hr
echo
echo "***Scan complete.***"
echo
echo
printf 'The new report is located at \x1B[1;33m%s\x1B[0m\n' $phost
echo
echo
showMenu

}

#====================================================================================

showlist(){
clear
banner

echo
echo -e "\x1B[1;34mTARGET LISTS\x1B[0m"
echo
echo "1. ARP Scan List"
echo "2. Ping Sweep List"
echo "3. Return to Main Menu"
echo
echo -n "Choice: "
read choice

case $choice in
     1) 
     if [ ! -e $home/data/hosts-arp.txt ]; then
        echo -e "\x1B[1;31m Target list does not exist! \x1B[0m"
        main
     fi

       echo $hr 
       echo -e "\x1B[1;31m                *** Current Target ARP List ***\x1B[0m"

       cat $home/data/hosts-arp.txt

       echo $hr
       echo 
       showMenu
     ;;
     2) 
     if [ ! -e $phost ]; then
        echo -e "\x1B[1;31m Target list does not exist! \x1B[0m"
        main
     fi
 
       echo $hr 
       echo -e "\x1B[1;31m                *** Current Target Ping List ***\x1B[0m"

       cat $phost

       echo $hr
       echo
       showMenu
     ;;
     3) main;;
     *) error;;
esac

}

#===================================================================================

filePath(){

echo
echo -n "Enter the path to your file: "
read -e location

# Check for no answer
if [[ -z $location ]]; then
     error
fi

# Check for wrong answer
if [ ! -f $location ]; then
     error
fi

}

#===================================================================================

agressiveScan(){
clear
banner

echo -e "\x1B[1;34mType of input:\x1B[0m"
echo
echo "1.  List containing new IPs"
echo "2.  List from previous scan ${phost}"
echo "3.  Manual Entry"
echo "4.  Return to Main Menu"
echo
echo -n "Choice: "
read choice

case $choice in
     1)
     filePath

     echo
     echo "Running Nmap Agressive scan using $location."
     # create an array of hosts from file
     declare -a myHosts
     readarray myHosts < $location
     #echo ${myHosts[@]} -for debug
        # loop through each host run agressive scan
        for myHost in "${myHosts[@]}";
        do
            echo "Creating Nmap report for ${myHost}"
            echo $hr
            mkdir ${work}/${myHost}
            cd ${work}/${myHost} 
               nmap -A --stats-every 10s ${myHost} -oX agressive_scan.xml
               xsltproc agressive_scan.xml -o agressive_scan.html
               rm agressive_scan.xml
            echo  "Finished! Nmap report at ${work}/${myHost}/agressive_scan.html"
            echo $hr
        done
     ;;

     2)

     echo
     echo "Running Nmap Agressive scan using ${phost}"
     # create an array of hosts from file
     declare -a myHosts
     readarray myHosts < ${phost}
     #echo ${myHosts[@]} -for debug
        # loop through each host run agressive scan
        for myHost in "${myHosts[@]}";
        do
            echo "Creating Nmap report for ${myHost}"
            echo $hr
            mkdir ${work}/${myHost}
            cd ${work}/${myHost}
               nmap -A --stats-every 10s ${myHost} -oX agressive_scan.xml
               xsltproc agressive_scan.xml -o agressive_scan.html
               rm agressive_scan.xml
            echo  "Finished! Nmap report at ${work}/${myHost}/agressive_scan.html"
            echo $hr
        done
     ;;


     3)
     echo
     echo -n "Enter your targets: "
     read manual

     # Check for no answer
     if [[ -z $manual ]]; then
          error
     fi

     echo
     echo "Running an Nmap ping sweep for live hosts using manual entries."
     # create an array of hosts from entries
     declare -a myHosts=(${manual})
     #echo ${myHosts[@]} -for debug
        # loop through each host run agressive scan
        for myHost in "${myHosts[@]}";
        do
            echo "Creating Nmap report for ${myHost}"
            echo $hr
            mkdir ${work}/${myHost}
            cd ${work}/${myHost}
               nmap -A --stats-every 10s ${myHost} -oX agressive_scan.xml
               xsltproc agressive_scan.xml -o agressive_scan.html
               rm agressive_scan.xml
            echo  "Finished! Nmap report at ${work}/${myHost}/agressive_scan.html"
            echo $hr
        done
     ;;

     4) main;;     
     *) error;;
esac

echo
echo $hr
echo
echo "***Agressive Scans complete.***"
echo
echo
echo
echo
showMenu

}

#===================================================================================

autoreconScan() {
clear
banner

echo -e "\x1B[1;34mType of input:\x1B[0m"
echo
echo "1.  List containing new IPs"
echo "2.  List from previous scan ${phost}"
echo "3.  Manual Entry (e.g. 192.168.1.1/24)"
echo "4.  Return to Main Menu"
echo
echo -n "Choice: "
read choice

case $choice in
     1)
     filePath

     echo
     echo "Running AutoRecon scan using $location."
     # change to working dir
     cd ${work}
     # run autorecon
     /usr/bin/python3 /opt/AutoRecon/autorecon.py -t ${location} --only-scans-dir
     ;;

     2)
     echo
     echo "Running AutoRecon scan using ${phost}"
     # change to working dir
     cd ${work}
     # run autorecon
     /usr/bin/python3 /opt/AutoRecon/autorecon.py -t ${phost} --only-scans-dir
     ;;

     3)
     echo
     echo -n "Enter your targets: "
     read manual

     # Check for no answer
     if [[ -z $manual ]]; then
          error
     fi

     echo
     echo "Running AutoRecon scan using manual entries."
     # change to working dir
     cd ${work}
     # run autorecon
     /usr/bin/python3 /opt/AutoRecon/autorecon.py ${manual} --only-scans-dir
     ;;

     4) main;;
     *) error;;

esac

echo
echo $hr
echo
echo "***AutoRecon Scans complete.***"
echo
echo
echo
echo
showMenu


}

#===================================================================================

showMenu(){

echo
echo -e "\x1B[1;34mSCANNING\x1B[0m"
echo
echo "1.  Generate Target List"
echo "2.  Show Target List"
echo "3.  Run Agressive Scan"
echo "4.  Run AutoRecon Scan"
echo "5.  Return to Main Menu"
echo "6.  Exit"
echo
echo -n "Choice: "
read choice

case $choice in
     1) generateTargets;;
     2) showlist;;
     3) agressiveScan;;
     4) autoreconScan;;
     5) main;;
     6) clear && exit;;
     *) error;;
esac

}

#====================================================================================

main(){
clear
banner

if [ ! -d $home/data ]; then
     mkdir -p $home/data
fi

showMenu

}

#=========================================================================================

# Run Main Function
main
