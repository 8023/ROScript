#!/bin/sh
crontab /root/root.cron && \
service cron start && \
python -m http.server 80 --directory wwwroot