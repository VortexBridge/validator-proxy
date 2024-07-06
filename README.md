# Validator Proxy

This is a containerized nginx reverse proxy for the purpose of obscuring validator IP's from front-ends. It only accepts the two endpoints `GetEthereumTransaction` and `GetKoiniosTransaction`. It will round-robin the requests to however many validators are specified in a list (can be one, or, many)

## First time setup for production TLS/SSL with letsencrypt

These instructions will work on Ubuntu 20.04 but should be easily adapted to anything else.

1) Make sure the domain proxy.vortexbridge.io is pointed at the IP of your VPS. (An A record)

2) Install letsencrypt's certbot app:
```
sudo apt-get update && sudo apt-get install certbot -y
```

3) Install docker if not already installed:
```
curl -fsSL https://get.docker.com -o install-docker.sh
sudo sh install-docker.sh
```

3) Create directories for webroot and letsencrypt files and make sure they are accessible by other system users:
```
sudo mkdir /var/www && sudo mkdir /var/www/certbot
sudo mkdir /etc/letsencrypt
sudo chmod a+rw /var/www/certbot
sudo chmod a+rw /etc/letsencrypt
```

4) Clone and build the repo with docker
```
git clone https://github.com/VortexBridge/validator-proxy
cd validator-proxy
sudo docker build -t=validator-proxy:latest .
```

5) Start the server (server must be running for letsencrypt to find the files and verify the domain)

The entry script takes in a variable called `$VALIDATORS` which can be a list of IP's and ports seperated by a comma

Example list format: `127.0.0.1:3020,127.0.0.1:3021`

By default, it will run on port 80 and 443 - you can map this to any other port you wish using the -p parameter.

To run in production, simply use a command like this that runs the container daemonized and causing it to always restart even if the server is restarted:

```
sudo docker run -d --name validator-proxy --restart always -e VALIDATORS=127.0.0.1:3020,127.0.0.1:3021 -p 80:80 -p 443:443 -v /etc/letsencrypt:/etc/letsencrypt -v /var/www/certbot:/var/www/certbot validator-proxy:latest
```

To follow the logs on the server, run: `docker logs -f validator-proxy`. You can simply ctrl-c to stop viewing the logs at any time.

6) Generate the letsencrypt files:
```
sudo certbot certonly --webroot --webroot-path /var/www/certbot/ -d proxy.vortexbridge.io
```
You will need to answer the questions (email address, terms of service).

7) As long as certificate generation was succesful, stop and start the docker container to restart (it will automatically use the SSL cert this time)
```
sudo docker stop validator-proxy
sudo docker start validator-proxy
```

You now have a proxy running with SSL/TLS that allows communication to the validator list on the two specified endpoints.

## Restarting / Updating

If you need to change the validators list you will need to stop and remove the container, and then re-run the original run command with the new validators list.

```
sudo docker stop validator-proxy
sudo docker rm validator-proxy
```

If you need to pull in changes from the repo and re-build, do this. If there are no changes, you can skip this.
```
cd validator-proxy
git pull
sudo docker build -t=validator-proxy:latest .
```

Start the server again:
```
sudo docker run -d --name validator-proxy --restart always -e VALIDATORS=127.0.0.1:3020,127.0.0.1:3021 -p 80:80 -p 443:443 -v /etc/letsencrypt:/etc/letsencrypt -v /var/www/certbot:/var/www/certbot validator-proxy:latest
```

## Certification renewal

Certs expire every 90 days, so, the cert will need to be renewed prior to then.

To renew, use this command:
```
sudo certbot certonly --webroot --webroot-path --force-renewal /var/www/certbot/ -d proxy.vortexbridge.io
```

TODO: update this readme to include instructions to automatically handle this with a cronjob or something similar.