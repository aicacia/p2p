/**
 * create a JWT for this device to connect to the WebSocket
 * @returns {string}
 */
async function authenticateDevice() {
  const res = await fetch("http://localhost:4000/device", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ id: "test", password: "password" }),
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
async function initDevice() {
  const token = await authenticateDevice();
  window.socket = new WebSocket(
    `ws://localhost:4000/device/websocket?token=${token}`
  );
  socket.addEventListener("open", () => {
    socket.addEventListener("message", (event) => {
      const message = JSON.parse(event.data);
      switch (message.type) {
        case "join": {
          const peerId = message.from;
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
            peer.send("Hello");
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
    body: JSON.stringify({ id: "test", password: "password" }),
  });
  if (res.status >= 400) {
    throw new Error("failed to authenticate");
  }
  return await res.text();
}
/**
 * starts WebSocket and signals the device to create a WebRTC connection
 */
async function initClient() {
  const token = await authenticateClient();
  window.socket = new WebSocket(
    `ws://localhost:4000/client/websocket?token=${token}`
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
      socket.close();
    });
  });
}

async function main() {
  // add #device to the browser tab's url you want to act as the device
  const isDevice = location.hash.includes("device");
  if (isDevice) {
    await initDevice();
  } else {
    await initClient();
  }
}

main();
