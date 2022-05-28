import '../components/circular_text.dart';
import '../components/flushbar.dart';
import '../constant/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:farm_location_app/models/farm.dart';

import '../models/region.dart';
import '../provider/app_provider.dart';
import '../services/database.dart';
import 'new_location.dart';

class EditPage extends StatefulWidget {
  final Farm oldFarm;
  const EditPage(this.oldFarm, {Key? key}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _numberFocus = FocusNode();
  final _nameFocus = FocusNode();
  bool _loading = false;
  bool _sure = false;
  late Farm _newFarm;

  var isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _newFarm = widget.oldFarm;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listRegion = Provider.of<List<Region>>(context);
    final appProvider = Provider.of<AppProvider>(context);
    _newFarm.setRegion = appProvider.currentRegion;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: WillPopScope(
        onWillPop: () async => await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => _onCancel(context)),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text(
                            //Title
                            'تعديل مزرعة ${widget.oldFarm.getName}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline5,
                            maxLines: 2,
                          ),
                        )),
                        const SizedBox(height: 30),
                        _numberField(context),
                        const SizedBox(height: 20),
                        _nameField(context),
                        const SizedBox(height: 20),
                        _buildRegions(listRegion),
                        const SizedBox(height: 10),
                        _positionField(context),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Builder(builder: (context) => _addButton(context)),
                //_cancelBtton(),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  //Get data after sign.
  Widget _buildRegions(List<Region> regions) {
    List<Widget> regionCircles = [];
    for (Region region in regions) {
      regionCircles.add(CircularText(region, typeOfSelected.currentRegion));
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

  Widget _numberField(BuildContext context) {
    return TextFormField(
      autofocus: false,
      readOnly: false,
      focusNode: _numberFocus,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        fieldFocusChange(context, _numberFocus, _nameFocus);
      },
      style: const TextStyle(color: Colors.black, fontSize: 23),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      keyboardType: TextInputType.phone,
      initialValue: widget.oldFarm.getId,
      onChanged: (value) => _newFarm.setId = value,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
          labelText: 'رقم المزرعة',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
    );
  }

  Widget _nameField(BuildContext context) {
    return TextFormField(
      initialValue: widget.oldFarm.getName,
      onChanged: (value) => _newFarm.setName = value,
      autofocus: false,
      focusNode: _nameFocus,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: Colors.black, fontSize: 23),
      keyboardType: TextInputType.text,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
          labelText: 'اسم المالك',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
    );
  }

  Widget _positionField(BuildContext context) {
    var lat = widget.oldFarm.getLocationCrd.latitude;
    var lng = widget.oldFarm.getLocationCrd.longtude;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: TextFormField(
                key: Key('$lat, $lng'),
                initialValue: '$lat, $lng',
                style: const TextStyle(color: Colors.black, fontSize: 23),
                readOnly: true,
                enableInteractiveSelection: false,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'الإحداثيات',
                  contentPadding:
                      const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(0)),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _navigateAndGetNewLocation(context);
            },
            child: Container(
              height: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              color: const Color(ApplicationColor.primarycolor),
              child: Center(
                child: Text(
                  "تغيير",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _addButton(BuildContext context) {
    return Expanded(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: _sure
            ? const Color(ApplicationColor.sure)
            : const Color(ApplicationColor.primarycolor),
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (_sure) {
          if (!_loading) {
            _submit(context);
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
            : Text((_sure) ? 'متأكد' : 'تعديل',
                style: Theme.of(context)
                    .textTheme
                    .button
                    ?.copyWith(color: Colors.white)),
      ),
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

  void _submit(BuildContext context) async {
    bool result = await DataBaseService().updateFarm(widget.oldFarm, _newFarm);
    setState(() {
      _loading = false;
      _sure = false;
    });
    if (result) {
      debugPrint("editing complete");
      ApplicationSnackBar.showSnackBarWithMessage(
          context: context,
          message: "تم التعديل",
          isValid: true,
          title: '',
          onDone: () {});
    } else {
      debugPrint("editing failed");
      ApplicationSnackBar.showSnackBarWithMessage(
          context: context,
          title: "حصل خطأ",
          message: "تأكد من اتصالك بالإنترنت",
          isValid: false,
          onDone: () {});
    }
  }

  _navigateAndGetNewLocation(BuildContext context) async {
    FarmLocation result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NewLocationPage(),
        ));

    setState(() {
      _newFarm.setLocationCrd = result;
    });
  }
}
