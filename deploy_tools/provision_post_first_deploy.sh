#!/usr/bin/env bash
# either run this, or reboot

# run this post fabric deployment
# Copy deploy_tools to server like so::
#    $ scp -r -i ~/.ssh/MyAmznKeyPair.pem deploy_tools dewald@52.25.219.198:/home/dewald

# run this script like so:
# chmod +x provision_post_first_deploy.sh
# ./provision_pre_first_deploy.sh 52.25.219.198 dewald superlists

if [ $# -ne 3 ]
  then
    echo "No arguments supplied"
    exit 1
fi

url=$1  # pass the url of the server
user=$2  # pass unix username on server
django_app_name=$3  # name of app containing wsgi.py


# And we write the Systemd service, with another sed:
echo "-------------------------------"
echo "Configure gunicorn auto startup"
echo "-------------------------------"
sed -e "s/SITENAME/$url/g" \
    -e "s/USER/$user/g" \
    -e "s/DJANGO_APP_NAME/$django_app_name/g" \
    gunicorn-systemd.template.service \
    | sudo tee /etc/systemd/system/gunicorn-$url.service

# Check validity of service configuration
echo "-------------------------"
echo "Check auto-startup config"
echo "-------------------------"
systemd-analyze verify /etc/systemd/system/gunicorn-$url.service



# bind gunicorn to unix socket (for talking to nginx)
echo "--------------------------------------------"
echo "Bind guinicorn webapp to nginx's unix socket"
echo "--------------------------------------------"

# Finally we start both services:
echo "----------------------------------------"
echo "Reloading services to effect new configs"
echo "----------------------------------------"
sudo systemctl enable gunicorn-$url
sudo systemctl start gunicorn-$url
sudo systemctl reload nginx

echo "----------------------------------------"
echo "Rebooting ..."
echo "----------------------------------------"
sudo reboot