import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

import 'paygoods.dart';

///
///商户
///
class Business extends DbBaseModel {
  ///唯一id
  ObjectId _id;

  ///自定义数据
  DbJsonWraper _extra;

  ///创建时间
  int _time;

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

  ///手机
  String phone;

  ///邮箱
  String email;

  ///SDK加解密密钥
  String secret;

  ///最新源码版本序号
  int version;

  ///最新源码最小sdk
  int minsdkv;

  ///服务端语言环境类型
  String language;

  ///提现交易金额的分红比例
  int cashoutRate;

  ///虚拟交易金额的分红比例
  int vritualRate;

  ///支持的提现方式配置
  List<String> cashStyleList;

  ///实时通讯ICE服务器配置
  List<DbJsonWraper> iceServerList;

  ///超级管理员id
  ObjectId systemUid;

  ///管理员id列表
  List<ObjectId> adminIds;

  ///客服号id列表
  List<ObjectId> staffIds;

  ///通知群id列表
  List<ObjectId> groupIds;

  ///自定义数据管理集合序号
  Map<int, String> customXAdminNos;

  ///自定义数据状态约束序号（开发版、审核版、发布版）
  List<int> customXStateNos;

  ///自定义数据私有保护序号
  List<int> customXOwnerNos;

  ///充值商品列表
  List<PayGoods> rechargeGoodsList;

  ///虚拟商品列表
  List<PayGoods> virvalueGoodsList;

  ///微信应用Id
  String wechatAppId;

  ///微信应用Secret
  String wechatAppSecret;

  ///微信商户Id
  String wechatMchId;

  ///微信商户Secret
  String wechatMchSecret;

  ///支付宝应用Id
  String alipayAppId;

  ///支付宝内容密钥
  String alipayAesKey;

  ///支付宝平台公钥
  String alipayPublicKey;

  ///支付宝商户私钥
  String alipayAppPrivateKey;

  ///支付宝平台根证书（证书模式）
  String alipayCertRootKey;

  ///支付宝平台公钥证书（证书模式）
  String alipayCertPublicKey;

  ///支付宝商户应用公钥证书（证书模式））
  String alipayCertAppPublicKey;

  ///阿里短信AccessKeyId
  String alismsAccessKeyId;

  ///阿里短信AccessKeySecret
  String alismsAccessKeySecret;

  ///阿里短信Endpoint
  String alismsEndpoint;

  ///阿里短信ApiVersion
  String alismsApiVersion;

  ///阿里短信SignName
  String alismsSignName;

  ///阿里短信TemplateCode
  String alismsTemplateCode;

  ///苹果KeyP8
  String appleKeyP8;

  ///苹果KeyP8Public
  ///生成方法: openssl ec -in appleKey.p8 -pubout -out appleKey_public.p8 
  String appleKeyP8Public;

  ///苹果AuthClientId
  String appleAuthClientId;

  ///苹果AuthTeamId
  String appleAuthTeamId;

  ///苹果AuthKeyId
  String appleAuthKeyId;

  ///苹果AuthRedirectUri
  ///定向url，网页登录需要，只是客服端登录可以不写
  String appleAuthRedirectUri;

  ///苹果AppSiteAssociation
  String appleAppSiteAssociation;

  ///唯一id
  ObjectId get id => _id;

  ///自定义数据
  DbJsonWraper get extra => _extra;

  ///创建时间
  int get time => _time;

