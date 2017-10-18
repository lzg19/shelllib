# Table of contents
- [Basic comands](#basiccommand)
- [test](#vlanprocess)



# commands for create a new interface

```
  ip link add veth0 type veth peer name veth1
  add veth1 to the namespace
  ip netns add vm1
  ip link set veth1 netns vm1
  ip link set dev veth0 up
  ip addr add 192.168.100.0/24 dev veth0
```
# openvswitch command
## start the ovsdb-server and vswitch-d
```
sudo ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach
sudo ovs-vsctl --no-wait init
sudo ovs-vswitchd --pidfile --detach
```
## baisc commands
```
  ovs-vsctl add-br br-int -- set Bridge br-int datapath_type=netdev
  ovs-vsctl add-port br-int aa -- set Interface aa type=internal
  ovs-vsctl add-port br-int vxlan0 -- set interface vxlan0 type=vxlan options:remote_ip=172.168.1.2
```
## ovs-vsctl commands
### patch ports
```
ovs-vsctl -- add-port br0 patch0 -- set interface patch0 type=patch options:peer=patch1 \
    -- add-port br1 patch1 \
    -- set interface patch1 type=patch options:peer=patch0
```
After the above commands, br0 and br1 can communicate with each other. 
## ovs-ofctl commands
```
  ovs-ofctl dump-ports  //display all information abou the ports
```
## ovs-appctl commands
### route commands
```
ovs-appctl ovs/route/show
ovs-appctl ovs/route/add 172.168.1.1/24 br-eth1
ovs-appctl ovs/route/del <IP address>/<prefix length>
ovs-appctl ovs/route/lookup <IP address>
```
### arp commands
```
ovs-appctl tnl/arp/show
ovs-appctl tnl/arp/flush
ovs-appctl tnl/arp/set <bridge> <IP address> <MAC address>
```
### ports
```
ovs-appctl tnl/ports/show
ovs-appctl tnl/egress_port_range <num1> <num2>
ovs-appctl tnl/egress_port_range
```
### datapath
```
ovs-appctl dpif/show
ovs-appctl dpif/dump-flows
```
## test
### rspan and span test
```
ovs-vsctl add-br helloworld
ip link add first_br type veth peer name first_if
ip link add second_br type veth peer name second_if
ip link add third_br type veth peer name third_if
ovs-vsctl add-br ubuntu-br
ovs-vsctl add-port ubuntu-br first_br
ovs-vsctl add-port ubuntu-br second_br -- set port second_br tag=110
ovs-vsctl add-port helloworld second_if -- set port second_if tag=110
ovs-vsctl add-port helloworld third_br -- set port third_br tag=110
ovs-vsctl show
ip link add vnet0 type veth peer name veth0b
ip link add vnet1 type veth peer name veth1b
ip link add vnet2 type veth peer name veth2b
ip netns add vm1
ip netns add vm2
ip netns add vm3
ip netns list
ip link set veth0b netns vm1
ip link set veth1b netns vm2
ip link set veth2b netns vm3
ip netns exec vm1 ifconfig -a
ip netns exec vm1
ip netns exec vm1 bash
ip netns exec vm0 bash
ip netns exec vm2 bash
ip netns exec vm3 bash
ovs-vsctl add-port ubuntu-br vnet0
ovs-vsctl add-port ubuntu-br vnet1
ovs-vsctl add-port ubuntu-br vnet2
ovs-vsctl -- set bridge ubuntu-br mirrors=@m -- --id=@vnet0 get Port vnet0 -- --id=@first_br get Port first_br -- --id=@m create Mirror name=mirrorvnet0 select-dst-port=@vnet0 select-src-port=@vnet0 output-port=@first_br

ovs-vsctl -- set bridge ubuntu-br mirrors=@m -- --id=@vnet1 get Port vnet1 -- --id=@m create Mirror name=mirrorvnet1 select-dst-port=@vnet1 select-src-port=@vnet1 output-vlan=110

ovs-vsctl -- set bridge helloworld mirrors=@m -- --id=@m create Mirror name=mirrorvlan select-vlan=110 output-vlan=110


ovs-vsctl set bridge helloworld flood-vlans=110

ovs-vsctl clear bridge ubuntu-br mirrors
ovs-vsctl clear bridge helloworld mirrors

watch -n.5 "ovs-ofctl dump-ports helloworld"
watch -n.5 "ovs-ofctl dump-ports ubuntu-br"

ovs-vsctl clear Bridge ubuntu-br flood_vlans
ovs-vsctl clear Bridge helloworld flood_vlans
```
### vlan tag test
```
ovs-vsctl add-br br0
ovs-vsctl -- add-port br0 first_br \
  -- add-port br0 second_br \
  -- add-port br0 third_br

ovs-vsctl add-port br0 vnet0 -- set port vnet0 tag=101
ovs-vsctl add-port br0 vnet1 -- set port vnet1 tag=102
ovs-vsctl add-port br0 vnet2 -- set port vnet2 tag=103
ovs-vsctl set port first_br tag=103
ovs-vsctl set port third_br trunks=101,102
ovs-vsctl set bridge br0 flood-vlans=101,102,103

ifconfig first_if 192.168.100.103
ifconfig second_if 192.168.100.104
ifconfig third_if 192.168.100.105


\\\\\\\\\\\\\\\\\\\

ovs-vsctl clear Bridge br0 flood_vlans 
ovs-vsctl list Port
ovs-vsctl clear Port vnet1 tag
ovs-vsctl clear Port vnet0 tag
ovs-vsctl clear Port first_br tag
ovs-vsctl clear Port third_br trunks

```
The principle to process the vlan is as the following:

trunk ports:

1. no 'tag' configuration. only trunks configuration.

2. if trunks is not null, only the vid which is in the trunks [] could be forwarded.

3. if trunks is null, all packets will be forwarded. For the ports without vid, vlan 0 will be assigned, it means no vlan. Otherwise, the orignial vlan will be forwarded.

access ports:

1. only 'tag' configuration, no 'trunks' configuration.

2. ports ingress from trunk ports, whose vid is same to 'tag', will be forwarded to this port

3. other access ports with same 'tag' configuration, will forward port to this port.

4. only untag packets can be accepted by this port.
  
### bond test
```
ip link add vnet3 type veth peer name veth3

ovs-vsctl add-br br0
ovs-vsctl add-br br1
ovs-vsctl -- add-port br0 vnet0 \
  -- add-port br0 vnet1 
ovs-vsctl -- add-port br1 vnet2 \
  -- add-port br1 vnet3

ovs-vsctl add-bond br0 bond0 first_br second_br

ovs-vsctl add-bond br0 bond0 first_br second_br
ovs-vsctl set port bond0 lacp=active
ovs-vsctl set port bond1 lacp=active

ovs-vsctl set port bond0 bond_mode=balance_tcp
ovs-vsctl set port bond1 bond_mode=balance_tcp
```
Then we can use netserver and netperf to do test.

### openvswitch qos test
```
vnet1   vnet2   vnet3
  |       |       |
|--------------------|
|       br0          |
|--------------------|
      first_br
         |
      first_if
|--------------------|
|        br1         |
|--------------------|
        vnet3
```
configuration is as the following:
```
ovs-vsctl set Interface first_if ingress_policing_rate=100000
ovs-vsctl set Interface first_if ingress_policing_burst=10000

ovs-vsctl set Interface first_if ingress_policing_burst=0 
ovs-vsctl set Interface first_if ingress_policing_rate=0
ovs-vsctl list interface first_if

ovs-vsctl set port first_br qos=@newqos -- --id=@newqos create qos type=linux-htb other-config:max-rate=10000000 queues=0=@q0,1=@q1,2=@q2 -- --id=@q0 create queue other-config:min-rate=3000000 other-config:max-rate=10000000 -- --id=@q1 create queue other-config:min-rate=1000000 other-config:max-rate=10000000 -- --id=@q2 create queue other-config:min-rate=6000000 other-config:max-rate=10000000

ovs-ofctl add-flow br0 "in_port=1 nw_src=192.168.100.1 actions=enqueue:6:0" 
ovs-ofctl add-flow br0 "in_port=2 nw_src=192.168.100.2 actions=enqueue:6:1" 
ovs-ofctl add-flow br0 "in_port=5 nw_src=192.168.100.3 actions=enqueue:6:2"

ovs-ofctl del-flows br0 "in_port=1 nw_src=192.168.100.1"
ovs-ofctl del-flows br0 "in_port=2 nw_src=192.168.100.2"
ovs-ofctl del-flows br0 "in_port=5 nw_src=192.168.100.3"
```
### tunnel test
```
//vxlan configuration
//for host1
ovs-vsctl add-br br0
ifconfig br0 10.0.0.1/24
ovs-vsctl add-port br0 vxlan0 -- set interface vxlan0 type=vxlan options:local_ip=192.168.5.166 options:remote_ip=192.168.5.168

//for host2
ovs-vsctl add-br br0
ifconfig br0 10.0.0.2/24
ovs-vsctl add-port br0 vxlan0 -- set interface vxlan0 type=vxlan options:local_ip=192.168.5.168 options:remote_ip=192.168.5.166

//detele command
ovs-vsctl del-port br0 vxlan0

//ipsec configuration
//host0  ???, weird, here the ipsec could not work
ovs-vsctl add-port br0 ipsec0 -- set interface ipsec0 type=ipsec-gre options:local_ip=192.168.5.166 options:remote_ip=192.168.5.168 options:psk=password

//host1
ovs-vsctl add-port br0 ipsec0 -- set interface ipsec0 type=ipsec_gre options:local_ip=192.168.5.168 options:remote_ip=192.168.5.166 options:psk=password

//gre tunnel
//host1
ovs-vsctl add-port br0 gre0 -- set Interface gre0 type=gre options:local_ip=192.168.5.166 options:remote_ip=192.168.5.168

//host2， here, gre is protocol of 0x2f(47)
ovs-vsctl add-port br0 gre0 -- set Interface gre0 type=gre options:local_ip=192.168.5.168 options:remote_ip=192.168.5.166

ovs-vsctl del-port br0 gre0
```
### spanning-tree
very weird thing here.

### openstack test
we only have 2 hosts. so the topology is as the following
step1: topology
```
  (10.0.0.1)   (10.0.1.1)
    vnet0b      vnet1b
      |           |
    vnet0a      vnet1a
      |(tag1)     |(tag2)
  |---------------------|
  |       br-int        |
  |---------------------|
            |
          vnet2a
            |
          vnet2b
            |
  |---------------------|
  |       br-tun        |
  |---------------------|
            |
           gre0  
```
step2: basic configuration
```
//host1
ip link add vnet0a type veth peer name vnet0b
ip link add vnet1a type veth peer name vnet1b
ip link add vnet2a type veth peer name vnet2b
ip link set vnet0a up
ip link set vnet0b up
ip link set vnet1a up
ip link set vnet1b up
ip link set vnet2a up
ip link set vnet2b up
ovs-vsctl add-br br-int
ovs-vsctl add-br br-tun

ovs-vsctl add-port br-int vnet2a
ovs-vsctl add-port br-int vnet0b
ovs-vsctl add-port br-int vnet1b
ovs-vsctl add-port br-tun vnet2b

ovs-vsctl set port vnet0b tag=1
ovs-vsctl set port vnet1b tag=2

ifconfig vnet0a 10.0.0.1/24
ifconfig vnet1a 10.0.1.1/24

ovs-vsctl add-port br-tun gre0 -- set interface gre0 type=gre options:local_ip=192.168.5.166 options:in_key=flow options:remote_ip=192.168.5.168 options:out_key=flow

//host2
ifconfig vnet0a 10.0.0.2/24
ifconfig vnet1a 10.0.1.2/24

ovs-vsctl add-port br-tun gre0 -- set interface gre0 type=gre options:local_ip=192.168.5.168 options:in_key=flow options:remote_ip=192.168.5.166 options:out_key=flow
```

step3: openflow operations

```
//here, assume vnet2b's ofport is 1 in openflow view, gre's ofport is 2 for host1
//for host2, vnet2b's ofport is 1, gre0's is 2
ovs-ofctl del-flows br-tun
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 in_port=1 actions=resubmit(,1)"
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 in_port=2 actions=resubmit(,3)"
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=0 actions=drop"

ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 table=1 dl_dst=00:00:00:00:00:00/01:00:00:00:00:00 actions=resubmit(,20)"

ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 table=1
dl_dst=01:00:00:00:00:00/01:00:00:00:00:00 actions=resubmit(,21)"

ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=0 table=2 actions=drop"
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=0 table=3 actions=drop"
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 table=3 tun_id=0x1 actions=mod_vlan_vid:1,resubmit(,10)"
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 table=3 tun_id=0x2 actions=mod_vlan_vid:2,resubmit(,10)"

ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 table=10 actions=learn(table=20,priority=1,hard_timeout=300,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:NXM_OF_IN_PORT[]),output:1"

ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=0 table=20 actions=resubmit(,21)"
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=0 table=21 actions=drop"
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 table=21 dl_vlan=1 actions=strip_vlan,set_tunnel:0x1,output:2"
ovs-ofctl add-flow br-tun "hard_timeout=0 idle_timeout=0 priority=1 table=21 dl_vlan=2 actions=strip_vlan,set_tunnel:0x2,output:2"
```

### vlan process test <a name="vlanprocess"></a>
configuration
```
//basic configuration
ovs-vsctl add-br br0
ip link add first_br type veth peer name first_if
ip link add second_br type veth peer name second_if 
ip link add third_br type veth peer name third_if
ip link add forth_br type veth peer name forth_if

ovs-vsctl add-port br0 first_br -- set Interface first_br ofport_request=1 
ovs-vsctl add-port br0 second_br -- set Interface second_br ofport_request=2 
ovs-vsctl add-port br0 third_br -- set Interface third_br ofport_request=3 
ovs-vsctl add-port br0 forth_br -- set Interface forth_br ofport_request=4

ip link set first_if up
ip link set first_br up
ip link set second_br up 
ip link set second_if up 
ip link set third_if up
ip link set third_br up 
ip link set forth_br up 
ip link set forth_if up

//flow configuration
//drop mutlicast packets
ovs-ofctl add-flow br0 "table=0, dl_src=01:00:00:00:00:00/01:00:00:00:00:00, actions=drop"

//drop bpdu packets
//table 0 configuraiton
ovs-ofctl add-flow br0 "table=0, dl_dst=01:80:c2:00:00:00/ff:ff:ff:ff:ff:f0, actions=drop"

ovs-ofctl add-flow br0 "table=0, priority=0, actions=resubmit(,1)"

//table 1 configuration
ovs-ofctl add-flow br0 "table=1, priority=0, actions=drop"

ovs-ofctl add-flow br0 "table=1, priority=99, in_port=1, actions=resubmit(,2)"

ovs-ofctl add-flow br0 "table=1, priority=99, in_port=2, vlan_tci=0, actions=mod_vlan_vid:20, resubmit(,2)" 

ovs-ofctl add-flow br0 "table=1, priority=99, in_port=3, vlan_tci=0, actions=mod_vlan_vid:30, resubmit(,2)"

ovs-ofctl add-flow br0 "table=1, priority=99, in_port=4, vlan_tci=0, actions=mod_vlan_vid:30, resubmit(,2)"

//table 2 configuration
ovs-ofctl add-flow br0 "table=2 actions=learn(table=10, NXM_OF_VLAN_TCI[0..11], NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[], load:NXM_OF_IN_PORT[]->NXM_NX_REG0[0..15]), resubmit(,3)"

//table 3 configuration
ovs-ofctl add-flow br0 "table=3 priority=50 actions=resubmit(,10), resubmit(,4)"

ovs-ofctl add-flow br0 "table=3 priority=99 dl_dst=01:00:00:00:00:00/01:00:00:00:00:00 actions=resubmit(,4)"

//table 4 conf
ovs-ofctl add-flow br0 "table=4 reg0=1 actions=1"
ovs-ofctl add-flow br0 "table=4 reg0=2 actions=strip_vlan,2"
ovs-ofctl add-flow br0 "table=4 reg0=3 actions=strip_vlan,3"
ovs-ofctl add-flow br0 "table=4 reg0=4 actions=strip_vlan,4"

ovs-ofctl add-flow br0 "table=4 reg0=0 priority=99 dl_vlan=20 actions=1,strip_vlan,2"
ovs-ofctl add-flow br0 "table=4 reg0=0 priority=99 dl_vlan=30 actions=1,strip_vlan,3,4"
ovs-ofctl add-flow br0 "table=4 reg0=0 priority=50 actions=1"


//debug
ovs-appctl ofproto/trace br0 in_port=1,dl_dst=01:80:c2:00:00:05

ovs-appctl ofproto/trace br0 in_port=1,dl_dst=01:80:c2:00:00:10

ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=5

ovs-appctl ofproto/trace br0 in_port=2

ovs-appctl ofproto/trace br0 in_port=2,vlan_tci=5

ovs-appctl ofproto/trace br0 in_port=1,vlan_tci=20,dl_src=50:00:00:00:00:01 -generate 
ovs-ofctl dump-flows br0

ovs-appctl ofproto/trace br0 in_port=2,dl_src=50:00:00:00:00:02 -generate

ovs-ofctl dump-flows br0


//test for table 3
ovs-appctl ofproto/trace br0 in_port=1,dl_vlan=20,dl_src=f0:00:00:00:00:01,dl_dst=90:00:00:00:00:01 -generate

ovs-appctl ofproto/trace br0 in_port=2,dl_src=90:00:00:00:00:01,dl_dst=f0:00:00:00:00:01 -generate

//test table4
ovs-appctl ofproto/trace br0 in_port=1,dl_dst=ff:ff:ff:ff:ff:ff,dl_vlan=30

ovs-appctl ofproto/trace br0 in_port=3,dl_dst=ff:ff:ff:ff:ff:ff

ovs-appctl ofproto/trace br0 in_port=1,dl_vlan=30,dl_src=10:00:00:00:00:01,dl_dst=20:00:00:00:00:01 -generate
ovs-appctl ofproto/trace br0 in_port=4,dl_src=20:00:00:00:00:01,dl_dst=10:00:00:00:00:01 -generate

ip link del dev first_br
ip link del dev second_br
ip link del dev third_br
ip link del dev forth_br

ip link del dev vnet0a
ip link del dev vnet1a
ip link del dev vnet2a
ip link del dev vnet3a

```

### userspace vxlan test
topology
```
    +--------------+
    |     vm0      | 192.168.1.1/24
    +--------------+
      (vm_port0)
          |
          |
          |
    +--------------+
    |    br-int    |                                    192.168.1.2/24
    +--------------+                                   +--------------+
    |    vxlan0    |                                   |    vxlan0    |
    +--------------+                                   +--------------+
          |                                                  |
          |                                                  |
          |                                                  |
    172.168.1.1/24                                           |
    +--------------+                                          |
    |    br-phy    |                                   172.168.1.2/24
    +--------------+                                  +---------------+
    |  dpdk0/eth1  |----------------------------------|      eth1     |
    +--------------+                                  +---------------+
    Host A with OVS.                                     Remote host.
```
configuration
```
ip link add first_br type veth peer name first_if
ovs-vsctl --may-exist add-br br-int \
  -- set Bridge br-int datapath_type=netdev \
  -- br-set-external-id br-int bridge-id br-int \
  -- set bridge br-int fail-mode=standalone

ip link set first_if up
ip link set first_br up
ifconfig first_br 10.0.0.1/24
ovs-vsctl add-port br-int first_br
ovs-vsctl add-port br-int vxlan0 -- set interface vxlan0 type=vxlan options:remote_ip=192.168.5.166

ovs-vsctl --may-exist add-br br-phy \
    -- set Bridge br-phy datapath_type=netdev \
    -- br-set-external-id br-phy bridge-id br-phy \
    -- set bridge br-phy fail-mode=standalone \
         other_config:hwaddr=00:0c:29:01:65:41

ovs-vsctl add-port br-int vxlan0 \
  -- set interface vxlan0 type=vxlan options:remote_ip=172.168.1.2
```

Any, after the above test, this could work.

