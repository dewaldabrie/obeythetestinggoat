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


# bind gunicorn to unix socket (for talking to nginx)
echo "Bind guinicorn webapp to nginx's unix socket"
sudo systemctl reload nginx
cd /home/$user/sites/$url/source
/home/$user/sites/$url/virtualenv/bin/gunicorn --bind \
    unix:/tmp/$url.socket $django_app_name.wsgi:application