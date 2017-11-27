class SolipschismApp extends HTMLElement {
  constructor(){
    super();
    var shadowRoot = this.attachShadow({mode: 'open'});

    shadowRoot.innerHTML = `
    <style>
      #container{
        width: 100%;
        height: 100%;
      }

    </style>

    <div id="container">
    </div>
    `
  }

  connectedCallback(){
    var this_solipschism_app = this;
    var shadow = this.shadowRoot;
    retrieveStoredApiKey(function(response){
      if (Object.keys(response).length === 0 && response.constructor === Object){
        // No Stored API keys
        console.log("No stored API Key, creating login/signup");
        this_solipschism_app.createLoginSignup();
      } else {
        // Need to test validity of stored api key
        checkValidityOfApiKey(
          // Success Function ()
          function(response){
            console.log(response);
            console.log("Stored API Key is good to go, creating Homepage");
            this_solipschism_app.createHomepage();
          },
          // Failure Function (Stored API Key Doesnt work)
          function(response){
            response = new XMLHttpRequest();
            console.log(response);
            console.log("Stored API Key is invalid, creating login/signup");
            this_solipschism_app.createLoginSignup();
          },
          // API Key
          response.api_key
        );
      }
    });
  }

  disconnectedCallback(){

  }

  attributeChangedCallback(attr, oldValue, newValue){

  }

  createLoginSignup(){
    var this_solipschism_app = this;
    var shadow = this.shadowRoot;

    var login_signup = new LoginSignup();
    var this_affected_area = $(shadow.querySelector("#container")).html(login_signup);
  }

  createHomepage(){
    var this_solipschism_app = this;
    var shadow = this.shadowRoot;

    var this_affected_area = $(shadow.querySelector("#container")).html(`
      <H1>You dont need to login or signup</h1>
      `)
  }

  login(){
    
  }


}

customElements.define('solipschism-app', SolipschismApp);
