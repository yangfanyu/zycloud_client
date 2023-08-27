import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

///
///商品
///
class PayGoods extends DbBaseModel {
  ///唯一id
  ObjectId _id;

  ///商户id
  ObjectId _bsid;

  ///创建时间
  int _time;

  ///自定义数据
  DbJsonWraper _extra;

  ///未完成的事务列表
  List<ObjectId> _trans;

  ///商品编号
  int goodsNo;

  ///商品名称
  String goodsName;

  ///商品图标
  String goodsIcon;

  ///商品描述
  String goodsDesc;

  ///商品购买时实际支付RMB金额（分）
  int goodsActualRmbfen;

  ///商品购买后账号得到RMB金额（分）
  int goodsGottenRmbfen;

  ///商品购买后得到的虚拟货币值
  int goodsVirtualValue;

  ///唯一id
  ObjectId get id => _id;

  ///商户id
  ObjectId get bsid => _bsid;

  ///创建时间
  int get time => _time;

  ///自定义数据
  DbJsonWraper get extra => _extra;

  ///未完成的事务列表
  List<ObjectId> get trans => _trans;

  PayGoods({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    int? goodsNo,
    String? goodsName,
    String? goodsIcon,
    String? goodsDesc,
    int? goodsActualRmbfen,
    int? goodsGottenRmbfen,
    int? goodsVirtualValue,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        goodsNo = goodsNo ?? 0,
        goodsName = goodsName ?? '',
        goodsIcon = goodsIcon ?? '',
        goodsDesc = goodsDesc ?? '',
        goodsActualRmbfen = goodsActualRmbfen ?? 0,
        goodsGottenRmbfen = goodsGottenRmbfen ?? 0,
        goodsVirtualValue = goodsVirtualValue ?? 0;

  factory PayGoods.fromString(String data) {
    return PayGoods.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory PayGoods.fromJson(Map<String, dynamic> map) {
    return PayGoods(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      goodsNo: DbQueryField.tryParseInt(map['goodsNo']),
      goodsName: DbQueryField.tryParseString(map['goodsName']),
      goodsIcon: DbQueryField.tryParseString(map['goodsIcon']),
      goodsDesc: DbQueryField.tryParseString(map['goodsDesc']),
      goodsActualRmbfen: DbQueryField.tryParseInt(map['goodsActualRmbfen']),
      goodsGottenRmbfen: DbQueryField.tryParseInt(map['goodsGottenRmbfen']),
      goodsVirtualValue: DbQueryField.tryParseInt(map['goodsVirtualValue']),
    );
  }

  @override
  String toString() {
    return 'PayGoods(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      '_bsid': DbQueryField.toBaseType(_bsid),
      '_time': DbQueryField.toBaseType(_time),
      '_extra': DbQueryField.toBaseType(_extra),
      '_trans': DbQueryField.toBaseType(_trans),
      'goodsNo': DbQueryField.toBaseType(goodsNo),
      'goodsName': DbQueryField.toBaseType(goodsName),
      'goodsIcon': DbQueryField.toBaseType(goodsIcon),
      'goodsDesc': DbQueryField.toBaseType(goodsDesc),
      'goodsActualRmbfen': DbQueryField.toBaseType(goodsActualRmbfen),
      'goodsGottenRmbfen': DbQueryField.toBaseType(goodsGottenRmbfen),
      'goodsVirtualValue': DbQueryField.toBaseType(goodsVirtualValue),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      '_id': _id,
      '_bsid': _bsid,
      '_time': _time,
      '_extra': _extra,
      '_trans': _trans,
      'goodsNo': goodsNo,
      'goodsName': goodsName,
      'goodsIcon': goodsIcon,
      'goodsDesc': goodsDesc,
      'goodsActualRmbfen': goodsActualRmbfen,
      'goodsGottenRmbfen': goodsGottenRmbfen,
      'goodsVirtualValue': goodsVirtualValue,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {PayGoods? parser}) {
    parser = parser ?? PayGoods.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('goodsNo')) goodsNo = parser.goodsNo;
    if (map.containsKey('goodsName')) goodsName = parser.goodsName;
    if (map.containsKey('goodsIcon')) goodsIcon = parser.goodsIcon;
    if (map.containsKey('goodsDesc')) goodsDesc = parser.goodsDesc;
    if (map.containsKey('goodsActualRmbfen')) goodsActualRmbfen = parser.goodsActualRmbfen;
    if (map.containsKey('goodsGottenRmbfen')) goodsGottenRmbfen = parser.goodsGottenRmbfen;
    if (map.containsKey('goodsVirtualValue')) goodsVirtualValue = parser.goodsVirtualValue;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('goodsNo')) goodsNo = map['goodsNo'];
    if (map.containsKey('goodsName')) goodsName = map['goodsName'];
    if (map.containsKey('goodsIcon')) goodsIcon = map['goodsIcon'];
    if (map.containsKey('goodsDesc')) goodsDesc = map['goodsDesc'];
    if (map.containsKey('goodsActualRmbfen')) goodsActualRmbfen = map['goodsActualRmbfen'];
    if (map.containsKey('goodsGottenRmbfen')) goodsGottenRmbfen = map['goodsGottenRmbfen'];
    if (map.containsKey('goodsVirtualValue')) goodsVirtualValue = map['goodsVirtualValue'];
  }
}

class PayGoodsDirty {
  final Map<String, dynamic> data = {};

  ///唯一id
  set id(ObjectId value) => data['_id'] = DbQueryField.toBaseType(value);

  ///商户id
  set bsid(ObjectId value) => data['_bsid'] = DbQueryField.toBaseType(value);

  ///创建时间
  set time(int value) => data['_time'] = DbQueryField.toBaseType(value);

  ///自定义数据
  set extra(DbJsonWraper value) => data['_extra'] = DbQueryField.toBaseType(value);

  ///未完成的事务列表
  set trans(List<ObjectId> value) => data['_trans'] = DbQueryField.toBaseType(value);

  ///商品编号
  set goodsNo(int value) => data['goodsNo'] = DbQueryField.toBaseType(value);

  ///商品名称
  set goodsName(String value) => data['goodsName'] = DbQueryField.toBaseType(value);

  ///商品图标
  set goodsIcon(String value) => data['goodsIcon'] = DbQueryField.toBaseType(value);

  ///商品描述
  set goodsDesc(String value) => data['goodsDesc'] = DbQueryField.toBaseType(value);

  ///商品购买时实际支付RMB金额（分）
  set goodsActualRmbfen(int value) => data['goodsActualRmbfen'] = DbQueryField.toBaseType(value);

  ///商品购买后账号得到RMB金额（分）
  set goodsGottenRmbfen(int value) => data['goodsGottenRmbfen'] = DbQueryField.toBaseType(value);

  ///商品购买后得到的虚拟货币值
  set goodsVirtualValue(int value) => data['goodsVirtualValue'] = DbQueryField.toBaseType(value);
}
