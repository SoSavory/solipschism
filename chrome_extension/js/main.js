// =============================================================================
// functions for accessing api
// =============================================================================

function getUnauthedApi(endpoint, callback){
  $.ajax(
    {
      type: 'GET',
      url: "http://165.227.107.115/" + String(endpoint),
      contentType: 'application/json',
      success: function( response ){
        if (callback == null){
          console.log(response);
        }

        else {
          callback(response);
        }
      }
    }
  );
}

function getApi(endpoint, api_key, callback){
  $.ajax(
    {
      type: 'GET',
      url: "http://165.227.107.115/" + String(endpoint),
      contentType: 'application/json',
      headers: {"Authorization":" Token token="+api_key},
      success: function( response ){
        if (callback == null){
          console.log(response);
        }

        else {
          callback(response);
        }
      }
    }
  );
}

function postApi(endpoint, data, api_key, callback){
  console.log(data);
  $.ajax(
    {
      type: 'POST',
      url: "http://165.227.107.115/" + String(endpoint),
      contentType: 'application/json',
      dataType: 'json',
      headers: {"Authorization":" Token token="+api_key},
      data: JSON.stringify(data),
      success: function( response ){
        if (callback == null){
          console.log(response);
        }

        else {
          console.log("Running Callback");
          callback(response);
        }
      },
      failure: function( response ){
        console.log(response);
      }
    }
  )
}

function deleteApi(endpoint, api_key, callback){
  $.ajax(
    {
      type: 'DELETE',
      url: "http://165.227.107.115/" + String(endpoint),
      contentType: 'application/json',
      dataType: 'json',
      headers: {"Authorization": " Token token="+api_key},
      success: function( response ){
        if (callback == null){
          console.log(response);
        }
        else{
          console.log("Running Callback");
          callback(response);
        }
      },
      failure: function( response ){
        console.log(response);
      }
    }
  )
}

function updateApi(endpoint, data, api_key, callback){

  $.ajax(
    {
      type: 'PATCH',
      url: "http://165.227.107.115/" + String(endpoint),
      contentType: 'application/json',
      dataType: 'json',
      headers: {"Authorization":" Token token="+api_key},
      data: JSON.stringify(data),
      success: function( response ){
        if (callback == null){
          console.log(response);
        }

        else {
          console.log("Running Callback");
          callback(response);
        }
      },
      failure: function( response ){
        console.log(response);
      }
    }
  )
}

// =============================================================================
// sends authentication + data to api
// =============================================================================

function sendData(endpoint, data, callback){
  $endpoint = endpoint;
  $data = data;

  checkApiKeyPresence(function(api_key){
    postApi($endpoint, $data, api_key['api_key'], function(response){
      console.log(response);
      if (callback != null){
        callback(response)
      }
    })
  },
  function(){
    console.log("Could not process request because there is no stored API Key.");
  }
  )
}

function getData(endpoint, callback){
  $endpoint = endpoint;

  checkApiKeyPresence(function(api_key){
    getApi($endpoint, api_key['api_key'], function(response){
      callback(response);
    });
  },
  function(){
    console.log("Could not process request because there is no stored API Key.")
  }
  )
}

function getUnauthedData(endpoint, call){
  getUnauthedApi(endpoint, function(response){
    call(response);
  });
}

function deleteData(endpoint, callback){
  $endpoint = endpoint;

  checkApiKeyPresence(function(api_key){
    deleteApi($endpoint, api_key['api_key'], function(response){
      console.log(response);
      callback(response);
    });
  },
  function(){
    console.log("Could not process request because there is no stored API Key.")
  }
  )
}

function updateData(endpoint, data, callback){
  $endpoint = endpoint;
  $data = data;

  checkApiKeyPresence(function(api_key){
    updateApi($endpoint, $data, api_key['api_key'], function(response){
      console.log(response);
      callback(response);
    });
  },
  function(){
    console.log("Could not process request because there is no stored API Key.")
  }
  )
}



//======================================================================================
// Methods for setting/removing sync storage
//======================================================================================

function setStorage(key, value) {
  $json_data = {};
  $json_data[key] = value;
  chrome.storage.sync.set($json_data, function(){
    console.log('Saved a value', key, value);
  });
}

function removeStorage(key){
  chrome.storage.sync.remove(key, function(){
    console.log('Removed from storage', key);
  })
}

function retrieveSyncStorage(key, callback){
  chrome.storage.sync.get(key, function(key){
    callback(key);
  });
}

function retrieveStoredApiKey(callback){
  retrieveSyncStorage("api_key", function(api_key){
    callback(api_key);
  });
  // chrome.storage.sync.get("api_key", function(api_key){
  //   callback(api_key);
  // });
}

function checkValidityOfApiKey(successCallback, failureCallback, key){
  $.ajax(
    {
      type: 'GET',
      url: "http://165.227.107.115/aliases/index",
      contentType: 'application/json',
      headers: {"Authorization":" Token token="+key},
      success: function( response ){
        successCallback(response);
      },
      error: function( response ){
        failureCallback(response);
      }
    }
  );
}

//========================================================================================
// Method for checking if an API Key is present
//========================================================================================

function checkApiKeyPresence(successFunction, failureFunction){
  retrieveStoredApiKey(function(api_key){
    if (api_key['api_key'] != undefined){
      console.log("An API Key is Stored: " + api_key['api_key']);
      successFunction(api_key);
    }
    else {
      console.log("An API Key is not stored");
      failureFunction();
    }
  });
}

//========================================================================================
// Method for submitting data from a form
//========================================================================================

function grabFormData(formElement, callback){
  $values = {};
  $(formElement).on('submit', function( event ){
    event.preventDefault();
    $.each($(formElement).serializeArray(), function(i, field){
      $values[field.name] = field.value;
    });
    callback($values);
  })
}


//========================================================================================
// Method for executing a series of callback functions
//========================================================================================

// Takes an array of functions (holster) to chain as argument. Make sure that every function can accept a callback (last one doesnt need to).
// Initial argument should be holster.shift().
function multiCallback(holster,fn){
  if(fn){
    fn( ()=> multiCallback(holster,holster.shift()));
  }
}

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}

// Plugs the cards from the active list into local storage
function loadCardstoLocalDB(list_id){
  checkApiKeyPresence(function(){
    getData('lists/' + String(list_id), function(data){
      $cards = data.cards;
      $card_ids = [];
      $cards_list = [];
      fns = [
        function(callback){
          $.each($cards, function(){
            $card_ids.push(this.id)
            $cards_list.push({id: this.id, question: this.question, answer: this.answer});
          });
          callback();
        }
        ,
        function(callback){
          setStorage("active_list_card_ids", $card_ids);
          setStorage("active_cards", $cards_list);
          setStorage("active_list", list_id);
          callback();
        }
      ];
      multiCallback(fns,fns.shift());
    })
  },
  function(){
  })
}
