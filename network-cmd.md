# commands for create a new interface
```
  ip link add veth0 type veth peer name veth1
  add veth1 to the namespace
  ip netns add vm1
  ip link set set veth1 netns vm1
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
  
  

  

  
