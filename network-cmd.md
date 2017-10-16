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
ovs-vsctl add-port ubuntu-br third_br -- set port third_br tag=110
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
```
  

  

  
