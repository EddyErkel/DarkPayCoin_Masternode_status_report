#!/bin/bash
#
# Creator: Eddy Erkel
# Version: v0.1
# Date:    November 12, 2018
#
# Disclamer:
# This script is provided "as is", without warranty of any kind.
# Use it at your own risk. I assume no liability for damages,
# direct or consequential, that may result from the use of this script.
#
#
# Grateful for my work and in a generous mood?
# DKPC: DCCNs3eRkNrT1Hh6Di3TUMM8Z9RSHzTwe4
# BTC: 18JNWyGhfAmhkWs7jzuuHn54jEZRPj81Jx
# ETH: 0x067e8b995f7dbaf32081bc32927f6fac29b32055
# LTC: LLqwyRiKiuvxkx76grFmbxEeoChLnxvaKH
#
#
# This script can be used to check you DarkPayCoin MN Masternode status
# This script will:
# - Verify DKPC masternode status at explorer2.darkpaycoin.io 
# - Verify DKPC masternode status
# - Verify DKPC masternode service
# - Verify DKPC block count
# - Verify DKPC balance
# - Verify DKPC process ID
# - Verify number of running DKPC processes
# - Verify DKPC masternode port connection
# - Send an email when a warning or error has been raised
#
#
# For info about DKPC please visit: https://darkpaycoin.io/ 
# For DKPC at Github please visit : https://github.com/DarkPayCoin/releases/
#
#
# This script uses SSMTP to send email:
# - SSMTP: https://help.ubuntu.com/community/EmailAlerts
# - SSMTP: https://wiki.archlinux.org/index.php/SSMTP
# - SSMTP config file: /etc/ssmtp/ssmtp.conf
#
# You can schedule this script via crontab
# - https://crontab.guru/
# - https://crontab.guru/examples.html
# - Run every hour:
#   0 * * * * /path/to/darkpaycoin/script/DarkPayCoin_MN_status.sh
#
#
# Verify functions can be enabled, disabled and reordered at the bottom of this script
#
#
# Remark:
# This script was developed and tested on a Ubuntu 16.04.5 LTS server with an IP-v4 IP-address
#
####################################################################################################


###################################################################################################
# Custom Variables (change if needed)
###################################################################################################
balanceinterval=720                                 # Minimum time expected between balance changes (in minutes)
filler="-"                                          # Character to fill header to same length
mailto="your.email@address.com"                     # Mail recipients separated by a space. Send result to when an alarm or error has been detected
mailsubject="DarkPayCoin MN status report"          # Email subject
installfilegithub=https://raw.githubusercontent.com/DarkPayCoin/releases/master/dpc_mn_install.sh	# On-line DarkPayCoin MN installation file (raw format)
installfilelocal=~/darkpaycoin/dpc_mn_install.sh    # Local DarkPayCoin MN installation file which was used during set-up
clifile=~/darkpaycoin-cli                           # darkpaycoin-cli path
pidfile=~/.darkpaycoin/darkpaycoind.pid             # DKPC daemon process id file
explorerip=142.93.97.228                            # IP address of explorer2.darkpaycoin.io (IP is used because http address does not always seem to work)
masternodeport=6667                                 # Port used by DKPC masternode
processes=1                                         # Expected number of running darkpaycoind processes
diskspace_alert=90                                  # set alert level 90% is default


###################################################################################################
# Default script variables
###################################################################################################
script_full=$( readlink -m $( type -p $0 ))         # Script file name including full path
script_dir=`dirname ${script_full}`                 # Script location path
script_name=`basename ${script_full}`               # Script file name without path
script_base="${script_name%.*}"                     # Script file name without extension
script_bal="$script_base.bal"                       # Script balance file
script_log="$script_base.log"                       # Script log file name
script_mail="$script_base.mail"                     # Script mail body
script_alert="$script_base.alert"                   # Alert file. Created when alert is raised
date_time="`date +%Y-%m-%d\ %H:%M:%S`"              # Set date variable
ssmtp=/usr/sbin/ssmtp                               # ssmtp path
warnings=0                                          # Set warnings to 0
errors=0                                            # Set errros to 0
checks=0                                            # Set checks to 0


