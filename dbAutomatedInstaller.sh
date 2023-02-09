#!/bin/sh
MOSQUITTOpwdTemplateF=/etc/mosquitto/dbun.txt
MOSQUITTOpwdF=/etc/mosquitto/pwd
MOSQUITTOconf=/etc/mosquitto/mosquitto.conf
MOSQUITTOerror="None"
clear
echo "Duurzame Bouwkeet automated installer v1"
echo "® Duurzame Bouwkeet 2023"
sleep 3s

echo "Starting installer.."
sleep 2s
clear
echo "Updating repositories to prepare for base software installation"
sleep 1s
sudo apt-get update -y
sudo apt install openvpn chromium-browser mosquitto mosquitto-clients -y
clear
echo "Configuring Mosquitto"
sleep 1s
if [ test -f "$MOSQUITTOpwdF" ] 
then
    sudo rm -rf $MOSQUITTOpwdF
    if [test -f "$MOSQUITTOpwdTemplateF"]
    then
        sudo rm -rf $MOSQUITTOpwdF
        touch $MOSQUITTOpwdTemplateF
        read -P 'MQTT username: ' MQTTUSER
        read -P 'MQTT password: ' MQTTPASS
        echo "$MQTTUSER:$MQTTPASS" tee $MOSQUITTOpwdTemplateF
    else
        touch $MOSQUITTOpwdTemplateF
        echo "$MQTTUSER:$MQTTPASS" tee $MOSQUITTOpwdTemplateF
    fi
    mosquitto_passwd -U $MOSQUITTOpwdTemplateF
    if [ test -f "$MOSQUITTOpwdF"]
    then 
        rm -rf $MOSQUITTOpwdTemplateF
        mv $MOSQUITTOconf /etc/mosquitto.conf.bak
        touch $MOSQUITTOconf
        printf "pid_file /run/mosquitto/mosquitto.pid \npersistence true \npersistence_location /var/lib/mosquitto/ \nlog_dest file /var/log/mosquitto/mosquitto.log\ninclude_dir /etc/mosquitto/conf.d" >> $MOSQUITTOconf
    else
        echo MOSQUITTOerror="Error creating password file for MOSQUITTO.."
    fi
fi 
echo "Creating Zigbee2MQTT directory"
mkdir -p /zigbee2mqtt
wget https://raw.githubusercontent.com/Koenkk/zigbee2mqtt/master/data/configuration.yaml -P /zigbee2mqtt/data
clear
echo "Downloading Docker"
sleep 1s
curl -fsSL https://get.docker.com -o /home/pi/Downloads/get-docker.sh
source /home/pi/Downloads/get-docker.sh
echo "Downloading Node-Red"
sudo -H -u pi source <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --node18
echo "Setting up KIOSK mode and configuring Node-Red Dashboard as page on boot"
echo "@xset s off" | tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo "@xset -dpms" tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo "@xset s noblank" tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo "@chromium-browser --kiosk http://127.0.0.1:1880/ui" tee -a /etc/xdg/lxsession/LXDE-pi/autostart
clear
echo "Dont forget to follow steps for configure and install Zigbee2MQTT!!"
sleep 2s
echo "Done. Check output files to see if they are correct. If not change them before rebooting!"
sleep 10s
clear
cat $MOSQUITTOconf
sleep 5s
cat /etc/xdg/lxsession/LXDE-pi/autostart
echo "Dont forget to follow steps for configure and install Zigbee2MQTT!!"
break;;