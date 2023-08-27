import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

import 'message.dart';

///
///用户关系
///
class UserShip extends DbBaseModel {
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

  ///用户id
  ObjectId uid;

  ///会话id
  ObjectId sid;

  ///关联目标id（用户id或群组id）
  ObjectId rid;

  ///关系来源id（用户id或群组id）
  ObjectId fid;

  ///关系来源
  int from;

  ///关系状态
  int state;

  ///申请描述
  String apply;

  ///好友备注名 或 群昵称
  String alias;

  ///是否处于对话状态
  bool dialog;

  ///消息是否显示通知
  bool notice;

  ///是否置顶聊天
  bool top;

  ///未读消息数量
  int unread;

  ///最近消息缩写
  String recent;

  ///最近消息时间
  int update;

  ///对话激活时间
  int active;

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

  ///
  ///展示的名称
  ///
  String displayNick = '';

  ///
  ///展示的图标
  ///
  String displayIcon = '';

  ///
  ///展示的头像
  ///
  List<String> displayHead = [];

  ///
  ///展示的名称对应的拼音
  ///
  String displayPinyin = '';

  ///
  ///消息加载序号
  ///
  int msgasync = 0;

  ///
  ///消息缓存列表
  ///
  List<Message> msgcache = [];

  ///
  ///消息加载完毕
  ///
  bool msgloaded = false;

  UserShip({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    ObjectId? uid,
    ObjectId? sid,
    ObjectId? rid,
    ObjectId? fid,
    int? from,
    int? state,
    String? apply,
    String? alias,
    bool? dialog,
    bool? notice,
    bool? top,
    int? unread,
    String? recent,
    int? update,
    int? active,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        uid = uid ?? ObjectId.fromHexString('000000000000000000000000'),
        sid = sid ?? ObjectId.fromHexString('000000000000000000000000'),
        rid = rid ?? ObjectId.fromHexString('000000000000000000000000'),
        fid = fid ?? ObjectId.fromHexString('000000000000000000000000'),
        from = from ?? 0,
        state = state ?? 0,
        apply = apply ?? '',
        alias = alias ?? '',
        dialog = dialog ?? true,
        notice = notice ?? true,
        top = top ?? false,
        unread = unread ?? 0,
        recent = recent ?? '',
        update = update ?? DateTime.now().millisecondsSinceEpoch,
        active = active ?? DateTime.now().millisecondsSinceEpoch;

  factory UserShip.fromString(String data) {
    return UserShip.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory UserShip.fromJson(Map<String, dynamic> map) {
    return UserShip(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      uid: DbQueryField.tryParseObjectId(map['uid']),
      sid: DbQueryField.tryParseObjectId(map['sid']),
      rid: DbQueryField.tryParseObjectId(map['rid']),
      fid: DbQueryField.tryParseObjectId(map['fid']),
      from: DbQueryField.tryParseInt(map['from']),
      state: DbQueryField.tryParseInt(map['state']),
      apply: DbQueryField.tryParseString(map['apply']),
      alias: DbQueryField.tryParseString(map['alias']),
      dialog: DbQueryField.tryParseBool(map['dialog']),
      notice: DbQueryField.tryParseBool(map['notice']),
      top: DbQueryField.tryParseBool(map['top']),
      unread: DbQueryField.tryParseInt(map['unread']),
      recent: DbQueryField.tryParseString(map['recent']),
      update: DbQueryField.tryParseInt(map['update']),
      active: DbQueryField.tryParseInt(map['active']),
    );
  }

  @override
  String toString() {
    return 'UserShip(${jsonEncode(toJson())})';
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
      'sid': DbQueryField.toBaseType(sid),
      'rid': DbQueryField.toBaseType(rid),
      'fid': DbQueryField.toBaseType(fid),
      'from': DbQueryField.toBaseType(from),
      'state': DbQueryField.toBaseType(state),
      'apply': DbQueryField.toBaseType(apply),
      'alias': DbQueryField.toBaseType(alias),
      'dialog': DbQueryField.toBaseType(dialog),
      'notice': DbQueryField.toBaseType(notice),
      'top': DbQueryField.toBaseType(top),
      'unread': DbQueryField.toBaseType(unread),
      'recent': DbQueryField.toBaseType(recent),
      'update': DbQueryField.toBaseType(update),
      'active': DbQueryField.toBaseType(active),
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
      'sid': sid,
      'rid': rid,
      'fid': fid,
      'from': from,
      'state': state,
      'apply': apply,
      'alias': alias,
      'dialog': dialog,
      'notice': notice,
      'top': top,
      'unread': unread,
      'recent': recent,
      'update': update,
      'active': active,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {UserShip? parser}) {
    parser = parser ?? UserShip.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('uid')) uid = parser.uid;
    if (map.containsKey('sid')) sid = parser.sid;
    if (map.containsKey('rid')) rid = parser.rid;
    if (map.containsKey('fid')) fid = parser.fid;
    if (map.containsKey('from')) from = parser.from;
    if (map.containsKey('state')) state = parser.state;
    if (map.containsKey('apply')) apply = parser.apply;
    if (map.containsKey('alias')) alias = parser.alias;
    if (map.containsKey('dialog')) dialog = parser.dialog;
    if (map.containsKey('notice')) notice = parser.notice;
    if (map.containsKey('top')) top = parser.top;
    if (map.containsKey('unread')) unread = parser.unread;
    if (map.containsKey('recent')) recent = parser.recent;
    if (map.containsKey('update')) update = parser.update;
    if (map.containsKey('active')) active = parser.active;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('uid')) uid = map['uid'];
    if (map.containsKey('sid')) sid = map['sid'];
    if (map.containsKey('rid')) rid = map['rid'];
    if (map.containsKey('fid')) fid = map['fid'];
    if (map.containsKey('from')) from = map['from'];
    if (map.containsKey('state')) state = map['state'];
    if (map.containsKey('apply')) apply = map['apply'];
    if (map.containsKey('alias')) alias = map['alias'];
    if (map.containsKey('dialog')) dialog = map['dialog'];
    if (map.containsKey('notice')) notice = map['notice'];
    if (map.containsKey('top')) top = map['top'];
    if (map.containsKey('unread')) unread = map['unread'];
    if (map.containsKey('recent')) recent = map['recent'];
    if (map.containsKey('update')) update = map['update'];
    if (map.containsKey('active')) active = map['active'];
  }
}

class UserShipDirty {
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

