DEPLOY TOOLS
============

Amazon Configuration
````````````````````
Get an EC2 instance running with elastic IP, hosting space and records for subdomains.
Your domain must configured with the elsatic IP nameservers.

Start Amazon EC2 Ubuntu server instance.
Make sure SSH private key is present on your PC.
Create Amazon Elastic IP and associate it with the EC2 instance.
Create a Amazon Route53 Hosted Zone and add a record for the subdomain to use (if required).
In this example the domain is wonderous.website and the subdomain is superlists.
Log into the default EC2 user to setup a new user account::

    $ ssh -i ~/.ssh/MyAmznKeyPair.pem ubuntu@superlists.wonderous.website
    $ sudo adduser dewald
    (follow prompts)
    $ sudo usermod -aG sudo dewald

Copy the authorized_keys contents from the /home/ubuntu/.ssh/ to the corresponding home
directory of the new user.

Exit and log in as the new  user::

    $ ssh -i ~/.ssh/MyAmznKeyPair.pem dewald@superlists.wonderous.website

This should work. Exit again.
Upload the deploy tools to the server::

    $ scp -r -i ~/.ssh/MyAmznKeyPair.pem deploy_tools dewald@superlists.wonderous.website:~/

SSH in (as the new user), add execution permission to the scripts and execute the pre-provisioning::

    $ ssh -i ~/.ssh/MyAmznKeyPair.pem dewald@superlists.wonderous.website
    $ cd deploy_tools
    $ chmod +x provision_pre_first_deploy.sh
    $ ./provision_pre_first_deploy.sh superlists.wonderous.website dewald superlists

Next, run the fab deployment from your local pc::

    $ cd deploy_tools
    $ fab deploy:host=superlists.wonderous.website -u dewald -i ~/.ssh/MyAmznKeyPair.pem

Finally, reboot the remote instance, or run the post_provisioning script similar to the pre-provisioning
above.

Remember to attach port-80 security group to Amazon EC2 instance.

Usage
`````

On a new amazon instance (with elastic ip and hosting space and domain record configured)
Copy to server like so::

    $ scp -r -i ~/.ssh/MyAmznKeyPair.pem deploy_tools dewald@52.25.219.198:/home/dewald