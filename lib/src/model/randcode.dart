import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

///
///验证码
///
class Randcode extends DbBaseModel {
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

  ///手机号码
  String phone;

  ///验证码
  String code;

  ///是否已失效
  bool expired;

  ///过期时间
  int timeout;

  ///检测次数
  int testcnt;

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

  Randcode({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    String? phone,
    String? code,
    bool? expired,
    int? timeout,
    int? testcnt,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        phone = phone ?? '',
        code = code ?? '',
        expired = expired ?? false,
        timeout = timeout ?? 0,
        testcnt = testcnt ?? 0;

  factory Randcode.fromString(String data) {
    return Randcode.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Randcode.fromJson(Map<String, dynamic> map) {
    return Randcode(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      phone: DbQueryField.tryParseString(map['phone']),
      code: DbQueryField.tryParseString(map['code']),
      expired: DbQueryField.tryParseBool(map['expired']),
      timeout: DbQueryField.tryParseInt(map['timeout']),
      testcnt: DbQueryField.tryParseInt(map['testcnt']),
    );
  }

  @override
  String toString() {
    return 'Randcode(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      '_bsid': DbQueryField.toBaseType(_bsid),
      '_time': DbQueryField.toBaseType(_time),
      '_extra': DbQueryField.toBaseType(_extra),
      '_trans': DbQueryField.toBaseType(_trans),
      'phone': DbQueryField.toBaseType(phone),
      'code': DbQueryField.toBaseType(code),
      'expired': DbQueryField.toBaseType(expired),
      'timeout': DbQueryField.toBaseType(timeout),
      'testcnt': DbQueryField.toBaseType(testcnt),
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
      'phone': phone,
      'code': code,
      'expired': expired,
      'timeout': timeout,
      'testcnt': testcnt,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Randcode? parser}) {
    parser = parser ?? Randcode.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('phone')) phone = parser.phone;
    if (map.containsKey('code')) code = parser.code;
    if (map.containsKey('expired')) expired = parser.expired;
    if (map.containsKey('timeout')) timeout = parser.timeout;
    if (map.containsKey('testcnt')) testcnt = parser.testcnt;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('phone')) phone = map['phone'];
    if (map.containsKey('code')) code = map['code'];
    if (map.containsKey('expired')) expired = map['expired'];
    if (map.containsKey('timeout')) timeout = map['timeout'];
    if (map.containsKey('testcnt')) testcnt = map['testcnt'];
  }
}

class RandcodeDirty {
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

  ///手机号码
  set phone(String value) => data['phone'] = DbQueryField.toBaseType(value);

  ///验证码
  set code(String value) => data['code'] = DbQueryField.toBaseType(value);

  ///是否已失效
  set expired(bool value) => data['expired'] = DbQueryField.toBaseType(value);

  ///过期时间
  set timeout(int value) => data['timeout'] = DbQueryField.toBaseType(value);

  ///检测次数
  set testcnt(int value) => data['testcnt'] = DbQueryField.toBaseType(value);
}
