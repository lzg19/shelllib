# samba configuration
## ubuntu 16.04
```
  sudo apt-get install samba
  sudo smbpasswd add -a lizg
```
Then open the /etc/samba/smb.conf file, add the following to the end of the file
```
  [share]
  path=/home/xxx
  valid users=lizg
  read only=no
```
After that, restart the smb service,
```
  sudo service smbd restart
```
Finally, the samba should work now
