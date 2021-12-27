#!/bin/bash

# Запускать в папке проекта (/opt/web)
sudo apt-get update
sudo apt install -y docker.io
sudo apt install -y docker-compose
cd /opt/web_iiot

# сконфигурируем сервис
sudo ln -s /opt/web_iiot/web_iiot.service /etc/systemd/system/web_iiot.service
sudo chmod 777 /etc/systemd/system/web_iiot.service
sudo systemctl daemon-reload

# добавим в автозагрузку
sudo systemctl enable web_iiot
sudo systemctl enable docker

sudo docker build -t web_iiot .
sudo docker run -p 443:5000 --name web -d web_iiot