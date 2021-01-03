FROM jrei/systemd-ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales sudo python3-pip libssl-dev

RUN sed -i -e 's/# pl_PL.UTF-8 UTF-8/pl_PL.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=pl_PL.UTF-8

ENV LANG pl_PL.UTF-8

RUN pip3 install ansible

# COPY . /app
# RUN ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 /app/ansible/webserver.yml
