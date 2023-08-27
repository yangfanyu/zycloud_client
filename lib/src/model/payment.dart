import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';
import 'package:shelf_easy/shelf_deps.dart' show ObjectId;

import 'message.dart';
import 'paygoods.dart';

///
///订单
///
class Payment extends DbBaseModel {
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

  ///订单类型
  int type;

  ///订单资金事务的处理状态
  int state;

  ///订单资金事务的RMB金额，即uid用户的rmbfen增加或减少该值
  int rmbfen;

  ///订单资金事务执行到一定步骤时，要推送的通知消息的数据
  Message? notice;

  ///订单创建时关联的商品数据（充值订单商品、虚拟货币商品）
  PayGoods? paygoods;

  ///订单创建时关联的原始对象id（各种红包订单关联的原始红包消息id、各种分红订单关联的原始交易订单id）
  ObjectId relation;

  ///订单子事务的处理状态（提现订单转资金到提现账户的处理状态、虚拟交易订单交易事务的处理状态）
  int substate;

  ///订单描述信息
  String describe;

  ///订单更新时间
  int update;

  ///主动型充值订单下单时的请求数据
  DbJsonWraper activeRechargeOrderData;

  ///主动型充值订单下单时的请求结果
  DbJsonWraper activeRechargeOrderResult;

  ///主动型充值订单支付后的异步通知次数
  int activeRechargeNotifyCount;

  ///主动型充值订单支付后的异步通知结果列表
  List<DbJsonWraper> activeRechargeNotifyResult;

  ///被动型充值订单的远程订单号码
  String passiveRechargeOrderNo;

  ///被动型充值订单的远程验证凭据
  DbJsonWraper passiveRechargeOrderReceipt;

  ///被动型充值订单的远程验证次数
  int passiveRechargeVerifyCount;

  ///被动型充值订单的远程验证结果列表
  List<DbJsonWraper> passiveRechargeVerifyResult;

  ///提现账户类型
  String cashoutAccountTp;

  ///提现账户号码
  String cashoutAccountNo;

  ///提现扣除手续费后实际到账
  int cashoutActualRmbfen;

  ///是否为虚拟货币充值
  bool virtualValueMode;

  ///虚拟货币充值的到账集合序号、 虚拟商品购买的商品集合序号
  int virtualCustomXNo;

  ///虚拟货币充值的到账对象id、虚拟商品购买的商品对象id
  ObjectId virtualCustomXId;

  ///虚拟货币充值的到账对象类型、 虚拟商品购买的商品对象类型
  int virtualCustomXTp;

  ///分红的用户id列表
  List<ObjectId> bonusesUids;

  ///分红的RMB金额列表
  List<int> bonusesRmbfen;

  ///分红的等待创建订单的用户id
  List<ObjectId> bonusesPending;

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

