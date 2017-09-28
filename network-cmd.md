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
## baisc commands
```
  ovs-vsctl add-br br-int -- set Bridge br-int datapath_type=netdev
  ovs-vsctl add-port br-int aa -- set Interface aa type=internal
```
## ovs-ofctl commands
```
  ovs-ofctl dump-ports  //display all information abou the ports
```

## ovs-appctl commands
```
```
  
  

  

  
