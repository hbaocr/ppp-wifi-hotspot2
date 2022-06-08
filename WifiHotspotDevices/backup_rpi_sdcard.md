# list all disk 
```
df -h
--->
Filesystem       Size   Used  Avail Capacity iused      ifree %iused  Mounted on
/dev/disk4s1s1  463Gi   14Gi  218Gi     7%  500637 2280725800    0%   /
devfs           353Ki  353Ki    0Bi   100%    1220          0  100%   /dev
/dev/disk4s6    463Gi   20Ki  218Gi     1%       0 2280725800    0%   /System/Volumes/VM
/dev/disk4s2    463Gi  384Mi  218Gi     1%    1275 2280725800    0%   /System/Volumes/Preboot
/dev/disk4s4    463Gi  5.6Mi  218Gi     1%      44 2280725800    0%   /System/Volumes/Update
/dev/disk1s2    500Mi  6.0Mi  480Mi     2%       1    4913640    0%   /System/Volumes/xarts
/dev/disk1s1    500Mi  7.4Mi  480Mi     2%      30    4913640    0%   /System/Volumes/iSCPreboot
/dev/disk1s3    500Mi  2.0Mi  480Mi     1%      51    4913640    0%   /System/Volumes/Hardware
/dev/disk4s5    463Gi  230Gi  218Gi    52% 1954180 2280725800    0%   /System/Volumes/Data
/dev/disk3s1    463Gi   82Gi  381Gi    18% 1532635 3994563280    0%   /Volumes/Data
map auto_home     0Bi    0Bi    0Bi   100%       0          0  100%   /System/Volumes/Data/home
/dev/disk5s1    252Mi   31Mi  221Mi    13%       0          0  100%   /Volumes/boot
```
#/dev/disk5s1  ---> this is the logical Volumes Boot on /dev/disk5 disk. Need to backup physical disk /dev/disk5 sector by sector
#===> check physical sdcard /dev/disk5
ls /dev/disk5

#to backup
#sudo dd bs=4m if=/dev/disk5 of=rpi4-ppp-dial.img

#to write: can  use banana etcher to write