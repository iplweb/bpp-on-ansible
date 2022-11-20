# BPP_PACKAGE_VERSION=`yolk -V bpp-iplweb|head|sed s/bpp-iplweb\ //`
BPP_PACKAGE_VERSION=202101.54
BPP_PACKAGE=bpp-iplweb==$(BPP_PACKAGE_VERSION)

uname_m := $(shell uname -m)

PRIVATE_KEY=--private-key=.vagrant/machines/staging/virtualbox/private_key

ifeq ($(uname_m),arm64)	
PRIVATE_KEY=--private-key=.vagrant/machines/staging/parallels/private_key
endif

setup-ansible:
	ansible-galaxy collection install community.general
	ansible-galaxy collection install community.postgresql

staging: staging-up staging-ansible

staging-up: 
	vagrant up

staging-ansible:
	ansible-playbook ansible/bpp-cluster.yml $(PRIVATE_KEY)

staging-update: # "szybka" ścieżka aktualizacji
	ansible-playbook ansible/bpp-cluster.yml -t django-site $(PRIVATE_KEY)

pristine-staging:
	vagrant pristine -f staging

rebuild-staging: pristine-staging staging

demo-vm-ansible: 
	ansible-playbook ansible/demo-vm.yml $(PRIVATE_KEY)

# cel: demo-vm-clone
# Tworzy klon Vagrantowego boxa "staging" celem stworzenia pliku OVA
# z demo-wersją maszyny wirtualnej.
demo-vm-clone:
	-rm bpp-$(BPP_PACKAGE_VERSION).ova
	vagrant halt staging
	VBoxManage clonevm `VBoxManage list vms|grep bpp_staging|cut -f 2 -d\  ` --name Demo\ BPP\ $(BPP_PACKAGE_VERSION) --register
	VBoxManage export Demo\ BPP\ $(BPP_PACKAGE_VERSION) -o bpp-$(BPP_PACKAGE_VERSION)-`date +%Y%m%d%H%M`.ova --options nomacs --options manifest --vsys 0 --product "Maszyna wirtualna BPP" --producturl http://iplweb.pl/kontakt/ --vendor IPLWeb --vendorurl http://iplweb.pl --version $(BPP_PACKAGE_VERSION)  --eulafile LICENSE

# cel: demo-vm-cleanup
# Usuwa klon demo-maszyny wirutalnej
demo-vm-cleanup:
	VBoxManage unregistervm Demo\ BPP\ $(BPP_PACKAGE_VERSION) --delete

vagrantclean:
	vagrant destroy -f

vagrantup:
	vagrant up 

demo-vm: vagrantclean vagrantup staging demo-vm-ansible demo-vm-clone demo-vm-cleanup

INVENTORY_PATH?="/Volumes/Dane zaszyfrowane/${CUSTOMER}/ansible/hosts.cfg"

# cel: production -DCUSTOMER=... or CUSTOMER=... make production
fresh-install:
    # Instalowane jest wszystko, z certyfikatami SSL i konfiguracją serwera WWW włącznie
	ansible-playbook -i ${INVENTORY_PATH} ansible/bpp-cluster.yml ${ANSIBLE_OPTIONS}

install:
    # Instalowane jest wszystko oprócz konfigracji Nginx i certyfikatów SSL
	ansible-playbook -i ${INVENTORY_PATH} ansible/bpp-cluster.yml --skip-tags=ssl-certificate,nginx-config-file ${ANSIBLE_OPTIONS}

cert-install:
    # Instalowane są wyłącznie certyfikaty SSL
	ansible-playbook -i ${INVENTORY_PATH} -t ssl-certificate ansible/bpp-cluster.yml ${ANSIBLE_OPTIONS}

# Instalowane jest wszystko oprócz konfigracji Nginx i certyfikatów SSL
install-umwtest:
	ansible-playbook -i ${INVENTORY_PATH} ansible/bpp-cluster.yml --skip-tags=ssl-certificate ${ANSIBLE_OPTIONS}

# "Szybka" ścieżka aktualizacji - tylko serwis BPP
update:
	ansible-playbook -i ${INVENTORY_PATH} ansible/bpp-cluster.yml -t bpp-site --skip-tags=ssl-certificate,nginx-config-file ${ANSIBLE_OPTIONS}

# Tylko certyfikaty SSL i konfiguracja NGINX -- przy zmianie nazwy domeny
hostname-change:
	ansible-playbook -i ${INVENTORY_PATH} ansible/bpp-cluster.yml -t ssl-certificate,nginx-config-file ${ANSIBLE_OPTIONS}


docker-build:
	docker build . -t mpasternak79/bpp-on-ansible:20.04

docker-up:
	docker run -d --name systemd-ubuntu --privileged -v `pwd`:/app -v /sys/fs/cgroup:/sys/fs/cgroup:ro mpasternak79/bpp-on-ansible:20.04

docker-shell:
	docker exec -it systemd-ubuntu /bin/bash

docker-test-on-docker:
	docker exec systemd-ubuntu ansible-playbook --connection=local --inventory /ansible_inventory_docker --skip-tags=django-check-email /app/ansible/bpp-cluster.yml

docker-down:
	docker stop systemd-ubuntu
	docker rm systemd-ubuntu

test-on-docker: docker-build docker-up docker-test-on-docker docker-down

install-vagrant-plugins:
	vagrant plugin install vagrant-timezone vagrant-hostmanager vagrant-pristine
ifeq ($(uname_m),arm64)	
	vagrant plugin install vagrant-parallels
endif
