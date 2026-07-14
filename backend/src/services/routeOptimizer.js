// backend/src/services/routeOptimizer.js

class RouteOptimizer {
  
  static calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; 
    const dLat = this._deg2rad(lat2 - lat1);
    const dLon = this._deg2rad(lon2 - lon1);
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(this._deg2rad(lat1)) * Math.cos(this._deg2rad(lat2)) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  }

  static _deg2rad(deg) {
    return deg * (Math.PI/180);
  }

  static estimateTime(distance, trafficFactor = 1) {
    const avgSpeed = 30 / 60; 
    const baseTime = distance / avgSpeed;
    return Math.round(baseTime * trafficFactor);
  }

  static optimizeRoute(orders, startLocation) {
    if (!orders || orders.length === 0) {
      return { route: [], totalDistance: 0, totalTime: 0 };
    }

    const locations = orders.map(order => ({
      id: order.order_id,
      lat: order.latitude || 0,
      lng: order.longitude || 0,
      order: order
    }));

    let currentLat = startLocation.lat;
    let currentLng = startLocation.lng;
    const route = [];
    let totalDistance = 0;
    let totalTime = 0;

    const unvisited = [...locations];

    while (unvisited.length > 0) {
      let nearestIndex = 0;
      let nearestDistance = Infinity;

      for (let i = 0; i < unvisited.length; i++) {
        const dist = this.calculateDistance(
          currentLat, currentLng,
          unvisited[i].lat, unvisited[i].lng
        );
        if (dist < nearestDistance) {
          nearestDistance = dist;
          nearestIndex = i;
        }
      }

      const nearest = unvisited.splice(nearestIndex, 1)[0];
      route.push(nearest.order);
      totalDistance += nearestDistance;
      
      const time = this.estimateTime(nearestDistance);
      totalTime += time;

      currentLat = nearest.lat;
      currentLng = nearest.lng;
    }

    return {
      route: route,
      totalDistance: Math.round(totalDistance * 10) / 10,
      totalTime: totalTime,
      estimatedEarnings: route.reduce((sum, o) => sum + (o.estimated_earning || 0), 0)
    };
  }

  static optimizeWithTimeWindows(orders, startLocation, startTime) {
    // خوارزمية متقدمة لتحسين المسار مع مراعاة وقت التوصيل
    // (يمكن تحسينها لاحقاً)
    return this.optimizeRoute(orders, startLocation);
  }

  static estimateCompletion(startTime, totalTime) {
    const estimatedEnd = new Date(startTime);
    estimatedEnd.setMinutes(estimatedEnd.getMinutes() + totalTime);
    return estimatedEnd;
  }

  static getTrafficFactor(date) {
    const hour = date.getHours();
    const day = date.getDay();
    
    const isPeakHour = (hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 19);
    const isWeekend = day === 0 || day === 6;
    
    if (isWeekend) return 1.1;
    if (isPeakHour) return 1.5;
    return 1.0;
  }
}

module.exports = RouteOptimizer;