terraform {
  required_version = ">= 1.0.0"

  required_providers {
    rustack = {
      source  = "pilat/rustack"
      version = "~> 0.1"
    }
  }
}

provider "rustack" {
    api_endpoint = var.rustack_endpoint
    token = var.rustack_token
}

# Получение id проекта
data "rustack_project" "iiot_project" {
    name = "IIoT Project"
}

# Получение id гипервизора
data "rustack_hypervisor" "iiot_hypervisor" {
    project_id = data.rustack_project.iiot_project.id
    name = "KVM"
}

# Создвние ВЦОД
resource "rustack_vdc" "vdc1" {
    name = "KVM IIoT"
    project_id = data.rustack_project.iiot_project.id
    hypervisor_id = data.rustack_hypervisor.iiot_hypervisor.id
}

# Получение id сети
data "rustack_network" "service_network" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Сеть"
}

# Получение id диска
data "rustack_storage_profile" "ocfs2" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "ocfs2"
}

# Получение id шаблона Ubuntu
data "rustack_template" "ubuntu20" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Ubuntu 20.04"
}

# Получение id брэнмаузера для исходящих потоков
data "rustack_firewall_template" "allow_default" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "По-умолчанию"
}

# Получение id брэнмаузера для исходящих потоков
data "rustack_firewall_template" "allow_ssh" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Разрешить SSH"
}

# Получение id брэнмаузера для исходящих потоков
data "rustack_firewall_template" "allow_web" {
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "Разрешить WEB"
}


resource "time_sleep" "wait_30_seconds" {
    depends_on = [rustack_vdc.vdc1]
    create_duration = "30s"
}

# Создание сервера. 
# Задаём его имя и конфигурацию. Выбираем шаблон ОС по его id, который получили на шаге 7. Ссылаемся на скрипт инициализации. Указываем размер и тип основного диска. 
# Выбираем Сеть в которую будет подключен сервер по её id, который получили на шаге 5. 
# Выбираем шаблон брандмауера по его id, который получили на шаге 8. Указываем, что необходимо получить публичный адрес.
resource "rustack_vm" "web" {
    depends_on = [time_sleep.wait_30_seconds]
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "WEB"
    cpu = 1
    ram = 1

    template_id = data.rustack_template.ubuntu20.id
    
    user_data = "${file("cloud-config.yaml")}"

    system_disk = "20-ocfs2"

    port {
        network_id = data.rustack_network.service_network.id
        firewall_templates = [
            data.rustack_firewall_template.allow_default.id,
            data.rustack_firewall_template.allow_ssh.id,
            data.rustack_firewall_template.allow_web.id
        ]
    }

    floating = true
}

# Создание сервера. 
# Задаём его имя и конфигурацию. Выбираем шаблон ОС по его id, который получили на шаге 7. Ссылаемся на скрипт инициализации. Указываем размер и тип основного диска. 
# Выбираем Сеть в которую будет подключен сервер по её id, который получили на шаге 5. 
# Выбираем шаблон брандмауера по его id, который получили на шаге 8. Указываем, что необходимо получить публичный адрес.
resource "rustack_vm" "db" {
    depends_on = [time_sleep.wait_30_seconds]
    vdc_id = resource.rustack_vdc.vdc1.id
    name = "DB"
    cpu = 1
    ram = 1

    template_id = data.rustack_template.ubuntu20.id
    
    user_data = "${file("cloud-config.yaml")}"

    system_disk = "20-ocfs2"

    port {
        network_id = data.rustack_network.service_network.id
        firewall_templates = [
            data.rustack_firewall_template.allow_default.id,
            data.rustack_firewall_template.allow_ssh.id,
            data.rustack_firewall_template.allow_web.id
        ]
    }

    floating = true
}

resource "time_sleep" "wait_50_seconds" {
  depends_on = [rustack_vm.web]
  create_duration = "50s"
}

resource "null_resource" "next_web" {
    depends_on = [time_sleep.wait_50_seconds]
    provisioner "remote-exec" {
        inline = [
            "sudo chmod 777 /opt",
            "cd /opt",
            "mkdir web_iiot",
            "cd web_iiot",
            "sudo chmod 777 /opt/web_iiot",
            "echo '${rustack_vm.db.floating_ip}' > ip.txt",
        ]
        connection {
            type     = "ssh"
            user     = "ubuntu"
            password = "qwerty123"
            host     = "${rustack_vm.web.floating_ip}"
        }
    }
    provisioner "file" {
        source      = "./IIoTWeb/"
        destination = "/opt/web_iiot"
        connection {
            type     = "ssh"
            user     = "ubuntu"
            password = "qwerty123"
            host     = "${rustack_vm.web.floating_ip}"
        }
    }
    provisioner "remote-exec" {
        inline = [
            "chmod +x /opt/web_iiot/prepare.sh",
            "chmod +x /opt/web_iiot/start.sh",
            "sudo /opt/web_iiot/prepare.sh",
        ]
        connection {
            type     = "ssh"
            user     = "ubuntu"
            password = "qwerty123"
            host     = "${rustack_vm.web.floating_ip}"
        }
    }
}

resource "null_resource" "next_db" {
    depends_on = [time_sleep.wait_50_seconds]
    provisioner "remote-exec" {
        inline = [
            "sudo chmod 777 /opt",
            "mkdir /opt/db_iiot",
            "sudo chmod 777 /opt/db_iiot",
        ]
        connection {
            type     = "ssh"
            user     = "ubuntu"
            password = "qwerty123"
            host     = "${rustack_vm.db.floating_ip}"
        }
    }
    provisioner "file" {
        source      = "./IIoTDB/"
        destination = "/opt/db_iiot"
        connection {
            type     = "ssh"
            user     = "ubuntu"
            password = "qwerty123"
            host     = "${rustack_vm.db.floating_ip}"
        }
    }
    provisioner "remote-exec" {
        inline = [
            "chmod +x /opt/db_iiot/prepare.sh",
            "chmod +x /opt/db_iiot/start.sh",
            "sudo /opt/db_iiot/prepare.sh",
        ]
        connection {
            type     = "ssh"
            user     = "ubuntu"
            password = "qwerty123"
            host     = "${rustack_vm.db.floating_ip}"
        }
    }
}