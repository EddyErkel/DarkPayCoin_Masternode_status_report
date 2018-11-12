<pre>
# DarkPayCoin_Masternode_status_report
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

Example script output:
----------------------

Subject: DarkPayCoin MN status report

Mon Nov 12 11:12:13 UTC 2018

-------- Verify DKPC masternode status at explorer2.darkpaycoin.io ---------
_id:ab01234cd56789efab012345
active:123456
addr:Aa1Bb2Cc3Dd4Ee5Ff6Gg7Hh8Ii9Jj0KkLl
createdAt:2018-11-12T00:00:00.000Z
lastAt:2018-11-12T00:00:00.000Z
lastPaidAt:2018-11-12T00:00:00.000Z
network:ipv4
rank:555
status:ENABLED
txHash:ab01234cd56789efab01234cd56789efab01234cd56789efab01234cd56789ef
txOutIdx:0
ver:70004

DKPC masternode is enabled according to explorer2.darkpaycoin.io.

---------------------- Verify DKPC masternode status -----------------------
"Masternode successfully started"

DKPC masternode is running.

---------------------- Verify DKPC masternode service ----------------------
Active: active (running) since Fri 2018-11-09 00:00:00 UTC; 3 days ago

DKPC masternode service is active (running).

------------------------- Verify DKPC block count --------------------------
Latest online block: 97710
Current local block: 97715

DKPC masternode is ahead of api getblockcount.

------------- Verify DKPC balance at explorer2.darkpaycoin.io --------------
Checking balance online for Aa1Bb2Cc3Dd4Ee5Ff6Gg7Hh8Ii9Jj0KkLl
Previous balance: 10010
Current balance : 10010

DKPC balance unchanged since previous check at 2018-11-12 11:12:13.

---------------------- Verify DKPC installer version -----------------------
DKPC masternode github installer version: 1.02
DKPC masternode local installed version : 1.02

DKPC masternode installer version is correct.

-------------------------- Verify DKPC process ID --------------------------
PID file /root/.darkpaycoin/darkpaycoind.pid exists.
Process ID: 1234

----------------- Verify number of running DKPC processes ------------------
UID        PID  PPID  C STIME TTY          TIME CMD
root      1234     1  2 Nov09 ?        01:23:45 /usr/local/bin/darkpaycoind -daemon -conf=/root/.darkpaycoin/darkpaycoin.conf -datadir=/root/.darkpaycoin

Expected number of DKPC processes running (1 of 1).

------------------ Verify DKPC masternode port connection ------------------
DKPC masternode external IP-address: 12.34.56.78
Connection to 12.34.56.78 6667 port [tcp/ircd] succeeded!

Connection to 12.34.56.78 on port 6667 succeeded.

--------------------------------- Summary ----------------------------------
Checks  : 9
Warnings: 0
Errors  : 0
----------------------------------------------------------------------------
</pre>
