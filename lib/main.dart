import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {}; // Store your markers here
  LatLng? _currentLocation;
  String? _selectedPlantType;
  Map<String, Color> plantColors = {
    "කොහොඹ (Neem Tree)": Colors.green,
    "කෝමරිකා (Aloe vera)": Colors.red,
    "වද කහ (Sweet flag)": Colors.blue,
  };

  @override
  void initState() {
    super.initState();
  }

  Future<LatLng?> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted, you can now access the location.
    } else {
      // Permission denied, handle accordingly (e.g., show a message).
      // You can also provide an option for the user to manually enable permissions in settings.
    }
  }

  void _addMarker() async {
    await _requestLocationPermission();
    if (_currentLocation != null && _selectedPlantType != null) {
      String markerTitle = _selectedPlantType!;
      BitmapDescriptor markerIcon;

      // Assign different marker colors based on plant types
      if (markerTitle == 'කොහොඹ (Neem Tree)') {
        markerIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      } else if (markerTitle == 'කෝමරිකා (Aloe vera)') {
        markerIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else if (markerTitle == 'වද කහ (Sweet flag)') {
        markerIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      } else {
        markerIcon = BitmapDescriptor.defaultMarker;
      }

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(markerTitle),
            position: _currentLocation!,
            icon: markerIcon,
            infoWindow: InfoWindow(
              title: markerTitle,
              snippet: 'Custom location',
            ),
          ),
        );
      });
    }
  }

  void _locateCurrentLocation() async {
    await _requestLocationPermission();
    LatLng? location = await _getCurrentLocation();
    if (location != null && mapController != null) {
      setState(() {
        _currentLocation = location;
      });
      mapController.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Medicinal Plant Locator",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.green,
        toolbarHeight: 100,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.green[50],
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Plant Types:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    for (String plant in plantColors.keys)
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            color: plantColors[plant],
                          ),
                          SizedBox(width: 8),
                          Text(
                            plant,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    _locateCurrentLocation();
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? LatLng(0, 0),
                    zoom: _currentLocation != null ? 15.0 : 1.0,
                  ),
                  markers: _markers,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedPlantType,
                  items: [
                    "කොහොඹ (Neem Tree)",
                    "කෝමරිකා (Aloe vera)",
                    "වද කහ (Sweet flag)"
                  ]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(fontSize: 18),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlantType = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Plant Type',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _addMarker,
                child: Text(
                  'Add Location Marker',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
