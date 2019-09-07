'use strict';

const app = require('./Main.elm')
  .Elm
  .Main
  .init({ 
    node: document.querySelector("addr-mgr"),
    flags: document.cookie
  });

function sendToElm(messageData) { 
  app.ports.fromJs.send(messageData);
}

// subscribe to messages from Elm - will eventually use this for caching state if necessary
// app.ports.toJs.subscribe(data => handlePortMessage(data));


function handlePortMessage(data) {
  let command = data.command;
  switch(command) {
    // TODO
    default:
      console.log("unexpected command value | ", command)
  }
}
