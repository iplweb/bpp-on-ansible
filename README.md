# bpp-on-ansible
[![TravisCI odznaka](https://travis-ci.org/iplweb/bpp-on-ansible.svg?branch=develop)](https://travis-ci.org/iplweb/bpp-on-ansible/)

Skrypty Ansible konfigurujące serwery do uruchamiania BPP na serwerach "bare metal".

Na ten moment dostępna jest kongfiguracja uruchamiająca i testująca wszystko przez Vagranta.

Jako eksperymentalna konfiguracja dołożony jest Docker - ale jedynie do testów. Na Dockerze najpierw uruchomiony jest kontener z systemd,
następnie konfigurowany jest on konfiguracją Ansible zawartą w tym repo. Jak widać jest to pewne nadużycie Dockera,
swoisty krok w tył - więc po co? Ano po to, żeby móc weryfikować konfigurację Ansible na serwerach typu TravisCI
czy CircleCI, które Vagranta nie obsługują.

Osoby zainteresowane uruchomieniem BPP w kontenerach dockera zapraszamy do repo `bpp-on-docker`. 
