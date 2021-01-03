# BPP_PACKAGE_VERSION=`yolk -V bpp-iplweb|head|sed s/bpp-iplweb\ //`
BPP_PACKAGE_VERSION=1.0.26.1
BPP_PACKAGE=bpp-iplweb==$(BPP_PACKAGE_VERSION)

configure-vagrantfile:
	rm -f Vagrantfile
	ln -s Vagrantfile.`uname -m` Vagrantfile

staging: staging-up staging-ansible

staging-up: 
	vagrant up

staging-ansible:
	ansible-playbook ansible/webserver.yml --private-key=.vagrant/machines/staging/virtualbox/private_key

staging-update: # "szybka" ścieżka aktualizacji
	ansible-playbook ansible/webserver.yml -t django-site --private-key=.vagrant/machines/staging/virtualbox/private_key

pristine-staging:
	vagrant pristine -f staging

rebuild-staging: pristine-staging staging

demo-vm-ansible: 
	ansible-playbook ansible/demo-vm.yml --private-key=.vagrant/machines/staging/virtualbox/private_key

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
	ansible-playbook -i ${INVENTORY_PATH} ansible/webserver.yml ${ANSIBLE_OPTIONS}

install:
    # Instalowane jest wszystko oprócz konfigracji Nginx i certyfikatów SSL
	ansible-playbook -i ${INVENTORY_PATH} ansible/webserver.yml --skip-tags=ssl-certificate,nginx-config-file ${ANSIBLE_OPTIONS}

update:
    # "szybka" ścieżka aktualizacji - tylko serwis BPP
	ansible-playbook -i ${INVENTORY_PATH} ansible/webserver.yml -t bpp-site --skip-tags=ssl-certificate,nginx-config-file ${ANSIBLE_OPTIONS}

docker-build:
	docker build . -t mpasternak79/bpp-on-ansible:20.04

docker-up:
	docker run -d --name systemd-ubuntu --privileged -v `pwd`:/app -v /sys/fs/cgroup:/sys/fs/cgroup:ro mpasternak79/bpp-on-ansible:20.04

docker-shell:
	docker exec -it systemd-ubuntu /bin/bash

docker-test-on-docker:
	docker exec -it systemd-ubuntu ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 --skip-tags=django-check-email /app/ansible/webserver.yml

docker-down:
	docker stop systemd-ubuntu
	docker rm systemd-ubuntu

test-on-docker: docker-build docker-up docker-test-on-docker docker-down

install-vagrant-plugins:
	vagrant plugin install vagrant-timezone vagrant-hostmanager vagrant-cachier vagrant-pristine