  Business({
    ObjectId? id,
    DbJsonWraper? extra,
    int? time,
    String? no,
    String? pwd,
    String? nick,
    String? desc,
    String? icon,
    String? phone,
    String? email,
    String? secret,
    int? version,
    int? minsdkv,
    String? language,
    int? cashoutRate,
    int? vritualRate,
    List<String>? cashStyleList,
    List<DbJsonWraper>? iceServerList,
    ObjectId? systemUid,
    List<ObjectId>? adminIds,
    List<ObjectId>? staffIds,
    List<ObjectId>? groupIds,
    Map<int, String>? customXAdminNos,
    List<int>? customXStateNos,
    List<int>? customXOwnerNos,
    List<PayGoods>? rechargeGoodsList,
    List<PayGoods>? virvalueGoodsList,
    String? wechatAppId,
    String? wechatAppSecret,
    String? wechatMchId,
    String? wechatMchSecret,
    String? alipayAppId,
    String? alipayAesKey,
    String? alipayPublicKey,
    String? alipayAppPrivateKey,
    String? alipayCertRootKey,
    String? alipayCertPublicKey,
    String? alipayCertAppPublicKey,
    String? alismsAccessKeyId,
    String? alismsAccessKeySecret,
    String? alismsEndpoint,
    String? alismsApiVersion,
    String? alismsSignName,
    String? alismsTemplateCode,
    String? appleKeyP8,
    String? appleKeyP8Public,
    String? appleAuthClientId,
    String? appleAuthTeamId,
    String? appleAuthKeyId,
    String? appleAuthRedirectUri,
    String? appleAppSiteAssociation,
  })  : _id = id ?? ObjectId(),
        _extra = extra ?? DbJsonWraper(),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        no = no ?? '',
        pwd = pwd ?? '',
        nick = nick ?? '',
        desc = desc ?? '',
        icon = icon ?? '',
        phone = phone ?? '',
        email = email ?? '',
        secret = secret ?? '',
        version = version ?? 0,
        minsdkv = minsdkv ?? 0,
        language = language ?? 'zh',
        cashoutRate = cashoutRate ?? 0,
        vritualRate = vritualRate ?? 0,
        cashStyleList = cashStyleList ?? [],
        iceServerList = iceServerList ?? [],
        systemUid = systemUid ?? ObjectId.fromHexString('000000000000000000000000'),
        adminIds = adminIds ?? [],
        staffIds = staffIds ?? [],
        groupIds = groupIds ?? [],
        customXAdminNos = customXAdminNos ?? {},
        customXStateNos = customXStateNos ?? [],
        customXOwnerNos = customXOwnerNos ?? [],
        rechargeGoodsList = rechargeGoodsList ?? [],
        virvalueGoodsList = virvalueGoodsList ?? [],
        wechatAppId = wechatAppId ?? '',
        wechatAppSecret = wechatAppSecret ?? '',
        wechatMchId = wechatMchId ?? '',
        wechatMchSecret = wechatMchSecret ?? '',
        alipayAppId = alipayAppId ?? '',
        alipayAesKey = alipayAesKey ?? '',
        alipayPublicKey = alipayPublicKey ?? '',
        alipayAppPrivateKey = alipayAppPrivateKey ?? '',
        alipayCertRootKey = alipayCertRootKey ?? '',
        alipayCertPublicKey = alipayCertPublicKey ?? '',
        alipayCertAppPublicKey = alipayCertAppPublicKey ?? '',
        alismsAccessKeyId = alismsAccessKeyId ?? '',
        alismsAccessKeySecret = alismsAccessKeySecret ?? '',
        alismsEndpoint = alismsEndpoint ?? '',
        alismsApiVersion = alismsApiVersion ?? '',
        alismsSignName = alismsSignName ?? '',
        alismsTemplateCode = alismsTemplateCode ?? '',
        appleKeyP8 = appleKeyP8 ?? '',
        appleKeyP8Public = appleKeyP8Public ?? '',
        appleAuthClientId = appleAuthClientId ?? '',
        appleAuthTeamId = appleAuthTeamId ?? '',
        appleAuthKeyId = appleAuthKeyId ?? '',
        appleAuthRedirectUri = appleAuthRedirectUri ?? '',
        appleAppSiteAssociation = appleAppSiteAssociation ?? '';

