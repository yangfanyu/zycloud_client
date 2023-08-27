import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

///
///异常日志
///
class LogError extends DbBaseModel {
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

  ///所属用户id
  ObjectId uid;

  ///客户端版本号
  int clientVersion;

  ///设备系统类型
  String deviceType;

  ///设备系统版本
  String deviceVersion;

  ///设备详细信息
  DbJsonWraper deviceDetail;

  ///异常详细信息
  DbJsonWraper errorDetail;

  ///异常产生时间
  int errorTime;

  ///异常是否解决
  bool finished;

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

  LogError({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    ObjectId? uid,
    int? clientVersion,
    String? deviceType,
    String? deviceVersion,
    DbJsonWraper? deviceDetail,
    DbJsonWraper? errorDetail,
    int? errorTime,
    bool? finished,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        uid = uid ?? ObjectId.fromHexString('000000000000000000000000'),
        clientVersion = clientVersion ?? 0,
        deviceType = deviceType ?? '',
        deviceVersion = deviceVersion ?? '',
        deviceDetail = deviceDetail ?? DbJsonWraper(),
        errorDetail = errorDetail ?? DbJsonWraper(),
        errorTime = errorTime ?? 0,
        finished = finished ?? false;

  factory LogError.fromString(String data) {
    return LogError.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory LogError.fromJson(Map<String, dynamic> map) {
    return LogError(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      uid: DbQueryField.tryParseObjectId(map['uid']),
      clientVersion: DbQueryField.tryParseInt(map['clientVersion']),
      deviceType: DbQueryField.tryParseString(map['deviceType']),
      deviceVersion: DbQueryField.tryParseString(map['deviceVersion']),
      deviceDetail: map['deviceDetail'] is Map ? DbJsonWraper.fromJson(map['deviceDetail']) : map['deviceDetail'],
      errorDetail: map['errorDetail'] is Map ? DbJsonWraper.fromJson(map['errorDetail']) : map['errorDetail'],
      errorTime: DbQueryField.tryParseInt(map['errorTime']),
      finished: DbQueryField.tryParseBool(map['finished']),
    );
  }

  @override
  String toString() {
    return 'LogError(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      '_bsid': DbQueryField.toBaseType(_bsid),
      '_time': DbQueryField.toBaseType(_time),
      '_extra': DbQueryField.toBaseType(_extra),
      '_trans': DbQueryField.toBaseType(_trans),
      'uid': DbQueryField.toBaseType(uid),
      'clientVersion': DbQueryField.toBaseType(clientVersion),
      'deviceType': DbQueryField.toBaseType(deviceType),
      'deviceVersion': DbQueryField.toBaseType(deviceVersion),
      'deviceDetail': DbQueryField.toBaseType(deviceDetail),
      'errorDetail': DbQueryField.toBaseType(errorDetail),
      'errorTime': DbQueryField.toBaseType(errorTime),
      'finished': DbQueryField.toBaseType(finished),
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
      'uid': uid,
      'clientVersion': clientVersion,
      'deviceType': deviceType,
      'deviceVersion': deviceVersion,
      'deviceDetail': deviceDetail,
      'errorDetail': errorDetail,
      'errorTime': errorTime,
      'finished': finished,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {LogError? parser}) {
    parser = parser ?? LogError.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('uid')) uid = parser.uid;
    if (map.containsKey('clientVersion')) clientVersion = parser.clientVersion;
    if (map.containsKey('deviceType')) deviceType = parser.deviceType;
    if (map.containsKey('deviceVersion')) deviceVersion = parser.deviceVersion;
    if (map.containsKey('deviceDetail')) deviceDetail = parser.deviceDetail;
    if (map.containsKey('errorDetail')) errorDetail = parser.errorDetail;
    if (map.containsKey('errorTime')) errorTime = parser.errorTime;
    if (map.containsKey('finished')) finished = parser.finished;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('uid')) uid = map['uid'];
    if (map.containsKey('clientVersion')) clientVersion = map['clientVersion'];
    if (map.containsKey('deviceType')) deviceType = map['deviceType'];
    if (map.containsKey('deviceVersion')) deviceVersion = map['deviceVersion'];
    if (map.containsKey('deviceDetail')) deviceDetail = map['deviceDetail'];
    if (map.containsKey('errorDetail')) errorDetail = map['errorDetail'];
    if (map.containsKey('errorTime')) errorTime = map['errorTime'];
    if (map.containsKey('finished')) finished = map['finished'];
  }
}

class LogErrorDirty {
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

  ///所属用户id
  set uid(ObjectId value) => data['uid'] = DbQueryField.toBaseType(value);

  ///客户端版本号
  set clientVersion(int value) => data['clientVersion'] = DbQueryField.toBaseType(value);

  ///设备系统类型
  set deviceType(String value) => data['deviceType'] = DbQueryField.toBaseType(value);

  ///设备系统版本
  set deviceVersion(String value) => data['deviceVersion'] = DbQueryField.toBaseType(value);

  ///设备详细信息
  set deviceDetail(DbJsonWraper value) => data['deviceDetail'] = DbQueryField.toBaseType(value);

  ///异常详细信息
  set errorDetail(DbJsonWraper value) => data['errorDetail'] = DbQueryField.toBaseType(value);

  ///异常产生时间
  set errorTime(int value) => data['errorTime'] = DbQueryField.toBaseType(value);

  ///异常是否解决
  set finished(bool value) => data['finished'] = DbQueryField.toBaseType(value);
}
