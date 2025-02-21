import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  StreamSubscription<Position>? _locationSubscription;
  bool isPermissionGranted = false;
  StreamSubscription<CompassEvent>? _compassSubscription;
  GoogleMapController? _mapController;
  double _bearing = 0.0; // اتجاه البوصلة
  Polyline _routePolyline = const Polyline(polylineId: PolylineId('route'));

  TrackingCubit() : super(TrackingState.initial()) {
    checkAndRequestPermission();
    _trackCompass();
  }

  /// Check & Request Location Permission
  Future<void> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      isPermissionGranted = false;
    } else {
      isPermissionGranted = true;
      _trackUserLocation();
    }
  }

  /// متابعة الموقع وتحديث الكاميرا
  void _trackUserLocation() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // تحديث كل 2 متر
      ),
    ).listen((Position position) async {
      final LatLng newPosition = LatLng(position.latitude, position.longitude);
      emit(state.copyWith(currentLocation: newPosition));

      // تحديث الكاميرا
      _updateCamera();
      fetchPolyline(); // تحديث مسار الطريق

      // حساب المسافة
      final double distance = await calculateDistance(
        newPosition,
        LatLng(30.0167698, 31.2596834),
      );
      emit(state.copyWith(distance: distance));
    });
  }

  /// متابعة اتجاه البوصلة
  void _trackCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        _bearing = event.heading!;
        emit(state.copyWith(bearing: _bearing));
        _updateCamera();
      }
    });
  }

  /// تحديث الكاميرا بناءً على الموقع والاتجاه
  Future<void> _updateCamera() async {
    if (_mapController == null || state.currentLocation == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: state.currentLocation!,
          zoom: 18,
          tilt: 45, // إيقاف الميل ثلاثي الأبعاد
          bearing: _bearing, // اتجاه الجهاز
        ),
      ),
    );
  }

  /// استرجاع Polyline من Google Directions API
  Future<void> fetchPolyline() async {
    if (state.currentLocation == null) return;

    final Dio dio = Dio();
    final String apiKey = 'Google_map_key';
    final LatLng destination = LatLng(30.0167698, 31.2596834); // وجهة تجريبية
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${state.currentLocation!.latitude},${state.currentLocation!.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await dio.get(url);
    if (response.statusCode == 200) {
      final points = response.data['routes'][0]['overview_polyline']['points'];
      final List<LatLng> routePoints = _decodePolyline(points);

      _routePolyline = Polyline(
        polylineId: const PolylineId('route'),
        color: const Color(0xFF0A74DA),
        width: 5,
        points: routePoints,
      );

      // إضافة علامة للوجهة
      final Marker destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      emit(
        state.copyWith(
          routePolyline: _routePolyline,
          destinationMarker: destinationMarker,
        ),
      );
    }
  }

  /// فك ترميز الـ Polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  /// تعيين Google Map Controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<double> calculateDistance(LatLng start, LatLng end) async {
    return await Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _compassSubscription?.cancel();
    return super.close();
  }
}
