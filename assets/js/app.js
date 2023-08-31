// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

let Hooks = {};

import suneditor from "../vendor/suneditor.min.js";
import katex from "../vendor/katex.min.js";

Hooks.Editor = {
  mounted() {
    const textareaEditor = document.getElementById("editor");
    const editor = SUNEDITOR.create(textareaEditor, {
      mode: "classic",
      rtl: false,
      //fullPage: true,
      katex: katex,
      charCounter: true,
      charCounterLabel: "Chars",
      width: "auto",
      minWidth: "300",
      height: "auto",
      minHeight: "200",
      videoFileInput: false,
      audioUrlInput: false,
      tabDisable: false,
      buttonList: [
        [
          "undo",
          "redo",
          "font",
          "fontSize",
          "formatBlock",
          "paragraphStyle",
          "blockquote",
          "bold",
          "underline",
          "italic",
          "strike",
          "subscript",
          "superscript",
          "fontColor",
          "hiliteColor",
          "textStyle",
          "removeFormat",
          "outdent",
          "indent",
          "align",
          "horizontalRule",
          "list",
          "lineHeight",
          "table",
          "link",
          "image",
          "math",
          //"imageGallery",
          "fullScreen",
          "showBlocks",
          //"preview",
          //"save",
        ],
      ],
    });

    // Listeners
    editor.onInput = (e, core) => editor.save();

    editor.onPaste = (e, cleanData, maxCharCount, core) => editor.save();

    editor.onImageUpload = (
      targetElement,
      index,
      state,
      info,
      remainingFilesCount,
      core
    ) => editor.save()
  },
};

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
//let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

function toggleSlideover(){
  document.getElementById('slideover-container').classList.toggle('invisible');
  document.getElementById('slideover-bg').classList.toggle('opacity-0');
  document.getElementById('slideover-bg').classList.toggle('opacity-50');
  document.getElementById('slideover').classList.toggle('translate-x-full');
}

let toggleButton = document.getElementById("slideover-toggle")
let slideoverBg = document.getElementById("slideover-bg")
let slideoverClose = document.getElementById("slideover-close")
if(toggleButton !== null) toggleButton.addEventListener("click", toggleSlideover)
if(slideoverBg !== null) slideoverBg.addEventListener("click", toggleSlideover)
if(slideoverClose !== null) slideoverClose.addEventListener("click", toggleSlideover)

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug();
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
