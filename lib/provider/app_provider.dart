// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/region.dart';

enum typeOfSelected {
  addRegion,
  searchRegion,
  currentRegion,
}

class AppProvider with ChangeNotifier {
  Region _selectedAddRegion;
  Region _selectedSearchRegion;
  Region _currentRegion;
  bool _isTracking = true;
  bool _isGPSEnable = false;
  LatLng _lastLocation;

  bool first = true;

  AppProvider() {
    loadPreferences();
  }

  //Getters

  LatLng get lastLocation => _lastLocation;

  bool get isGPSEnable => _isGPSEnable;

  Region get selectedAddRegion => _selectedAddRegion;

  Region get selectedSearchRegion => _selectedSearchRegion;

  Region get currentRegion => _currentRegion;

  bool get isTracking {
    return _isTracking;
  }

  //Setters
  set lastLocation(LatLng location) {
    _lastLocation = location;
    savePreferences();
  }

  set isGPSEnable(bool isEnable) {
    _isGPSEnable = isEnable;
    _isTracking = isEnable;

    notifyListeners();
    print("change isGPSEnable");
  }

  set isTracking(bool isTracking) {
    _isTracking = isTracking;
    notifyListeners();
    print("change isTracking");
  }

  void setSelected(Region region, typeOfSelected type) {
    switch (type) {
      case typeOfSelected.addRegion:
        selectedAddRegion = region;
        break;
      case typeOfSelected.searchRegion:
        selectedSearchRegion = region;
        break;
      case typeOfSelected.currentRegion:
        currentRegion = region;
        break;
      default:
        throw NoSuchMethodError;
    }
  }

  Region getSelected(typeOfSelected type) {
    switch (type) {
      case typeOfSelected.addRegion:
        return selectedAddRegion;
        break;
      case typeOfSelected.searchRegion:
        return selectedSearchRegion;
        break;
      case typeOfSelected.currentRegion:
        return currentRegion;
        break;
      default:
        throw NoSuchMethodError;
    }
  }

  set currentRegion(Region region) {
    _currentRegion = region;
    notifyListeners();
    print("change currentRegion");
  }

  set selectedAddRegion(Region region) {
    _selectedAddRegion = region;
    notifyListeners();
    savePreferences();
    print("change selectedAddRegion");
  }

  set selectedSearchRegion(Region region) {
    _selectedSearchRegion = region;
    notifyListeners();
    savePreferences();
    print("change selectedSearchRegion");
  }

  void savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "selectedAddRegion", json.encode(_selectedAddRegion.toJson()));
    prefs.setString(
        "selectedSearchRegion", json.encode(_selectedSearchRegion.toJson()));
    prefs.setString("lastLocation", json.encode(_lastLocation.toJson()));
    print("saved all data");
  }

  void loadPreferences() async {
    print("selectedAddRegion");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedAddRegion = prefs.getString("selectedAddRegion");
    if (selectedAddRegion != null)
      _selectedAddRegion = Region.fromJson(json.decode(selectedAddRegion));
    else
      _selectedAddRegion = Region(name: "", id: "");

    String selectedSearchRegion = prefs.getString("selectedSearchRegion");
    if (selectedSearchRegion != null)
      _selectedSearchRegion =
          Region.fromJson(json.decode(selectedSearchRegion));
    else
      _selectedSearchRegion = Region(name: "", id: "");

    String lastLocation = prefs.getString("lastLocation");
    if (lastLocation != null)
      _lastLocation = LatLng.fromJson(json.decode(lastLocation));
    print("finish loading all data");
  }
}
