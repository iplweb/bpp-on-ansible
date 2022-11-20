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
   wersji LTS, czyli w chwili pisania tej dokumentacji ``22.04-LTS``. Po instalacji zaktualizuj
   jeszcze system poleceniem ``apt upgrade``. Domyślnie zestaw skryptów Ansible instalującym
   BPP nie przeprowadza tej operacji, zostawiając ją administratorowi:

   .. code-block:: shell

      # apt update
      # apt full-upgrade -y
      # reboot

#. Potrzebujemy certyfikat SSL dla tego serwera. Od pewnego czasu nieszyfrowane połączenia
   po protokole HTTP są delikatnie mówiąc wypierane, stąd warto postarać się o certyfikat. 
   BPP domyślnie przekierowuje zapytania HTTP na HTTPS. Pliki certyfikatów muszą być nazwane
   jak nasza domena, powinny być dwa, jeden powinien mieć rozszerzenie ``.cert`` a drugi 
   ``.key``. Skopiuj te pliki do katalogu z którego uruchamiasz ``ansible-playbook`` (patrz niżej)

#. W dalszej części tej instrukcji zakładamy, że logowanie na użytkownika ``root``
   ma miejsce bez hasła tzn przy wykorzystaniu publicznego klucza SSH użytkownika, 
   który instaluje system. Jeżeli chcesz szybko skopiować swój klucz SSH na serwer, 
   użyj polecenia ``ssh-copy-id(1)``:

   .. code-block: shell

      $ ssh-copy-id root@example.iplweb.pl

#. Lokalnie potrzebujemy Pythona z wirtualnym środowiskiem, żeby uruchomić Ansible. 
   Jeżeli działasz pod Linux lub macOS to wszystko powinno być na miejscu, a jeżeli 
   działasz na Windows, to dużo dobrego słyszałem o dystrybucji `Anaconda`_

#. Lokalnie potrzebujemy skopiować zawartość tego repozytorium do jakiegoś katalogu. 
   Potrzebny będzie zatem ``git(1)``:

   .. code-block: shell

      $ git clone https://github.com/iplweb/bpp-on-ansible/

   To polecenie utworzy katalog ``bpp-on-ansible``.

#. Gdy mamy już nasze lokalne wirtualne środowisko Pythona, instalujemy ``ansible`` 
   za pomocą polecenia:
   
   .. code-block:: python

      pip install ansible 

#. Konfigurujemy Ansible: 

   #. Plik ``hosts.cfg`` powinien mieć zawartość:

      .. code-block:: 

         example.iplweb.pl ansible_user=root django_site_name="Moj serwer BPP"

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

   #. Warto pamiętać, że zmienne konfiguracyjne Ansible możemy upchnąć potem do katalogu ``host_vars/nazwa-servera`` czyli
      tutaj byłby to katalog ``host_vars/example.iplweb.pl``. W przeciwnym wypadku ta pierwsza linia z pliku
      konfiguracyjnego może nam się zacząć wydłużać w nieskończoność...

#. Uruchamiamy instalację systemu BPP. Poniższe polecenie zakłada, ze w katalogu, z którego je 
   uruchamiamy znajdują się pliki certyfikatów SSL:

   .. code-block:: shell

      ansible-playbook -i hosts.cfg -e ssl_certs_path=`pwd` ansible/bpp-cluster.yml

#. Po instalacji systemu zostanie utworzone konto użytkownika (domyślnie ``bpp``). Konfiguracja systemu
   znajdzie się w pliku ``.env`` znajdującym się w domowym katalogu użytkownika ``bpp`` czyli w ``/home/bpp/.env``. 
   Domyślną konfigurację systemu po utworzeniu jej przez Ansible można próbować wzbogacić korzystając 
   z przykładowych ustawień, które można znaleźć w repozytorium kodu - plik `.env.example`_ , warto 
   również obejrzeć odpowiednią sekcję w pliku `settings/base.py`_

#. Na lokalnym komputerze (zwanym w terminologii Ansible kontrolerem) zostanie utworzony katalog 
   ``ansible/credentials`` gdzie znajdą się zapisane wartości haseł do systemu - hasło do bazy danych
   oraz zawartość zmiennej ``SECRET_KEY`` dla Django. Proponujemy przechowywać te dane w bezpiecznym
   miejscu. 

#. System powinien być dostępny pod adresem serwera czyli ``https://example.iplweb.pl/``

Co dalej?
---------

Jeżeli udało się zainstalować system BPP, jego baza w konfiguracji domyślnej będzie w mniejszym lub 
większym stopniu pusta. Pod adresem `bpp.readthedocs.io`_ znajdziemy dokumentację systemu. Być może
powstał już w niej rozdział o zaczynaniu od zera, na czystej bazie? Kto to wie...

Na ten moment proponujemy: 

Aktualizacja systemu z poziomu Ansible
--------------------------------------

Aktualizujemy repozytorium ``bpp-on-ansible`` poleceniem ``git pull``, następnie robimy dokładnie
to samo, co przy instalacji systemu (polecenie ``ansible-playbook ...``). 

Aktualizacja systemu z poziomu konta użytkownika
------------------------------------------------

#. Proponujemy utworzenie kopii zapasowej serwera aplikacji i bazy danych. 
#. Po zalogowaniu się na konto użytkownika ``bpp`` prosimy o wykonanie polecenia:

   .. code-block:: shell

      $ pip install --upgrade bpp-iplweb
      $ bpp-manage.py migrate

#. Po zalogowaniu się na konto administratora prosimy o wykonanie polecenia:

   .. code-block:: shell

      # supervisorctl signal HUP all

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
typu TravisCI czy CircleCI, które Vagranta nie obsługują. Na ten moment jednak
nie są przeprowadzane żadne automatyczne testy przy użyciu Dockera. 

.. |Status testów| image:: https://github.com/iplweb/bpp-on-ansible/actions/workflows/tests.yml/badge.svg
   :target: https://github.com/iplweb/bpp-on-ansible/actions/workflows/tests.yml

.. _bpp_on_docker: https://github.com/iplweb/bpp-on-docker/
.. _płatnego wsparcia: https://bpp.iplweb.pl/kontakt/
.. _Ubuntu Linux Server: https://ubuntu.com/download/server
.. _Anaconda: https://www.anaconda.com/products/distribution
.. _.env.example: https://github.com/iplweb/bpp/blob/dev/.env.example
.. _settings/base.py: https://github.com/iplweb/bpp/blob/dev/src/django_bpp/settings/base.py
.. _bpp.readthedocs.io: https://bpp.readthedocs.io/pl/latest/