# bridge

This script sets up two network namespaces connected by a bridge and configures
MAC, IPv4 and IPv6 addresses on the virtual ethernet interfaces and the bridge:

```
+----------+               +----------+
| ns-host1 |               | ns-host2 |
|          |               |          |
+-[veth12]-+               +-[veth22]-+
     |                          |
     |________          ________|
              |        |
        +--[veth11]-[veth21]--+
        |        bridge       |
        +---------------------+

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

# bridge interface
BRIDGE_DEV="netnsbr0"

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
