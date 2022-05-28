// @dart=2.9

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../components/flushbar.dart';
import '../components/map.dart';
import '../components/searchBar.dart';
import '../models/farm.dart';
import '../provider/app_provider.dart';
import '../services/auth.dart';
import '../services/check_permission.dart';
import 'add_farm.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isFloatHide = false;
  bool isSearchHide = false;
  MapPage map;
  AppProvider appProvider;
  bool permission;

  @override
  Widget build(BuildContext context) {
    appProvider = Provider.of<AppProvider>(context);
    permission = Provider.of<bool>(context);
    FocusScope.of(context).unfocus();
    return Scaffold(
      floatingActionButton:
          (!isFloatHide) ? _buildFloatingAction() : Container(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            map = MapPage(),
            (!isSearchHide)
                ? Positioned(
                    right: 0,
                    left: 0,
                    top: 20,
                    child: Builder(
                      builder: (context) => GestureDetector(
                          onTap: () {
                            Scaffold.of(context).hideCurrentSnackBar();
                            showSearch(
                                context: context, delegate: SearchProcess());
                          },
                          child: searchBar(context)),
                    ),
                  )
                : Container(),
            Positioned(
              left: 10,
              top: 100,
              child: Builder(
                builder: (context) => FloatingActionButton(
                  onPressed: () => AuthService().logout(),
                  child: const Icon(Icons.exit_to_app),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void buildBottomSheetPage(BuildContext context) async {
    setState(() {
      isSearchHide = true;
    });
    FarmLocation position = FarmLocation(
        latitude: appProvider.lastLocation.latitude,
        longtude: appProvider.lastLocation.longitude);
    if (position == null) return;
    var saved = await showMaterialModalBottomSheet(
      context: context,
      useRootNavigator: true,
      enableDrag: false,
      animationCurve: Curves.easeInOutQuart,
      duration: const Duration(milliseconds: 900),
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (context) => AddFarmPage(position),
    );

    if (saved == "success") {
      ApplicationSnackBar.showSnackBarWithMessage(
          context: context,
          message: "تمت الإضافة",
          isValid: true,
          onDone: () {
            setState(() {
              isSearchHide = false;
            });
          });
    } else {
      setState(() {
        isSearchHide = false;
      });
    }
  }

  Widget _buildFloatingAction() {
    var checkPermission = CheckPermission(context: context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Builder(
          builder: (context) => FloatingActionButton(
            heroTag: null,
            onPressed: () {
              if (!permission) {
                checkPermission.gpsService();
              } else
                appProvider.isTracking = true;
            },
            child: (permission)
                ? const Icon(Icons.my_location)
                : const Icon(Icons.location_disabled),
          ),
        ),
        const SizedBox(height: 20),
        Builder(
          builder: (context) => FloatingActionButton(
            heroTag: null,
            onPressed: () {
              buildBottomSheetPage(context);
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
