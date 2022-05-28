// @dart=2.9

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/map.dart';
import '../constant/color.dart';
import '../models/farm.dart';
import '../provider/app_provider.dart';
import '../services/geolocator.dart';

class NewLocationPage extends StatelessWidget {
  const NewLocationPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      body: SafeArea(
          right: true,
          left: true,
          child: Stack(
            children: <Widget>[
              MapPage(),
              Align(
                  alignment: const Alignment(0, 0.9),
                  child: _controlWidget(appProvider, context)),
            ],
          )),
    );
  }

  Widget _controlWidget(AppProvider appProvider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.arrow_back),
              onPressed: () {
                appProvider.isTracking = false;

                Navigator.pop(context, null);
              }),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  const Color(ApplicationColor.primarycolor)),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Text(
                'تغيير إلى موقعي',
                style: Theme.of(context).textTheme.button,
              ),
            ),
            onPressed: () async {
              var position = await GeolocatorService().getCurrentLocation();
              appProvider.isTracking = false;
              Navigator.pop(
                  context,
                  FarmLocation(
                      latitude: position.latitude,
                      longtude: position.longitude));
            },
          ),
          FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.gps_fixed),
              onPressed: () {
                appProvider.isTracking = true;
              }),
        ],
      ),
    );
  }
}
