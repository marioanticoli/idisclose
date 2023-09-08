// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/idisclose_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {params: {token: window.userToken, user: window.user}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/idisclose_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/idisclose_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/idisclose_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
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
  console.log(payload)
  const messageItem = document.createElement("p")
  const user = payload.user
  messageItem.innerText = `[${formattedDate()}] - System: ${payload.body}`
  userMsgContainer.appendChild(messageItem)
})

userChannel.join()
  .receive("ok", resp => { console.log("Joined private channel", resp) })
  .receive("error", resp => { console.log("Unable to join private channel", resp) })

export default socket
