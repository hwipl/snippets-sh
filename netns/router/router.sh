#!/bin/bash

# commands
IP=/usr/bin/ip
SYSCTL=/usr/bin/sysctl

# name of network namespaces
NS_HOST1="router-host1"
NS_HOST2="router-host2"
NS_ROUTER="router-router1"

# veth interfaces
VETH_HOST11="veth1"
VETH_HOST12="veth2"
VETH_HOST21="veth3"
VETH_HOST22="veth4"

# mac addresses
MAC_HOST11="0a:bc:de:f0:00:11"
MAC_HOST12="0a:bc:de:f0:00:12"
MAC_HOST21="0a:bc:de:f0:00:21"
MAC_HOST22="0a:bc:de:f0:00:22"

# ipv4 addresses
IPV4_HOST1="192.168.1.2/24"
IPV4_HOST2="192.168.2.2/24"
IPV4_ROUTER1="192.168.1.1/24"
IPV4_ROUTER2="192.168.2.1/24"

# ipv6 addresses
IPV6_HOST1="fd00:1::2/64"
IPV6_HOST2="fd00:2::2/64"
IPV6_ROUTER1="fd00:1::1/64"
IPV6_ROUTER2="fd00:2::1/64"

# create network namespaces
function create_namespaces {
	echo "Creating network namespaces..."
	$IP netns add $NS_HOST1
	$IP netns add $NS_HOST2
	$IP netns add $NS_ROUTER
}

# delete network namespaces
function delete_namespaces {
	echo "Removing network namespaces..."
	$IP netns delete $NS_HOST1
	$IP netns delete $NS_HOST2
	$IP netns delete $NS_ROUTER
}

# add veth interfaces to network namespaces
function add_veths {
	echo "Adding veth interfaces..."

	# add veth interfaces
	$IP netns exec $NS_ROUTER $IP link add $VETH_HOST11 type veth \
		peer name $VETH_HOST12
	$IP netns exec $NS_ROUTER $IP link add $VETH_HOST21 type veth \
		peer name $VETH_HOST22

	# set mac addresses of veth interfaces
	$IP netns exec $NS_ROUTER $IP link set $VETH_HOST11 address $MAC_HOST11
	$IP netns exec $NS_ROUTER $IP link set $VETH_HOST12 address $MAC_HOST12
	$IP netns exec $NS_ROUTER $IP link set $VETH_HOST21 address $MAC_HOST21
	$IP netns exec $NS_ROUTER $IP link set $VETH_HOST22 address $MAC_HOST22

	# move second veth interfaces to other namespaces
	$IP netns exec $NS_ROUTER $IP link set $VETH_HOST12 netns $NS_HOST1
	$IP netns exec $NS_ROUTER $IP link set $VETH_HOST22 netns $NS_HOST2

	# set veth interfaces up
	$IP netns exec $NS_ROUTER $IP link set $VETH_HOST11 up
	$IP netns exec $NS_HOST1 $IP link set $VETH_HOST12 up
	$IP netns exec $NS_ROUTER $IP link set $VETH_HOST21 up
	$IP netns exec $NS_HOST2 $IP link set $VETH_HOST22 up
}

# delete veth interfaces from network namespaces
function delete_veths {
	echo "Removing veth interfaces..."
	$IP netns exec $NS_ROUTER $IP link delete $VETH_HOST11 type veth
	$IP netns exec $NS_ROUTER $IP link delete $VETH_HOST21 type veth
}

# add ip addresses to veth interfaces
function add_ips {
	echo "Adding ip addresses to veth interfaces..."

	# add ipv4 addresses to veth interfaces
	$IP netns exec $NS_HOST1 $IP address add $IPV4_HOST1 dev $VETH_HOST12
	$IP netns exec $NS_HOST2 $IP address add $IPV4_HOST2 dev $VETH_HOST22
	$IP netns exec $NS_ROUTER $IP address add $IPV4_ROUTER1 \
		dev $VETH_HOST11
	$IP netns exec $NS_ROUTER $IP address add $IPV4_ROUTER2 \
		dev $VETH_HOST21

	# add ipv6 addresses to veth interfaces
	$IP netns exec $NS_HOST1 $IP address add $IPV6_HOST1 dev $VETH_HOST12
	$IP netns exec $NS_HOST2 $IP address add $IPV6_HOST2 dev $VETH_HOST22
	$IP netns exec $NS_ROUTER $IP address add $IPV6_ROUTER1 \
		dev $VETH_HOST11
	$IP netns exec $NS_ROUTER $IP address add $IPV6_ROUTER2 \
		dev $VETH_HOST21
}

# add routing that connects veth interfaces
function add_routing {
	echo "Adding routing..."

	# enable ipv4 and ipv6 routing on router
	$IP netns exec $NS_ROUTER $SYSCTL -q -w net.ipv4.conf.all.forwarding=1
	$IP netns exec $NS_ROUTER $SYSCTL -q -w net.ipv6.conf.all.forwarding=1

	# set default ipv4 routes on hosts
	$IP netns exec $NS_HOST1 $IP route add default via ${IPV4_ROUTER1%/*} \
		dev $VETH_HOST12
	$IP netns exec $NS_HOST2 $IP route add default via ${IPV4_ROUTER2%/*} \
		dev $VETH_HOST22

	# set default ipv6 routes on hosts
	$IP netns exec $NS_HOST1 $IP -6 route add default \
		via ${IPV6_ROUTER1%/*} dev $VETH_HOST12
	$IP netns exec $NS_HOST2 $IP -6 route add default \
		via ${IPV6_ROUTER2%/*} dev $VETH_HOST22
}

# set everything up
function setup {
	create_namespaces
	add_veths
	add_ips
	add_routing
}

# tear everything down
function tear_down {
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
