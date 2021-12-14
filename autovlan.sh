#!/bin/bash

# Purpose of this script is to automate the process of add vlans

if [[ $EUID -ne 0 ]]; then
    echo "Must be root to run this, please ru-run this as root.."
    exit 1
fi

# help
function help {
    echo "Usage: ./autovlan.sh [add/remove] [interface] [vlan id]"
    echo "Example: ./autovlan.sh add eth1 220"
    interfaces=$(ip --br a | awk '{ print $1 }')
    echo "interfaces currenly available:"
    echo "$interfaces"
}

if [ "$#" -ne 3 ]; then
    help
    exit 1
fi

choice=$1
interface=$2
vlan=$3

# module 8021q is loaded, this is needed to use vlan tagging
modinfo 8021q &>/dev/null
if [ $? -eq 1 ]; then
    echo "Kernal module 8021q not loaded, will do so now..."
    modprobe 8021q
fi

function addVlan {
    # Add vlan interface as child of given interface
    ip link add link ${interface} name "${interface}.${vlan}" type vlan id ${vlan}
    # Bring up vlan interface
    ip link set dev "${interface}.${vlan}"
    echo "Added VLAN interface ${interface}.${vlan}@${interface}"
}

function removeVlan {
    # Remove interface
    ip link delete "${interface}.${vlan}"
}

if [ ${choice} == "add" ]; then
    echo "Adding interface as child of ${interface} for VLAN ID ${vlan}"
    addVlan
elif [ ${choice} == "remove" ]; then
    echo "Removing VLAN interface ${interface}.${vlan}"
    removeVlan
fi
