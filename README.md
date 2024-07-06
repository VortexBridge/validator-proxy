# Validator Proxy

This is a containerized nginx reverse proxy for the purpose of obscuring validator IP's from front-ends. It only accepts the two endpoints `GetEthereumTransaction` and `GetKoiniosTransaction`. It will round-robin the requests to however many validators are specified in a list (can be one, or, many)

## Building

To build, simply do this:

```
docker build -t=validator-proxy:latest .
```

## Running

The entry script takes in a variable called `$VALIDATORS` which can be a list of IP's and ports seperated by a comma

Example list format: `127.0.0.1:3020,127.0.0.1:3021`

By default, it will run on port 80 and 443 - you can map this to any other port you wish using the -p parameter.

To run in production, simply use a command like this that runs the container daemonized and causing it to always restart even if the server is restarted:

```
sudo docker run -d --name validator-proxy --restart always -e VALIDATORS=127.0.0.1:3020,127.0.0.1:3021 -p 80:80 -p 443:443 -v /etc/letsencrypt:/etc/letsencrypt -v /var/www/certbot:/var/www/certbot validator-proxy:latest
```

And then to follow the logs:

```
sudo docker logs -f validator-proxy
```

## Restarting / Updating

If you need to change the validators list you will need to stop and remove the container, and then re-run the original run command with the new validators list.

```
sudo docker stop validator-proxy
sudo docker rm validatory-proxy
```

Start again:
```
sudo docker run -d --name validator-proxy --restart always -e VALIDATORS=127.0.0.1:3020,127.0.0.1:3021 -p 80:80 -p 443:443 -v /etc/letsencrypt:/etc/letsencrypt -v /var/www/certbot:/var/www/certbot validator-proxy:latest
```