  Payment({
    ObjectId? id,
    ObjectId? bsid,
    int? time,
    DbJsonWraper? extra,
    List<ObjectId>? trans,
    ObjectId? uid,
    int? type,
    int? state,
    int? rmbfen,
    this.notice,
    this.paygoods,
    ObjectId? relation,
    int? substate,
    String? describe,
    int? update,
    DbJsonWraper? activeRechargeOrderData,
    DbJsonWraper? activeRechargeOrderResult,
    int? activeRechargeNotifyCount,
    List<DbJsonWraper>? activeRechargeNotifyResult,
    String? passiveRechargeOrderNo,
    DbJsonWraper? passiveRechargeOrderReceipt,
    int? passiveRechargeVerifyCount,
    List<DbJsonWraper>? passiveRechargeVerifyResult,
    String? cashoutAccountTp,
    String? cashoutAccountNo,
    int? cashoutActualRmbfen,
    bool? virtualValueMode,
    int? virtualCustomXNo,
    ObjectId? virtualCustomXId,
    int? virtualCustomXTp,
    List<ObjectId>? bonusesUids,
    List<int>? bonusesRmbfen,
    List<ObjectId>? bonusesPending,
  })  : _id = id ?? ObjectId(),
        _bsid = bsid ?? ObjectId.fromHexString('000000000000000000000000'),
        _time = time ?? DateTime.now().millisecondsSinceEpoch,
        _extra = extra ?? DbJsonWraper(),
        _trans = trans ?? [],
        uid = uid ?? ObjectId.fromHexString('000000000000000000000000'),
        type = type ?? 0,
        state = state ?? 0,
        rmbfen = rmbfen ?? 0,
        relation = relation ?? ObjectId.fromHexString('000000000000000000000000'),
        substate = substate ?? 0,
        describe = describe ?? '',
        update = update ?? DateTime.now().millisecondsSinceEpoch,
        activeRechargeOrderData = activeRechargeOrderData ?? DbJsonWraper(),
        activeRechargeOrderResult = activeRechargeOrderResult ?? DbJsonWraper(),
        activeRechargeNotifyCount = activeRechargeNotifyCount ?? 0,
        activeRechargeNotifyResult = activeRechargeNotifyResult ?? [],
        passiveRechargeOrderNo = passiveRechargeOrderNo ?? '',
        passiveRechargeOrderReceipt = passiveRechargeOrderReceipt ?? DbJsonWraper(),
        passiveRechargeVerifyCount = passiveRechargeVerifyCount ?? 0,
        passiveRechargeVerifyResult = passiveRechargeVerifyResult ?? [],
        cashoutAccountTp = cashoutAccountTp ?? '',
        cashoutAccountNo = cashoutAccountNo ?? '',
        cashoutActualRmbfen = cashoutActualRmbfen ?? 0,
        virtualValueMode = virtualValueMode ?? false,
        virtualCustomXNo = virtualCustomXNo ?? 0,
        virtualCustomXId = virtualCustomXId ?? ObjectId.fromHexString('000000000000000000000000'),
        virtualCustomXTp = virtualCustomXTp ?? 0,
        bonusesUids = bonusesUids ?? [],
        bonusesRmbfen = bonusesRmbfen ?? [],
        bonusesPending = bonusesPending ?? [];

