import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

///
///群组
///
class Team extends DbBaseModel {
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

  ///创建者用户id
  ObjectId owner;

  ///管理员用户id
  List<ObjectId> admin;

  ///群组成员总数量
  int member;

  ///群组授权密钥
  String appSecret;

  ///群组授权域名
  List<String> appHosts;

  ///群组菜单数据
  List<DbJsonWraper> appMenus;

  ///账号
  String no;

  ///密码
  String pwd;

  ///昵称
  String nick;

  ///描述
  String desc;

  ///图标
  String icon;

  ///头像
  List<String> head;

  ///是否允许 通过搜索信息来 添加好友 或 加入群组
  bool byfind;

  ///是否允许 通过扫描二维码 添加好友 或 加入群组
  bool bycode;

  ///是否允许 通过分享的名片 添加好友 或 加入群组
  bool bycard;

  ///是否允许 通过群组内关系 添加好友 或 互加好友
  bool byteam;

  ///是否开启 收到消息有后台通知 或 群组成员变化后发送通知
  bool notice;

  ///是否开启 收到消息无声音提醒 或 群组管理员才能发送消息
  bool silent;

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

  Team({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    ObjectId? owner,
    List<ObjectId>? admin,
    int? member,
    String? appSecret,
    List<String>? appHosts,
    List<DbJsonWraper>? appMenus,
    String? no,
    String? pwd,
    String? nick,
    String? desc,
    String? icon,
    List<String>? head,
    bool? byfind,
    bool? bycode,
    bool? bycard,
    bool? byteam,
    bool? notice,
    bool? silent,
    int? deny,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        owner = owner ?? ObjectId.fromHexString('000000000000000000000000'),
        admin = admin ?? [],
        member = member ?? 0,
        appSecret = appSecret ?? '',
        appHosts = appHosts ?? [],
        appMenus = appMenus ?? [],
        no = no ?? '',
        pwd = pwd ?? '',
        nick = nick ?? '',
        desc = desc ?? '',
        icon = icon ?? '',
        head = head ?? [],
        byfind = byfind ?? true,
        bycode = bycode ?? true,
        bycard = bycard ?? true,
        byteam = byteam ?? true,
        notice = notice ?? true,
        silent = silent ?? false,
        deny = deny ?? 0;

  factory Team.fromString(String data) {
    return Team.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Team.fromJson(Map<String, dynamic> map) {
    return Team(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      owner: DbQueryField.tryParseObjectId(map['owner']),
      admin: (map['admin'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      member: DbQueryField.tryParseInt(map['member']),
      appSecret: DbQueryField.tryParseString(map['appSecret']),
      appHosts: (map['appHosts'] as List?)?.map((v) => DbQueryField.parseString(v)).toList(),
      appMenus: (map['appMenus'] as List?)?.map((v) => DbJsonWraper.fromJson(v)).toList(),
      no: DbQueryField.tryParseString(map['no']),
      pwd: DbQueryField.tryParseString(map['pwd']),
      nick: DbQueryField.tryParseString(map['nick']),
      desc: DbQueryField.tryParseString(map['desc']),
      icon: DbQueryField.tryParseString(map['icon']),
      head: (map['head'] as List?)?.map((v) => DbQueryField.parseString(v)).toList(),
      byfind: DbQueryField.tryParseBool(map['byfind']),
      bycode: DbQueryField.tryParseBool(map['bycode']),
      bycard: DbQueryField.tryParseBool(map['bycard']),
      byteam: DbQueryField.tryParseBool(map['byteam']),
      notice: DbQueryField.tryParseBool(map['notice']),
      silent: DbQueryField.tryParseBool(map['silent']),
      deny: DbQueryField.tryParseInt(map['deny']),
    );
  }

  @override
  String toString() {
    return 'Team(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      '_bsid': DbQueryField.toBaseType(_bsid),
      '_time': DbQueryField.toBaseType(_time),
      '_extra': DbQueryField.toBaseType(_extra),
      '_trans': DbQueryField.toBaseType(_trans),
      'owner': DbQueryField.toBaseType(owner),
      'admin': DbQueryField.toBaseType(admin),
      'member': DbQueryField.toBaseType(member),
      'appSecret': DbQueryField.toBaseType(appSecret),
      'appHosts': DbQueryField.toBaseType(appHosts),
      'appMenus': DbQueryField.toBaseType(appMenus),
      'no': DbQueryField.toBaseType(no),
      'pwd': DbQueryField.toBaseType(pwd),
      'nick': DbQueryField.toBaseType(nick),
      'desc': DbQueryField.toBaseType(desc),
      'icon': DbQueryField.toBaseType(icon),
      'head': DbQueryField.toBaseType(head),
      'byfind': DbQueryField.toBaseType(byfind),
      'bycode': DbQueryField.toBaseType(bycode),
      'bycard': DbQueryField.toBaseType(bycard),
      'byteam': DbQueryField.toBaseType(byteam),
      'notice': DbQueryField.toBaseType(notice),
      'silent': DbQueryField.toBaseType(silent),
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
      'owner': owner,
      'admin': admin,
      'member': member,
      'appSecret': appSecret,
      'appHosts': appHosts,
      'appMenus': appMenus,
      'no': no,
      'pwd': pwd,
      'nick': nick,
      'desc': desc,
      'icon': icon,
      'head': head,
      'byfind': byfind,
      'bycode': bycode,
      'bycard': bycard,
      'byteam': byteam,
      'notice': notice,
      'silent': silent,
      'deny': deny,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Team? parser}) {
    parser = parser ?? Team.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('owner')) owner = parser.owner;
    if (map.containsKey('admin')) admin = parser.admin;
    if (map.containsKey('member')) member = parser.member;
    if (map.containsKey('appSecret')) appSecret = parser.appSecret;
    if (map.containsKey('appHosts')) appHosts = parser.appHosts;
    if (map.containsKey('appMenus')) appMenus = parser.appMenus;
    if (map.containsKey('no')) no = parser.no;
    if (map.containsKey('pwd')) pwd = parser.pwd;
    if (map.containsKey('nick')) nick = parser.nick;
    if (map.containsKey('desc')) desc = parser.desc;
    if (map.containsKey('icon')) icon = parser.icon;
    if (map.containsKey('head')) head = parser.head;
    if (map.containsKey('byfind')) byfind = parser.byfind;
    if (map.containsKey('bycode')) bycode = parser.bycode;
    if (map.containsKey('bycard')) bycard = parser.bycard;
    if (map.containsKey('byteam')) byteam = parser.byteam;
    if (map.containsKey('notice')) notice = parser.notice;
    if (map.containsKey('silent')) silent = parser.silent;
    if (map.containsKey('deny')) deny = parser.deny;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_bsid')) _bsid = map['_bsid'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_trans')) _trans = map['_trans'];
    if (map.containsKey('owner')) owner = map['owner'];
    if (map.containsKey('admin')) admin = map['admin'];
    if (map.containsKey('member')) member = map['member'];
    if (map.containsKey('appSecret')) appSecret = map['appSecret'];
    if (map.containsKey('appHosts')) appHosts = map['appHosts'];
    if (map.containsKey('appMenus')) appMenus = map['appMenus'];
    if (map.containsKey('no')) no = map['no'];
    if (map.containsKey('pwd')) pwd = map['pwd'];
    if (map.containsKey('nick')) nick = map['nick'];
    if (map.containsKey('desc')) desc = map['desc'];
    if (map.containsKey('icon')) icon = map['icon'];
    if (map.containsKey('head')) head = map['head'];
    if (map.containsKey('byfind')) byfind = map['byfind'];
    if (map.containsKey('bycode')) bycode = map['bycode'];
    if (map.containsKey('bycard')) bycard = map['bycard'];
    if (map.containsKey('byteam')) byteam = map['byteam'];
    if (map.containsKey('notice')) notice = map['notice'];
    if (map.containsKey('silent')) silent = map['silent'];
    if (map.containsKey('deny')) deny = map['deny'];
  }
}

class TeamDirty {
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

