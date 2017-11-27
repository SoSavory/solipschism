chrome.runtime.onStartup.addListener(function(){
  chrome.alarms.create({delayInMinutes: 1});
});



chrome.alarms.onAlarm.addListener(function(){
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position){
      var lat = position.coords.latitude * Math.PI / 180;
      var long = position.coords.longitude * Math.PI / 180;
      sendData('coordinates/update', {latitude: lat, longitude: long}, function(response){
        console.log("Updated Coordinates");
      });
    });
  } else {
    alert("Geolocation is not supported");
  }
  chrome.alarms.create({delayInMinutes: 5});
});
