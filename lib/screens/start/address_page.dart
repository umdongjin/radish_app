import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/src/provider.dart';
import 'package:radish_app/constants/shared_pref_keys.dart';
import 'package:radish_app/data/address_model.dart';
import 'package:radish_app/data/address_point_model.dart';
import 'package:radish_app/screens/start/address_service.dart';
import 'package:radish_app/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressPage extends StatefulWidget {
  AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {

  TextEditingController _addressController = TextEditingController();
  AddressModel? _addressModel;
  List<AddressPointModel> _addressPointModel = [];
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.all(16.0),

      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            TextFormField(
              onFieldSubmitted: (text) async {
                _addressPointModel.clear();
                _addressModel = await AddressService().SearchAddressByStr(text);
                setState(() {

                });
              },
              controller: _addressController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                prefixIconConstraints: BoxConstraints(
                    minWidth: 24,
                    minHeight: 24
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey),
                ),
                hintText: '도로명으로 검색하세요.',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),

            TextButton.icon(
              onPressed: () async {
                _addressModel = null;
                _addressPointModel.clear();
                setState(() {
                  _isGettingLocation = true;
                });

                Location location = new Location();

                bool _serviceEnabled;
                PermissionStatus _permissionGranted;
                LocationData _locationData;

                _serviceEnabled = await location.serviceEnabled();
                if (!_serviceEnabled) {
                  _serviceEnabled = await location.requestService();
                  if (!_serviceEnabled) {
                    return;
                  }
                }

                _permissionGranted = await location.hasPermission();
                if (_permissionGranted == PermissionStatus.denied) {
                  _permissionGranted = await location.requestPermission();
                  if (_permissionGranted != PermissionStatus.granted) {
                    return;
                  }
                }

                _locationData = await location.getLocation();
                logger.d(_locationData);

                List<AddressPointModel> addresses = await AddressService().findAddressByCoordinate(
                    log: _locationData.longitude!,
                    lat: _locationData.latitude!
                );

                _addressPointModel.addAll(addresses);

                setState(() {
                  _isGettingLocation = false;
                });
              },
              icon: _isGettingLocation
                  ?SizedBox(width:24, height:24, child: CircularProgressIndicator(color: Colors.white))
                  :Icon(
                  CupertinoIcons.compass,
                  color: Colors.white
              ),
              label: Text(_isGettingLocation
                  ?'위치찾는중...'
                  :'현재 위치로 찾기',
                style: Theme.of(context).textTheme.button,
              ),
            ),
            if(_addressModel != null)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16),

                  itemBuilder: (context, index){

                    if(_addressModel == null ||
                        _addressModel!.result == null ||
                        _addressModel!.result!.items == null ||
                        _addressModel!.result!.items![index].address == null)
                      return Container();

                    return ListTile(
                      onTap: (){
                        _saveAddressAndGoToNextPage(
                            _addressModel!.result!.items![index].address!.road??"",
                            num.parse(_addressModel!.result!.items![index].point!.y ?? "0"),
                            num.parse(_addressModel!.result!.items![index].point!.x ?? "0")
                        );
                      },
                      title: Text(_addressModel!.result!.items![index].address!.road??""),
                      subtitle: Text(_addressModel!.result!.items![index].address!.parcel??""),
                    );
                  },
                  itemCount: (_addressModel == null ||
                      _addressModel!.result == null ||
                      _addressModel!.result!.items == null)
                      ?0
                      :_addressModel!.result!.items!.length,
                ),
              ),

            if(_addressPointModel != null)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16),

                  itemBuilder: (context, index){

                    if(_addressPointModel[index].result == null ||
                        _addressPointModel[index].result!.isEmpty)
                      return Container();

                    return ListTile(
                      onTap: (){
                        _saveAddressAndGoToNextPage(
                            _addressPointModel[index].result![0].text??"",
                            num.parse(_addressPointModel[index].input!.point!.y ?? "0"),
                            num.parse(_addressPointModel[index].input!.point!.x ?? "0")
                        );
                      },
                      title: Text(_addressPointModel[index].result![0].text??""),
                      subtitle: Text(_addressPointModel[index].result![0].zipcode??""),
                    );
                  },
                  itemCount: _addressPointModel.length,
                ),
              ),

          ],),
      ),
    );

  }


  //Provider 페이지 이동 및 주소저장 인스턴스

  _saveAddressAndGoToNextPage(String address, num lat, num lon) async {
    await _saveAddressOnSharedPreference(address, lat, lon); //주소저장 함수
    context.read<PageController>().animateToPage(  //provider 페이지 이동 함수
        2,
        duration: Duration(milliseconds: 700),
        curve: Curves.easeOut);
  }

  _saveAddressOnSharedPreference(String address, num lat, num lon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SHARED_ADDRESS, address);
    await prefs.setDouble(SHARED_LAT, lat.toDouble());
    await prefs.setDouble(SHARED_LON, lon.toDouble());
  }

}