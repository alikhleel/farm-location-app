// @dart=2.9

import 'package:flutter/material.dart';

import '../constant/color.dart';

Widget searchBar(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    height: MediaQuery.of(context).size.height / 16,
    width: double.infinity - 100,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.search,
            color: Color(ApplicationColor.primarycolor),
          ),
          Text(
            "بحــث",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.black),
          ),
        ],
      ),
    ),
  );
}
