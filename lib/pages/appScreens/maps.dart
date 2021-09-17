import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: must_be_immutable
class Maps extends StatefulWidget {
  String lat;
  String lng;
  String checkLocation;

  Maps(this.lat, this.lng, this.checkLocation);

  @override
  _MapsState createState() => _MapsState();
}

Completer<GoogleMapController> _controller = Completer();
Set<Marker> _markers = {};

class _MapsState extends State<Maps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (Text(widget.checkLocation)),
        centerTitle: true,
        backgroundColor: Color(0xff022b5e),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target:
                    LatLng(double.parse(widget.lat), double.parse(widget.lng)),
                zoom: 14.5),
            onMapCreated: (GoogleMapController controller) {
              // _controller.complete(controller);

              if (!_controller.isCompleted) {
                _controller.complete(controller);
              } else {}

              setState(() {
                _markers.add(
                  Marker(
                    markerId: MarkerId("init Mark_1"),
                    position: LatLng(
                      double.parse(widget.lat),
                      double.parse(widget.lng),
                    ),
                  ),
                );
              });
            },
            mapType: MapType.normal,
            markers: _markers,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            // minMaxZoomPreference: MinMaxZoomPreference(15, 19),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff022b5e),
        onPressed: () async {
          final GoogleMapController mapController = await _controller.future;
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(
                    double.parse(widget.lat),
                    double.parse(widget.lng),
                  ),
                  zoom: 14.5),
            ),
          );
        },
        child: Icon(
          Icons.center_focus_strong,
        ),
      ),
    );
  }
}