  factory Business.fromString(String data) {
    return Business.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Business.fromJson(Map<String, dynamic> map) {
    return Business(
      id: DbQueryField.tryParseObjectId(map['_id']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      time: DbQueryField.tryParseInt(map['_time']),
      no: DbQueryField.tryParseString(map['no']),
      pwd: DbQueryField.tryParseString(map['pwd']),
      nick: DbQueryField.tryParseString(map['nick']),
      desc: DbQueryField.tryParseString(map['desc']),
      icon: DbQueryField.tryParseString(map['icon']),
      phone: DbQueryField.tryParseString(map['phone']),
      email: DbQueryField.tryParseString(map['email']),
      secret: DbQueryField.tryParseString(map['secret']),
      version: DbQueryField.tryParseInt(map['version']),
      minsdkv: DbQueryField.tryParseInt(map['minsdkv']),
      language: DbQueryField.tryParseString(map['language']),
      cashoutRate: DbQueryField.tryParseInt(map['cashoutRate']),
      vritualRate: DbQueryField.tryParseInt(map['vritualRate']),
      cashStyleList: (map['cashStyleList'] as List?)?.map((v) => DbQueryField.parseString(v)).toList(),
      iceServerList: (map['iceServerList'] as List?)?.map((v) => DbJsonWraper.fromJson(v)).toList(),
      systemUid: DbQueryField.tryParseObjectId(map['systemUid']),
      adminIds: (map['adminIds'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      staffIds: (map['staffIds'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      groupIds: (map['groupIds'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      customXAdminNos: (map['customXAdminNos'] as Map?)?.map((k, v) => MapEntry(DbQueryField.parseInt(k), DbQueryField.parseString(v))),
      customXStateNos: (map['customXStateNos'] as List?)?.map((v) => DbQueryField.parseInt(v)).toList(),
      customXOwnerNos: (map['customXOwnerNos'] as List?)?.map((v) => DbQueryField.parseInt(v)).toList(),
      rechargeGoodsList: (map['rechargeGoodsList'] as List?)?.map((v) => PayGoods.fromJson(v)).toList(),
      virvalueGoodsList: (map['virvalueGoodsList'] as List?)?.map((v) => PayGoods.fromJson(v)).toList(),
      wechatAppId: DbQueryField.tryParseString(map['wechatAppId']),
      wechatAppSecret: DbQueryField.tryParseString(map['wechatAppSecret']),
      wechatMchId: DbQueryField.tryParseString(map['wechatMchId']),
      wechatMchSecret: DbQueryField.tryParseString(map['wechatMchSecret']),
      alipayAppId: DbQueryField.tryParseString(map['alipayAppId']),
      alipayAesKey: DbQueryField.tryParseString(map['alipayAesKey']),
      alipayPublicKey: DbQueryField.tryParseString(map['alipayPublicKey']),
      alipayAppPrivateKey: DbQueryField.tryParseString(map['alipayAppPrivateKey']),
      alipayCertRootKey: DbQueryField.tryParseString(map['alipayCertRootKey']),
      alipayCertPublicKey: DbQueryField.tryParseString(map['alipayCertPublicKey']),
      alipayCertAppPublicKey: DbQueryField.tryParseString(map['alipayCertAppPublicKey']),
      alismsAccessKeyId: DbQueryField.tryParseString(map['alismsAccessKeyId']),
      alismsAccessKeySecret: DbQueryField.tryParseString(map['alismsAccessKeySecret']),
      alismsEndpoint: DbQueryField.tryParseString(map['alismsEndpoint']),
      alismsApiVersion: DbQueryField.tryParseString(map['alismsApiVersion']),
      alismsSignName: DbQueryField.tryParseString(map['alismsSignName']),
      alismsTemplateCode: DbQueryField.tryParseString(map['alismsTemplateCode']),
      appleKeyP8: DbQueryField.tryParseString(map['appleKeyP8']),
      appleKeyP8Public: DbQueryField.tryParseString(map['appleKeyP8Public']),
      appleAuthClientId: DbQueryField.tryParseString(map['appleAuthClientId']),
      appleAuthTeamId: DbQueryField.tryParseString(map['appleAuthTeamId']),
      appleAuthKeyId: DbQueryField.tryParseString(map['appleAuthKeyId']),
      appleAuthRedirectUri: DbQueryField.tryParseString(map['appleAuthRedirectUri']),
      appleAppSiteAssociation: DbQueryField.tryParseString(map['appleAppSiteAssociation']),
    );
  }

  @override
  String toString() {
    return 'Business(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': DbQueryField.toBaseType(_id),
      '_extra': DbQueryField.toBaseType(_extra),
      '_time': DbQueryField.toBaseType(_time),
      'no': DbQueryField.toBaseType(no),
      'pwd': DbQueryField.toBaseType(pwd),
      'nick': DbQueryField.toBaseType(nick),
      'desc': DbQueryField.toBaseType(desc),
      'icon': DbQueryField.toBaseType(icon),
      'phone': DbQueryField.toBaseType(phone),
      'email': DbQueryField.toBaseType(email),
      'secret': DbQueryField.toBaseType(secret),
      'version': DbQueryField.toBaseType(version),
      'minsdkv': DbQueryField.toBaseType(minsdkv),
      'language': DbQueryField.toBaseType(language),
      'cashoutRate': DbQueryField.toBaseType(cashoutRate),
      'vritualRate': DbQueryField.toBaseType(vritualRate),
      'cashStyleList': DbQueryField.toBaseType(cashStyleList),
      'iceServerList': DbQueryField.toBaseType(iceServerList),
      'systemUid': DbQueryField.toBaseType(systemUid),
      'adminIds': DbQueryField.toBaseType(adminIds),
      'staffIds': DbQueryField.toBaseType(staffIds),
      'groupIds': DbQueryField.toBaseType(groupIds),
      'customXAdminNos': DbQueryField.toBaseType(customXAdminNos),
      'customXStateNos': DbQueryField.toBaseType(customXStateNos),
      'customXOwnerNos': DbQueryField.toBaseType(customXOwnerNos),
      'rechargeGoodsList': DbQueryField.toBaseType(rechargeGoodsList),
      'virvalueGoodsList': DbQueryField.toBaseType(virvalueGoodsList),
      'wechatAppId': DbQueryField.toBaseType(wechatAppId),
      'wechatAppSecret': DbQueryField.toBaseType(wechatAppSecret),
      'wechatMchId': DbQueryField.toBaseType(wechatMchId),
      'wechatMchSecret': DbQueryField.toBaseType(wechatMchSecret),
      'alipayAppId': DbQueryField.toBaseType(alipayAppId),
      'alipayAesKey': DbQueryField.toBaseType(alipayAesKey),
      'alipayPublicKey': DbQueryField.toBaseType(alipayPublicKey),
      'alipayAppPrivateKey': DbQueryField.toBaseType(alipayAppPrivateKey),
      'alipayCertRootKey': DbQueryField.toBaseType(alipayCertRootKey),
      'alipayCertPublicKey': DbQueryField.toBaseType(alipayCertPublicKey),
      'alipayCertAppPublicKey': DbQueryField.toBaseType(alipayCertAppPublicKey),
      'alismsAccessKeyId': DbQueryField.toBaseType(alismsAccessKeyId),
      'alismsAccessKeySecret': DbQueryField.toBaseType(alismsAccessKeySecret),
      'alismsEndpoint': DbQueryField.toBaseType(alismsEndpoint),
      'alismsApiVersion': DbQueryField.toBaseType(alismsApiVersion),
      'alismsSignName': DbQueryField.toBaseType(alismsSignName),
      'alismsTemplateCode': DbQueryField.toBaseType(alismsTemplateCode),
      'appleKeyP8': DbQueryField.toBaseType(appleKeyP8),
      'appleKeyP8Public': DbQueryField.toBaseType(appleKeyP8Public),
      'appleAuthClientId': DbQueryField.toBaseType(appleAuthClientId),
      'appleAuthTeamId': DbQueryField.toBaseType(appleAuthTeamId),
      'appleAuthKeyId': DbQueryField.toBaseType(appleAuthKeyId),
      'appleAuthRedirectUri': DbQueryField.toBaseType(appleAuthRedirectUri),
      'appleAppSiteAssociation': DbQueryField.toBaseType(appleAppSiteAssociation),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      '_id': _id,
      '_extra': _extra,
      '_time': _time,
      'no': no,
      'pwd': pwd,
      'nick': nick,
      'desc': desc,
      'icon': icon,
      'phone': phone,
      'email': email,
      'secret': secret,
      'version': version,
      'minsdkv': minsdkv,
      'language': language,
      'cashoutRate': cashoutRate,
      'vritualRate': vritualRate,
      'cashStyleList': cashStyleList,
      'iceServerList': iceServerList,
      'systemUid': systemUid,
      'adminIds': adminIds,
      'staffIds': staffIds,
      'groupIds': groupIds,
      'customXAdminNos': customXAdminNos,
      'customXStateNos': customXStateNos,
      'customXOwnerNos': customXOwnerNos,
      'rechargeGoodsList': rechargeGoodsList,
      'virvalueGoodsList': virvalueGoodsList,
      'wechatAppId': wechatAppId,
      'wechatAppSecret': wechatAppSecret,
      'wechatMchId': wechatMchId,
      'wechatMchSecret': wechatMchSecret,
      'alipayAppId': alipayAppId,
      'alipayAesKey': alipayAesKey,
      'alipayPublicKey': alipayPublicKey,
      'alipayAppPrivateKey': alipayAppPrivateKey,
      'alipayCertRootKey': alipayCertRootKey,
      'alipayCertPublicKey': alipayCertPublicKey,
      'alipayCertAppPublicKey': alipayCertAppPublicKey,
      'alismsAccessKeyId': alismsAccessKeyId,
      'alismsAccessKeySecret': alismsAccessKeySecret,
      'alismsEndpoint': alismsEndpoint,
      'alismsApiVersion': alismsApiVersion,
      'alismsSignName': alismsSignName,
      'alismsTemplateCode': alismsTemplateCode,
      'appleKeyP8': appleKeyP8,
      'appleKeyP8Public': appleKeyP8Public,
      'appleAuthClientId': appleAuthClientId,
      'appleAuthTeamId': appleAuthTeamId,
      'appleAuthKeyId': appleAuthKeyId,
      'appleAuthRedirectUri': appleAuthRedirectUri,
      'appleAppSiteAssociation': appleAppSiteAssociation,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Business? parser}) {
    parser = parser ?? Business.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('no')) no = parser.no;
    if (map.containsKey('pwd')) pwd = parser.pwd;
    if (map.containsKey('nick')) nick = parser.nick;
    if (map.containsKey('desc')) desc = parser.desc;
    if (map.containsKey('icon')) icon = parser.icon;
    if (map.containsKey('phone')) phone = parser.phone;
    if (map.containsKey('email')) email = parser.email;
    if (map.containsKey('secret')) secret = parser.secret;
    if (map.containsKey('version')) version = parser.version;
    if (map.containsKey('minsdkv')) minsdkv = parser.minsdkv;
    if (map.containsKey('language')) language = parser.language;
    if (map.containsKey('cashoutRate')) cashoutRate = parser.cashoutRate;
    if (map.containsKey('vritualRate')) vritualRate = parser.vritualRate;
    if (map.containsKey('cashStyleList')) cashStyleList = parser.cashStyleList;
    if (map.containsKey('iceServerList')) iceServerList = parser.iceServerList;
    if (map.containsKey('systemUid')) systemUid = parser.systemUid;
    if (map.containsKey('adminIds')) adminIds = parser.adminIds;
    if (map.containsKey('staffIds')) staffIds = parser.staffIds;
    if (map.containsKey('groupIds')) groupIds = parser.groupIds;
    if (map.containsKey('customXAdminNos')) customXAdminNos = parser.customXAdminNos;
    if (map.containsKey('customXStateNos')) customXStateNos = parser.customXStateNos;
    if (map.containsKey('customXOwnerNos')) customXOwnerNos = parser.customXOwnerNos;
    if (map.containsKey('rechargeGoodsList')) rechargeGoodsList = parser.rechargeGoodsList;
    if (map.containsKey('virvalueGoodsList')) virvalueGoodsList = parser.virvalueGoodsList;
    if (map.containsKey('wechatAppId')) wechatAppId = parser.wechatAppId;
    if (map.containsKey('wechatAppSecret')) wechatAppSecret = parser.wechatAppSecret;
    if (map.containsKey('wechatMchId')) wechatMchId = parser.wechatMchId;
    if (map.containsKey('wechatMchSecret')) wechatMchSecret = parser.wechatMchSecret;
    if (map.containsKey('alipayAppId')) alipayAppId = parser.alipayAppId;
    if (map.containsKey('alipayAesKey')) alipayAesKey = parser.alipayAesKey;
    if (map.containsKey('alipayPublicKey')) alipayPublicKey = parser.alipayPublicKey;
    if (map.containsKey('alipayAppPrivateKey')) alipayAppPrivateKey = parser.alipayAppPrivateKey;
    if (map.containsKey('alipayCertRootKey')) alipayCertRootKey = parser.alipayCertRootKey;
    if (map.containsKey('alipayCertPublicKey')) alipayCertPublicKey = parser.alipayCertPublicKey;
    if (map.containsKey('alipayCertAppPublicKey')) alipayCertAppPublicKey = parser.alipayCertAppPublicKey;
    if (map.containsKey('alismsAccessKeyId')) alismsAccessKeyId = parser.alismsAccessKeyId;
    if (map.containsKey('alismsAccessKeySecret')) alismsAccessKeySecret = parser.alismsAccessKeySecret;
    if (map.containsKey('alismsEndpoint')) alismsEndpoint = parser.alismsEndpoint;
    if (map.containsKey('alismsApiVersion')) alismsApiVersion = parser.alismsApiVersion;
    if (map.containsKey('alismsSignName')) alismsSignName = parser.alismsSignName;
    if (map.containsKey('alismsTemplateCode')) alismsTemplateCode = parser.alismsTemplateCode;
    if (map.containsKey('appleKeyP8')) appleKeyP8 = parser.appleKeyP8;
    if (map.containsKey('appleKeyP8Public')) appleKeyP8Public = parser.appleKeyP8Public;
    if (map.containsKey('appleAuthClientId')) appleAuthClientId = parser.appleAuthClientId;
    if (map.containsKey('appleAuthTeamId')) appleAuthTeamId = parser.appleAuthTeamId;
    if (map.containsKey('appleAuthKeyId')) appleAuthKeyId = parser.appleAuthKeyId;
    if (map.containsKey('appleAuthRedirectUri')) appleAuthRedirectUri = parser.appleAuthRedirectUri;
    if (map.containsKey('appleAppSiteAssociation')) appleAppSiteAssociation = parser.appleAppSiteAssociation;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('_id')) _id = map['_id'];
    if (map.containsKey('_extra')) _extra = map['_extra'];
    if (map.containsKey('_time')) _time = map['_time'];
    if (map.containsKey('no')) no = map['no'];
    if (map.containsKey('pwd')) pwd = map['pwd'];
    if (map.containsKey('nick')) nick = map['nick'];
    if (map.containsKey('desc')) desc = map['desc'];
    if (map.containsKey('icon')) icon = map['icon'];
    if (map.containsKey('phone')) phone = map['phone'];
    if (map.containsKey('email')) email = map['email'];
    if (map.containsKey('secret')) secret = map['secret'];
    if (map.containsKey('version')) version = map['version'];
    if (map.containsKey('minsdkv')) minsdkv = map['minsdkv'];
    if (map.containsKey('language')) language = map['language'];
    if (map.containsKey('cashoutRate')) cashoutRate = map['cashoutRate'];
    if (map.containsKey('vritualRate')) vritualRate = map['vritualRate'];
    if (map.containsKey('cashStyleList')) cashStyleList = map['cashStyleList'];
    if (map.containsKey('iceServerList')) iceServerList = map['iceServerList'];
    if (map.containsKey('systemUid')) systemUid = map['systemUid'];
    if (map.containsKey('adminIds')) adminIds = map['adminIds'];
    if (map.containsKey('staffIds')) staffIds = map['staffIds'];
    if (map.containsKey('groupIds')) groupIds = map['groupIds'];
    if (map.containsKey('customXAdminNos')) customXAdminNos = map['customXAdminNos'];
    if (map.containsKey('customXStateNos')) customXStateNos = map['customXStateNos'];
    if (map.containsKey('customXOwnerNos')) customXOwnerNos = map['customXOwnerNos'];
    if (map.containsKey('rechargeGoodsList')) rechargeGoodsList = map['rechargeGoodsList'];
    if (map.containsKey('virvalueGoodsList')) virvalueGoodsList = map['virvalueGoodsList'];
    if (map.containsKey('wechatAppId')) wechatAppId = map['wechatAppId'];
    if (map.containsKey('wechatAppSecret')) wechatAppSecret = map['wechatAppSecret'];
    if (map.containsKey('wechatMchId')) wechatMchId = map['wechatMchId'];
    if (map.containsKey('wechatMchSecret')) wechatMchSecret = map['wechatMchSecret'];
    if (map.containsKey('alipayAppId')) alipayAppId = map['alipayAppId'];
    if (map.containsKey('alipayAesKey')) alipayAesKey = map['alipayAesKey'];
    if (map.containsKey('alipayPublicKey')) alipayPublicKey = map['alipayPublicKey'];
    if (map.containsKey('alipayAppPrivateKey')) alipayAppPrivateKey = map['alipayAppPrivateKey'];
    if (map.containsKey('alipayCertRootKey')) alipayCertRootKey = map['alipayCertRootKey'];
    if (map.containsKey('alipayCertPublicKey')) alipayCertPublicKey = map['alipayCertPublicKey'];
    if (map.containsKey('alipayCertAppPublicKey')) alipayCertAppPublicKey = map['alipayCertAppPublicKey'];
    if (map.containsKey('alismsAccessKeyId')) alismsAccessKeyId = map['alismsAccessKeyId'];
    if (map.containsKey('alismsAccessKeySecret')) alismsAccessKeySecret = map['alismsAccessKeySecret'];
    if (map.containsKey('alismsEndpoint')) alismsEndpoint = map['alismsEndpoint'];
    if (map.containsKey('alismsApiVersion')) alismsApiVersion = map['alismsApiVersion'];
    if (map.containsKey('alismsSignName')) alismsSignName = map['alismsSignName'];
    if (map.containsKey('alismsTemplateCode')) alismsTemplateCode = map['alismsTemplateCode'];
    if (map.containsKey('appleKeyP8')) appleKeyP8 = map['appleKeyP8'];
    if (map.containsKey('appleKeyP8Public')) appleKeyP8Public = map['appleKeyP8Public'];
    if (map.containsKey('appleAuthClientId')) appleAuthClientId = map['appleAuthClientId'];
    if (map.containsKey('appleAuthTeamId')) appleAuthTeamId = map['appleAuthTeamId'];
    if (map.containsKey('appleAuthKeyId')) appleAuthKeyId = map['appleAuthKeyId'];
    if (map.containsKey('appleAuthRedirectUri')) appleAuthRedirectUri = map['appleAuthRedirectUri'];
    if (map.containsKey('appleAppSiteAssociation')) appleAppSiteAssociation = map['appleAppSiteAssociation'];
  }
}

class BusinessDirty {
  final Map<String, dynamic> data = {};

  ///唯一id
  set id(ObjectId value) => data['_id'] = DbQueryField.toBaseType(value);

  ///自定义数据
  set extra(DbJsonWraper value) => data['_extra'] = DbQueryField.toBaseType(value);

  ///创建时间
  set time(int value) => data['_time'] = DbQueryField.toBaseType(value);

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

  ///手机
  set phone(String value) => data['phone'] = DbQueryField.toBaseType(value);

  ///邮箱
  set email(String value) => data['email'] = DbQueryField.toBaseType(value);

  ///SDK加解密密钥
  set secret(String value) => data['secret'] = DbQueryField.toBaseType(value);

  ///最新源码版本序号
  set version(int value) => data['version'] = DbQueryField.toBaseType(value);

  ///最新源码最小sdk
  set minsdkv(int value) => data['minsdkv'] = DbQueryField.toBaseType(value);

  ///服务端语言环境类型
  set language(String value) => data['language'] = DbQueryField.toBaseType(value);

  ///提现交易金额的分红比例
  set cashoutRate(int value) => data['cashoutRate'] = DbQueryField.toBaseType(value);

  ///虚拟交易金额的分红比例
  set vritualRate(int value) => data['vritualRate'] = DbQueryField.toBaseType(value);

  ///支持的提现方式配置
  set cashStyleList(List<String> value) => data['cashStyleList'] = DbQueryField.toBaseType(value);

  ///实时通讯ICE服务器配置
  set iceServerList(List<DbJsonWraper> value) => data['iceServerList'] = DbQueryField.toBaseType(value);

  ///超级管理员id
  set systemUid(ObjectId value) => data['systemUid'] = DbQueryField.toBaseType(value);

  ///管理员id列表
  set adminIds(List<ObjectId> value) => data['adminIds'] = DbQueryField.toBaseType(value);

  ///客服号id列表
  set staffIds(List<ObjectId> value) => data['staffIds'] = DbQueryField.toBaseType(value);

  ///通知群id列表
  set groupIds(List<ObjectId> value) => data['groupIds'] = DbQueryField.toBaseType(value);

  ///自定义数据管理集合序号
  set customXAdminNos(Map<int, String> value) => data['customXAdminNos'] = DbQueryField.toBaseType(value);

  ///自定义数据状态约束序号（开发版、审核版、发布版）
  set customXStateNos(List<int> value) => data['customXStateNos'] = DbQueryField.toBaseType(value);

  ///自定义数据私有保护序号
  set customXOwnerNos(List<int> value) => data['customXOwnerNos'] = DbQueryField.toBaseType(value);

  ///充值商品列表
  set rechargeGoodsList(List<PayGoods> value) => data['rechargeGoodsList'] = DbQueryField.toBaseType(value);

  ///虚拟商品列表
  set virvalueGoodsList(List<PayGoods> value) => data['virvalueGoodsList'] = DbQueryField.toBaseType(value);

  ///微信应用Id
  set wechatAppId(String value) => data['wechatAppId'] = DbQueryField.toBaseType(value);

  ///微信应用Secret
  set wechatAppSecret(String value) => data['wechatAppSecret'] = DbQueryField.toBaseType(value);

  ///微信商户Id
  set wechatMchId(String value) => data['wechatMchId'] = DbQueryField.toBaseType(value);

  ///微信商户Secret
  set wechatMchSecret(String value) => data['wechatMchSecret'] = DbQueryField.toBaseType(value);

  ///支付宝应用Id
  set alipayAppId(String value) => data['alipayAppId'] = DbQueryField.toBaseType(value);

  ///支付宝内容密钥
  set alipayAesKey(String value) => data['alipayAesKey'] = DbQueryField.toBaseType(value);

  ///支付宝平台公钥
  set alipayPublicKey(String value) => data['alipayPublicKey'] = DbQueryField.toBaseType(value);

  ///支付宝商户私钥
  set alipayAppPrivateKey(String value) => data['alipayAppPrivateKey'] = DbQueryField.toBaseType(value);

  ///支付宝平台根证书（证书模式）
  set alipayCertRootKey(String value) => data['alipayCertRootKey'] = DbQueryField.toBaseType(value);

  ///支付宝平台公钥证书（证书模式）
  set alipayCertPublicKey(String value) => data['alipayCertPublicKey'] = DbQueryField.toBaseType(value);

  ///支付宝商户应用公钥证书（证书模式））
  set alipayCertAppPublicKey(String value) => data['alipayCertAppPublicKey'] = DbQueryField.toBaseType(value);

  ///阿里短信AccessKeyId
  set alismsAccessKeyId(String value) => data['alismsAccessKeyId'] = DbQueryField.toBaseType(value);

  ///阿里短信AccessKeySecret
  set alismsAccessKeySecret(String value) => data['alismsAccessKeySecret'] = DbQueryField.toBaseType(value);

  ///阿里短信Endpoint
  set alismsEndpoint(String value) => data['alismsEndpoint'] = DbQueryField.toBaseType(value);

  ///阿里短信ApiVersion
  set alismsApiVersion(String value) => data['alismsApiVersion'] = DbQueryField.toBaseType(value);

  ///阿里短信SignName
  set alismsSignName(String value) => data['alismsSignName'] = DbQueryField.toBaseType(value);

  ///阿里短信TemplateCode
  set alismsTemplateCode(String value) => data['alismsTemplateCode'] = DbQueryField.toBaseType(value);

  ///苹果KeyP8
  set appleKeyP8(String value) => data['appleKeyP8'] = DbQueryField.toBaseType(value);

  ///苹果KeyP8Public
  ///生成方法: openssl ec -in appleKey.p8 -pubout -out appleKey_public.p8 
  set appleKeyP8Public(String value) => data['appleKeyP8Public'] = DbQueryField.toBaseType(value);

  ///苹果AuthClientId
  set appleAuthClientId(String value) => data['appleAuthClientId'] = DbQueryField.toBaseType(value);

  ///苹果AuthTeamId
  set appleAuthTeamId(String value) => data['appleAuthTeamId'] = DbQueryField.toBaseType(value);

  ///苹果AuthKeyId
  set appleAuthKeyId(String value) => data['appleAuthKeyId'] = DbQueryField.toBaseType(value);

  ///苹果AuthRedirectUri
  ///定向url，网页登录需要，只是客服端登录可以不写
  set appleAuthRedirectUri(String value) => data['appleAuthRedirectUri'] = DbQueryField.toBaseType(value);

  ///苹果AppSiteAssociation
  set appleAppSiteAssociation(String value) => data['appleAppSiteAssociation'] = DbQueryField.toBaseType(value);
}
