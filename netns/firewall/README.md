# firewall

This script sets up two network namespaces connected by a firewall in a third
network namespace and configures MAC, IPv4 and IPv6 addresses on all virtual
ethernet interfaces and packet filter rules on the firewall:

```
+--------------+                    +--------------+
|   ns-host1   |                    |   ns-host2   |
|              |                    |              |
+-[veth-host1]-+                    +-[veth-host2]-+
       |                                   |
       |________                   ________|
                |                 |
       +-[veth-firewall1]-[veth-firewall2]-+
       |        |_________________|        |
       |                                   |
       |            ns-firewall            |
       +-----------------------------------+
```

## Usage

```
./firewall.sh setup|teardown
```

Configuration of `firewall.sh` is at the top of the script:

```bash
# name of network namespaces
NS_HOST1="firewall-host1"
NS_HOST2="firewall-host2"
NS_FIREWALL="firewall-fw1"

# veth interfaces
VETH_HOST1="eth0"
VETH_HOST2="eth0"
VETH_FIREWALL1="fw-host1"
VETH_FIREWALL2="fw-host2"

# mac addresses
MAC_HOST1="0a:bc:de:f0:00:01"
MAC_HOST2="0a:bc:de:f0:00:02"
MAC_FIREWALL1="0a:bc:de:f0:00:f1"
MAC_FIREWALL2="0a:bc:de:f0:00:f2"

# ipv4 addresses
IPV4_HOST1="192.168.1.2/24"
IPV4_HOST2="192.168.2.2/24"
IPV4_FIREWALL1="192.168.1.1/24"
IPV4_FIREWALL2="192.168.2.1/24"

# ipv6 addresses
IPV6_HOST1="fd00:1::2/64"
IPV6_HOST2="fd00:2::2/64"
IPV6_FIREWALL1="fd00:1::1/64"
IPV6_FIREWALL2="fd00:2::1/64"

# firewall rules
declare -a FIREWALL_RULES=(
"iptables -P INPUT DROP"
"iptables -P OUTPUT DROP"
"iptables -P FORWARD DROP"
"iptables -A FORWARD -i $VETH_FIREWALL1 -o $VETH_FIREWALL2 \
	-s $IPV4_HOST1 -d $IPV4_HOST2 -p icmp -j ACCEPT"
"iptables -A FORWARD -i $VETH_FIREWALL2 -o $VETH_FIREWALL1 \
	-s $IPV4_HOST2 -d $IPV4_HOST1 -p icmp -j ACCEPT"

"ip6tables -P INPUT DROP"
"ip6tables -A INPUT -p icmpv6 -j ACCEPT"
"ip6tables -P OUTPUT DROP"
"ip6tables -A OUTPUT -p icmpv6 -j ACCEPT"
"ip6tables -P FORWARD DROP"
"ip6tables -A FORWARD -i $VETH_FIREWALL1 -o $VETH_FIREWALL2 \
	-s $IPV6_HOST1 -d $IPV6_HOST2 -p icmpv6 -j ACCEPT"
"ip6tables -A FORWARD -i $VETH_FIREWALL2 -o $VETH_FIREWALL1 \
	-s $IPV6_HOST2 -d $IPV6_HOST1 -p icmpv6 -j ACCEPT"
)
```

## Examples

Setting up:

```console
$ sudo ./firewall.sh setup
```

Tearing down:

```console
$ sudo ./firewall.sh teardown
```

Pinging second from first host with default configuration and IPv4:

```console
$ sudo ip netns exec firewall-host1 ping 192.168.2.2
```

Pinging second from first host with default configuration and IPv6:

```console
$ sudo ip netns exec firewall-host1 ping fd00:2::1
```
