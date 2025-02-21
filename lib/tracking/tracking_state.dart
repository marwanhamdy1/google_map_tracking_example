import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingState extends Equatable {
  final LatLng? currentLocation; // الموقع الحالي
  final double bearing; // اتجاه البوصلة
  final Polyline routePolyline; // خط المسار
  final Marker? destinationMarker; // علامة الوجهة
  final double? distance; // المسافة المتبقية للوصول إلى الوجهة

  const TrackingState({
    required this.currentLocation,
    required this.bearing,
    required this.routePolyline,
    this.destinationMarker,
    this.distance,
  });

  // حالة أولية
  factory TrackingState.initial() {
    return TrackingState(
      currentLocation: null,
      bearing: 0.0,
      routePolyline: const Polyline(polylineId: PolylineId('route')),
      destinationMarker: null,
      distance: null,
    );
  }

  // نسخ الحالة مع تحديث بعض القيم
  TrackingState copyWith({
    LatLng? currentLocation,
    double? bearing,
    Polyline? routePolyline,
    Marker? destinationMarker,
    double? distance,
  }) {
    return TrackingState(
      currentLocation: currentLocation ?? this.currentLocation,
      bearing: bearing ?? this.bearing,
      routePolyline: routePolyline ?? this.routePolyline,
      destinationMarker: destinationMarker ?? this.destinationMarker,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [
    currentLocation,
    bearing,
    routePolyline,
    destinationMarker,
    distance,
  ];
}
