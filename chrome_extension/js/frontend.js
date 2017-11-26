function refreshAjaxyPortal(portal, content){
  $(portal).html(content);
}

function grabID(element){
  $id = $(element).data( "id" );
  return $id
}

function alertApiKey(){
  retrieveStoredApiKey(function(api_key){
    alert("Your API Key is: " + api_key['api_key']);
  });
}

function displayApiKey(){
  retrieveStoredApiKey(function(api_key){
    $('#api-key-display-area').html("<p>"+api_key['api_key']+"</p>")
  })
}



// Function for template-building out html
//elementsObject is the input labels and types, and is given: [{type: 'textbox', placeholder: 'lol'},{},{}]
function formBuilder(id, formObject, elementsObject, labelsObject=null, labelText=null, callback){
  dataStart = "<form id='" + id + "'";

  if(formObject != null){
    $.each(Object.entries(formObject), function(index){
      dataStart += " "+this[0] + "=" + "'" + this[1] + "'";
    })
  }
  dataStart += ">";

  dataMiddle = [];
  $.each(elementsObject, function(index){
    if(labelsObject[index] != null && labelText[index] != null){
      label = "<label";
      labelMiddle = "";
    }
    start = "<input";
    middle = "";
    if(labelsObject[index] != null && labelText[index] != null){
      $.each(Object.entries(labelsObject[index]), function(){
        labelMiddle += " "+this[0] + "=" + "'" + this[1] + "'";
      });
    }
    $.each(Object.entries(this), function(){
      middle += " "+ this[0] + "=" + "'" + this[1] + "'";
    });
    if(labelsObject[index] != null && labelText[index] != null){
      label += labelMiddle + " >";
      label += labelText[index] + "</label>";
    }
    start += middle + " >";
    if(labelsObject[index] != null && labelText[index] != null){
      dataMiddle.push(label);
    }
    dataMiddle.push(start);
  });

  dataEnd   = "</form>";
  $.each(dataMiddle, function(){
    dataStart += this;
  });
  dataStart += dataEnd;
  callback(dataStart);
}

// Function for building an html list.
// onHoverEffects generates appropriate
function listBuilder(type, resource, callback){

}

function listClickEventHandler(){

}

function updateArea(callback, location, data){
  $(location).html(data);
  callback();
}

function showMaximumContainer(){
  $("#normal-contents").fadeTo('fast', 0.4, function(){
    $("#maximum-container").css("display", "flex");
  });
}

function hideMaximumContainer(){
  $("#normal-contents").fadeTo('fast', 1, function(){
    $("#maximum-container").fadeOut();
  })
}

//========================================================================================
// Pagination Methods
//========================================================================================

function getListPagination(callback){
  getData('list/pagination_splines', function(data){
    if(callback){
      callback(data);
    }
  });
}

function getCardPagination(callback){
  getData('card/pagination_splines', function(data){
    if(callback){
      callback(data);
    }
  });
}

function getListCardPagination(list_id,callback){
  getData('list/'+String(list_id)+'cards/pagination_splines', function(data){
    if(callback){
      callback(data)
    }
  })
}

function getCardListPagination(card_id,callback){
  getData('card/'+String(card_id)+'lists/pagination_splines', function(data){
    if(callback){
      callback(data)
    }
  })
}
