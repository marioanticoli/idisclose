// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/idisclose_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {params: {token: window.userToken, user: window.user}})

// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `room` and the
// subtopic is its id - in this case 42:
let generalChannel = socket.channel("room:lobby", {})
let chatInput         = document.querySelector("#chat-input")
let generalMsgContainer = document.querySelector("#chat-messages")

if(chatInput !== null) {
  chatInput.addEventListener("keypress", event => {
    if(event.key === 'Enter'){
      generalChannel.push("broadcast_msg", {body: chatInput.value})
      chatInput.value = ""
    }
  })
}

const formattedDate = () => {
  const now = new Date();
  return now.toLocaleString('en-GB', { timeZone: 'UTC' })
}

generalChannel.on("broadcast_msg", payload => {
  const messageItem = document.createElement("p")
  const user = payload.user
  //let msgTypeClass = []
  //if(user === window.user) {
    //msgTypeClass = []
  //} else {
    //msgTypeClass = []
  //}
  //for(let i = 0; i < msgTypeClass.length - 1; i++) {
    //messageItem.classList.add(msgTypeClass[i])
  //}
  messageItem.innerText = `[${formattedDate()}] - ${user}: ${payload.body}`
  generalMsgContainer.appendChild(messageItem)
})

generalChannel.join()
  .receive("ok", resp => { console.log("Joined lobby", resp) })
  .receive("error", resp => { console.log("Unable to join lobby", resp) })

let userChannel = socket.channel(`room:${window.user}`, {})
let userMsgContainer = document.querySelector("#private-messages")

userChannel.on("new_sys_msg", payload => {
  const messageItem = document.createElement("p")
  const user = payload.user
  messageItem.innerText = `[${formattedDate()}] - System: ${payload.body}`
  userMsgContainer.appendChild(messageItem)
})

userChannel.join()
  .receive("ok", resp => { console.log("Joined private channel", resp) })
  .receive("error", resp => { console.log("Unable to join private channel", resp) })

let signalingChannel = socket.channel("signaling:lobby", {})
const localVideo = document.getElementById("localVideo");
const remoteVideo = document.getElementById("remoteVideo");
const callButton = document.getElementById("callButton");
const hangupButton = document.getElementById("hangupButton");
const configuration = {
	iceServers: [{
		username: "prYipP7xJxFteeZWH63FN9WqENqgXfojSJ_qzzVWsbVT6mUbAXnfdVbz29WkQ1AoAAAAAGT_JaFtYXJpb2FudGljb2xp",
		urls: [
			"stun:fr-turn3.xirsys.com",
			"turn:fr-turn3.xirsys.com:80?transport=udp",
			"turn:fr-turn3.xirsys.com:3478?transport=udp",
			"turn:fr-turn3.xirsys.com:80?transport=tcp",
			"turn:fr-turn3.xirsys.com:3478?transport=tcp",
			"turns:fr-turn3.xirsys.com:443?transport=tcp",
			"turns:fr-turn3.xirsys.com:5349?transport=tcp"
		],
		credential: "6b4c4e36-50b0-11ee-a51b-0242ac120004"
	}]
}
console.log(configuration);
const peerConnection = new RTCPeerConnection(configuration);

signalingChannel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined signaling channel", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join signaling channel", resp);
  });

signalingChannel.on("offer", async (payload) => {
  // Create an RTCSessionDescription object from the received offer
  const remoteOffer = new RTCSessionDescription(payload);

  // Set the remote description with the received offer
  await peerConnection.setRemoteDescription(remoteOffer);

  // Create an answer and set it as the local description
  const answer = await peerConnection.createAnswer();
  await peerConnection.setLocalDescription(answer);

  // Send the answer to the other peer
  await sendAnswerToOtherPeer(answer);
});

signalingChannel.on("answer", async (payload) => {
  // Handle incoming answers from the remote peer here
  const remoteAnswer = new RTCSessionDescription(payload);
  if (peerConnection.signalingState === "have-local-offer") {
    // If the connection is in the "stable" state, set the remote description immediately
    await peerConnection.setRemoteDescription(remoteAnswer);
  } else {
    // If the connection is not in the "stable" state, queue the remote description and wait for
    // the "negotiationneeded" event to handle it
    peerConnection.pendingRemoteDescription = remoteAnswer;
  }
});

signalingChannel.on("ice_candidate", async (payload) => {
  // Handle incoming ICE candidates from the remote peer here
  const candidate = new RTCIceCandidate(payload);
  if (candidate.usernameFragment === payload.usernameFragment) {
    return;
  }
  await peerConnection.addIceCandidate(candidate);
});

peerConnection.onnegotiationneeded = async () => {
  // Request access to the local media.
  const constraints = {
    video: true,
    audio: true,
  };
  const stream = await navigator.mediaDevices.getUserMedia(constraints);

  // Add the local video stream to the DOM.
  localVideo.srcObject = stream;

  // Add the tracks from the local stream to the peer connection
  stream.getTracks().forEach((track) => {
    peerConnection.addTrack(track, stream);
  });

  // Create an offer and send it to the other peer.
  const offer = await peerConnection.createOffer();
  peerConnection.setLocalDescription(offer);
  await sendOfferToOtherPeer(offer);
};

peerConnection.onicecandidate = async (event) => {
  // Send the ICE candidate to the other peer.
  if (event.candidate) {
    await sendIceCandidateToOtherPeer(event.candidate);
  }
};

peerConnection.ontrack = async (event) => {
   // Add the remote video stream to the DOM.
  remoteVideo.srcObject = event.streams[0];
};

async function sendOfferToOtherPeer(offer) {
  // Send the offer to the other peer
  signalingChannel.push("offer", offer);
}

async function sendAnswerToOtherPeer(answer) {
  // Send the answer to the other peer
  signalingChannel.push("answer", answer);
}

async function sendIceCandidateToOtherPeer(candidate) {
  // Send the ICE candidate to the other peer
  signalingChannel.push("ice_candidate", candidate);
}

// Add click event listeners to call and hangup buttons
if(callButton !== null) callButton.addEventListener("click", () => {
  // You can initiate the call here, e.g., when the "Call" button is clicked
  peerConnection.onnegotiationneeded();
});

if(hangupButton !== null) hangupButton.addEventListener("click", () => {
  // You can end the call here, e.g., when the "Hang Up" button is clicked
  peerConnection.close();
  localVideo.srcObject = null;
  remoteVideo.srcObject = null;
});

export default socket
