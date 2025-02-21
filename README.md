Tracking App

Overview

This Flutter project provides real-time location tracking with Google Maps integration, compass direction, and route polyline drawing using the Google Directions API. The app is built using the Bloc pattern for state management.

Features

Real-time user location tracking

Compass direction updates

Google Maps integration

Route polyline fetching from Google Directions API

Distance calculation between the current location and a predefined destination

Technologies Used

Flutter

Bloc (flutter_bloc) for state management

Google Maps API

Geolocator for location services

Flutter Compass for direction updates

Dio for making HTTP requests

Installation

Clone the repository:

git clone <repository_url>

Navigate to the project directory:

cd tracking_app

Install dependencies:

flutter pub get

Add your Google Maps API key:

Open AndroidManifest.xml and replace Google_map_key with your API key.

Do the same in ios/Runner/AppDelegate.swift if targeting iOS.

Usage

Run the application:

flutter run

Grant location permissions when prompted.

The map will display your current location and track movement in real time.

A polyline will be drawn to the predefined destination.

The distance to the destination will be displayed on the screen.

Code Structure

TrackingCubit: Handles state management for location tracking, compass updates, and polyline fetching.

TrackingScreen: UI implementation using BlocBuilder to reflect real-time updates.

TrackingState: Stores the state of tracking, including location, bearing, and polyline data.

Permissions Required

Ensure the following permissions are set in your AndroidManifest.xml and Info.plist (iOS):

Android (AndroidManifest.xml):

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

iOS (Info.plist):

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track your movement.</string>

Future Enhancements

Dynamic destination selection

Offline map support

Custom markers and UI improvements

License

This project is open-source and available under the MIT License.

