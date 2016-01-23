//location detection

if (navigator.geolocation) {
  navigator.geolocation.getCurrentPosition(
    function(position){
      alert('asdf');
      $.get('/init/',{'lat':position.coords.latitude,'lon':position.coords.longitude});
    },
    function(error){
      console.log("Error sdfs: ", error);
    },
    {
      timeout: (5 * 1000),
      maximumAge: (1000 * 60 * 15),
      enableHighAccuracy: true
    }
  );
   
   
  var positionTimer = navigator.geolocation.watchPosition(
    function(position){
      lat = position.coords.latitude;
      lon = position.coords.longitude;
    }
  );

  // stop watching for change after 5 mins
  //setTimeout(
  // function(){
  //    navigator.geolocation.clearWatch(positionTimer);
  //  },
  //  (1000 * 60 * 5)
  //);
 
}

