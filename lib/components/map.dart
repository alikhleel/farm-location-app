// @dart=2.9

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui'
    as ui; // imported as ui to prevent conflict between ui.Image and the Image widget
import 'package:provider/provider.dart';

import '../models/farm.dart';
import '../provider/app_provider.dart';
import '../services/check_permission.dart';
import '../services/geolocator.dart';

class MapPage extends StatefulWidget {
  static GoogleMapController _controller;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  StreamSubscription _locaionSubscription;
  final _geo = GeolocatorService();
  Circle _circle;
  Marker _marker;
  AppProvider _appProvider;
  CameraPosition initialCamera;
  CheckPermission checkPermission;
  BitmapDescriptor bitmapDescriptor;
  @override
  void initState() {
    super.initState();
    checkPermission = CheckPermission(context: context);
    checkPermission.requestLocationPermission();
    checkPermission.gpsService();
    getMarker();
  }

  @override
  void dispose() {
    if (_locaionSubscription != null) _locaionSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appProvider = Provider.of<AppProvider>(context);
    getCurrentLocation();
    return FutureProvider<List<Farm>>.value(
      value: null,
      builder: (context, child) => _buildGoogleMap(),
      initialData: [],
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: setInitalMap(),
      mapType: MapType.hybrid,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      minMaxZoomPreference: MinMaxZoomPreference(0, 18.5),
      zoomControlsEnabled: false,
      circles: Set.of((_circle != null ? [_circle] : [])),
      markers: Set.of((_marker != null ? [_marker] : [])),
      gestureRecognizers: Set()
        ..add(
          Factory<DragGestureRecognizer>(() => Test(() {
                _appProvider.isTracking = false;
              })),
        ),
      onMapCreated: (controller) {
        MapPage._controller = controller;
      },
    );
  }

  updateLocation(Position position, bitmapDescriptor) {
    LatLng latLng = LatLng(position.latitude, position.longitude);

    this.setState(() {
      _marker = Marker(
        markerId: MarkerId("my-home"),
        draggable: false,
        visible: true,
        consumeTapEvents: true,
        onTap: () {},
        flat: true,
        zIndex: 1,
        anchor: Offset(0.5, 0.5),
        icon: bitmapDescriptor,
        position: latLng,
      );
      _circle = Circle(
        circleId: CircleId("my-location"),
        radius: position.accuracy ?? 5,
        zIndex: 2,
        center: latLng,
        strokeWidth: 0,
        strokeColor: Colors.red,
        fillColor: Colors.red.withAlpha(70),
      );
    });
  }

  getMarker() async {
    bitmapDescriptor = await _bitmapDescriptorFromSvgAsset(
        context, 'assets/icons/my_location.svg');
  }

  getCurrentLocation() async {
    try {
      if (_locaionSubscription != null) _locaionSubscription.cancel();
      _locaionSubscription = _geo.getStreamLocation().listen((event) async {
        _appProvider.lastLocation = LatLng(event.latitude, event.longitude);
        updateLocation(event, bitmapDescriptor);

        if (_appProvider.isTracking) {
          if (MapPage._controller != null) {
            // var zoom = await MapPage._controller.getZoomLevel();
            MapPage._controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(event.latitude, event.longitude),
                    zoom: 17)));
          }
        }
      });
    } catch (e) {
      //print(e);
    }
  }

  CameraPosition setInitalMap() {
    LatLng location = _appProvider.lastLocation;

    if (location != null) {
      return CameraPosition(target: _appProvider.lastLocation, zoom: 18.0);
    } else {
      return CameraPosition(target: LatLng(25.3057092, 49.543273), zoom: 10.0);
    }
  }
}

class Test extends DragGestureRecognizer {
  Function _test;

  Test(this._test);

  @override
  void resolve(GestureDisposition disposition) {
    super.resolve(disposition);
    //print(disposition);

    this._test();
  }

  @override
  String get debugDescription => 'dragging';

  @override
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    return false;
  }
}

Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
    BuildContext context, String assetName) async {
  // Read SVG file as String
  String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
  // Create DrawableRoot from SVG String
  DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, null);

  // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
  MediaQueryData queryData = MediaQuery.of(context);
  double devicePixelRatio = queryData.devicePixelRatio;
  double width = 64 * devicePixelRatio; // where 32 is your SVG's original width
  double height = 64 * devicePixelRatio; // same thing

  // Convert to ui.Picture
  ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

  // Convert to ui.Image. toImage() takes width and height as parameters
  // you need to find the best size to suit your needs and take into account the
  // screen DPI
  ui.Image image = await picture.toImage(width.toInt(), width.toInt());
  ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
}
