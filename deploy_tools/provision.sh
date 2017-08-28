#! /bin/bash

url=$1
# We substitute the string SITENAME for the address of our site,
# with the s/replaceme/withthis/g syntax.
# We pipe (|) the output of that to a root-user process (sudo),
# which uses tee to write what’s piped to it to a file,
# in this case the Nginx sites-available virtualhost config file.
sed "s/SITENAME/$url/g" \
    nginx.template.conf \
    | sudo tee /etc/nginx/sites-available/$url

# Next we activate that file with a symlink:
sudo ln -s ../sites-available/$url \
    /etc/nginx/sites-enabled/$url

# And we write the Systemd service, with another sed:
sed "s/SITENAME/$url/g" \
    gunicorn-systemd.template.service \
    | sudo tee /etc/systemd/system/gunicorn-$url.service

# Finally we start both services:
sudo systemctl daemon-reload
sudo systemctl reload nginx
sudo systemctl enable gunicorn-$url
sudo systemctl start gunicorn-$url