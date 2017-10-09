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
# ssh server
```
sudo apt-get install openssh-server
```
If we want to configure it, do the following:
```
sudo cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
sudo nano /etc/ssh/sshd_config
```
