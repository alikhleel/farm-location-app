// @dart=2.9

import '../components/circular_text.dart';
import '../models/farm.dart';
import '../models/region.dart';
import '../provider/app_provider.dart';
import '../services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_page.dart';

// I have added new thing to the original SearchDelegate class which is line 516.

class SearchProcess extends SearchDelegate {
  List<Farm> results = <Farm>[];

  @override
  String get searchFieldLabel => 'رقم المزرعة';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        FocusNode().unfocus();
        Future.delayed(const Duration(milliseconds: 500));
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final listRegion = Provider.of<List<Region>>(context);
    final appProvider = Provider.of<AppProvider>(context);
    DataBaseService dataBaseService = DataBaseService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        (listRegion != null)
            ? _topWidget(listRegion)
            : const Center(
                child: CircularProgressIndicator(),
              ),
        const Divider(
          height: 20,
          thickness: 1.5,
          color: Colors.black,
        ),
        Expanded(
          child: (listRegion != null)
              ? FutureBuilder<List<Farm>>(
                  future: dataBaseService.searchFarms(appProvider
                      .getSelected(typeOfSelected.searchRegion)
                      .getId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data != null) {
                        results = snapshot.data
                            .where((element) => element.getId.contains(query))
                            .toList();
                        if (results.isNotEmpty) {
                          return ListView.separated(
                              itemBuilder: (context, index) {
                                return _listTile(context, results[index]);
                              },
                              separatorBuilder: (context, index) =>
                                  const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Divider(
                                        color: Colors.grey,
                                        height: 5,
                                        thickness: 1,
                                      )),
                              itemCount: results.length);
                        } else {
                          return _emptyData(context);
                        }
                      } else {
                        return _emptyData(context);
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
              : const Center(
                  child: (CircularProgressIndicator()),
                ),
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final listRegion = Provider.of<List<Region>>(context);
    final appProvider = Provider.of<AppProvider>(context);
    DataBaseService dataBaseService = DataBaseService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        (listRegion != null)
            ? _topWidget(listRegion)
            : const Center(
                child: CircularProgressIndicator(),
              ),
        const Divider(
          height: 20,
          thickness: 1.5,
          color: Colors.black,
        ),
        Expanded(
          child: (listRegion != null)
              ? FutureBuilder<List<Farm>>(
                  future: dataBaseService.searchFarms(appProvider
                      .getSelected(typeOfSelected.searchRegion)
                      .getId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data != null) {
                        results = snapshot.data
                            .where((element) => element.getId.contains(query))
                            .toList();
                        if (results.isNotEmpty) {
                          return ListView.separated(
                              itemBuilder: (context, index) {
                                return _listTile(context, results[index]);
                              },
                              separatorBuilder: (context, index) =>
                                  const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Divider(
                                        color: Colors.grey,
                                        height: 5,
                                        thickness: 1,
                                      )),
                              itemCount: results.length);
                        } else {
                          return _emptyData(context);
                        }
                      } else {
                        return _emptyData(context);
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
              : const Center(
                  child: (CircularProgressIndicator()),
                ),
        )
      ],
    );
  }

  Widget _emptyData(BuildContext context) {
    return Center(
      child: Text(
        'لا يوجد بيانات',
        style: Theme.of(context).textTheme.caption.copyWith(fontSize: 20),
      ),
    );
  }

  Widget _listTile(BuildContext context, Farm farm) {
    final appProvider = Provider.of<AppProvider>(context);

    return ListTile(
        title: Text(
          farm.getId,
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Text(
          farm.getName,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () {
                _launchMapsUrl(
                    farm.getLocationCrd.latitude, farm.getLocationCrd.longtude);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                appProvider.setSelected(
                    farm.getRegion, typeOfSelected.currentRegion);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPage(farm),
                    ));
              },
            ),
          ],
        ));
  }

  Widget _topWidget(List<Region> listRegion) {
    List<Widget> regionCircles = [];
    print(listRegion);
    if (listRegion == null) return Container();
    for (Region region in listRegion) {
      if (region != null) {
        regionCircles.add(CircularText(region, typeOfSelected.searchRegion));
      } else {
        continue;
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: regionCircles,
      ),
    );
  }

  void _launchMapsUrl(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
