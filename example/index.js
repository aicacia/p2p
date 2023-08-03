/**
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

async function initDevice() {
  const token = await authenticateDevice();
  const socket = new WebSocket(
    `ws://localhost:4000/device/websocket?token=${token}`
  );
  const peers = {};
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
          peer.on("connect", () => {
            peer.send("Hello");
          });
          break;
        }
        case "leave": {
          const peerId = message.from;
          peers[peerId].destroy();
          delete peers[peerId];
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

async function initClient() {
  const token = await authenticateClient();
  const socket = new WebSocket(
    `ws://localhost:4000/client/websocket?token=${token}`
  );
  socket.addEventListener("open", () => {
    const peer = new SimplePeer({
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
    peer.on("connect", () => {
      socket.close();
    });
    peer.on("data", (data) => {
      console.log(new TextDecoder().decode(data));
    });
  });
}

async function main() {
  const isDevice = location.hash.includes("device");
  if (isDevice) {
    await initDevice();
  } else {
    await initClient();
  }
}

main();
