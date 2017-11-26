class LoginSignup extends HTMLElement {
  constructor(){
    super();
    var shadowRoot = this.attachShadow({mode: "open"});

    shadowRoot.innerHTML = `
      <style>
      </style>
    `
  }

  connectedCallback(){

  }

  disconnectedCallback(){

  }

  attributeChangedCallback(attr, oldValue, newValue){

  }
}

customElements.define('login-signup', LoginSignup);
