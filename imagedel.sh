#!/bin/bash

GC_SIZE=31457280
DOCKER_STORAGE_SIZE=`sudo du -s /var/lib/docker/devicemapper|awk '{print $1}'`
DOCKER_IMAGE_LIST=`sudo docker images|grep -v -e "IMAGE ID" -e "seconds" -e "minute"  -e "hours" -e "days" -e "1 weeks ago" -e "2 weeks ago"|awk '{print $3}'`
DATE=$(date +%Y%m%d)

echo $DOCKER_STORAGE_SIZE > /home/devuser/danli/imagesize.txt
if [ "$DOCKER_STORAGE_SIZE" -gt "$GC_SIZE" ]
    then sudo docker rmi `sudo docker images -q -f "dangling=true"`
    else echo $DATE docker storage size `sudo du -s /var/lib/docker/devicemapper|awk '{print $1}'` Do not need to delete. >> /home/devuser/danli/imagedel.txt
         exit 0
fi

if [ "`sudo du -s /var/lib/docker/devicemapper|awk '{print $1}'`" -gt "$GC_SIZE" ]
    then sudo docker rmi $DOCKER_IMAGE_LIST
         DELSIZE=$((`cat /home/devuser/danli/imagesize.txt`-`sudo du -s /var/lib/docker/devicemapper|awk '{print $1}'`))
         echo $DATE docker storage   size `cat /home/devuser/danli/imagesize.txt` KB >> /home/devuser/danli/imagedel.txt
         echo $DATE docker storage deleted $DELSIZE KB >> /home/devuser/danli/imagedel.txt
    else echo $DATE docker storage size `sudo du -s /var/lib/docker/devicemapper|awk '{print $1}'` Do not need to delete. >> /home/devuser/danli/imagedel.txt
         exit 0
fi

if [ "`sudo du -s /var/lib/docker/devicemapper|awk '{print $1}'`" -gt "$GC_SIZE" ]
     then echo $DATE docker storage size greater than 30GB. Please delete it manually. >> /home/devuser/danli/imagedel.txt
#    curl http://xxx.xxx.xx.xx:2379/v2/keys/$DATE -XPUT -d dir=true
#    curl http://xxx.xxx.xx.xx:2379/v2/keys/$DATE/`hostname` -XPUT -d value=0 -d ttl=30
fi
