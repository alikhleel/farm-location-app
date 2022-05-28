// @dart=2.9

import 'package:access_settings_menu/access_settings_menu.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';

class CheckPermission {
  BuildContext context;

  CheckPermission({this.context});

/*Checking if your App has been Given Permission*/
  Future<void> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await LocationPermissions().requestPermissions();
    if (granted != PermissionStatus.granted) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
  }

/*Show dialog if GPS not enabled and open settings location*/
  Future _checkGps() async {
    var status = await LocationPermissions().checkServiceStatus();
    if (!(status == ServiceStatus.enabled)) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("لا يمكن الوصول إلى موقعك الحالي"),
                content: const Text('الرجاء التأكد من أن الـGPS يعمل'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('موافق'),
                      onPressed: () {
                        _openSettingsMenu("ACTION_LOCATION_SOURCE_SETTINGS");
                        Navigator.of(context, rootNavigator: true).pop();
                      })
                ],
              );
            });
      }
    }
  }

/*Check if gps service is enabled or not*/
  Future gpsService() async {
    var status = await LocationPermissions().checkServiceStatus();
    if (!(status == ServiceStatus.enabled)) {
      _checkGps();
      return null;
    } else
      return true;
  }

  _openSettingsMenu(settingsName) async {
    var resultSettingsOpening = false;

    try {
      resultSettingsOpening =
          await AccessSettingsMenu.openSettings(settingsType: settingsName);
    } catch (e) {
      resultSettingsOpening = false;
    }
    return resultSettingsOpening;
  }
}
