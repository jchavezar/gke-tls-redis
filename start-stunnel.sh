#!/bin/bash

/usr/bin/stunnel /etc/stunnel/redis-cli.conf

# run forever
tail -f /dev/null