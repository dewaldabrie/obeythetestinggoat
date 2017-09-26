#! /bin/bash
# run this before fabric deployment
# run like so:
# chmod +x provision_pre_first_deploy.sh
# ./provision_pre_first_deploy.sh 52.25.219.198 dewald superlists

# checks:
# * is gunicorn listed in your django requirements.txt?
if [ $# -ne 3 ]
  then
    echo "No arguments supplied"
    exit 1
fi

url=$1  # pass the url of the server
user=$2  # pass unix username on server
django_app_name=$3  # name of app containing wsgi.py

# Install Python3.6, venv, and nginx
echo "--------------------"
echo "Installing Python3.6"
echo "--------------------"
sudo add-apt-repository -y ppa:fkrull/deadsnakes
sudo apt-get update
sudo apt-get install -y nginx git python3.6 python3.6-venv

# Use nginx template to configure server to serve our site

# We substitute the string SITENAME for the address of our site,
# with the s/replaceme/withthis/g syntax.
# We pipe (|) the output of that to a root-user process (sudo),
# which uses tee to write what’s piped to it to a file,
# in this case the Nginx sites-available virtualhost config file.
echo "-----------------"
echo "Configuring nginx"
echo "-----------------"
sed -e "s/SITENAME/$url/g" \
    -e "s/USER/$user/g" \
    nginx.template.conf \
    | sudo tee /etc/nginx/sites-available/$url

# Next we activate that file with a symlink:
sudo ln -s /etc/nginx/sites-available/$url \
    /etc/nginx/sites-enabled/$url

# Remove default "Welcome to Nginx" config
sudo rm /etc/nginx/sites-enabled/default

# Test nginx config
echo "---------------------"
echo "Checking nginx config"
echo "---------------------"
sudo nginx -t


# Finally we start both services:
echo "----------------------------------------"
echo "Reloading services to effect new configs"
echo "----------------------------------------"
sudo systemctl daemon-reload
sudo systemctl reload nginx
