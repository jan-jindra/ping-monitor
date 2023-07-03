FROM debian
RUN apt update && apt install openssl shellinabox apache2 bash iputils-ping passwd -y
COPY ping-monitor/*.sh /root/.
EXPOSE 80/tcp
EXPOSE 4200/tcp
ENTRYPOINT bash /root/repeat.sh
