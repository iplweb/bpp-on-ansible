bpp-on-ansible
==============

|Status testów|

Repozytorium ``bpp-on-ansible`` zawiera skrypty Ansible konfigurujące 
serwery do uruchamiania BPP. Docelowe zastosowanie tych skryptów - 
serwery typu "bare-metal" czy serwery wirtualne, z pełnym systemem
operacynym (czytaj: nie-Docker, osoby zainteresowane uruchomieniem 
BPP w kontenerach dockera zapraszamy do repo `bpp_on_docker`_ ).  

Instalowanie systemu BPP od zera - instrukcja krok po kroku
-----------------------------------------------------------

Dokumentacja w trakcie tworzenia - zapraszamy za jakiś czas...

Testowanie tego repozytorium
----------------------------

Na potrzeby automatycznego testowania tego repozytorium stworzona 
jest kongfiguracja  uruchamiająca i testująca wszystko przez Vagranta
i wchodzi ona w skład tego repozytorium. 


Dodatkowo, jako eksperymentalna konfiguracja testująca dołożony jest
Docker. Na Dockerze najpierw uruchomiony jest kontener z systemd,
następnie konfigurowany jest on konfiguracją Ansible zawartą w tym repo.
Jak widać jest to pewne nadużycie Dockera, swoisty krok w tył - więc po
co? Ano po to, żeby móc weryfikować konfigurację Ansible na serwerach
typu TravisCI czy CircleCI, które Vagranta nie obsługują.

.. |Status testów| image:: https://github.com/iplweb/bpp-on-ansible/actions/workflows/tests.yml/badge.svg
   :target: https://github.com/iplweb/bpp-on-ansible/actions/workflows/tests.yml

.. _bpp_on_docker: https://github.com/iplweb/bpp-on-docker/