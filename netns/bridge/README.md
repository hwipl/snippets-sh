# bridge

This script sets up two network namespaces connected by a bridge in a third
network namespace and configures MAC, IPv4 and IPv6 addresses on the virtual
ethernet interfaces and the bridge:

```
+--------------+                  +--------------+
|   ns-host1   |                  |   ns-host2   |
|              |                  |              |
+-[veth-host1]-+                  +-[veth-host2]-+
       |                                 |
       |________                 ________|
                |               |
        +-[veth-bridge1]-[veth-bridge2]-+
        |          [bridge-dev]         |
        |                               |
        |           ns-bridge           |
        +-------------------------------+
```

## Usage

```
./bridge.sh setup|teardown
```

Configuration of `bridge.sh` is at the top of the script:

```bash
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
MAC_HOST1="0a:bc:de:f0:00:01"
MAC_HOST2="0a:bc:de:f0:00:02"
MAC_BRIDGE1="0a:bc:de:f0:00:b1"
MAC_BRIDGE2="0a:bc:de:f0:00:b2"

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
```

## Examples

Setting up:

```console
$ sudo ./bridge.sh setup
```

Tearing down:

```console
$ sudo ./bridge.sh teardown
```

Pinging second from first host with default configuration and IPv4:

```console
$ sudo ip netns exec bridge-host1 ping 192.168.1.2
```

Pinging second from first host with default configuration and IPv6:

```console
$ sudo ip netns exec bridge-host1 ping fd00::2
```
