#!/usr/bin/env sh

sudo cp enregistrement.service /usr/lib/systemd/system/.
sudo systemctl daemon-reload
sudo systemctl restart enregistrement
sudo systemctl enable enregistrement

