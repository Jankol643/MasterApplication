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

  let sq = x => (x*x);
  let sqr = x => Math.sqrt(x);
  let cos = x => Math.cos(x);
  let sin = x => Math.sin(x);
  let radius = lat => sqr((sq(a*a*cos(lat))+sq(b*b*sin(lat)))/(sq(a*cos(lat))+sq(b*sin(lat))));

  lat1 = lat1 * Math.PI / 180;
  lng1 = lng1 * Math.PI / 180;
  lat2 = lat2 * Math.PI / 180;
  lng2 = lng2 * Math.PI / 180;

  let R1 = radius(lat1);
  let x1 = R1*cos(lat1)*cos(lng1);
  let y1 = R1*cos(lat1)*sin(lng1);
  let z1 = R1*sin(lat1);

  let R2 = radius(lat2);
  let x2 = R2*cos(lat2)*cos(lng2);
  let y2 = R2*cos(lat2)*sin(lng2);
  let z2 = R2*sin(lat2);

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
  let R = 6371; // Radius of the earth in km
  let dLat = deg2rad(lat2-lat1);  // deg2rad below
  let dLon = deg2rad(lon2-lon1); 
  let a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ; 
  let c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  let d = R * c; // Distance in km
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI/180)
}