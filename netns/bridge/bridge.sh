#!/bin/bash

# commands
IP=/usr/bin/ip

# name of network namespaces
NS_HOST1="bridge-host1"
NS_HOST2="bridge-host2"
NS_BRIDGE="bridge-bridge1"

# veth interfaces
VETH_HOST1="eth0"
VETH_HOST2="eth0"
VETH_BRIDGE1="br0-host1"
VETH_BRIDGE2="br0-host2"

# mac addresses
MAC_HOST11="0a:bc:de:f0:00:11"
MAC_HOST12="0a:bc:de:f0:00:12"
MAC_HOST21="0a:bc:de:f0:00:21"
MAC_HOST22="0a:bc:de:f0:00:22"

# bridge interface
BRIDGE_DEV="br0"

# ipv4 addresses
IPV4_HOST1="192.168.1.1/24"
IPV4_HOST2="192.168.1.2/24"
IPV4_BRIDGE="192.168.1.3/24"

# ipv6 addresses
IPV6_HOST1="fd00::1/64"
IPV6_HOST2="fd00::2/64"
IPV6_BRIDGE="fd00::3/64"

# create network namespaces
function create_namespaces {
	echo "Creating network namespaces..."
	$IP netns add $NS_HOST1
	$IP netns add $NS_HOST2
	$IP netns add $NS_BRIDGE
}

# delete network namespaces
function delete_namespaces {
	echo "Removing network namespaces..."
	$IP netns delete $NS_HOST1
	$IP netns delete $NS_HOST2
	$IP netns delete $NS_BRIDGE
}

# add veth interfaces to network namespaces
function add_veths {
	echo "Adding veth interfaces..."

	# add veth interfaces
	local VETH_TEMP1="temp-host1"
	local VETH_TEMP2="temp-host2"
	$IP netns exec $NS_BRIDGE $IP link add $VETH_BRIDGE1 type veth \
		peer name $VETH_TEMP1
	$IP netns exec $NS_BRIDGE $IP link add $VETH_BRIDGE2 type veth \
		peer name $VETH_TEMP2

	# move second veth interfaces to other namespaces
	$IP netns exec $NS_BRIDGE $IP link set $VETH_TEMP1 netns $NS_HOST1
	$IP netns exec $NS_BRIDGE $IP link set $VETH_TEMP2 netns $NS_HOST2

	# rename veth interfaces in other namespaces
	$IP netns exec $NS_HOST1 $IP link set $VETH_TEMP1 name $VETH_HOST1
	$IP netns exec $NS_HOST2 $IP link set $VETH_TEMP2 name $VETH_HOST2

	# set mac addresses of veth interfaces
	$IP netns exec $NS_BRIDGE $IP link set $VETH_BRIDGE1 \
		address $MAC_HOST11
	$IP netns exec $NS_BRIDGE $IP link set $VETH_BRIDGE2 \
		address $MAC_HOST21
	$IP netns exec $NS_HOST1 $IP link set $VETH_HOST1 address $MAC_HOST12
	$IP netns exec $NS_HOST2 $IP link set $VETH_HOST2 address $MAC_HOST22

	# set veth interfaces up
	$IP netns exec $NS_BRIDGE $IP link set $VETH_BRIDGE1 up
	$IP netns exec $NS_BRIDGE $IP link set $VETH_BRIDGE2 up
	$IP netns exec $NS_HOST1 $IP link set $VETH_HOST1 up
	$IP netns exec $NS_HOST2 $IP link set $VETH_HOST2 up
}

# delete veth interfaces from network namespaces
function delete_veths {
	echo "Removing veth interfaces..."
	$IP netns exec $NS_BRIDGE $IP link delete $VETH_BRIDGE1 type veth
	$IP netns exec $NS_BRIDGE $IP link delete $VETH_BRIDGE2 type veth
}

# add bridge that connects veth interfaces
function add_bridge {
	echo "Adding bridge..."
	$IP netns exec $NS_BRIDGE $IP link add $BRIDGE_DEV type bridge
	$IP netns exec $NS_BRIDGE $IP link set dev $VETH_BRIDGE1 \
		master $BRIDGE_DEV
	$IP netns exec $NS_BRIDGE $IP link set dev $VETH_BRIDGE2 \
		master $BRIDGE_DEV
	$IP netns exec $NS_BRIDGE $IP link set dev $VETH_BRIDGE1 promisc on
	$IP netns exec $NS_BRIDGE $IP link set dev $VETH_BRIDGE2 promisc on
	$IP netns exec $NS_BRIDGE $IP link set dev $BRIDGE_DEV up
}

# delete bridge that connects veth interfaces
function delete_bridge {
	echo "Removing bridge..."
	$IP netns exec $NS_BRIDGE $IP link delete $BRIDGE_DEV type bridge
}

# add ip addresses to veth interfaces
function add_ips {
	echo "Adding ip addresses to veth interfaces..."

	# add ipv4 addresses to veth interfaces
	$IP netns exec $NS_HOST1 $IP address add $IPV4_HOST1 dev $VETH_HOST1
	$IP netns exec $NS_HOST2 $IP address add $IPV4_HOST2 dev $VETH_HOST2

	# add ipv6 addresses to veth interfaces
	$IP netns exec $NS_HOST1 $IP address add $IPV6_HOST1 dev $VETH_HOST1
	$IP netns exec $NS_HOST2 $IP address add $IPV6_HOST2 dev $VETH_HOST2

	echo "Adding ip address to bridge..."
	$IP netns exec $NS_BRIDGE $IP address add $IPV4_BRIDGE dev $BRIDGE_DEV
	$IP netns exec $NS_BRIDGE $IP address add $IPV6_BRIDGE dev $BRIDGE_DEV
}

# set everything up
function setup {
	create_namespaces
	add_veths
	add_bridge
	add_ips
}

# tear everything down
function tear_down {
	delete_bridge
	delete_veths
	delete_namespaces
}

# handle command line arguments
case $1 in
	"setup")
		setup
		;;
	"teardown")
		tear_down
		;;
	*)
		echo "$0 setup|teardown"
		;;
esac
