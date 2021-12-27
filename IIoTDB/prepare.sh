#!/bin/bash

# Запускать в папке проекта (/opt/web)
sudo apt-get update
sudo apt install -y docker.io
sudo apt install -y docker-compose

cd /opt/db_iiot
# дадим право на исполнение скрипта запуска
sudo chmod +x run.sh

# сконфигурируем сервис
sudo ln -s /opt/db_iiot/db_iiot.service /etc/systemd/system/db_iiot.service
sudo chmod 777 /etc/systemd/system/db_iiot.service
sudo systemctl daemon-reload

# добавим в автозагрузку
sudo systemctl enable db_iiot
sudo systemctl enable docker

sudo docker-compose up --build -d
