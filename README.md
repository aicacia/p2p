# P2p

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Idea

Devices create a long running websocket from a unique id and a password that listens
for clients, once a client is authenticated you can send any data between your device and the client
this socket should be used to create a WebRTC connection between the peers and then this socket should
be dropped on the clients end, now we have to peers connected peer to peer no middleman. see [Example](example/index.js)
