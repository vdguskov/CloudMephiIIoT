#!/bin/bash

# Запускать в папке проекта (/opt/web)
sudo apt-get update

sudo apt install -y python3-pip
sudo apt install -y python3-venv
sudo apt install postgresql postgresql-contrib

# создадим виртуальное окружение и установим в него зависимости согласно requirements.txt
python3 -m venv web_server

source web_server/bin/activate

pip install -r requirements.in

deactivate

# дадим право на исполнение скрипта запуска
sudo chmod +x run.sh

# сконфигурируем сервис
sudo ln -s /opt/db_iiot/web_iiot.service /etc/systemd/system/web_iiot.service
sudo chmod 777 /etc/systemd/system/web_iiot.service
sudo systemctl daemon-reload

# добавим в автозагрузку
sudo systemctl enable web_iiot
