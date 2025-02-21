import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_tracking/tracking/tracking_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'tracking/tracking_cubit.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(30.0167698, 31.2596834), // نقطة بداية تجريبية
                  zoom: 16,
                ),
                onMapCreated: (controller) {
                  context.read<TrackingCubit>().setMapController(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                polylines: {
                  if (state.routePolyline.points.isNotEmpty)
                    state.routePolyline,
                },
                markers: {
                  if (state.destinationMarker != null) state.destinationMarker!,
                },
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: Text(
                    'المسافة المتبقية: ${state.distance?.toStringAsFixed(2) ?? '...'} متر',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
