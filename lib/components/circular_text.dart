// @dart=2.9

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constant/color.dart';
import '../models/region.dart';
import '../provider/app_provider.dart';

class CircularText extends StatefulWidget {
  final Region _region;
  final typeOfSelected type;

  const CircularText(this._region, this.type, {Key key}) : super(key: key);
  @override
  _CircularTextState createState() => _CircularTextState();
}

class _CircularTextState extends State<CircularText> {
  @override
  Widget build(
    BuildContext context,
  ) {
    final appProvider = Provider.of<AppProvider>(context);
    var isClicked =
        appProvider.getSelected(widget.type).getId == widget._region.getId;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          appProvider.setSelected(widget._region, widget.type);
        },
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
            child: Text(widget._region.getName,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: isClicked ? Colors.white : Colors.black)),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(16),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                  spreadRadius: 1),
            ],
            gradient: isClicked
                ? const LinearGradient(colors: [
                    Color(ApplicationColor.deepBlueBtn),
                    Color(ApplicationColor.lightBlueBtn)
                  ], begin: Alignment.centerRight, end: Alignment.centerLeft)
                : null,
          ),
        ),
      ),
    );
  }
}
