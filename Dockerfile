# Ref: https://www.linuxbabe.com/ubuntu/set-up-cups-print-server-ubuntu-bonjour-ipp-samba-airprint

# docker build -t cups --build-arg LPADMIN_PASSWORD=password .

FROM ubuntu:noble

ARG LPADMIN_PASSWORD

RUN apt update && \
    apt upgrade -y && \
    apt install -y cups net-tools

RUN useradd cupsadmin && \
    usermod -aG lpadmin cupsadmin && \
    echo "cupsadmin:$LPADMIN_PASSWORD" | chpasswd

RUN mv /etc/cups /etc/cups.orig

COPY start.sh /root/start.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/root/start.sh"]

EXPOSE 631
