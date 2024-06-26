/**
 * create a JWT for this server to connect to the WebSocket
 * @returns {string}
 */
async function authenticateServer() {
  const res = await fetch("http://localhost:4000/server", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization:
        "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJQMlAiLCJpYXQiOjE3MTk0NDI3NDQsImV4cCI6bnVsbCwiYXVkIjoiUDJQIiwic3ViIjoic29tZS1nbG9iYWxseS11bmlxdWUtaWQifQ.s9YPld1ES38LYDNUOZFIfZ_Vcuz8I-H4OKIjEEJ9ago",
    },
    body: JSON.stringify({
      id: "some-globally-unique-id",
      password: "password",
    }),
  });
  if (res.status >= 400) {
    throw new Error("failed to authenticate");
  }
  return await res.text();
}

window.peers = {};
/**
 * starts WebSocket and listens for new clients, creates a WebRTC connection for new clients
 */
async function initServer() {
  const token = await authenticateServer();
  window.socket = new WebSocket(
    `ws://localhost:4000/server/websocket?token=${token}`
  );
  socket.addEventListener("open", () => {
    socket.addEventListener("message", (event) => {
      const message = JSON.parse(event.data);
      switch (message.type) {
        case "join": {
          const peerId = message.from;
          const payload = message.payload;
          console.log("new peer " + peerId, payload);
          const peer = (peers[peerId] = new SimplePeer({
            initiator: false,
            trickle: true,
          }));
          peer.on("error", (err) => console.log("error", err));
          peer.on("signal", (data) => {
            socket.send(JSON.stringify({ to: peerId, payload: data }));
          });
          peer.on("data", (data) => {
            console.log(new TextDecoder().decode(data));
          });
          peer.on("connect", () => {
            peer.send("Hello from the Server!");
          });
          peer.on("disconnect", () => {
            peer.destroy();
            delete peers[peerId];
          });
          break;
        }
        case "leave": {
          console.log(`leave ${message.from}`);
          break;
        }
        case "message": {
          const peerId = message.from;
          const peer = peers[peerId];
          peer.signal(message.payload);
        }
      }
    });
  });
}
/**
 * create a JWT for this client to connect to the WebSocket
 * @returns {string}
 */
async function authenticateClient() {
  const res = await fetch("http://localhost:4000/client", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      id: "some-globally-unique-id",
      password: "password",
    }),
  });
  if (res.status >= 400) {
    throw new Error("failed to authenticate");
  }
  return await res.text();
}
/**
 * starts WebSocket and signals the server to create a WebRTC connection
 */
async function initClient() {
  const token = await authenticateClient();
  window.socket = new WebSocket(
    `ws://localhost:4000/client/websocket?token=${token}&payload=${encodeURIComponent(
      JSON.stringify({ name: "test" })
    )}`
  );
  socket.addEventListener("open", () => {
    window.peer = new SimplePeer({
      initiator: true,
      trickle: true,
    });
    socket.addEventListener("message", (event) => {
      peer.signal(JSON.parse(event.data));
    });
    peer.on("error", (err) => console.log("error", err));
    peer.on("signal", (data) => {
      socket.send(JSON.stringify(data));
    });
    peer.on("data", (data) => {
      console.log(new TextDecoder().decode(data));
    });
    peer.on("connect", () => {
      // after we have connected over WebRTC close the client's WebSocket
      peer.send("Hello from a Client!");
      socket.close();
    });
  });
}

async function onLoad() {
  // add #server to the browser tab's url you want to act as the server
  const isServer = location.hash.includes("server");
  if (isServer) {
    await initServer();
  } else {
    await initClient();
  }
}

if (document.readyState === "complete") {
  onLoad();
} else {
  window.addEventListener("load", onLoad);
}
