import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

///
///源码文件
///
class CodeFile extends DbBaseModel {
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

  ///源文件名称
  String name;

  ///源文件版本
  int version;

  ///源文件内容
  String content;

  ///源文件内容的md5
  String md5key;

  ///源文件加载顺序
  int order;

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

  CodeFile({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    String? name,
    int? version,
    String? content,
    String? md5key,
    int? order,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        name = name ?? '',
        version = version ?? 0,
        content = content ?? '',
        md5key = md5key ?? '',
        order = order ?? 0;

  factory CodeFile.fromString(String data) {
    return CodeFile.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory CodeFile.fromJson(Map<String, dynamic> map) {
    return CodeFile(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      name: DbQueryField.tryParseString(map['name']),
      version: DbQueryField.tryParseInt(map['version']),
      content: DbQueryField.tryParseString(map['content']),
      md5key: DbQueryField.tryParseString(map['md5key']),
      order: DbQueryField.tryParseInt(map['order']),
    );
  }

  @override
  String toString() {
    return 'CodeFile(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      '_bsid': DbQueryField.toBaseType(_bsid),
      '_time': DbQueryField.toBaseType(_time),
      '_extra': DbQueryField.toBaseType(_extra),
      '_trans': DbQueryField.toBaseType(_trans),
      'name': DbQueryField.toBaseType(name),
      'version': DbQueryField.toBaseType(version),
      'content': DbQueryField.toBaseType(content),
      'md5key': DbQueryField.toBaseType(md5key),
      'order': DbQueryField.toBaseType(order),
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
      'name': name,
      'version': version,
      'content': content,
      'md5key': md5key,
      'order': order,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {CodeFile? parser}) {
    parser = parser ?? CodeFile.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('name')) name = parser.name;
    if (map.containsKey('version')) version = parser.version;
    if (map.containsKey('content')) content = parser.content;
    if (map.containsKey('md5key')) md5key = parser.md5key;
    if (map.containsKey('order')) order = parser.order;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('name')) name = map['name'];
    if (map.containsKey('version')) version = map['version'];
    if (map.containsKey('content')) content = map['content'];
    if (map.containsKey('md5key')) md5key = map['md5key'];
    if (map.containsKey('order')) order = map['order'];
  }
}

class CodeFileDirty {
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

  ///源文件名称
  set name(String value) => data['name'] = DbQueryField.toBaseType(value);

  ///源文件版本
  set version(int value) => data['version'] = DbQueryField.toBaseType(value);

  ///源文件内容
  set content(String value) => data['content'] = DbQueryField.toBaseType(value);

  ///源文件内容的md5
  set md5key(String value) => data['md5key'] = DbQueryField.toBaseType(value);

  ///源文件加载顺序
  set order(int value) => data['order'] = DbQueryField.toBaseType(value);
}
