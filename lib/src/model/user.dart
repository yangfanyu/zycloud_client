import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

import 'location.dart';

///
///用户
///
class User extends DbBaseModel {
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

  ///加密口令
  String token;

  ///RMB支付密码
  String rmbpwd;

  ///RMB拥有数量（分）
  int rmbfen;

  ///第三方账号类型
  int thirdTp;

  ///第三方账号标志
  String thirdNo;

  ///自定义的第三方账号类型
  int customType;

  ///真实姓名
  String name;

  ///身份证号
  String card;

  ///生日
  String birth;

  ///性别
  int sex;

  ///国家
  String country;

  ///省份
  String province;

  ///市
  String city;

  ///县（区）
  String district;

  ///最近定位信息
  Location location;

  ///最近登录时间
  int login;

  ///最近登录ip地址
  String ip;

  ///私有扩展数据，仅用户自己能读取到该数据
  DbJsonWraper ownerExtra;

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

  User({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    String? phone,
    String? token,
    String? rmbpwd,
    int? rmbfen,
    int? thirdTp,
    String? thirdNo,
    int? customType,
    String? name,
    String? card,
    String? birth,
    int? sex,
    String? country,
    String? province,
    String? city,
    String? district,
    Location? location,
    int? login,
    String? ip,
    DbJsonWraper? ownerExtra,
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
        phone = phone ?? '',
        token = token ?? '',
        rmbpwd = rmbpwd ?? '',
        rmbfen = rmbfen ?? 0,
        thirdTp = thirdTp ?? 0,
        thirdNo = thirdNo ?? '',
        customType = customType ?? 0,
        name = name ?? '',
        card = card ?? '',
        birth = birth ?? '',
        sex = sex ?? 0,
        country = country ?? '',
        province = province ?? '',
        city = city ?? '',
        district = district ?? '',
        location = location ?? Location(),
        login = login ?? 0,
        ip = ip ?? '',
        ownerExtra = ownerExtra ?? DbJsonWraper(),
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

  factory User.fromString(String data) {
    return User.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      phone: DbQueryField.tryParseString(map['phone']),
      token: DbQueryField.tryParseString(map['token']),
      rmbpwd: DbQueryField.tryParseString(map['rmbpwd']),
      rmbfen: DbQueryField.tryParseInt(map['rmbfen']),
      thirdTp: DbQueryField.tryParseInt(map['thirdTp']),
      thirdNo: DbQueryField.tryParseString(map['thirdNo']),
      customType: DbQueryField.tryParseInt(map['customType']),
      name: DbQueryField.tryParseString(map['name']),
      card: DbQueryField.tryParseString(map['card']),
      birth: DbQueryField.tryParseString(map['birth']),
      sex: DbQueryField.tryParseInt(map['sex']),
      country: DbQueryField.tryParseString(map['country']),
      province: DbQueryField.tryParseString(map['province']),
      city: DbQueryField.tryParseString(map['city']),
      district: DbQueryField.tryParseString(map['district']),
      location: map['location'] is Map ? Location.fromJson(map['location']) : map['location'],
      login: DbQueryField.tryParseInt(map['login']),
      ip: DbQueryField.tryParseString(map['ip']),
      ownerExtra: map['ownerExtra'] is Map ? DbJsonWraper.fromJson(map['ownerExtra']) : map['ownerExtra'],
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
    return 'User(${jsonEncode(toJson())})';
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
      'token': DbQueryField.toBaseType(token),
      'rmbpwd': DbQueryField.toBaseType(rmbpwd),
      'rmbfen': DbQueryField.toBaseType(rmbfen),
      'thirdTp': DbQueryField.toBaseType(thirdTp),
      'thirdNo': DbQueryField.toBaseType(thirdNo),
      'customType': DbQueryField.toBaseType(customType),
      'name': DbQueryField.toBaseType(name),
      'card': DbQueryField.toBaseType(card),
      'birth': DbQueryField.toBaseType(birth),
      'sex': DbQueryField.toBaseType(sex),
      'country': DbQueryField.toBaseType(country),
      'province': DbQueryField.toBaseType(province),
      'city': DbQueryField.toBaseType(city),
      'district': DbQueryField.toBaseType(district),
      'location': DbQueryField.toBaseType(location),
      'login': DbQueryField.toBaseType(login),
      'ip': DbQueryField.toBaseType(ip),
      'ownerExtra': DbQueryField.toBaseType(ownerExtra),
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
      'phone': phone,
      'token': token,
      'rmbpwd': rmbpwd,
      'rmbfen': rmbfen,
      'thirdTp': thirdTp,
      'thirdNo': thirdNo,
      'customType': customType,
      'name': name,
      'card': card,
      'birth': birth,
      'sex': sex,
      'country': country,
      'province': province,
      'city': city,
      'district': district,
      'location': location,
      'login': login,
      'ip': ip,
      'ownerExtra': ownerExtra,
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
  void updateByJson(Map<String, dynamic> map, {User? parser}) {
    parser = parser ?? User.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('phone')) phone = parser.phone;
    if (map.containsKey('token')) token = parser.token;
    if (map.containsKey('rmbpwd')) rmbpwd = parser.rmbpwd;
    if (map.containsKey('rmbfen')) rmbfen = parser.rmbfen;
    if (map.containsKey('thirdTp')) thirdTp = parser.thirdTp;
    if (map.containsKey('thirdNo')) thirdNo = parser.thirdNo;
    if (map.containsKey('customType')) customType = parser.customType;
    if (map.containsKey('name')) name = parser.name;
    if (map.containsKey('card')) card = parser.card;
    if (map.containsKey('birth')) birth = parser.birth;
    if (map.containsKey('sex')) sex = parser.sex;
    if (map.containsKey('country')) country = parser.country;
    if (map.containsKey('province')) province = parser.province;
    if (map.containsKey('city')) city = parser.city;
    if (map.containsKey('district')) district = parser.district;
    if (map.containsKey('location')) location = parser.location;
    if (map.containsKey('login')) login = parser.login;
    if (map.containsKey('ip')) ip = parser.ip;
    if (map.containsKey('ownerExtra')) ownerExtra = parser.ownerExtra;
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
    if (map.containsKey('phone')) phone = map['phone'];
    if (map.containsKey('token')) token = map['token'];
    if (map.containsKey('rmbpwd')) rmbpwd = map['rmbpwd'];
    if (map.containsKey('rmbfen')) rmbfen = map['rmbfen'];
    if (map.containsKey('thirdTp')) thirdTp = map['thirdTp'];
    if (map.containsKey('thirdNo')) thirdNo = map['thirdNo'];
    if (map.containsKey('customType')) customType = map['customType'];
    if (map.containsKey('name')) name = map['name'];
    if (map.containsKey('card')) card = map['card'];
    if (map.containsKey('birth')) birth = map['birth'];
    if (map.containsKey('sex')) sex = map['sex'];
    if (map.containsKey('country')) country = map['country'];
    if (map.containsKey('province')) province = map['province'];
    if (map.containsKey('city')) city = map['city'];
    if (map.containsKey('district')) district = map['district'];
    if (map.containsKey('location')) location = map['location'];
    if (map.containsKey('login')) login = map['login'];
    if (map.containsKey('ip')) ip = map['ip'];
    if (map.containsKey('ownerExtra')) ownerExtra = map['ownerExtra'];
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

class UserDirty {
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

  ///加密口令
  set token(String value) => data['token'] = DbQueryField.toBaseType(value);

  ///RMB支付密码
  set rmbpwd(String value) => data['rmbpwd'] = DbQueryField.toBaseType(value);

  ///RMB拥有数量（分）
  set rmbfen(int value) => data['rmbfen'] = DbQueryField.toBaseType(value);

  ///第三方账号类型
  set thirdTp(int value) => data['thirdTp'] = DbQueryField.toBaseType(value);

  ///第三方账号标志
  set thirdNo(String value) => data['thirdNo'] = DbQueryField.toBaseType(value);

  ///自定义的第三方账号类型
  set customType(int value) => data['customType'] = DbQueryField.toBaseType(value);

  ///真实姓名
  set name(String value) => data['name'] = DbQueryField.toBaseType(value);

  ///身份证号
  set card(String value) => data['card'] = DbQueryField.toBaseType(value);

  ///生日
  set birth(String value) => data['birth'] = DbQueryField.toBaseType(value);

  ///性别
  set sex(int value) => data['sex'] = DbQueryField.toBaseType(value);

  ///国家
  set country(String value) => data['country'] = DbQueryField.toBaseType(value);

  ///省份
  set province(String value) => data['province'] = DbQueryField.toBaseType(value);

  ///市
  set city(String value) => data['city'] = DbQueryField.toBaseType(value);

  ///县（区）
  set district(String value) => data['district'] = DbQueryField.toBaseType(value);

  ///最近定位信息
  set location(Location value) => data['location'] = DbQueryField.toBaseType(value);

  ///最近登录时间
  set login(int value) => data['login'] = DbQueryField.toBaseType(value);

  ///最近登录ip地址
  set ip(String value) => data['ip'] = DbQueryField.toBaseType(value);

  ///私有扩展数据，仅用户自己能读取到该数据
  set ownerExtra(DbJsonWraper value) => data['ownerExtra'] = DbQueryField.toBaseType(value);

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
