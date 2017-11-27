class SolipschismHomepage extends HTMLElement {
  constructor(){
    super();
    var shadowRoot = this.attachShadow({mode: 'open'});

    shadowRoot.innerHTML = `
      <style>
        #container{
          display: flex;
          flex-direction: column;
          align-items: center;
        }

        #tab-selector-container{
          width: 100%;
        }
        #tab-selector{

          display: flex;
          flex-direction: row;
          align-items: center;
          justify-content: space-between;
        }
        .tab-selector-li{
          text-decoration: none;
          list-style: none;
          flex-grow: 1;
        }
        .tab-selector-li-a{
          height: 1em;
        }
        .tab-selector-li-a:hover{
          text-decoration: underline;
          cursor: pointer;
        }

        #tab-content-container{
          width: 100%;
          display: flex;
          flex-direction: column;
          align-items: center;
        }

        form{
          width: 80%;
          display: flex;
          flex-direction: column;
          margin: 0 auto 0 auto;
        }

        textarea, input{
          width: 100%;
          padding: 0.25em;
          border: none;
          margin-bottom: 0.25em;
        }
        textarea:focus, input:focus{
          outline: none;
        }

        #old-journals-container{
          width: 100%;
          height: 100%;
          display: flex;
          flex-direction: row;
          justify-content: space-between;
        }

        #list-of-old-journals{
          max-height: 400px;
          width: 40%;
          overflow: auto;
          flex-grow: 1;
        }

        #active-article{
          max-height: 400px;
          width: 40%;
          flex-grow: 1;
          overflow: auto;

        }


        .article{

        }

        .article-title{
          font-size: 1.3em;
        }

        .article-body{
          font-size: 1.1em;
        }

        .list-item{
          list-style: number;
          cursor: pointer;
          font-size: 2em;
        }


      </style>

      <div id="container">

        <div id="tab-selector-container">
          <ul id="tab-selector">
            <li class="tab-selector-li"><a class="tab-selector-li-a" id="enter-journal">Write in Journal</a></li>
            <li class="tab-selector-li"><a class="tab-selector-li-a" id="read-matched-journals">Read Matched Journals</a></li>
            <li class="tab-selector-li"><a class="tab-selector-li-a" id="read-old-journals">Read Your Journal</a></li>
          </ul>
        </div>

        <div id="tab-content-container">

        </div>
      </div>
    `
  }

  handleTabs(){
    var this_homepage = this;
    var shadow = this.shadowRoot;
    var tab_content_container = shadow.querySelector('#tab-content-container');

    $(shadow.querySelector("#enter-journal")).on("click", function(){
      $(tab_content_container).html(`
          <form id="create-article-form">
            <input class="enter-journal-input" name="title" type="text" placeholder="Title">
            <textarea class="enter-journal-input" name="body" rows="10" placeholder="Journal Body" />

            <input type="submit" value="Record In Journal">
          </form>
        `);
      var form_element = shadow.querySelector('#create-article-form');
      grabFormData(form_element, function(data){
        sendData("articles/create", data, function(response){
          $(shadow.querySelectorAll('.enter-journal-input')).val('');
          console.log("Thank you for uploading your day!");
        });
      });
    });
    $(shadow.querySelector("#read-matched-journals")).on("click", function(){

    });
    $(shadow.querySelector("#read-old-journals")).on("click", function(){
      var old_journals_container = document.createElement('div');
      $(old_journals_container).attr('id', 'old-journals-container');
      $(tab_content_container).html(old_journals_container);

      var list_of_old_journals = document.createElement('ul');
      $(list_of_old_journals).attr('id', 'list-of-old-journals');
      $(old_journals_container).append(list_of_old_journals);

      var active_article = document.createElement('div');
      $(active_article).attr('id', 'active-article');
      $(old_journals_container).append(active_article);

      getData('articles/index', function(data){
        console.log(list_of_old_journals);
        for(let article of data.articles){
          var list_element = document.createElement('li');
          list_element.className = 'list-item';
          list_element.innerHTML = article.title;

          list_element.addEventListener("click", function(){

            $(active_article).html(`
              <div class="article">
                <div class="article-title">` + article.title+ `</div><div class="article-body">` + article.body + `</div></div>`);
          });
          $(list_of_old_journals).append(list_element);
        }
      });
    });

  }

  connectedCallback(){
    this.handleTabs();
  }

  disconnectedCallback(){

  }

  attributeChangedCallback(attr, oldValue, newValue){

  }
}
customElements.define('solipschism-homepage', SolipschismHomepage);
