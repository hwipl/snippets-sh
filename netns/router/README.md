# router

This script sets up two network namespaces connected by a router in a third
network namespace and configures MAC, IPv4 and IPv6 addresses on all virtual
ethernet interfaces:

```
+----------+               +----------+
| ns-host1 |               | ns-host2 |
|          |               |          |
+-[veth12]-+               +-[veth22]-+
     |                          |
     |________          ________|
              |        |
        +--[veth11]-[veth21]--+
        |        router       |
        +---------------------+

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
