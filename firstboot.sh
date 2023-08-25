#!/bin/sh
sudo su root
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py
apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false
sudo apt-get install -y git unzip
wget -O svctodownload.txt https://raw.githubusercontent.com/the-one-with-raspberry/temp-hum-bucket/main/services.txt?token=GHSAT0AAAAAACGC34CZAUSS5SWQFEKXVAM4ZHFZJOQ
wget -i svctodownload.txt
mv *.service /etc/systemd/system
rm svctodownload.txt
wget -O temp-hum-sensor-backend.zip https://github.com/the-one-with-raspberry/temp-hum-sensor-backend/archive/refs/heads/main.zip
unzip temp-hum-sensor-backend.zip
rm temp-hum-sensor-backend.zip
mv temp-hum-sensor-backend-main/ temp-hum-sensor-backend/
sudo systemctl enable dbupdate
sudo systemctl enable suserv
sudo raspi-config nonint do_boot_wait 0