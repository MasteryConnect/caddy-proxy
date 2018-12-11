# caddy-proxy
Automated [caddy](https://github.com/mholt/caddy) proxy for Docker containers using docker-gen.

### Usage

Start any containers you want proxied with an env var `VIRTUAL_HOST=subdomain.youdomain.com` just like [nginx-proxy](https://github.com/jwilder/nginx-proxy):
```sh
$ docker run -e VIRTUAL_HOST=foo.bar.com  ...
```

If you want the container protected by HTTP Basic Authentication add a `BASIC_AUTH` env var with the path to protect (i.e. `/`), username, and password:
```sh
$ docker run -e VIRTUAL_HOST=foo.bar.com -e BASIC_AUTH="/ myname mysecrect" ...
```

Then to run it:
```sh
$ docker run -v /var/run/docker.sock:/tmp/docker.sock:ro -v /data/.caddy:/root/.caddy --name caddy-proxy -p 80:80 -p 443:443 -e CADDY_OPTIONS="--email youremail@example.com" -d masteryconnect/caddy-proxy:latest
```

When you launch new (or stop) containers caddy-proxy will reload its configuration to make the new containers available.

### Additional Caddy http.proxy options

There is support for adding additional options to [http.proxy](https://caddyserver.com/docs/proxy) using a technique similar to the one used by [caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy). Unlike [caddy-docker-proxy](https://github.com/lucaslorentz/caddy-docker-proxy), this project currently only supports options under [http.proxy](https://caddyserver.com/docs/proxy). An example would be adding 'websocket` proxying e.g.
```
proxy /stream localhost:8080 {
  websocket
}
```
To do so, add a the following label
```sh
$ docker run --label caddy.proxy.websocket="" -v /var/run/docker.sock:/tmp/docker.sock:ro -v /data/.caddy:/root/.caddy --name caddy-proxy -p 80:80 -p 443:443 -e CADDY_OPTIONS="--email youremail@example.com" -d masteryconnect/caddy-proxy:latest
```
Note: Since the `websocket` option under proxy has no value, we use an empty string.

Here is an example in a `docker-compose` YAML file:
```
 test:
    image: masteryconnect/test
    command: bash -c "rm -rf ./public/packs; ./bin/webpack-dev-server"
    networks:
      - caddy-net
    environment:
      VIRTUAL_HOST: foo.bar.com
      VIRTUAL_PORT: 8080
    labels:
      caddy.proxy.websocket: ""
```
