# elm-magento--address-book-manager
## Proof of concept for Elm with Magento
The current stack for Magento relies on technologies that require massive efforts to trouble-shoot and maintain. Elm is the opposite of that. This is an attempt to start improving the stack by taking a first step towards Elm.

### Please Help
I'm presenting the Elm argument at MageX in Austin in less than a month and need to get this prototype rolling! If you contribute code or documentation, I will happily give generous kudos during my talk.

Want to help? Pick up an issue from the [Project section](https://github.com/razoyo/elm-magento--address-book-manager/projects/1)

### Setup
You'll need to have webpack installed if you want to test in a local environment.
We're also using elm-ui for the styling. You can read more about Elm-inspired styling [here](https://github.com/mdgriffith/elm-ui).

The auto-populate feature depends on Loqate. You will need to get a Loqate account and add the tracking code to the head of the page. For simplicity's sake, we added the id in the Magento admin panel. Loqate works independently from Magento and Elm, however, the ability to use a plain-vanilla JS app in connection with ELM is part of the beauty of it. To get the auto-add to work, simply add a new project and go through the process of mapping it to the site. No require.js, no mess!

### Working on this project
The Magento module that will replace the address book area with our Elm app is in the backend folder. All of the code for the Elm app is in the frontend folder.

#### Back End
We have not tested this, yet, in terms of inserting, but, the idea is that you will add the module to a Magento 2.3.x site and drop the production-ready elm-address.js file into backend/ElmAddress/view/frontend/web/js/

So, you'll need your own instance of Magento up and running if you want to test out your code there.

#### Front End
We're using webpack so that you can spin up Elm and work interactively with it. We have not yet set up stubs for the html file to target in dev mode and associated stub data to use.

### Building the runtime js file
Use the command npm run make:js from the frontend folder. It will build the elm-address.js file and output it to backend/ElmAddress/etc/view/frontend/web/js - thus, when deployed, it should be in the right place to get picked up by Magento (we'll make that happen - has not been tested yet)

### Implementing the js
In the HTML file be sure to include the following init statement: 
`Elm.Main.init({ node: document.querySelector("elm-addr"), flags: ""})`
For now... we'll worry about the flags later. 

### Testing
Given the limited scope of development and Elm's advantages, we aren't planning to write extensive tests as part of the development process. However, we reserve the right to create some. If we do, we'll use the native Elm testing functions. 

## Architecture Basics
### Processes
#### Displaying the addresses from Magento
Upon loading the Elm app will send a message to Magento requesting the addresses for the currently logged in customer.
Elm will map the JSON response into a List of Records - each Record will have the address fields plus the Magento ID for the address. Each item in the list will have an index number.
If there are no addresses, only a button for adding addresses will appear.
Each address will appear as a row in a table.

#### Selecting an address to work with
Clicking anywhere on an address row in the table 'activates' the address for updating. It will set the 'targetAddress' in the model to that address and switch out the display tags with input tags. It will copy the active addresses fields to the root address fields in the model.

#### Updating and address
The model will update the 'root' address fields in the model with the 
