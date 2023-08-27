import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

import 'cusmark.dart';
import 'cusstar.dart';
import 'payment.dart';

///
///自定义数据
///
class CustomX extends DbBaseModel {
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

  ///创建者标志
  ObjectId uid;

  ///关联标志索引1
  ObjectId rid1;

  ///关联标志索引2
  ObjectId rid2;

  ///关联标志索引3
  ObjectId rid3;

  ///整数索引1
  int int1;

  ///整数索引2
  int int2;

  ///整数索引3
  int int3;

  ///字符串索引1
  String str1;

  ///字符串索引2
  String str2;

  ///字符串索引3
  String str3;

  ///数据内容1
  DbJsonWraper body1;

  ///数据内容2
  DbJsonWraper body2;

  ///数据内容3
  DbJsonWraper body3;

  ///数据状态1
  int state1;

  ///数据状态2
  int state2;

  ///数据状态3
  int state3;

  ///最近更新时间
  int update;

  ///平均得分（每个用户打分一次）
  double score;

  ///总标记数（每个用户标记一次）
  int mark;

  ///总收藏数（每个用户收藏一次）
  int star;

  ///整数增减量1（增减单位为1）
  int hot1;

  ///整数增减量2（增减单位为1）
  int hot2;

  ///整数增减量x（增减单位为x）
  int hotx;

  ///子customx.rid1为本customx.id的子customx数量
  int cnt1;

  ///子customx.rid2为本customx.id的子customx数量
  int cnt2;

  ///子customx.rid3为本customx.id的子customx数量
  int cnt3;

  ///自增整数标志
  int incxId;

  ///文件系统标志
  ObjectId pathId;

  ///任意目标标志
  ObjectId target;

  ///交易的受益人
  ObjectId earner;

  ///虚拟商品价格
  int rmbfen;

  ///虚拟货币数量
  int virval;

  ///被封禁状态（>0：被封禁时间截止时间；=0：正常状态；<0：永久封禁或永久注销）
  int deny;

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
  ///关联的自定义标记对象
  ///
  Cusmark? cusmark;

  ///
  ///关联的自定义收藏对象
  ///
  Cusstar? cusstar;

  ///
  ///关联的自定义已购对象
  ///
  Payment? cuspaid;

