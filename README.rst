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

.. admonition:: Uwaga! 
   
   Niniejsza instrukcja nie uczy podstaw administracji serwerem. Nie tłumaczymy, czym jest
   Ansible (w sieci jest dużo ciekawych opracowań, zarówno po angielsku jak i po polsku);
   nie tłumaczymy, jak zainstalować Linuxa, co to jest dystrybucja oraz jak działają
   klucze SSH. Nie tłumaczymy również zawiłości korzystania z Pythona, instalacji 
   wirtualnych środowisk (*virtualenv*) i innych. Jeżeli nie czujesz się na siłach, jeżeli nie instalowałeś/aś nigdy 
   systemu operacyjnego, jeżeli poza logowaniem hasłem nie znasz innych metod zdalnego
   dostępu to wówczas zapraszamy do skorzystania z `płatnego wsparcia`_ . 

Aby zainstalować BPP:

#. Potrzebujemy serwera. Ustalmy na potrzeby dalszej dokumentacji, ze identyfikujemy
   go za pomocą nazwy domeny. Przykładowo, domena może mieć postać np. ``example.iplweb.pl``

#. Potrzebujemy na serwerze systemu operacyjnego `Ubuntu Linux Server`_ w ostatniej
   wersji LTS, czyli w chwili pisania tej dokumentacji ``22.04-LTS``. 

#. W dalszej części tej instrukcji zakładamy, że logowanie na użytkownika ``root``
   ma miejsce bez hasła tzn przy wykorzystaniu publicznego klucza SSH użytkownika, 
   który instaluje system. 

#. Lokalnie potrzebujemy Pythona z wirtualnym środowiskiem. Jeżeli działasz pod Linux
   lub macOS to wszystko powinno być na miejscu, a jeżeli działasz na Windows, to dużo
   dobrego słyszałem o dystrybucji `Anaconda`_

#. Gdy mamy już nasze lokalne wirtualne środowisko Pythona, instalujemy ``ansible`` 
   za pomocą polecenia:
   
   .. code-block:: python

      pip install ansible 

#. Konfigurujemy Ansible: 

   #. Plik ``hosts.cfg`` powinien mieć zawartość:

      .. code-block:: 

         example.iplweb.pl ansible_user=root postgresql_host=localhost

         [bpp-dbserver]
         example.iplweb.pl

         [bpp-webserver]
         example.iplweb.pl

   #.  Jak widać, ta konfiguracja ansible w chwili pisania niniejszej dokumentacji definiuje
       dwie role w obrębie systemu. Możemy mieć rolę serwera bazodanowego ``bpp-db`` oraz 
       rolę serwera aplikacji czyli ``bpp-webserver``. W ten sposób możemy łatwo rozdzielić
       komptuery celem lepszej skalowalności całego przedsięwzięcia. Jeżeli jednak rozdzielimy
       serwer bazodanowy na drugi komputer, należy zmienić ustawienie ``postgresql_host`` na nazwę
       hosta bazodanowego. 

#. Uruchamiamy instalację systemu BPP:

   .. code-block:: shell

      ansible-playbook -i hosts.cfg ansible/bpp-cluster.yml

#. Po instalacji systemu zostanie utworzone konto użytkownika (domyślnie ``bpp``). Konfiguracja systemu
   znajdzie się w pliku ``.env`` znajdującym się w domowym katalogu użytkownika ``bpp``. Domyślną konfigurację
   systemu można próbować wzbogacić korzystając z przykładowych ustawień, które można znaleźć w 
   repozytorium kodu - plik `.env.example`_


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
.. _płatnego wsparcia: https://bpp.iplweb.pl/kontakt/
.. _Ubuntu Linux Server: https://ubuntu.com/download/server
.. _Anaconda: https://www.anaconda.com/products/distribution
.. _.env.example: https://github.com/iplweb/bpp/blob/dev/.env.example