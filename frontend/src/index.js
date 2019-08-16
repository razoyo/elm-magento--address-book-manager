'use strict';

const app = require('./Main.elm')
  .Elm
  .Main
  .init({ 
    node: document.querySelector("elm-addr"),
    flags: cookieMessage
  });

function sendToElm(messageData) { 
  app.ports.fromJs.send(messageData);
}

// sendToElm(groups.lname001[0]);

app.ports.toJs.subscribe(data => handlePortMessage(data));


function handlePortMessage(data) {
  let command = data.command;
  switch(command) {
  // TODO
      break;

    default:
      console.log("unexpected command value | ", command)
  }
}