  CustomX({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    ObjectId? uid,
    ObjectId? rid1,
    ObjectId? rid2,
    ObjectId? rid3,
    int? int1,
    int? int2,
    int? int3,
    String? str1,
    String? str2,
    String? str3,
    DbJsonWraper? body1,
    DbJsonWraper? body2,
    DbJsonWraper? body3,
    int? state1,
    int? state2,
    int? state3,
    int? update,
    double? score,
    int? mark,
    int? star,
    int? hot1,
    int? hot2,
    int? hotx,
    int? cnt1,
    int? cnt2,
    int? cnt3,
    int? incxId,
    ObjectId? pathId,
    ObjectId? target,
    ObjectId? earner,
    int? rmbfen,
    int? virval,
    int? deny,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        uid = uid ?? ObjectId.fromHexString('000000000000000000000000'),
        rid1 = rid1 ?? ObjectId.fromHexString('000000000000000000000000'),
        rid2 = rid2 ?? ObjectId.fromHexString('000000000000000000000000'),
        rid3 = rid3 ?? ObjectId.fromHexString('000000000000000000000000'),
        int1 = int1 ?? 0,
        int2 = int2 ?? 0,
        int3 = int3 ?? 0,
        str1 = str1 ?? '',
        str2 = str2 ?? '',
        str3 = str3 ?? '',
        body1 = body1 ?? DbJsonWraper(),
        body2 = body2 ?? DbJsonWraper(),
        body3 = body3 ?? DbJsonWraper(),
        state1 = state1 ?? 0,
        state2 = state2 ?? 0,
        state3 = state3 ?? 0,
        update = update ?? DateTime.now().millisecondsSinceEpoch,
        score = score ?? 0,
        mark = mark ?? 0,
        star = star ?? 0,
        hot1 = hot1 ?? 0,
        hot2 = hot2 ?? 0,
        hotx = hotx ?? 0,
        cnt1 = cnt1 ?? 0,
        cnt2 = cnt2 ?? 0,
        cnt3 = cnt3 ?? 0,
        incxId = incxId ?? 0,
        pathId = pathId ?? ObjectId.fromHexString('000000000000000000000000'),
        target = target ?? ObjectId.fromHexString('000000000000000000000000'),
        earner = earner ?? ObjectId.fromHexString('000000000000000000000000'),
        rmbfen = rmbfen ?? 0,
        virval = virval ?? 0,
        deny = deny ?? 0;

  factory CustomX.fromString(String data) {
    return CustomX.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory CustomX.fromJson(Map<String, dynamic> map) {
    return CustomX(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      uid: DbQueryField.tryParseObjectId(map['uid']),
      rid1: DbQueryField.tryParseObjectId(map['rid1']),
      rid2: DbQueryField.tryParseObjectId(map['rid2']),
      rid3: DbQueryField.tryParseObjectId(map['rid3']),
      int1: DbQueryField.tryParseInt(map['int1']),
      int2: DbQueryField.tryParseInt(map['int2']),
      int3: DbQueryField.tryParseInt(map['int3']),
      str1: DbQueryField.tryParseString(map['str1']),
      str2: DbQueryField.tryParseString(map['str2']),
      str3: DbQueryField.tryParseString(map['str3']),
      body1: map['body1'] is Map ? DbJsonWraper.fromJson(map['body1']) : map['body1'],
      body2: map['body2'] is Map ? DbJsonWraper.fromJson(map['body2']) : map['body2'],
      body3: map['body3'] is Map ? DbJsonWraper.fromJson(map['body3']) : map['body3'],
      state1: DbQueryField.tryParseInt(map['state1']),
      state2: DbQueryField.tryParseInt(map['state2']),
      state3: DbQueryField.tryParseInt(map['state3']),
      update: DbQueryField.tryParseInt(map['update']),
      score: DbQueryField.tryParseDouble(map['score']),
      mark: DbQueryField.tryParseInt(map['mark']),
      star: DbQueryField.tryParseInt(map['star']),
      hot1: DbQueryField.tryParseInt(map['hot1']),
      hot2: DbQueryField.tryParseInt(map['hot2']),
      hotx: DbQueryField.tryParseInt(map['hotx']),
      cnt1: DbQueryField.tryParseInt(map['cnt1']),
      cnt2: DbQueryField.tryParseInt(map['cnt2']),
      cnt3: DbQueryField.tryParseInt(map['cnt3']),
      incxId: DbQueryField.tryParseInt(map['incxId']),
      pathId: DbQueryField.tryParseObjectId(map['pathId']),
      target: DbQueryField.tryParseObjectId(map['target']),
      earner: DbQueryField.tryParseObjectId(map['earner']),
      rmbfen: DbQueryField.tryParseInt(map['rmbfen']),
      virval: DbQueryField.tryParseInt(map['virval']),
      deny: DbQueryField.tryParseInt(map['deny']),
    );
  }

  @override
  String toString() {
    return 'CustomX(${jsonEncode(toJson())})';
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
      'rid1': DbQueryField.toBaseType(rid1),
      'rid2': DbQueryField.toBaseType(rid2),
      'rid3': DbQueryField.toBaseType(rid3),
      'int1': DbQueryField.toBaseType(int1),
      'int2': DbQueryField.toBaseType(int2),
      'int3': DbQueryField.toBaseType(int3),
      'str1': DbQueryField.toBaseType(str1),
      'str2': DbQueryField.toBaseType(str2),
      'str3': DbQueryField.toBaseType(str3),
      'body1': DbQueryField.toBaseType(body1),
      'body2': DbQueryField.toBaseType(body2),
      'body3': DbQueryField.toBaseType(body3),
      'state1': DbQueryField.toBaseType(state1),
      'state2': DbQueryField.toBaseType(state2),
      'state3': DbQueryField.toBaseType(state3),
      'update': DbQueryField.toBaseType(update),
      'score': DbQueryField.toBaseType(score),
      'mark': DbQueryField.toBaseType(mark),
      'star': DbQueryField.toBaseType(star),
      'hot1': DbQueryField.toBaseType(hot1),
      'hot2': DbQueryField.toBaseType(hot2),
      'hotx': DbQueryField.toBaseType(hotx),
      'cnt1': DbQueryField.toBaseType(cnt1),
      'cnt2': DbQueryField.toBaseType(cnt2),
      'cnt3': DbQueryField.toBaseType(cnt3),
      'incxId': DbQueryField.toBaseType(incxId),
      'pathId': DbQueryField.toBaseType(pathId),
      'target': DbQueryField.toBaseType(target),
      'earner': DbQueryField.toBaseType(earner),
      'rmbfen': DbQueryField.toBaseType(rmbfen),
      'virval': DbQueryField.toBaseType(virval),
      'deny': DbQueryField.toBaseType(deny),
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
      'rid1': rid1,
      'rid2': rid2,
      'rid3': rid3,
      'int1': int1,
      'int2': int2,
      'int3': int3,
      'str1': str1,
      'str2': str2,
      'str3': str3,
      'body1': body1,
      'body2': body2,
      'body3': body3,
      'state1': state1,
      'state2': state2,
      'state3': state3,
      'update': update,
      'score': score,
      'mark': mark,
      'star': star,
      'hot1': hot1,
      'hot2': hot2,
      'hotx': hotx,
      'cnt1': cnt1,
      'cnt2': cnt2,
      'cnt3': cnt3,
      'incxId': incxId,
      'pathId': pathId,
      'target': target,
      'earner': earner,
      'rmbfen': rmbfen,
      'virval': virval,
      'deny': deny,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {CustomX? parser}) {
    parser = parser ?? CustomX.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('uid')) uid = parser.uid;
    if (map.containsKey('rid1')) rid1 = parser.rid1;
    if (map.containsKey('rid2')) rid2 = parser.rid2;
    if (map.containsKey('rid3')) rid3 = parser.rid3;
    if (map.containsKey('int1')) int1 = parser.int1;
    if (map.containsKey('int2')) int2 = parser.int2;
    if (map.containsKey('int3')) int3 = parser.int3;
    if (map.containsKey('str1')) str1 = parser.str1;
    if (map.containsKey('str2')) str2 = parser.str2;
    if (map.containsKey('str3')) str3 = parser.str3;
    if (map.containsKey('body1')) body1 = parser.body1;
    if (map.containsKey('body2')) body2 = parser.body2;
    if (map.containsKey('body3')) body3 = parser.body3;
    if (map.containsKey('state1')) state1 = parser.state1;
    if (map.containsKey('state2')) state2 = parser.state2;
    if (map.containsKey('state3')) state3 = parser.state3;
    if (map.containsKey('update')) update = parser.update;
    if (map.containsKey('score')) score = parser.score;
    if (map.containsKey('mark')) mark = parser.mark;
    if (map.containsKey('star')) star = parser.star;
    if (map.containsKey('hot1')) hot1 = parser.hot1;
    if (map.containsKey('hot2')) hot2 = parser.hot2;
    if (map.containsKey('hotx')) hotx = parser.hotx;
    if (map.containsKey('cnt1')) cnt1 = parser.cnt1;
    if (map.containsKey('cnt2')) cnt2 = parser.cnt2;
    if (map.containsKey('cnt3')) cnt3 = parser.cnt3;
    if (map.containsKey('incxId')) incxId = parser.incxId;
    if (map.containsKey('pathId')) pathId = parser.pathId;
    if (map.containsKey('target')) target = parser.target;
    if (map.containsKey('earner')) earner = parser.earner;
    if (map.containsKey('rmbfen')) rmbfen = parser.rmbfen;
    if (map.containsKey('virval')) virval = parser.virval;
    if (map.containsKey('deny')) deny = parser.deny;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('uid')) uid = map['uid'];
    if (map.containsKey('rid1')) rid1 = map['rid1'];
    if (map.containsKey('rid2')) rid2 = map['rid2'];
    if (map.containsKey('rid3')) rid3 = map['rid3'];
    if (map.containsKey('int1')) int1 = map['int1'];
    if (map.containsKey('int2')) int2 = map['int2'];
    if (map.containsKey('int3')) int3 = map['int3'];
    if (map.containsKey('str1')) str1 = map['str1'];
    if (map.containsKey('str2')) str2 = map['str2'];
    if (map.containsKey('str3')) str3 = map['str3'];
    if (map.containsKey('body1')) body1 = map['body1'];
    if (map.containsKey('body2')) body2 = map['body2'];
    if (map.containsKey('body3')) body3 = map['body3'];
    if (map.containsKey('state1')) state1 = map['state1'];
    if (map.containsKey('state2')) state2 = map['state2'];
    if (map.containsKey('state3')) state3 = map['state3'];
    if (map.containsKey('update')) update = map['update'];
    if (map.containsKey('score')) score = map['score'];
    if (map.containsKey('mark')) mark = map['mark'];
    if (map.containsKey('star')) star = map['star'];
    if (map.containsKey('hot1')) hot1 = map['hot1'];
    if (map.containsKey('hot2')) hot2 = map['hot2'];
    if (map.containsKey('hotx')) hotx = map['hotx'];
    if (map.containsKey('cnt1')) cnt1 = map['cnt1'];
    if (map.containsKey('cnt2')) cnt2 = map['cnt2'];
    if (map.containsKey('cnt3')) cnt3 = map['cnt3'];
    if (map.containsKey('incxId')) incxId = map['incxId'];
    if (map.containsKey('pathId')) pathId = map['pathId'];
    if (map.containsKey('target')) target = map['target'];
    if (map.containsKey('earner')) earner = map['earner'];
    if (map.containsKey('rmbfen')) rmbfen = map['rmbfen'];
    if (map.containsKey('virval')) virval = map['virval'];
    if (map.containsKey('deny')) deny = map['deny'];
  }
}

class CustomXDirty {
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

