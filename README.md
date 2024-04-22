# P2p

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Idea

Servers create a long running websocket from a unique id and a password that listens
for clients, once a client is authenticated you can send any data between your server and the client
this socket should be used to create a WebRTC connection between the peers and then this socket should
be dropped on the clients end, now we have two peers connected peer to peer no middleman. see [Example](example/index.js)

## [JWT](http://jwtbuilder.jamiekurtz.com/)

in order for servers to create a socket they need a JWT signed with your `JWT_SECRET` and claims

```
{
    "iss": "P2P",
    "iat": 1713779629,
    "exp": 1713879629,
    "aud": "P2P",
    "sub": "some-unique-id" // used when clients trys to connect `server_id`
}
```

## Helm

- `docker build -t aicacia/api-p2p:latest .`
- `docker push aicacia/api-p2p:latest`
- `helm upgrade p2p helm/p2p -n api --install --set image.hash="$(docker inspect --format='{{index .Id}}' aicacia/api-p2p:latest)"`
- `helm delete -n api p2p`
