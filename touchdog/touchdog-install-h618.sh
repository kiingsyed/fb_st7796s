sudo cp touchdog-h618.sh /usr/local/bin/touchdog.sh
sudo cp touchdog.service /etc/systemd/system/
sudo chmod +x /usr/local/bin/touchdog.sh
sudo systemctl enable touchdog.service