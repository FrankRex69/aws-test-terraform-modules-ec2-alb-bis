#!/bin/bash
{* BEWARE: Sometimes after the execution of the apt-get upgrade command a restart is required *}

sudo apt update

{* INSTALL NGINX *}
sudo apt install -y nginx
sudo bash -c 'echo Wait for your deployment to finish secondo Ec2 > /var/www/html/index.html'

{* INSTALL NODE, NPM *}
sudo apt install nodejs -y
sudo apt install node-typescript -y
sudo apt install npm -y

{* CLONE AND SETUP APP FROM GITHUB *}
cd /var/www/html/
sudo git clone https://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@github.com/FrankRex69/test-typescript-express-2.git
cd /var/www/html/test-typescript-express-2/
sudo npm install

{* INSTALL AND SETUP PM2 *}
sudo npm install pm2 -g
{* setup PM2 for BACKEND *}
cd /var/www/html/test-typescript-express-2/
sudo tsc --build
sudo pm2 start ./build/index.js --name "test-freendly-2"
sudo pm2 save

{* SETUP PROXY SERVER NGINX *}
cd /etc/nginx/sites-available/
sudo rm default

echo "server {
    # The listen directive serves content based on the port defined
    listen 80; # For IPv4 addresses
    listen [::]:80; # For IPv6 addresses

    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;

    # Replace the below if you have a domain name pointed to the server
    server_name    _;

    access_log /var/log/nginx/reverse-access.log;
    error_log /var/log/nginx/reverse-error.log;

    location / {
        # Specify the proxied server's address
        proxy_pass http://localhost:3006/test;
    }
}" > /etc/nginx/sites-available/default;

sudo systemctl restart nginx;