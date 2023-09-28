# ln-websocket-proxy

Websocket-based proxy for connecting to lightning nodes and mutiny wallets.

### Docker

Build the websocket-tcp-proxy image

```
DOCKER_BUILDKIT=1 docker build -f Dockerfile -t mutinywallet/ln-websocket-proxy .
```

Run the docker image locally

```
docker run -d -p 3001:3001 mutinywallet/ln-websocket-proxy
```

Deploy the docker image:

```
docker tag mutinywallet/ln-websocket-proxy registry.digitalocean.com/mutiny-wallet/websocket-tcp-proxy
docker push registry.digitalocean.com/mutiny-wallet/websocket-tcp-proxy
```

## How to test

You can change default port by setting `LN_PROXY_PORT=3001` or whatever your port should be.

You'll want `netcat` and [`websocat`](https://github.com/vi/websocat) installed.

Terminal 1:

```
RUST_LOG=debug LN_PROXY_PORT=3002 cargo run --features="server"
```

Terminal 2:

mac
```
netcat -l 127.0.0.1 -p 3000
```

linux
```
nc -l 127.0.0.1 3000
```

Terminal 3:

```
websocat -b ws://127.0.0.1:3001/v1/127_0_0_1/3000
```

Now you can type in the `websocat` terminal and you should see text on the netcat terminal, and type in the `netcat` terminal and it should show in the websocat terminal.
