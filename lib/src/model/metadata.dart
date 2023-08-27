import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

///
///文件信息
///
class Metadata extends DbBaseModel {
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

  ///上传者的用户id
  ObjectId uid;

  ///文件类型
  int type;

  ///文件保存的路径
  String path;

  ///文件的字节大小
  int size;

  ///文件是否已经删除
  bool removed;

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

  Metadata({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    ObjectId? uid,
    int? type,
    String? path,
    int? size,
    bool? removed,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        uid = uid ?? ObjectId.fromHexString('000000000000000000000000'),
        type = type ?? 0,
        path = path ?? '',
        size = size ?? 0,
        removed = removed ?? false;

  factory Metadata.fromString(String data) {
    return Metadata.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Metadata.fromJson(Map<String, dynamic> map) {
    return Metadata(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      uid: DbQueryField.tryParseObjectId(map['uid']),
      type: DbQueryField.tryParseInt(map['type']),
      path: DbQueryField.tryParseString(map['path']),
      size: DbQueryField.tryParseInt(map['size']),
      removed: DbQueryField.tryParseBool(map['removed']),
    );
  }

  @override
  String toString() {
    return 'Metadata(${jsonEncode(toJson())})';
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
      'type': DbQueryField.toBaseType(type),
      'path': DbQueryField.toBaseType(path),
      'size': DbQueryField.toBaseType(size),
      'removed': DbQueryField.toBaseType(removed),
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
      'type': type,
      'path': path,
      'size': size,
      'removed': removed,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Metadata? parser}) {
    parser = parser ?? Metadata.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('uid')) uid = parser.uid;
    if (map.containsKey('type')) type = parser.type;
    if (map.containsKey('path')) path = parser.path;
    if (map.containsKey('size')) size = parser.size;
    if (map.containsKey('removed')) removed = parser.removed;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('uid')) uid = map['uid'];
    if (map.containsKey('type')) type = map['type'];
    if (map.containsKey('path')) path = map['path'];
    if (map.containsKey('size')) size = map['size'];
    if (map.containsKey('removed')) removed = map['removed'];
  }
}

class MetadataDirty {
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

  ///上传者的用户id
  set uid(ObjectId value) => data['uid'] = DbQueryField.toBaseType(value);

  ///文件类型
  set type(int value) => data['type'] = DbQueryField.toBaseType(value);

  ///文件保存的路径
  set path(String value) => data['path'] = DbQueryField.toBaseType(value);

  ///文件的字节大小
  set size(int value) => data['size'] = DbQueryField.toBaseType(value);

  ///文件是否已经删除
  set removed(bool value) => data['removed'] = DbQueryField.toBaseType(value);
}
