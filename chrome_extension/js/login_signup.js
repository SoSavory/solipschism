class LoginSignup extends HTMLElement {
  constructor(){
    super();
    var shadowRoot = this.attachShadow({mode: "open"});
    shadowRoot.innerHTML = `
      <style>
        #container{
          display: flex;
          width: 100%;
          height: 100%;
          flex-direction: row;
          justify-content: space-between;
        }
        .form-container{
          display:flex;
          flex-direction: column;
          flex-grow: 1;
        }
        form{
          display: flex;
          flex-direction: column;
        }
        input{
          width: 70%;
          padding: 0.25em;
          border: none;
          margin-bottom: 0.25em;
        }
        input:focus{
          outline: none;
        }
      </style>

      <div id="container">
        <div class="form-container" id="login-container">
          <h1>Login</h1>
          <form id="login-form">
            <input name="email" type="text" placeholder="Email">
            <input name="password" type="password" placeholder="Password">
            <input type="submit" value="Login">
          </form>
        </div>
        <div class="form-container" id="signup-container">
          <h1>Sign Up</h1>
          <form id="signup-form">
            <input name="name" type="text" placeholder="Name">
            <input name="email" type="text" placeholder="Email">
            <input name="password" type="password" placeholder="Password">
            <input type="submit" value="Register">
          </form>
        </div>

      </div>
    `
  }

  handleLogin(){
    var this_login_signup = this;
    var shadow = this.shadowRoot;

    var this_solipschism_app_container = $('#app-container')[0];

    var form_element = shadow.querySelector("#login-form");
    grabFormData(form_element, function(data){
      console.log(data);
      $.ajax(
        {
          type: 'POST',
          url: "http://165.227.107.115/login.json",
          contentType: 'application/json',
          dataType: 'json',
          data: JSON.stringify(data),
          success: function( response ){
            // Trigger homepage and store api_key locally
            console.log("Successfully logged in, storing API key: " + response.token);

            setStorage("api_key", response.token, function(){
              var new_solipschism_app = new SolipschismApp();
              $(this_solipschism_app_container).html(new_solipschism_app);
            })

          },
          error: function( response ){
            // reload with errors
            var response = new XMLHttpRequest();
            console.log(response);
          }
        }
      );
    });
  }

  handleSignup(){
    var this_login_signup = this;
    var shadow = this.shadowRoot;

    var this_solipschism_app_container = $('#app-container')[0];
    var form_element = shadow.querySelector("#signup-form");
    grabFormData(form_element, function(data){
      data.opts_to_compute = false;
      console.log(data);
      $.ajax({
        type: 'POST',
        url: "http://165.227.107.115/users/create.json",
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify(data),
        success: function( response ){
          // Trigger homepage and store api_key locally
          console.log("Successfully registered and logged in, storing API key: " + response.token);

          setStorage("api_key", response.token, function(){
            var new_solipschism_app = new SolipschismApp();
            $(this_solipschism_app_container).html(new_solipschism_app);
          });

        },
        error: function( response ){
          // reload with errors
          var response = new XMLHttpRequest();
          console.log(response);
        }
      });
    });

  }

  connectedCallback(){
    this.handleLogin();
    this.handleSignup();
  }

  disconnectedCallback(){

  }

  attributeChangedCallback(attr, oldValue, newValue){

  }
}

customElements.define('login-signup', LoginSignup);