  ///用户id
  set uid(ObjectId value) => data['uid'] = DbQueryField.toBaseType(value);

  ///会话id
  set sid(ObjectId value) => data['sid'] = DbQueryField.toBaseType(value);

  ///关联目标id（用户id或群组id）
  set rid(ObjectId value) => data['rid'] = DbQueryField.toBaseType(value);

  ///关系来源id（用户id或群组id）
  set fid(ObjectId value) => data['fid'] = DbQueryField.toBaseType(value);

  ///关系来源
  set from(int value) => data['from'] = DbQueryField.toBaseType(value);

  ///关系状态
  set state(int value) => data['state'] = DbQueryField.toBaseType(value);

  ///申请描述
  set apply(String value) => data['apply'] = DbQueryField.toBaseType(value);

  ///好友备注名 或 群昵称
  set alias(String value) => data['alias'] = DbQueryField.toBaseType(value);

  ///是否处于对话状态
  set dialog(bool value) => data['dialog'] = DbQueryField.toBaseType(value);

  ///消息是否显示通知
  set notice(bool value) => data['notice'] = DbQueryField.toBaseType(value);

  ///是否置顶聊天
  set top(bool value) => data['top'] = DbQueryField.toBaseType(value);

  ///未读消息数量
  set unread(int value) => data['unread'] = DbQueryField.toBaseType(value);

  ///最近消息缩写
  set recent(String value) => data['recent'] = DbQueryField.toBaseType(value);

  ///最近消息时间
  set update(int value) => data['update'] = DbQueryField.toBaseType(value);

  ///对话激活时间
  set active(int value) => data['active'] = DbQueryField.toBaseType(value);
}
