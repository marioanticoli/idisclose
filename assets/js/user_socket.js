// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket } from "phoenix";

// And connect to the path in "lib/idisclose_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {
  params: { token: window.userToken, user: window.user },
});

// Finally, connect to the socket:
socket.connect();

// Channel for notifications
let generalChannel = socket.channel("room:lobby", {});
let chatInput = document.querySelector("#chat-input");
let generalMsgContainer = document.querySelector("#chat-messages");

if (chatInput !== null) {
  chatInput.addEventListener("keypress", (event) => {
    if (event.key === "Enter") {
      generalChannel.push("broadcast_msg", { body: chatInput.value });
      chatInput.value = "";
    }
  });
}

const formattedDate = () => {
  const now = new Date();
  return now.toLocaleString("en-GB", { timeZone: "UTC" });
};

generalChannel.on("broadcast_msg", (payload) => {
  const messageItem = document.createElement("p");
  const user = payload.user;
  //let msgTypeClass = []
  //if(user === window.user) {
  //msgTypeClass = []
  //} else {
  //msgTypeClass = []
  //}
  //for(let i = 0; i < msgTypeClass.length - 1; i++) {
  //messageItem.classList.add(msgTypeClass[i])
  //}
  messageItem.innerText = `[${formattedDate()}] - ${user}: ${payload.body}`;
  generalMsgContainer.appendChild(messageItem);
});

generalChannel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined lobby", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join lobby", resp);
  });

// Channel for user chat
let userChannel = socket.channel(`room:${window.user}`, {});
let userMsgContainer = document.querySelector("#private-messages");

userChannel.on("new_sys_msg", (payload) => {
  const messageItem = document.createElement("p");
  //const user = payload.user;
  messageItem.innerText = `[${formattedDate()}] - System: ${payload.body}`;
  userMsgContainer.appendChild(messageItem);
});

userChannel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined private channel", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join private channel", resp);
  });

// Channel for WebRTC signaling
let signalingChannel = socket.channel("signaling:lobby", {});

let callAllowed = false;
let inCall = false;
const callBtn = document.getElementById("call-btn");
const leaveBtn = document.getElementById("leave-btn");
const cameraBtn = document.getElementById("camera-btn");
const micBtn = document.getElementById("mic-btn");

signalingChannel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined signaling channel", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join signaling channel", resp);
  });

signalingChannel.on("presence_state", async (payload) => {
  console.log("presence:", Object.entries(payload).length);
  if (Object.entries(payload).length > 1) {
    callBtn.classList.remove("disabled");
    callAllowed = true;
  }
});

signalingChannel.on("offer", async (payload) => {
  console.log("on offer", payload);
  if (payload.sender !== window.user) {
    createAnswer(payload.offer);
  }
});

signalingChannel.on("ice_candidate", async (payload) => {
  if (peerConnection) {
    await peerConnection.addIceCandidate(payload.candidate);
  }
});

signalingChannel.on("answer", async (payload) => {
  console.log("on answer", payload);
  if (payload.sender !== window.user) {
    addAnswer(payload.answer);
  }
});

let localStream;
let remoteStream;
let peerConnection;

const servers = {
  iceServers: [
    {
      urls: ["stun:stun1.l.google.com:19302", "stun:stun2.l.google.com:19302"],
    },
  ],
};

const videoParams = {
  video: {
    width: { min: 640, ideal: 1920, max: 1920 },
    height: { min: 480, ideal: 1080, max: 1080 },
  },
  audio: true,
};

const init_webrtc = async () => {
  localStream = await navigator.mediaDevices.getUserMedia(videoParams);
  console.log("init_webrtc", localStream);
  document.getElementById("user-1").srcObject = localStream;
};

const createPeerConnection = async () => {
  peerConnection = new RTCPeerConnection(servers);

  remoteStream = new MediaStream();
  document.getElementById("user-2").srcObject = remoteStream;
  document.getElementById("user-2").style.display = "block";

  document.getElementById("user-1").classList.add("smallFrame");

  if (!localStream) await init_webrtc();

  localStream.getTracks().forEach((track) => {
    peerConnection.addTrack(track, localStream);
  });

  peerConnection.ontrack = (event) => {
    event.streams[0].getTracks().forEach((track) => {
      remoteStream.addTrack(track);
    });
  };

  peerConnection.onicecandidate = async (event) => {
    if (event.candidate) {
      signalingChannel.push("ice_candidate", {
        candidate: event.candidate,
        sender: window.user,
      });
    }
  };
};

const createOffer = async () => {
  console.log("create offer");
  await createPeerConnection();

  let offer = await peerConnection.createOffer();
  await peerConnection.setLocalDescription(offer);

  signalingChannel.push("offer", { offer: offer, sender: window.user });
};

const createAnswer = async (offer) => {
  console.log("create answer");
  await createPeerConnection();

  await peerConnection.setRemoteDescription(offer);

  let answer = await peerConnection.createAnswer();
  await peerConnection.setLocalDescription(answer);

  signalingChannel.push("answer", { answer: answer, sender: window.user });
};

const addAnswer = async (answer) => {
  if (!peerConnection.currentRemoteDescription) {
    peerConnection.setRemoteDescription(answer);
  }
};

if (callBtn)
  callBtn.addEventListener("click", (_event) => {
    if (callAllowed) createOffer();
  });

if (leaveBtn)
  leaveBtn.addEventListener("click", (_event) => {
    if (inCall) console.log("hang up");
  });

const toggleCamera = async (_event) => {
  let videoTrack = localStream
    .getTracks()
    .find((track) => track.kind === "video");

  if (videoTrack.enabled) {
    videoTrack.enabled = false;
    cameraBtn.style.backgroundColor = "rgb(255, 80, 80)";
  } else {
    videoTrack.enabled = true;
    cameraBtn.style.backgroundColor = "rgb(179, 102, 249, .9)";
  }
};

const toggleMic = async () => {
  let audioTrack = localStream
    .getTracks()
    .find((track) => track.kind === "audio");

  if (audioTrack.enabled) {
    audioTrack.enabled = false;
    micBtn.style.backgroundColor = "rgb(255, 80, 80)";
  } else {
    audioTrack.enabled = true;
    micBtn.style.backgroundColor = "rgb(179, 102, 249, .9)";
  }
};

if (cameraBtn) cameraBtn.addEventListener("click", toggleCamera);
if (micBtn) micBtn.addEventListener("click", toggleMic);

export default socket;
