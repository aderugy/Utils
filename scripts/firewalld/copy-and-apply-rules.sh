# Author: aderugy
#
#
# DESCRIPTION:
#
# Extracts all the rules (firewalld) associated to an IP range and adds them
# to another IP range.

ipsource='8.8.8.8'
ipdest='0.0.0.0'
zone='myzone'

sudo firewall-cmd --list-all | grep "$ipsource" | sed -E "s/(rule.*)$ipsource(.*)/sudo firewall\-cmd \-\-permanent \-\-zone=$zone \-\-add\-rich\-rule \'\1$ipdest\2\'/" | bash && sudo firewall-cmd --reload
