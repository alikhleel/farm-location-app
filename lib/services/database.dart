// @dart=2.9
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_location_app/services/auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/farm.dart';
import '../models/region.dart';

/*
 * document name would be in this formate {000000}
 * The first three zeros is the id of region
 * The last three zeros is the id f565arm 
 */
class DataBaseService {
  Future<bool> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
      //Here you can setState a bool like internetAvailable = false;
      //or use call this before uploading data to firestore/storage depending upon the result, you can move on further.
    }
  }

  String _generateDocId(String regionId, String farmId) {
    String part1 = "30" + "$regionId".padLeft(2, '0');
    String part2 = "$farmId".padLeft(3, '0');
    String finalPart = part1 + part2;
    return finalPart;
  }

  Future<List<Farm>> searchFarms(String regionId) async {
    return await FirebaseFirestore.instance
        .collection("Farms")
        .where('region_id', isEqualTo: regionId)
        .get()
        .then((value) {
      try {
        if (value.docs.isNotEmpty)
          return value.docs.map((e) => Farm.fromNetwork(e.data())).toList();
        else
          return null;
      } catch (e) {
        print(e.toString());
        return null;
      }
    });
  }

  Future<List<Farm>> getAllFarmsOfUser(String uid) async {
    print(await FirebaseFirestore.instance
        .collection("Farms")
        .where('region_id',
            whereIn: [/*(await getRegions()).map((e) => e.getId)*/])
        .get()
        .then((value) {
          try {
            if (value.docs.isNotEmpty)
              return value.docs.map((e) => Farm.fromNetwork(e.data())).toList();
            else
              return null;
          } catch (e) {
            print(e.toString());
            return null;
          }
        }));
    return null;
  }

  /// Get data from firebase
  Future<List<Region>> getRegions() async {
    var list = List<Region>.empty();
    int cmtNumber;
    try {
      String uid = AuthService().getUID();
      if (uid == null) return null;
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .get()
          .then((snapshot) {
        cmtNumber = snapshot.data()['cmt_number'];
      });

      await FirebaseFirestore.instance
          .collection("Regions")
          .where("cmt_number", isEqualTo: cmtNumber)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          list.add(Region.fromNetwork(element.data()));
        });
      });
    } catch (e) {
      return null;
    }
    return list;
  }

  Future<bool> createNewFarm(Farm farm) async {
    if (await _checkConnection() == false) return false;
    print(farm.toMap().toString());
    String docId = _generateDocId(farm.getRegion.getId, farm.getId);
    try {
      return await FirebaseFirestore.instance
          .collection("Farms")
          .doc(docId)
          .set(farm.toMap())
          .then((value) => true)
          .timeout(Duration(seconds: 5), onTimeout: () {
        throw Exception("timeout");
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> removeFarm(String docId) async {
    await FirebaseFirestore.instance.collection("Farms").doc(docId).delete();
  }

  Future<bool> updateFarm(Farm oldFarm, Farm newFarm) async {
    if (await _checkConnection() == false) return false;
    String oldDocId = _generateDocId(oldFarm.getRegion.getId, oldFarm.getId);
    String newDocId = _generateDocId(newFarm.getRegion.getId, newFarm.getId);
    try {
      if (oldDocId != newDocId) {
        removeFarm(oldDocId);
        createNewFarm(newFarm);
      } else
        return await FirebaseFirestore.instance
            .collection("Farms")
            .doc(oldDocId)
            .update(oldFarm.toMap())
            .timeout(Duration(seconds: 5), onTimeout: () {
          throw Exception("timeout");
        }).then((_) => true);
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }
}
