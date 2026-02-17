#!/bin/bash

chown opksshuser:opksshuser /etc/opk/providers /etc/opk/auth_id
chmod 640 /etc/opk/providers /etc/opk/auth_id

exec /usr/sbin/sshd -D -p 2222
