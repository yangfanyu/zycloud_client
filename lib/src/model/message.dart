import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

import 'location.dart';

///
///聊天消息
///
class Message extends DbBaseModel {
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

  ///聊天会话id
  ObjectId sid;

  ///发送者的id
  ObjectId uid;

  ///消息来源
  int from;

  ///消息类型
  int type;

  ///消息标题
  String title;

  ///消息主体
  String body;

  ///消息缩写
  String short;

  ///媒体的开始时间（实时媒体<=0表示通讯未开始过）
  int mediaTimeS;

  ///媒体的结束时间（减去mediaTimeS可得媒体时长）
  int mediaTimeE;

  ///媒体正在进行中
  bool mediaGoing;

  ///读取过静态媒体 或 参与实时媒体 的用户id
  List<ObjectId> mediaJoined;

  ///红包RMB金额总数
  int rmbfenTotal;

  ///红包已经被抢次数
  int rmbfenCount;

  ///红包金额分配数组
  List<int> rmbfenEvery;

  ///红包金额分配数组对应的幸运用户id
  List<ObjectId> rmbfenLuckly;

  ///红包被抢到后等待创建订单的用户id
  List<ObjectId> rmbfenPending;

  ///红包最近更新时间（红包最近被抢的时间）
  int rmbfenUpdate;

  ///红包逻辑是否已经完成（红包被抢完、红包过期后余额已完成退回检测）
  bool rmbfenFinished;

  ///红包通知消息相关的id：[原始红包消息id, 发送原始红包消息的用户id, 抢到红包的用户id]
  List<ObjectId> readpackNotice;

  ///分享名片的目标id（用户id或群组id）
  ObjectId shareCardId;

  ///分享名片的图标url
  String shareIconUrl;

  ///分享名片的头像url
  List<String> shareHeadUrl;

  ///分享网址url、媒体附件url
  String shareLinkUrl;

  ///位置分享消息的数据
  Location? shareLocation;

  ///自定义的消息类型
  int customType;

  ///本条是否已撤销
  bool revoked;

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
  ///消息发送者展示的名称
  ///
  String displayNick = '';

  ///
  ///消息发送者展示的图标
  ///
  String displayIcon = '';

  ///
  ///消息发送者展示的头像
  ///
  List<String> displayHead = [];