###################################################################################################
# Functions
###################################################################################################
f_disphead ()
{
    len="76"
    string="$1"
    strlen=${#string}                               # ${#string} expands to the length of $string
    n_fill=$(( (len - $strlen - 2) / 2 ))
    
    echo -en "\e[92m"                               # Green text to screen
    
    printf "%${n_fill}s" | tr ' ' $filler
    echo -n " $string "

    printf "%${n_fill}s" | tr ' ' - >> $script_mail
    echo -n " $string ">> $script_mail

    if [ $((strlen%2)) -eq 0 ];
    then
        printf "%${n_fill}s\n" | tr ' ' $filler
        printf "%${n_fill}s\n" | tr ' ' $filler >> $script_mail
    else
        echo -n "-"
        printf "%${n_fill}s\n" | tr ' ' $filler
        echo -n "-">> $script_mail
        printf "%${n_fill}s\n" | tr ' ' $filler >> $script_mail
    fi

    echo -en "\e[0m"                                # Restore default color
}

f_dispfoot ()
{
    echo ""
    echo "" >> $script_mail
}

f_dispnorm ()
{
    echo -e "\e[39m$1\e[0m"	                        # Default text to screen
    echo "$1" >> $script_mail
}

f_dispwarn ()
{
    let warnings+=1
    echo -e "\e[93m$1\e[0m"                         # Yellow text to screen
#   echo -e "\e[38;5;202m$1\e[0m"                   # Orange text to screen
#   echo -e "\e[38;5;172m$1\e[0m"                   # Orange text to screen
    echo "$1" >> $script_mail
}

f_disperr ()
{
    let errors+=1
    echo -e "\e[91m$1\e[0m"	                        # Red text to screen
    echo "$1" >> $script_mail
}


###################################################################################################
# Start mailbody
###################################################################################################
cd $script_dir
echo "Subject: $mailsubject" > $script_mail
echo "" >> $script_mail
echo $(date) >> $script_mail
echo "" >> $script_mail


###################################################################################################
# Display date and time
###################################################################################################
echo ""
echo $(date) 
echo ""


###################################################################################################
# Verify file variables
###################################################################################################
if ! [ -e $installfilelocal ] ; then f_disperr "File not found: $installfilelocal" ; exit; fi
if ! [ -e $clifile ] ; then f_disperr "File not found: $clifile" ; exit; fi
if ! [ -e $pidfile ] ; then f_disperr "File not found: $pidfile" ; exit; fi


###################################################################################################
#  Verify masternode status at explorer2.darkpaycoin.io 
###################################################################################################
f_verify_masternode_explorer () {
    let checks+=1
    f_disphead "Verify DKPC masternode status at explorer2.darkpaycoin.io"

    hash=$($clifile masternode status | grep "  \"addr\"" | sed -e "s/^  \"addr\": \"//" -e "s/\",//")

    prefix=\{\"mns\":\{
    suffix=\}\}

    mns=$(wget -qO- http://$explorerip/api/masternode/$hash | sed -e "s/^$prefix//" -e "s/$suffix$//")

    IFS=', ' read -r -a array <<< "$mns"
    for element in "${array[@]}"
    do
        element=$(echo $element | tr -d \")
        f_dispnorm "$element"
    done

    f_dispnorm ""

    enabled=$(echo $mns | grep ENABLED)

    if [ "$?" -ne "0" ]; then
            f_disperr "DKPC masternode is not enabled according to explorer2.darkpaycoin.io."
        else
            f_dispnorm "DKPC masternode is enabled according to explorer2.darkpaycoin.io."
    fi
    
    f_dispfoot
}


###################################################################################################
# Verify masternode status
###################################################################################################
f_verify_masternode_status () {
    let checks+=1
    f_disphead "Verify DKPC masternode status"
    $clifile masternode status | grep message | sed -e "s/^  \"message\": //" 2>&1 | tee -a $script_mail
    masternodestatus=$($clifile masternode status | grep status | sed -e "s/^  \"status\": //" -e "s/,//")

    # masternodestatus=1                                  # Unhash for script testing
    
    f_dispnorm ""
    
    if [ "$masternodestatus" == "4" ]; then
            f_dispnorm "DKPC masternode is running."
    else
            f_disperr "DKPC masternode is off-line."
    fi

    f_dispfoot
}


###################################################################################################
# Verify masternode service
###################################################################################################
f_verify_masternode_service () {
    let checks+=1
    f_disphead "Verify DKPC masternode service"
    systemctl status darkpaycoin | grep "active (running)" | sed -e 's/^[ \t]*//' 2>&1 | tee -a $script_mail
    errorlevel="$?"
    
    # errorlevel=1                                  # Unhash for script testing

    f_dispnorm ""
    
     if [ "$errorlevel" -ne "0" ]; then
            f_disperr "DKPC masternode service is not active (not running)."
        else
            f_dispnorm "DKPC masternode service is active (running)."
    fi

    f_dispfoot
}


###################################################################################################
# Verify block count
###################################################################################################
f_verify_block_count () {
    let checks+=1
    f_disphead  "Verify DKPC block count"

    # Get block count at explorer2.darkpaycoin.io
    expblockcount=$(wget -qO- http://$explorerip/api/getblockcount)
    f_dispnorm "Latest online block: $expblockcount"

    # Get NAV block count
    navblockcount=$($clifile getblockcount)
    f_dispnorm "Current local block: $navblockcount"

    # expblockcount=1                             # Unhash for script testing 
    # expblockcount=10000000000                   # Unhash for script testing
    
    f_dispnorm ""
    
    if [ "$expblockcount" -eq "$navblockcount" ]; then
        f_dispnorm "DKPC masternode is in sync."
    else
	if [ "$expblockcount" -gt "$navblockcount" ]; then
	        f_dispwarn "DKPC masternode is out of sync!"
	else
		f_dispnorm "DKPC masternode is ahead of api getblockcount."
	fi
    fi

    f_dispfoot
}


###################################################################################################
# Verify balance
###################################################################################################
f_verify_balance () {
    let checks+=1
    # Create old file for testing:  touch -t YYYYMMDDhhmm.ss <filename>
    f_disphead "Verify DKPC balance at explorer2.darkpaycoin.io"
    hash=$($clifile masternode status | grep "  \"addr\"" | sed -e "s/^  \"addr\": \"//" -e "s/\",//")

    newbalance=$(wget -qO- http://$explorerip/ext/getbalance/$hash | sed 's/\..*//')
    f_dispnorm "Checking balance online for $hash"
    if [ -f $script_bal ]; then
        oldbalance=$(cat $script_bal)
        datebalance=$(echo $(stat -c %y $script_bal) | sed 's/\..*//')
        balancechange=$(echo $(( $(date +%s) - $(stat -L --format %Y "$script_bal") > ($balanceinterval*60) )))
        f_dispnorm "Previous balance: $oldbalance"
        f_dispnorm "Current balance : $newbalance"
        
    # newbalance=1                                        # Unhash for script testing          
    # balancechange=1                                     # Unhash for script testing          

    f_dispnorm ""
    
    if [ $newbalance -gt $oldbalance ]; then
        f_dispnorm "DKPC rewards have been added since previous check at $datebalance."
        echo "$newbalance" > $script_bal
    else
        if [ "$balancechange" -eq "1" ]; then
            f_dispwarn "DKPC balance change is taking longer than expected. Unchanged since $datebalance."
        else
            f_dispnorm "DKPC balance unchanged since previous check at $datebalance."
        fi
    fi
    else
        f_dispnorm "Current balance : $newbalance"
            echo "$newbalance" > $script_bal
    fi

    f_dispfoot
}


###################################################################################################
# Verify installer version
###################################################################################################
f_verify_installer_version () {
    let checks+=1
    f_disphead "Verify DKPC installer version"

    installerversion=$(wget -qO- $installfilegithub | grep '▼ DarkPayCoin Installer' | sed -e "s/^▼ DarkPayCoin Installer v//")
    f_dispnorm "DKPC masternode github installer version: $installerversion"

    installedversion=$(cat $installfilelocal | grep '▼ DarkPayCoin Installer' | sed -e "s/^▼ DarkPayCoin Installer v//")
    f_dispnorm "DKPC masternode local installed version : $installedversion"

    # installerversion=1                             # Unhash for script testing
    
    f_dispnorm ""
    
    if [ "$installerversion" == "$installedversion" ]; then
            f_dispnorm "DKPC masternode installer version is correct."
    else
            f_dispwarn "DKPC masternode installer version is incorrect!"
    fi

    f_dispfoot
}


###################################################################################################
# Verify process ID
###################################################################################################
f_verify_process_id () {
    let checks+=1
    f_disphead "Verify DKPC process ID"

    # pidfile=./test                                      # Unhash for script testing
    
    if [ -f $pidfile ]; then
        f_dispnorm "PID file $pidfile exists."
        f_dispnorm "Process ID: $(cat $pidfile)"
    else
            f_disperr "PID file $pidfile does NOT exist."
    fi

    f_dispfoot
}


###################################################################################################
# Verify number of running DKPC processes
###################################################################################################
f_verify_dkpc_processes () {
    let checks+=1
    f_disphead "Verify number of running DKPC processes"
    processcount=$(ps -ef | grep darkpaycoind | grep -v grep | wc -l)
    ps -ef | egrep 'PID|darkpaycoind' | grep -v grep
    ps -ef | egrep 'PID|darkpaycoind' | grep -v grep >> $script_mail
    
    # processcount=0                                      # Unhash for script testing    
    
    f_dispnorm ""
    
    if [ "$processcount" == "$processes" ]; then
            f_dispnorm "Expected number of DKPC processes running ($processcount of $processes)."
    else
            f_dispwarn "Unexpted number of DKPC processes running ($processcount of $processes)."
    fi

    f_dispfoot
}


###################################################################################################
# Verify DKPC masternode port connection
###################################################################################################
f_check_port () {
    let checks+=1
    f_disphead "Verify DKPC masternode port connection"
    publicip=$(/usr/bin/wget -q -O - checkip.dyn.com|sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
    #publicip=$(/usr/bin/curl -s ident.me)
    f_dispnorm "DKPC masternode external IP-address: $publicip"
    /bin/nc -z -v -w2 $publicip $masternodeport 2>&1 | tee -a $script_mail
    
    f_dispnorm ""
        
    if [ "$?" -ne 0 ]; then
        f_disperr "Connection to $publicip on port $masternodeport failed."
    else
        f_dispnorm "Connection to $publicip on port $masternodeport succeeded."
    fi

    f_dispfoot
}


###################################################################################################
# Display summary
###################################################################################################
f_display_summary ()
{
    f_disphead "Summary"
    f_dispnorm "Checks  : $checks"
    f_dispnorm "Warnings: $warnings"
    f_dispnorm "Errors  : $errors"
	
    echo -e "\e[92m----------------------------------------------------------------------------\e[0m"
    f_dispfoot
}

    
###################################################################################################
# Write summary log file
###################################################################################################
f_write_logfile ()
{
    echo "$date_time   Block: $navblockcount   Balance: $newbalance   Warnings: $warnings   Errors: $errors" >> $script_log
}


###################################################################################################
# Send email
###################################################################################################
f_send_email ()
{
    if [ "$warnings" -gt 0 -o "$errors" -gt 0 ]; then   # Sent email on warnings and errors
#   if [ "$errors" -gt 0 ]; then		                # Sent email on errors
        echo "Sending '$mailsubject' to $mailto"
        $ssmtp $mailto < $script_mail
#   	ssmtp $mailto -vvv < $script_mail	# Verbose ssmtp output
    fi

    f_dispfoot 
}


###################################################################################################
# Enable, disable and change verification order.
###################################################################################################
f_verify_masternode_explorer
f_verify_masternode_status
f_verify_masternode_service
f_verify_block_count
f_verify_balance
f_verify_installer_version 
f_verify_process_id
f_verify_dkpc_processes
f_check_port
f_display_summary
f_write_logfile
f_send_email
