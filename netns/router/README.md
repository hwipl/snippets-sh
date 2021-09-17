# router

This script sets up two network namespaces connected by a router in a third
network namespace and configures MAC, IPv4 and IPv6 addresses on all virtual
ethernet interfaces:

```
+--------------+                  +--------------+
|   ns-host1   |                  |   ns-host2   |
|              |                  |              |
+-[veth-host1]-+                  +-[veth-host2]-+
       |                                 |
       |________                 ________|
                |               |
        +-[veth-router1]-[veth-router2]-+
        |       |_______________|       |
        |                               |
        |           ns-router           |
        +-------------------------------+
```

## Usage

```
./router.sh setup|teardown
```

Configuration of `router.sh` is at the top of the script:

```bash
# name of network namespaces
NS_HOST1="router-host1"
NS_HOST2="router-host2"
NS_ROUTER="router-router1"

# veth interfaces
VETH_HOST1="eth0"
VETH_HOST2="eth0"
VETH_ROUTER1="router-host1"
VETH_ROUTER2="router-host2"

# mac addresses
MAC_HOST1="0a:bc:de:f0:00:01"
MAC_HOST2="0a:bc:de:f0:00:02"
MAC_ROUTER1="0a:bc:de:f0:00:f1"
MAC_ROUTER2="0a:bc:de:f0:00:f2"

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
```

## Examples

Setting up:

```console
$ sudo ./router.sh setup
```

Tearing down:

```console
$ sudo ./router.sh teardown
```

Pinging second from first host with default configuration and IPv4:

```console
$ sudo ip netns exec router-host1 ping 192.168.2.2
```

Pinging second from first host with default configuration and IPv6:

```console
$ sudo ip netns exec router-host1 ping fd00:2::1
```
