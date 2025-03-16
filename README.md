# enregistrement

```bash
git clone git@github.com:kaloyansen/enregistrement
cd enregistrement
sudo cp enregistrement.service /usr/lib/systemd/system/enregistrement.service
sudo usermod -aG audio $USER
sudo systemctl daemon-reload
sudo systemctl enable enregistrement

```
