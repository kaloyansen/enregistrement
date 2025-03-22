#!/usr/bin/env sh

if [ "$(id -u)" -ne 0 ]; then
    echo "error: this script must be run as root, try" >&2
    echo "sudo $0" >&2
    exit 1
fi

SERVICE_SRC=/yocto/enregistrement/service
SERVICE_DEST=/usr/lib/systemd/system

cp -v $SERVICE_SRC/enregistrement.service $SERVICE_DEST/.
cp -v $SERVICE_SRC/reconnect.service $SERVICE_DEST/.

echo service configuration copied from $SERVICE_SRC to $SERVICE_DEST
echo -n restart daemon ...

systemctl daemon-reload

echo -n restart enregistrement ...
systemctl restart enregistrement
systemctl enable enregistrement
echo -n restart reconnect ...
systemctl restart reconnect
systemctl enable reconnect 
echo done

