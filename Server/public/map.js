function initMap() {
    var mapProp = {
        center: new google.maps.LatLng(40.375401, -74.256844),
        zoom: 12
    };
    map = new google.maps.Map(document.getElementById("googleMap"), mapProp);
    var latArr = [40.395401, 40.405401, 40.365401, 40.355401, 40.415401, 40.395401];
    var longArr = [-74.356844, -74.226844, -74.276844, -74.216844, -74.296844, -74.306844]
    var popArr = [26, 213, 13, 17, 104, 139]
    for (var x = 0; x<6; x++) {
        var cityCircle = new google.maps.Circle({
            strokeColor: '#FF0000',
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: '#FF0000',
            fillOpacity: 0.35,
            map: map,
            center: {lat: latArr[x], lng: longArr[x]},
            radius: Math.sqrt(popArr[x]) * 100
          });
    }
    
  }