#!/usr/bin/env sh

SERVICE_SRC=/yocto/enregistrement/service
SERVICE_DEST=/usr/lib/systemd/system

sudo cp $SERVICE_SRC/enregistrement.service $SERVICE_DEST/.
sudo cp $SERVICE_SRC/reconnect.service $SERVICE_DEST/.
sudo systemctl daemon-reload

sudo systemctl restart enregistrement
sudo systemctl enable enregistrement
sudo systemctl restart reconnect
sudo systemctl enable reconnect 
sudo systemctl status enregistrement
sudo systemctl status enregistrement