  Message({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    ObjectId? sid,
    ObjectId? uid,
    int? from,
    int? type,
    String? title,
    String? body,
    String? short,
    int? mediaTimeS,
    int? mediaTimeE,
    bool? mediaGoing,
    List<ObjectId>? mediaJoined,
    int? rmbfenTotal,
    int? rmbfenCount,
    List<int>? rmbfenEvery,
    List<ObjectId>? rmbfenLuckly,
    List<ObjectId>? rmbfenPending,
    int? rmbfenUpdate,
    bool? rmbfenFinished,
    List<ObjectId>? readpackNotice,
    ObjectId? shareCardId,
    String? shareIconUrl,
    List<String>? shareHeadUrl,
    String? shareLinkUrl,
    this.shareLocation,
    int? customType,
    bool? revoked,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        sid = sid ?? ObjectId.fromHexString('000000000000000000000000'),
        uid = uid ?? ObjectId.fromHexString('000000000000000000000000'),
        from = from ?? 0,
        type = type ?? 0,
        title = title ?? '',
        body = body ?? '',
        short = short ?? '',
        mediaTimeS = mediaTimeS ?? 0,
        mediaTimeE = mediaTimeE ?? 0,
        mediaGoing = mediaGoing ?? false,
        mediaJoined = mediaJoined ?? [],
        rmbfenTotal = rmbfenTotal ?? 0,
        rmbfenCount = rmbfenCount ?? 0,
        rmbfenEvery = rmbfenEvery ?? [],
        rmbfenLuckly = rmbfenLuckly ?? [],
        rmbfenPending = rmbfenPending ?? [],
        rmbfenUpdate = rmbfenUpdate ?? DateTime.now().millisecondsSinceEpoch,
        rmbfenFinished = rmbfenFinished ?? false,
        readpackNotice = readpackNotice ?? [],
        shareCardId = shareCardId ?? ObjectId.fromHexString('000000000000000000000000'),
        shareIconUrl = shareIconUrl ?? '',
        shareHeadUrl = shareHeadUrl ?? [],
        shareLinkUrl = shareLinkUrl ?? '',
        customType = customType ?? 0,
        revoked = revoked ?? false;

  factory Message.fromString(String data) {
    return Message.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Message.fromJson(Map<String, dynamic> map) {
    return Message(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      sid: DbQueryField.tryParseObjectId(map['sid']),
      uid: DbQueryField.tryParseObjectId(map['uid']),
      from: DbQueryField.tryParseInt(map['from']),
      type: DbQueryField.tryParseInt(map['type']),
      title: DbQueryField.tryParseString(map['title']),
      body: DbQueryField.tryParseString(map['body']),
      short: DbQueryField.tryParseString(map['short']),
      mediaTimeS: DbQueryField.tryParseInt(map['mediaTimeS']),
      mediaTimeE: DbQueryField.tryParseInt(map['mediaTimeE']),
      mediaGoing: DbQueryField.tryParseBool(map['mediaGoing']),
      mediaJoined: (map['mediaJoined'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      rmbfenTotal: DbQueryField.tryParseInt(map['rmbfenTotal']),
      rmbfenCount: DbQueryField.tryParseInt(map['rmbfenCount']),
      rmbfenEvery: (map['rmbfenEvery'] as List?)?.map((v) => DbQueryField.parseInt(v)).toList(),
      rmbfenLuckly: (map['rmbfenLuckly'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      rmbfenPending: (map['rmbfenPending'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      rmbfenUpdate: DbQueryField.tryParseInt(map['rmbfenUpdate']),
      rmbfenFinished: DbQueryField.tryParseBool(map['rmbfenFinished']),
      readpackNotice: (map['readpackNotice'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      shareCardId: DbQueryField.tryParseObjectId(map['shareCardId']),
      shareIconUrl: DbQueryField.tryParseString(map['shareIconUrl']),
      shareHeadUrl: (map['shareHeadUrl'] as List?)?.map((v) => DbQueryField.parseString(v)).toList(),
      shareLinkUrl: DbQueryField.tryParseString(map['shareLinkUrl']),
      shareLocation: map['shareLocation'] is Map ? Location.fromJson(map['shareLocation']) : map['shareLocation'],
      customType: DbQueryField.tryParseInt(map['customType']),
      revoked: DbQueryField.tryParseBool(map['revoked']),
    );
  }

  @override
  String toString() {
    return 'Message(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      '_bsid': DbQueryField.toBaseType(_bsid),
      '_time': DbQueryField.toBaseType(_time),
      '_extra': DbQueryField.toBaseType(_extra),
      '_trans': DbQueryField.toBaseType(_trans),
      'sid': DbQueryField.toBaseType(sid),
      'uid': DbQueryField.toBaseType(uid),
      'from': DbQueryField.toBaseType(from),
      'type': DbQueryField.toBaseType(type),
      'title': DbQueryField.toBaseType(title),
      'body': DbQueryField.toBaseType(body),
      'short': DbQueryField.toBaseType(short),
      'mediaTimeS': DbQueryField.toBaseType(mediaTimeS),
      'mediaTimeE': DbQueryField.toBaseType(mediaTimeE),
      'mediaGoing': DbQueryField.toBaseType(mediaGoing),
      'mediaJoined': DbQueryField.toBaseType(mediaJoined),
      'rmbfenTotal': DbQueryField.toBaseType(rmbfenTotal),
      'rmbfenCount': DbQueryField.toBaseType(rmbfenCount),
      'rmbfenEvery': DbQueryField.toBaseType(rmbfenEvery),
      'rmbfenLuckly': DbQueryField.toBaseType(rmbfenLuckly),
      'rmbfenPending': DbQueryField.toBaseType(rmbfenPending),
      'rmbfenUpdate': DbQueryField.toBaseType(rmbfenUpdate),
      'rmbfenFinished': DbQueryField.toBaseType(rmbfenFinished),
      'readpackNotice': DbQueryField.toBaseType(readpackNotice),
      'shareCardId': DbQueryField.toBaseType(shareCardId),
      'shareIconUrl': DbQueryField.toBaseType(shareIconUrl),
      'shareHeadUrl': DbQueryField.toBaseType(shareHeadUrl),
      'shareLinkUrl': DbQueryField.toBaseType(shareLinkUrl),
      'shareLocation': DbQueryField.toBaseType(shareLocation),
      'customType': DbQueryField.toBaseType(customType),
      'revoked': DbQueryField.toBaseType(revoked),
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
      'sid': sid,
      'uid': uid,
      'from': from,
      'type': type,
      'title': title,
      'body': body,
      'short': short,
      'mediaTimeS': mediaTimeS,
      'mediaTimeE': mediaTimeE,
      'mediaGoing': mediaGoing,
      'mediaJoined': mediaJoined,
      'rmbfenTotal': rmbfenTotal,
      'rmbfenCount': rmbfenCount,
      'rmbfenEvery': rmbfenEvery,
      'rmbfenLuckly': rmbfenLuckly,
      'rmbfenPending': rmbfenPending,
      'rmbfenUpdate': rmbfenUpdate,
      'rmbfenFinished': rmbfenFinished,
      'readpackNotice': readpackNotice,
      'shareCardId': shareCardId,
      'shareIconUrl': shareIconUrl,
      'shareHeadUrl': shareHeadUrl,
      'shareLinkUrl': shareLinkUrl,
      'shareLocation': shareLocation,
      'customType': customType,
      'revoked': revoked,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Message? parser}) {
    parser = parser ?? Message.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('sid')) sid = parser.sid;
    if (map.containsKey('uid')) uid = parser.uid;
    if (map.containsKey('from')) from = parser.from;
    if (map.containsKey('type')) type = parser.type;
    if (map.containsKey('title')) title = parser.title;
    if (map.containsKey('body')) body = parser.body;
    if (map.containsKey('short')) short = parser.short;
    if (map.containsKey('mediaTimeS')) mediaTimeS = parser.mediaTimeS;
    if (map.containsKey('mediaTimeE')) mediaTimeE = parser.mediaTimeE;
    if (map.containsKey('mediaGoing')) mediaGoing = parser.mediaGoing;
    if (map.containsKey('mediaJoined')) mediaJoined = parser.mediaJoined;
    if (map.containsKey('rmbfenTotal')) rmbfenTotal = parser.rmbfenTotal;
    if (map.containsKey('rmbfenCount')) rmbfenCount = parser.rmbfenCount;
    if (map.containsKey('rmbfenEvery')) rmbfenEvery = parser.rmbfenEvery;
    if (map.containsKey('rmbfenLuckly')) rmbfenLuckly = parser.rmbfenLuckly;
    if (map.containsKey('rmbfenPending')) rmbfenPending = parser.rmbfenPending;
    if (map.containsKey('rmbfenUpdate')) rmbfenUpdate = parser.rmbfenUpdate;
    if (map.containsKey('rmbfenFinished')) rmbfenFinished = parser.rmbfenFinished;
    if (map.containsKey('readpackNotice')) readpackNotice = parser.readpackNotice;
    if (map.containsKey('shareCardId')) shareCardId = parser.shareCardId;
    if (map.containsKey('shareIconUrl')) shareIconUrl = parser.shareIconUrl;
    if (map.containsKey('shareHeadUrl')) shareHeadUrl = parser.shareHeadUrl;
    if (map.containsKey('shareLinkUrl')) shareLinkUrl = parser.shareLinkUrl;
    if (map.containsKey('shareLocation')) shareLocation = parser.shareLocation;
    if (map.containsKey('customType')) customType = parser.customType;
    if (map.containsKey('revoked')) revoked = parser.revoked;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('sid')) sid = map['sid'];
    if (map.containsKey('uid')) uid = map['uid'];
    if (map.containsKey('from')) from = map['from'];
    if (map.containsKey('type')) type = map['type'];
    if (map.containsKey('title')) title = map['title'];
    if (map.containsKey('body')) body = map['body'];
    if (map.containsKey('short')) short = map['short'];
    if (map.containsKey('mediaTimeS')) mediaTimeS = map['mediaTimeS'];
    if (map.containsKey('mediaTimeE')) mediaTimeE = map['mediaTimeE'];
    if (map.containsKey('mediaGoing')) mediaGoing = map['mediaGoing'];
    if (map.containsKey('mediaJoined')) mediaJoined = map['mediaJoined'];
    if (map.containsKey('rmbfenTotal')) rmbfenTotal = map['rmbfenTotal'];
    if (map.containsKey('rmbfenCount')) rmbfenCount = map['rmbfenCount'];
    if (map.containsKey('rmbfenEvery')) rmbfenEvery = map['rmbfenEvery'];
    if (map.containsKey('rmbfenLuckly')) rmbfenLuckly = map['rmbfenLuckly'];
    if (map.containsKey('rmbfenPending')) rmbfenPending = map['rmbfenPending'];
    if (map.containsKey('rmbfenUpdate')) rmbfenUpdate = map['rmbfenUpdate'];
    if (map.containsKey('rmbfenFinished')) rmbfenFinished = map['rmbfenFinished'];
    if (map.containsKey('readpackNotice')) readpackNotice = map['readpackNotice'];
    if (map.containsKey('shareCardId')) shareCardId = map['shareCardId'];
    if (map.containsKey('shareIconUrl')) shareIconUrl = map['shareIconUrl'];
    if (map.containsKey('shareHeadUrl')) shareHeadUrl = map['shareHeadUrl'];
    if (map.containsKey('shareLinkUrl')) shareLinkUrl = map['shareLinkUrl'];
    if (map.containsKey('shareLocation')) shareLocation = map['shareLocation'];
    if (map.containsKey('customType')) customType = map['customType'];
    if (map.containsKey('revoked')) revoked = map['revoked'];
  }
}

class MessageDirty {
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

  ///聊天会话id
  set sid(ObjectId value) => data['sid'] = DbQueryField.toBaseType(value);

  ///发送者的id
  set uid(ObjectId value) => data['uid'] = DbQueryField.toBaseType(value);

  ///消息来源
  set from(int value) => data['from'] = DbQueryField.toBaseType(value);

  ///消息类型
  set type(int value) => data['type'] = DbQueryField.toBaseType(value);

  ///消息标题
  set title(String value) => data['title'] = DbQueryField.toBaseType(value);

  ///消息主体
  set body(String value) => data['body'] = DbQueryField.toBaseType(value);

  ///消息缩写
  set short(String value) => data['short'] = DbQueryField.toBaseType(value);

  ///媒体的开始时间（实时媒体<=0表示通讯未开始过）
  set mediaTimeS(int value) => data['mediaTimeS'] = DbQueryField.toBaseType(value);

  ///媒体的结束时间（减去mediaTimeS可得媒体时长）
  set mediaTimeE(int value) => data['mediaTimeE'] = DbQueryField.toBaseType(value);

  ///媒体正在进行中
  set mediaGoing(bool value) => data['mediaGoing'] = DbQueryField.toBaseType(value);

  ///读取过静态媒体 或 参与实时媒体 的用户id
  set mediaJoined(List<ObjectId> value) => data['mediaJoined'] = DbQueryField.toBaseType(value);

  ///红包RMB金额总数
  set rmbfenTotal(int value) => data['rmbfenTotal'] = DbQueryField.toBaseType(value);

  ///红包已经被抢次数
  set rmbfenCount(int value) => data['rmbfenCount'] = DbQueryField.toBaseType(value);

  ///红包金额分配数组
  set rmbfenEvery(List<int> value) => data['rmbfenEvery'] = DbQueryField.toBaseType(value);

  ///红包金额分配数组对应的幸运用户id
  set rmbfenLuckly(List<ObjectId> value) => data['rmbfenLuckly'] = DbQueryField.toBaseType(value);

  ///红包被抢到后等待创建订单的用户id
  set rmbfenPending(List<ObjectId> value) => data['rmbfenPending'] = DbQueryField.toBaseType(value);

  ///红包最近更新时间（红包最近被抢的时间）
  set rmbfenUpdate(int value) => data['rmbfenUpdate'] = DbQueryField.toBaseType(value);

  ///红包逻辑是否已经完成（红包被抢完、红包过期后余额已完成退回检测）
  set rmbfenFinished(bool value) => data['rmbfenFinished'] = DbQueryField.toBaseType(value);

  ///红包通知消息相关的id：[原始红包消息id, 发送原始红包消息的用户id, 抢到红包的用户id]
  set readpackNotice(List<ObjectId> value) => data['readpackNotice'] = DbQueryField.toBaseType(value);

  ///分享名片的目标id（用户id或群组id）
  set shareCardId(ObjectId value) => data['shareCardId'] = DbQueryField.toBaseType(value);

  ///分享名片的图标url
  set shareIconUrl(String value) => data['shareIconUrl'] = DbQueryField.toBaseType(value);

  ///分享名片的头像url
  set shareHeadUrl(List<String> value) => data['shareHeadUrl'] = DbQueryField.toBaseType(value);

  ///分享网址url、媒体附件url
  set shareLinkUrl(String value) => data['shareLinkUrl'] = DbQueryField.toBaseType(value);

  ///位置分享消息的数据
  set shareLocation(Location value) => data['shareLocation'] = DbQueryField.toBaseType(value);

  ///自定义的消息类型
  set customType(int value) => data['customType'] = DbQueryField.toBaseType(value);

  ///本条是否已撤销
  set revoked(bool value) => data['revoked'] = DbQueryField.toBaseType(value);
}
