If you want to see a live version of this working in Magento, go to https://paul.razoyo.com, sign in or create an account and go to MyAccount -> Addresses tab.

# elm-magento--address-book-manager
## Proof of concept for Elm with Magento
The current stack for Magento relies on technologies that require massive efforts to trouble-shoot and maintain. Elm is the opposite of that. This is an attempt to start improving the stack by taking a first step towards Elm.

Want to help? Pick up an issue from the [Project section](https://github.com/razoyo/elm-magento--address-book-manager/projects/1)
Or, just fork the repository, make your improvements and register a pull request. I'll do my best to respond quickly.

### Setup
This project was designed to be used as a UI feature on a Magento store. However, you can test the functionality (sans communicating with your Magento instance) on your local machine.

Step 1 - Install Elm
If you're not familiar with Elm, you can install it on your local machine. Instructions can be found on [GitHub] (https://www.elm-lang.org).

Step 2 - Install Nodejs if you don't have it

Step 3 - Clone this repository

Step 4 - Navigate to the 'frontend' directory and `npm install`

Step 5 - Install webpack

Step 6 - In the frontend directory run `npm run start:dev`

We're also using elm-ui for the styling. You can read more about Elm-inspired styling [here](https://github.com/mdgriffith/elm-ui).

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
Deploy the files from /backend/ElmAddress/... to your Magento instance.

### Testing
Given the limited scope of development and Elm's advantages, we aren't planning to write extensive tests as part of the development process. However, we reserve the right to create some. If we do, we'll use the native Elm testing functions. 