  ///创建者标志
  set uid(ObjectId value) => data['uid'] = DbQueryField.toBaseType(value);

  ///关联标志索引1
  set rid1(ObjectId value) => data['rid1'] = DbQueryField.toBaseType(value);

  ///关联标志索引2
  set rid2(ObjectId value) => data['rid2'] = DbQueryField.toBaseType(value);

  ///关联标志索引3
  set rid3(ObjectId value) => data['rid3'] = DbQueryField.toBaseType(value);

  ///整数索引1
  set int1(int value) => data['int1'] = DbQueryField.toBaseType(value);

  ///整数索引2
  set int2(int value) => data['int2'] = DbQueryField.toBaseType(value);

  ///整数索引3
  set int3(int value) => data['int3'] = DbQueryField.toBaseType(value);

  ///字符串索引1
  set str1(String value) => data['str1'] = DbQueryField.toBaseType(value);

  ///字符串索引2
  set str2(String value) => data['str2'] = DbQueryField.toBaseType(value);

  ///字符串索引3
  set str3(String value) => data['str3'] = DbQueryField.toBaseType(value);

  ///数据内容1
  set body1(DbJsonWraper value) => data['body1'] = DbQueryField.toBaseType(value);

  ///数据内容2
  set body2(DbJsonWraper value) => data['body2'] = DbQueryField.toBaseType(value);