  factory Payment.fromString(String data) {
    return Payment.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Payment.fromJson(Map<String, dynamic> map) {
    return Payment(
      id: DbQueryField.tryParseObjectId(map['_id']),
      bsid: DbQueryField.tryParseObjectId(map['_bsid']),
      time: DbQueryField.tryParseInt(map['_time']),
      extra: map['_extra'] is Map ? DbJsonWraper.fromJson(map['_extra']) : map['_extra'],
      trans: (map['_trans'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      uid: DbQueryField.tryParseObjectId(map['uid']),
      type: DbQueryField.tryParseInt(map['type']),
      state: DbQueryField.tryParseInt(map['state']),
      rmbfen: DbQueryField.tryParseInt(map['rmbfen']),
      notice: map['notice'] is Map ? Message.fromJson(map['notice']) : map['notice'],
      paygoods: map['paygoods'] is Map ? PayGoods.fromJson(map['paygoods']) : map['paygoods'],
      relation: DbQueryField.tryParseObjectId(map['relation']),
      substate: DbQueryField.tryParseInt(map['substate']),
      describe: DbQueryField.tryParseString(map['describe']),
      update: DbQueryField.tryParseInt(map['update']),
      activeRechargeOrderData: map['activeRechargeOrderData'] is Map ? DbJsonWraper.fromJson(map['activeRechargeOrderData']) : map['activeRechargeOrderData'],
      activeRechargeOrderResult: map['activeRechargeOrderResult'] is Map ? DbJsonWraper.fromJson(map['activeRechargeOrderResult']) : map['activeRechargeOrderResult'],
      activeRechargeNotifyCount: DbQueryField.tryParseInt(map['activeRechargeNotifyCount']),
      activeRechargeNotifyResult: (map['activeRechargeNotifyResult'] as List?)?.map((v) => DbJsonWraper.fromJson(v)).toList(),
      passiveRechargeOrderNo: DbQueryField.tryParseString(map['passiveRechargeOrderNo']),
      passiveRechargeOrderReceipt: map['passiveRechargeOrderReceipt'] is Map ? DbJsonWraper.fromJson(map['passiveRechargeOrderReceipt']) : map['passiveRechargeOrderReceipt'],
      passiveRechargeVerifyCount: DbQueryField.tryParseInt(map['passiveRechargeVerifyCount']),
      passiveRechargeVerifyResult: (map['passiveRechargeVerifyResult'] as List?)?.map((v) => DbJsonWraper.fromJson(v)).toList(),
      cashoutAccountTp: DbQueryField.tryParseString(map['cashoutAccountTp']),
      cashoutAccountNo: DbQueryField.tryParseString(map['cashoutAccountNo']),
      cashoutActualRmbfen: DbQueryField.tryParseInt(map['cashoutActualRmbfen']),
      virtualValueMode: DbQueryField.tryParseBool(map['virtualValueMode']),
      virtualCustomXNo: DbQueryField.tryParseInt(map['virtualCustomXNo']),
      virtualCustomXId: DbQueryField.tryParseObjectId(map['virtualCustomXId']),
      virtualCustomXTp: DbQueryField.tryParseInt(map['virtualCustomXTp']),
      bonusesUids: (map['bonusesUids'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
      bonusesRmbfen: (map['bonusesRmbfen'] as List?)?.map((v) => DbQueryField.parseInt(v)).toList(),
      bonusesPending: (map['bonusesPending'] as List?)?.map((v) => DbQueryField.parseObjectId(v)).toList(),
    );
  }

  @override
  String toString() {
    return 'Payment(${jsonEncode(toJson())})';
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
      'state': DbQueryField.toBaseType(state),
      'rmbfen': DbQueryField.toBaseType(rmbfen),
      'notice': DbQueryField.toBaseType(notice),
      'paygoods': DbQueryField.toBaseType(paygoods),
      'relation': DbQueryField.toBaseType(relation),
      'substate': DbQueryField.toBaseType(substate),
      'describe': DbQueryField.toBaseType(describe),
      'update': DbQueryField.toBaseType(update),
      'activeRechargeOrderData': DbQueryField.toBaseType(activeRechargeOrderData),
      'activeRechargeOrderResult': DbQueryField.toBaseType(activeRechargeOrderResult),
      'activeRechargeNotifyCount': DbQueryField.toBaseType(activeRechargeNotifyCount),
      'activeRechargeNotifyResult': DbQueryField.toBaseType(activeRechargeNotifyResult),
      'passiveRechargeOrderNo': DbQueryField.toBaseType(passiveRechargeOrderNo),
      'passiveRechargeOrderReceipt': DbQueryField.toBaseType(passiveRechargeOrderReceipt),
      'passiveRechargeVerifyCount': DbQueryField.toBaseType(passiveRechargeVerifyCount),
      'passiveRechargeVerifyResult': DbQueryField.toBaseType(passiveRechargeVerifyResult),
      'cashoutAccountTp': DbQueryField.toBaseType(cashoutAccountTp),
      'cashoutAccountNo': DbQueryField.toBaseType(cashoutAccountNo),
      'cashoutActualRmbfen': DbQueryField.toBaseType(cashoutActualRmbfen),
      'virtualValueMode': DbQueryField.toBaseType(virtualValueMode),
      'virtualCustomXNo': DbQueryField.toBaseType(virtualCustomXNo),
      'virtualCustomXId': DbQueryField.toBaseType(virtualCustomXId),
      'virtualCustomXTp': DbQueryField.toBaseType(virtualCustomXTp),
      'bonusesUids': DbQueryField.toBaseType(bonusesUids),
      'bonusesRmbfen': DbQueryField.toBaseType(bonusesRmbfen),
      'bonusesPending': DbQueryField.toBaseType(bonusesPending),
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
      'state': state,
      'rmbfen': rmbfen,
      'notice': notice,
      'paygoods': paygoods,
      'relation': relation,
      'substate': substate,
      'describe': describe,
      'update': update,
      'activeRechargeOrderData': activeRechargeOrderData,
      'activeRechargeOrderResult': activeRechargeOrderResult,
      'activeRechargeNotifyCount': activeRechargeNotifyCount,
      'activeRechargeNotifyResult': activeRechargeNotifyResult,
      'passiveRechargeOrderNo': passiveRechargeOrderNo,
      'passiveRechargeOrderReceipt': passiveRechargeOrderReceipt,
      'passiveRechargeVerifyCount': passiveRechargeVerifyCount,
      'passiveRechargeVerifyResult': passiveRechargeVerifyResult,
      'cashoutAccountTp': cashoutAccountTp,
      'cashoutAccountNo': cashoutAccountNo,
      'cashoutActualRmbfen': cashoutActualRmbfen,
      'virtualValueMode': virtualValueMode,
      'virtualCustomXNo': virtualCustomXNo,
      'virtualCustomXId': virtualCustomXId,
      'virtualCustomXTp': virtualCustomXTp,
      'bonusesUids': bonusesUids,
      'bonusesRmbfen': bonusesRmbfen,
      'bonusesPending': bonusesPending,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Payment? parser}) {
    parser = parser ?? Payment.fromJson(map);
    if (map.containsKey('_id')) _id = parser._id;
    if (map.containsKey('_bsid')) _bsid = parser._bsid;
    if (map.containsKey('_time')) _time = parser._time;
    if (map.containsKey('_extra')) _extra = parser._extra;
    if (map.containsKey('_trans')) _trans = parser._trans;
    if (map.containsKey('uid')) uid = parser.uid;
    if (map.containsKey('type')) type = parser.type;
    if (map.containsKey('state')) state = parser.state;
    if (map.containsKey('rmbfen')) rmbfen = parser.rmbfen;
    if (map.containsKey('notice')) notice = parser.notice;
    if (map.containsKey('paygoods')) paygoods = parser.paygoods;
    if (map.containsKey('relation')) relation = parser.relation;
    if (map.containsKey('substate')) substate = parser.substate;
    if (map.containsKey('describe')) describe = parser.describe;
    if (map.containsKey('update')) update = parser.update;
    if (map.containsKey('activeRechargeOrderData')) activeRechargeOrderData = parser.activeRechargeOrderData;
    if (map.containsKey('activeRechargeOrderResult')) activeRechargeOrderResult = parser.activeRechargeOrderResult;
    if (map.containsKey('activeRechargeNotifyCount')) activeRechargeNotifyCount = parser.activeRechargeNotifyCount;
    if (map.containsKey('activeRechargeNotifyResult')) activeRechargeNotifyResult = parser.activeRechargeNotifyResult;
    if (map.containsKey('passiveRechargeOrderNo')) passiveRechargeOrderNo = parser.passiveRechargeOrderNo;
    if (map.containsKey('passiveRechargeOrderReceipt')) passiveRechargeOrderReceipt = parser.passiveRechargeOrderReceipt;
    if (map.containsKey('passiveRechargeVerifyCount')) passiveRechargeVerifyCount = parser.passiveRechargeVerifyCount;
    if (map.containsKey('passiveRechargeVerifyResult')) passiveRechargeVerifyResult = parser.passiveRechargeVerifyResult;
    if (map.containsKey('cashoutAccountTp')) cashoutAccountTp = parser.cashoutAccountTp;
    if (map.containsKey('cashoutAccountNo')) cashoutAccountNo = parser.cashoutAccountNo;
    if (map.containsKey('cashoutActualRmbfen')) cashoutActualRmbfen = parser.cashoutActualRmbfen;
    if (map.containsKey('virtualValueMode')) virtualValueMode = parser.virtualValueMode;
    if (map.containsKey('virtualCustomXNo')) virtualCustomXNo = parser.virtualCustomXNo;
    if (map.containsKey('virtualCustomXId')) virtualCustomXId = parser.virtualCustomXId;
    if (map.containsKey('virtualCustomXTp')) virtualCustomXTp = parser.virtualCustomXTp;
    if (map.containsKey('bonusesUids')) bonusesUids = parser.bonusesUids;
    if (map.containsKey('bonusesRmbfen')) bonusesRmbfen = parser.bonusesRmbfen;
    if (map.containsKey('bonusesPending')) bonusesPending = parser.bonusesPending;
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
    if (map.containsKey('state')) state = map['state'];
    if (map.containsKey('rmbfen')) rmbfen = map['rmbfen'];
    if (map.containsKey('notice')) notice = map['notice'];
    if (map.containsKey('paygoods')) paygoods = map['paygoods'];
    if (map.containsKey('relation')) relation = map['relation'];
    if (map.containsKey('substate')) substate = map['substate'];
    if (map.containsKey('describe')) describe = map['describe'];
    if (map.containsKey('update')) update = map['update'];
    if (map.containsKey('activeRechargeOrderData')) activeRechargeOrderData = map['activeRechargeOrderData'];
    if (map.containsKey('activeRechargeOrderResult')) activeRechargeOrderResult = map['activeRechargeOrderResult'];
    if (map.containsKey('activeRechargeNotifyCount')) activeRechargeNotifyCount = map['activeRechargeNotifyCount'];
    if (map.containsKey('activeRechargeNotifyResult')) activeRechargeNotifyResult = map['activeRechargeNotifyResult'];
    if (map.containsKey('passiveRechargeOrderNo')) passiveRechargeOrderNo = map['passiveRechargeOrderNo'];
    if (map.containsKey('passiveRechargeOrderReceipt')) passiveRechargeOrderReceipt = map['passiveRechargeOrderReceipt'];
    if (map.containsKey('passiveRechargeVerifyCount')) passiveRechargeVerifyCount = map['passiveRechargeVerifyCount'];
    if (map.containsKey('passiveRechargeVerifyResult')) passiveRechargeVerifyResult = map['passiveRechargeVerifyResult'];
    if (map.containsKey('cashoutAccountTp')) cashoutAccountTp = map['cashoutAccountTp'];
    if (map.containsKey('cashoutAccountNo')) cashoutAccountNo = map['cashoutAccountNo'];
    if (map.containsKey('cashoutActualRmbfen')) cashoutActualRmbfen = map['cashoutActualRmbfen'];
    if (map.containsKey('virtualValueMode')) virtualValueMode = map['virtualValueMode'];
    if (map.containsKey('virtualCustomXNo')) virtualCustomXNo = map['virtualCustomXNo'];
    if (map.containsKey('virtualCustomXId')) virtualCustomXId = map['virtualCustomXId'];
    if (map.containsKey('virtualCustomXTp')) virtualCustomXTp = map['virtualCustomXTp'];
    if (map.containsKey('bonusesUids')) bonusesUids = map['bonusesUids'];
    if (map.containsKey('bonusesRmbfen')) bonusesRmbfen = map['bonusesRmbfen'];
    if (map.containsKey('bonusesPending')) bonusesPending = map['bonusesPending'];
  }
}

class PaymentDirty {
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

  ///订单类型
  set type(int value) => data['type'] = DbQueryField.toBaseType(value);

  ///订单资金事务的处理状态
  set state(int value) => data['state'] = DbQueryField.toBaseType(value);

  ///订单资金事务的RMB金额，即uid用户的rmbfen增加或减少该值
  set rmbfen(int value) => data['rmbfen'] = DbQueryField.toBaseType(value);

  ///订单资金事务执行到一定步骤时，要推送的通知消息的数据
  set notice(Message value) => data['notice'] = DbQueryField.toBaseType(value);

  ///订单创建时关联的商品数据（充值订单商品、虚拟货币商品）
  set paygoods(PayGoods value) => data['paygoods'] = DbQueryField.toBaseType(value);

  ///订单创建时关联的原始对象id（各种红包订单关联的原始红包消息id、各种分红订单关联的原始交易订单id）
  set relation(ObjectId value) => data['relation'] = DbQueryField.toBaseType(value);

  ///订单子事务的处理状态（提现订单转资金到提现账户的处理状态、虚拟交易订单交易事务的处理状态）
  set substate(int value) => data['substate'] = DbQueryField.toBaseType(value);

  ///订单描述信息
  set describe(String value) => data['describe'] = DbQueryField.toBaseType(value);

  ///订单更新时间
  set update(int value) => data['update'] = DbQueryField.toBaseType(value);

  ///主动型充值订单下单时的请求数据
  set activeRechargeOrderData(DbJsonWraper value) => data['activeRechargeOrderData'] = DbQueryField.toBaseType(value);

  ///主动型充值订单下单时的请求结果
  set activeRechargeOrderResult(DbJsonWraper value) => data['activeRechargeOrderResult'] = DbQueryField.toBaseType(value);

  ///主动型充值订单支付后的异步通知次数
  set activeRechargeNotifyCount(int value) => data['activeRechargeNotifyCount'] = DbQueryField.toBaseType(value);

  ///主动型充值订单支付后的异步通知结果列表
  set activeRechargeNotifyResult(List<DbJsonWraper> value) => data['activeRechargeNotifyResult'] = DbQueryField.toBaseType(value);

  ///被动型充值订单的远程订单号码
  set passiveRechargeOrderNo(String value) => data['passiveRechargeOrderNo'] = DbQueryField.toBaseType(value);

  ///被动型充值订单的远程验证凭据
  set passiveRechargeOrderReceipt(DbJsonWraper value) => data['passiveRechargeOrderReceipt'] = DbQueryField.toBaseType(value);

  ///被动型充值订单的远程验证次数
  set passiveRechargeVerifyCount(int value) => data['passiveRechargeVerifyCount'] = DbQueryField.toBaseType(value);

  ///被动型充值订单的远程验证结果列表
  set passiveRechargeVerifyResult(List<DbJsonWraper> value) => data['passiveRechargeVerifyResult'] = DbQueryField.toBaseType(value);

  ///提现账户类型
  set cashoutAccountTp(String value) => data['cashoutAccountTp'] = DbQueryField.toBaseType(value);

  ///提现账户号码
  set cashoutAccountNo(String value) => data['cashoutAccountNo'] = DbQueryField.toBaseType(value);

  ///提现扣除手续费后实际到账
  set cashoutActualRmbfen(int value) => data['cashoutActualRmbfen'] = DbQueryField.toBaseType(value);

  ///是否为虚拟货币充值
  set virtualValueMode(bool value) => data['virtualValueMode'] = DbQueryField.toBaseType(value);

  ///虚拟货币充值的到账集合序号、 虚拟商品购买的商品集合序号
  set virtualCustomXNo(int value) => data['virtualCustomXNo'] = DbQueryField.toBaseType(value);

  ///虚拟货币充值的到账对象id、虚拟商品购买的商品对象id
  set virtualCustomXId(ObjectId value) => data['virtualCustomXId'] = DbQueryField.toBaseType(value);

  ///虚拟货币充值的到账对象类型、 虚拟商品购买的商品对象类型
  set virtualCustomXTp(int value) => data['virtualCustomXTp'] = DbQueryField.toBaseType(value);

  ///分红的用户id列表
  set bonusesUids(List<ObjectId> value) => data['bonusesUids'] = DbQueryField.toBaseType(value);

  ///分红的RMB金额列表
  set bonusesRmbfen(List<int> value) => data['bonusesRmbfen'] = DbQueryField.toBaseType(value);

  ///分红的等待创建订单的用户id
  set bonusesPending(List<ObjectId> value) => data['bonusesPending'] = DbQueryField.toBaseType(value);
}
