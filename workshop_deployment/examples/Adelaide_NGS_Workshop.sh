#!/bin/bash
TRAINEE_USER='ngstrainee'
RO_DROP_CANVAS_URL='http://dropcanvas.com/ypavx'
TIME_ZONE="Australia/Adelaide"

wget https://github.com/nathanhaigh/ngs_workshop/raw/master/workshop_deployment/NGS_workshop_deployment.sh
bash NGS_workshop_deployment.sh

# set the timezone
echo "$TIME_ZONE" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# set things up from the trainee's perspective
sudo su $TRAINEE_USER
# Home and Desktop symlinks to the workshop's working directory
if [[ ! -e "/home/$TRAINEE_USER/Desktop" ]]; then
mkdir --mode=755 /home/$TRAINEE_USER/Desktop
fi
echo "[Desktop Entry]
Name=NGS dropcanvas
Type=Application
Encoding=UTF-8
Comment=A dropcanvas for NGS workshop materials
Exec=firefox $RO_DROP_CANVAS_URL
Icon=/usr/lib/firefox/icons/mozicon128.png
Terminal=FALSE" > /home/$TRAINEE_USER/Desktop/NGSdropcanvas.desktop
chmod 700 /home/$TRAINEE_USER/Desktop/NGSdropcanvas.desktop
chown $TRAINEE_USER:$TRAINEE_USER /home/$TRAINEE_USER/Desktop/NGSdropcanvas.desktop

apt-get update
apt-get -y upgrade

touch /home/ubuntu/cloud_init.finished
