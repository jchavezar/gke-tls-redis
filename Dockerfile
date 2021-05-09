FROM ubuntu
RUN apt update && apt install telnet -y && apt install -y stunnel4
ADD redis-cli.conf /etc/stunnel/redis-cli.conf
ADD start_stunnel.sh /start_stunnel.sh

RUN chmod +x /start_stunnel.sh
RUN chmod 600 /etc/stunnel/redis-cli.conf
CMD ["/start_stunnel.sh"]