  ///创建者用户id
  set owner(ObjectId value) => data['owner'] = DbQueryField.toBaseType(value);

  ///管理员用户id
  set admin(List<ObjectId> value) => data['admin'] = DbQueryField.toBaseType(value);

  ///群组成员总数量
  set member(int value) => data['member'] = DbQueryField.toBaseType(value);

  ///群组授权密钥
  set appSecret(String value) => data['appSecret'] = DbQueryField.toBaseType(value);

  ///群组授权域名
  set appHosts(List<String> value) => data['appHosts'] = DbQueryField.toBaseType(value);

  ///群组菜单数据
  set appMenus(List<DbJsonWraper> value) => data['appMenus'] = DbQueryField.toBaseType(value);

  ///账号
  set no(String value) => data['no'] = DbQueryField.toBaseType(value);

  ///密码
  set pwd(String value) => data['pwd'] = DbQueryField.toBaseType(value);

  ///昵称
  set nick(String value) => data['nick'] = DbQueryField.toBaseType(value);

  ///描述
  set desc(String value) => data['desc'] = DbQueryField.toBaseType(value);

  ///图标
  set icon(String value) => data['icon'] = DbQueryField.toBaseType(value);

  ///头像
  set head(List<String> value) => data['head'] = DbQueryField.toBaseType(value);

  ///是否允许 通过搜索信息来 添加好友 或 加入群组
  set byfind(bool value) => data['byfind'] = DbQueryField.toBaseType(value);

  ///是否允许 通过扫描二维码 添加好友 或 加入群组
  set bycode(bool value) => data['bycode'] = DbQueryField.toBaseType(value);

  ///是否允许 通过分享的名片 添加好友 或 加入群组
  set bycard(bool value) => data['bycard'] = DbQueryField.toBaseType(value);

  ///是否允许 通过群组内关系 添加好友 或 互加好友
  set byteam(bool value) => data['byteam'] = DbQueryField.toBaseType(value);

  ///是否开启 收到消息有后台通知 或 群组成员变化后发送通知
  set notice(bool value) => data['notice'] = DbQueryField.toBaseType(value);

  ///是否开启 收到消息无声音提醒 或 群组管理员才能发送消息
  set silent(bool value) => data['silent'] = DbQueryField.toBaseType(value);

  ///被封禁状态（>0：被封禁时间截止时间；=0：正常状态；<0：永久封禁或永久注销）
  set deny(int value) => data['deny'] = DbQueryField.toBaseType(value);
}
