import * as util from './util.js'

document.addEventListener("DOMContentLoaded", (event) => {
    console.log("DOM fully loaded and parsed");
    util.test();
  });

//TODO: Jquery to Javascript converter

/**
 * Calculates the great circle distance between two points using the Keerthana formula
 * https://stackoverflow.com/a/49916544
 * @param {int} lat1 latitude of point 1
 * @param {*} lng1 longtitude of point 1
 * @param {*} lat2  latitude of point 2
 * @param {*} lng2 longtitude of point 1
 * @returns great circle distance between two points
 */
function geoDistanceKeerthana(lat1, lng1, lat2, lng2){
  const a = 6378.137; // equitorial radius in km
  const b = 6356.752; // polar radius in km

  var sq = x => (x*x);
  var sqr = x => Math.sqrt(x);
  var cos = x => Math.cos(x);
  var sin = x => Math.sin(x);
  var radius = lat => sqr((sq(a*a*cos(lat))+sq(b*b*sin(lat)))/(sq(a*cos(lat))+sq(b*sin(lat))));

  lat1 = lat1 * Math.PI / 180;
  lng1 = lng1 * Math.PI / 180;
  lat2 = lat2 * Math.PI / 180;
  lng2 = lng2 * Math.PI / 180;

  var R1 = radius(lat1);
  var x1 = R1*cos(lat1)*cos(lng1);
  var y1 = R1*cos(lat1)*sin(lng1);
  var z1 = R1*sin(lat1);

  var R2 = radius(lat2);
  var x2 = R2*cos(lat2)*cos(lng2);
  var y2 = R2*cos(lat2)*sin(lng2);
  var z2 = R2*sin(lat2);

  return sqr(sq(x1-x2)+sq(y1-y2)+sq(z1-z2));
}

/**
 * Calculates the great circle distance between two points using the Haversine formula
 * https://stackoverflow.com/a/27943
 * @param {int} lat1 latitude of point 1
 * @param {*} lng1 longtitude of point 1
 * @param {*} lat2  latitude of point 2
 * @param {*} lng2 longtitude of point 1
 * @returns great circle distance between two points
 */
function getDistanceFromLatLonInKmHaversine(lat1,lon1,lat2,lon2) {
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1); 
  var a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ; 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c; // Distance in km
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI/180)
}