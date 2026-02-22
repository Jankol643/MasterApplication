function calculateEuclidianDist(
  latP1: number,
  lonP1: number,
  latP2: number,
  lonP2: number,
) {
  const latP1Rad = (latP1 * Math.PI) / 180;
  const lonP1Rad = (lonP1 * Math.PI) / 180;
  const latP2Rad = (latP2 * Math.PI) / 180;
  const lonP2Rad = (lonP2 * Math.PI) / 180;

  const EarthR = 6371; // earth radius in km
  const dlon = lonP2 - lonP1;
  const dlat = latP2 - latP1;
  const a =
    Math.sin(dlat / 2) ^
    (2 + Math.cos(latP1) * Math.cos(latP2) * Math.sin(dlon / 2)) ^
    2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EarthR * c;
}

function circleIntersectArea(
  C1CenterX: number,
  C1CenterY: number,
  r1: number,
  C2CenterX: number,
  C2CenterY: number,
  r2: number,
): number {
  // Calculate the distance between the centers of the two circles
  const d = Math.hypot(C2CenterX - C1CenterX, C2CenterY - C1CenterY);

  // If the circles do not overlap or one is completely inside the other
  if (d >= r1 + r2) {
    // No overlap
    return 0;
  } else if (d <= Math.abs(r1 - r2)) {
    // One circle is completely inside the other
    // The overlapMath.PIng area is the area of the smaller circle
    const rMin = Math.min(r1, r2);
    return Math.PI * rMin * rMin;
  } else {
    // Partial overlap; calculate using the circle intersection formula
    const r1Sq = r1 * r1;
    const r2Sq = r2 * r2;

    // Calculate angles for the intersecting segments
    const alpha = Math.acos((d * d + r1Sq - r2Sq) / (2 * d * r1));
    const beta = Math.acos((d * d + r2Sq - r1Sq) / (2 * d * r2));

    // Calculate the area of the intersection
    const area =
      r1Sq * alpha +
      r2Sq * beta -
      0.5 *
        Math.sqrt(
          (-d + r1 + r2) * (d + r1 - r2) * (d - r1 + r2) * (d + r1 + r2),
        );

    return area;
  }
}
