FROM ubuntu

EXPOSE 80
EXPOSE 5000

COPY . /app
WORKDIR /app

RUN apt-get update -y \
&& apt install -y python3-pip \
&& apt install -y python3-venv \
&& python3 -m venv db_server \
&& chmod +x run.sh

ENTRYPOINT ["bash", "./run.sh"]