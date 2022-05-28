// @dart=2.9

import '../components/circular_text.dart';
import '../components/flushbar.dart';
import '../constant/color.dart';
import '../models/farm.dart';
import '../models/region.dart';
import '../provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/database.dart';

class AddFarmPage extends StatefulWidget {
  static const _numberFields = 2;
  final FarmLocation location;

  const AddFarmPage(this.location, {Key key}) : super(key: key);

  @override
  _AddFarmPageState createState() => _AddFarmPageState();
}

class _AddFarmPageState extends State<AddFarmPage> {
  String _farmId;
  String _farmerName;
  Region _selectedRegion;
  bool _loading = false;
  bool _sure = false;
  var isKeyboardOpen = false;

  @override
  Widget build(BuildContext context) {
    final listRegion = Provider.of<List<Region>>(context);
    var appProvider = Provider.of<AppProvider>(context);
    _selectedRegion = appProvider.selectedAddRegion;

    return WillPopScope(
      onWillPop: () async => await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => _onCancel(context)),
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Text(
                  //Title
                  'إضافة مزرعة جديدة',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
              )),
              const SizedBox(height: 30),
              _textfield(context, 0, 'رقم المزرعة', true),
              const SizedBox(height: 10),
              _textfield(context, 1, 'اسم المالك'),
              const SizedBox(height: 10),
              Text(appProvider.getSelected(typeOfSelected.addRegion).getName,
                  style: Theme.of(context).textTheme.headline6),
              const SizedBox(height: 5),
              (listRegion != null)
                  ? buildRegions(listRegion)
                  : const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _addButton(context),
                  _cancelBtton(),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

//Get data after sign.
  Widget buildRegions(List<Region> regions) {
    List<Widget> regionCircles = [];
    for (Region region in regions) {
      if (region != null) {
        regionCircles.add(CircularText(region, typeOfSelected.addRegion));
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
        ));
  }

  Widget _cancelBtton() {
    return Expanded(
        child: TextButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        if (_sure) {
          setState(() {
            _sure = false;
          });
        } else {
          await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => _onCancel(context));
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateColor.resolveWith(
            (states) => Colors.red.withAlpha(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'إلغاء',
          style:
              Theme.of(context).textTheme.button.copyWith(color: Colors.black),
        ),
      ),
    ));
  }

  Widget _addButton(BuildContext context) {
    return Expanded(
        child: ElevatedButton(
      style: TextButton.styleFrom(
        backgroundColor: _sure
            ? const Color(ApplicationColor.sure)
            : const Color(ApplicationColor.primarycolor),
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (_sure) {
          if (!_loading) {
            _submitNewFarm(context);
            setState(() {
              _loading = true;
            });
          }
        } else {
          setState(() {
            _sure = true;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: (_loading)
            ? const Center(child: CircularProgressIndicator())
            : Text((_sure) ? 'متأكد' : 'إضافة',
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.white)),
      ),
    ));
  }

  Widget _textfield(BuildContext context, int id, String hintText,
      [bool isNumber = false]) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: const Color(0xFF707070).withAlpha(45))),
        child: TextField(
          autofocus: id == 0,
          textInputAction: id == AddFarmPage._numberFields - 1
              ? TextInputAction.done
              : TextInputAction.next,
          onSubmitted: (value) {
            id != AddFarmPage._numberFields - 1
                ? FocusScope.of(context).nextFocus()
                : FocusScope.of(context).unfocus();
          },
          onChanged: (value) {
            switch (id) {
              case 0:
                _farmId = value;
                break;
              case 1:
                _farmerName = value;
                break;
            }
          },
          style: const TextStyle(color: Colors.black, fontSize: 23),
          inputFormatters: isNumber
              ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
              : null,
          keyboardType: isNumber ? TextInputType.phone : null,
          textAlign: TextAlign.center,
          decoration: InputDecoration.collapsed(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey)),
        ));
  }

  Widget _onCancel(BuildContext context) {
    return (_loading)
        ? Container()
        : AlertDialog(
            elevation: 25,
            title: const Text("إلغاء العملية"),
            content: const Text("هل تريد إلغاء هذه العملية"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.pop(context);
                  },
                  child: const Text("نعم")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("لا"))
            ],
          );
  }

  void _submitNewFarm(BuildContext context) async {
    Farm farm = Farm(
        id: _farmId,
        name: _farmerName,
        locationCoordinate: widget.location,
        region: _selectedRegion);
    bool result = await DataBaseService().createNewFarm(farm);

    setState(() {
      _loading = false;
      _sure = false;
    });

    if (result) {
      Navigator.pop(context, "success");
    } else {
      ApplicationSnackBar.showSnackBarWithMessage(
        context: context,
        title: "حصل خطأ",
        message: "تأكد من اتصالك بالإنترنت",
        isValid: false,
      );
    }
  }
}