  ///数据内容3
  set body3(DbJsonWraper value) => data['body3'] = DbQueryField.toBaseType(value);

  ///数据状态1
  set state1(int value) => data['state1'] = DbQueryField.toBaseType(value);

  ///数据状态2
  set state2(int value) => data['state2'] = DbQueryField.toBaseType(value);

  ///数据状态3
  set state3(int value) => data['state3'] = DbQueryField.toBaseType(value);

  ///最近更新时间
  set update(int value) => data['update'] = DbQueryField.toBaseType(value);

  ///平均得分（每个用户打分一次）
  set score(double value) => data['score'] = DbQueryField.toBaseType(value);

  ///总标记数（每个用户标记一次）
  set mark(int value) => data['mark'] = DbQueryField.toBaseType(value);

  ///总收藏数（每个用户收藏一次）
  set star(int value) => data['star'] = DbQueryField.toBaseType(value);

  ///整数增减量1（增减单位为1）
  set hot1(int value) => data['hot1'] = DbQueryField.toBaseType(value);

  ///整数增减量2（增减单位为1）
  set hot2(int value) => data['hot2'] = DbQueryField.toBaseType(value);

  ///整数增减量x（增减单位为x）
  set hotx(int value) => data['hotx'] = DbQueryField.toBaseType(value);

  ///子customx.rid1为本customx.id的子customx数量
  set cnt1(int value) => data['cnt1'] = DbQueryField.toBaseType(value);

  ///子customx.rid2为本customx.id的子customx数量
  set cnt2(int value) => data['cnt2'] = DbQueryField.toBaseType(value);

  ///子customx.rid3为本customx.id的子customx数量
  set cnt3(int value) => data['cnt3'] = DbQueryField.toBaseType(value);

  ///自增整数标志
  set incxId(int value) => data['incxId'] = DbQueryField.toBaseType(value);

  ///文件系统标志
  set pathId(ObjectId value) => data['pathId'] = DbQueryField.toBaseType(value);

  ///任意目标标志
  set target(ObjectId value) => data['target'] = DbQueryField.toBaseType(value);

  ///交易的受益人
  set earner(ObjectId value) => data['earner'] = DbQueryField.toBaseType(value);

  ///虚拟商品价格
  set rmbfen(int value) => data['rmbfen'] = DbQueryField.toBaseType(value);

  ///虚拟货币数量
  set virval(int value) => data['virval'] = DbQueryField.toBaseType(value);

  ///被封禁状态（>0：被封禁时间截止时间；=0：正常状态；<0：永久封禁或永久注销）
  set deny(int value) => data['deny'] = DbQueryField.toBaseType(value);
}
