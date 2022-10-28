import 'dart:math';

import 'package:dio/dio.dart';
import 'package:radish_app/constants/keys.dart';
import 'package:radish_app/data/address_model.dart';
import 'package:radish_app/data/address_point_model.dart';
import 'package:radish_app/utils/logger.dart';

class AddressService {

  // string타입 검색주소 api 데이터 받기
  Future<AddressModel> SearchAddressByStr(String text) async {

    final formData = {
      'key' : VWORLD_KEY,
      'request' : 'search',
      'type' : 'ADDRESS',
      'category' : 'ROAD',
      'query' : text,
      'size' : 30,
    };

    // http통신 응답결과 받기
    final response = await Dio().get(
        'http://api.vworld.kr/req/search',
        queryParameters: formData)
        .catchError((e){
      logger.e(e.message);
    });

    //api 오브젝트 모델 연동
    AddressModel addressModel =
    AddressModel.fromJson(response.data["response"]);

    return addressModel;

  }

  Future<List<AddressPointModel>> findAddressByCoordinate (
      {required double log, required double lat}) async {

    final List<Map<String, dynamic>> formDatas = <Map<String, dynamic>> [];

    formDatas.add({
      'key' : VWORLD_KEY,
      'service' : 'address',
      'request' : 'getAddress',
      'type' : 'PARCEL',
      'point' : '$log, $lat',
    });
    formDatas.add({
      'key' : VWORLD_KEY,
      'service' : 'address',
      'request' : 'getAddress',
      'type' : 'PARCEL',
      'point' : '${log - 0.01}, $lat',
    });
    formDatas.add({
      'key' : VWORLD_KEY,
      'service' : 'address',
      'request' : 'getAddress',
      'type' : 'PARCEL',
      'point' : '${log + 0.01}, $lat',
    });
    formDatas.add({
      'key' : VWORLD_KEY,
      'service' : 'address',
      'request' : 'getAddress',
      'type' : 'PARCEL',
      'point' : '$log, ${lat - 0.01}',
    });
    formDatas.add({
      'key' : VWORLD_KEY,
      'service' : 'address',
      'request' : 'getAddress',
      'type' : 'PARCEL',
      'point' : '$log,${lat + 0.01}',
    });

    List<AddressPointModel> addresses = [];

    for(Map<String, dynamic> formData in formDatas) {
      final response = await Dio()
          .get('http://api.vworld.kr/req/address', queryParameters: formData)
          .catchError((e){
        logger.e(e.message);
      });
      logger.d(response);

      AddressPointModel addressModel =
      AddressPointModel.fromJson(response.data["response"]);

      if(response.data['response']['status'] == 'OK')
        addresses.add(addressModel);

    }

    return addresses;
  }
}