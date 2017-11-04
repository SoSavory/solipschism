// =============================================================================
// functions for accessing api
// =============================================================================

function getUnauthedApi(endpoint, callback){
  $.ajax(
    {
      type: 'GET',
      url: "http://localhost:3000/" + String(endpoint),
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
      url: "http://localhost:3000/" + String(endpoint),
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
      url: "http://localhost:3000/" + String(endpoint),
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
      url: "http://localhost:3000/" + String(endpoint),
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
      url: "http://localhost:3000/" + String(endpoint),
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
