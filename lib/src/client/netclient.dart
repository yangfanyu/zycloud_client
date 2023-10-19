import 'dart:convert';

import 'package:lpinyin/lpinyin.dart' show PinyinFormat, PinyinHelper;
import 'package:shelf_easy/shelf_deps.dart' show MediaType, ObjectId;
import 'package:shelf_easy/shelf_easy.dart' show DbJsonWraper, DbQueryField, EasyClient, EasyClientConfig, EasyLogHandler, EasyLogLevel, EasyLogger, EasyPacket, EasySecurity;

import '../model/all.dart';
import '../tool/compage.dart';
import '../tool/comtools.dart';
import '../tool/session.dart';

///
///网络客户端
///
class NetClient {
  ///日志处理方法
  final EasyLogHandler logger;

  ///日志输出级别
  final EasyLogLevel logLevel;

  ///日志输出标签
  final String? logTag;

  ///根服务器地址
  final String host;

  ///根服务器端口
  final int port;

  ///商户唯一标志
  final String bsid;

  ///商户通讯密钥
  final String secret;

  ///是否用二进制收发数据，需要与服务端保持一致
  final bool binary;

  ///是否启用隔离线程进行数据编解码
  final bool isolate;

  ///是否启用ssl证书模式，需要与服务端保持一致
  final bool sslEnable;

  ///登录凭据回调
  final void Function(User user, String? credentials) onCredentials;

  ///商户公开的配置信息
  final Business business;

  ///当前用户信息
  final User user;

  ///激活会话状态
  final NetClientAzState _sessionState;

  ///好友申请状态
  final NetClientAzState _waitshipState;

  ///好友关系状态
  final NetClientAzState _usershipState;

  ///群组关系状态
  final NetClientAzState _teamshipState;

  ///群组成员状态，key为群组id
  final Map<ObjectId, NetClientAzState> _teamuserStateMap;

  ///用户信息，key为用户id
  final Map<ObjectId, User> _userMap;

  ///群组信息，key为群组id
  final Map<ObjectId, Team> _teamMap;

  ///好友申请，key为用户id
  final Map<ObjectId, UserShip> _waitshipMap;

  ///好友关系，key为用户id
  final Map<ObjectId, UserShip> _usershipMap;

  ///群组关系，key为群组id
  final Map<ObjectId, TeamShip> _teamshipMap;

  ///群组成员，key为群组id，子级key为用户id
  final Map<ObjectId, Map<ObjectId, TeamShip>> _teamuserMapMap;

  ///数据缓存，key为查询参数Json转换后的md5
  final Map<String, ComPage<CustomX>> _customXPageMap;

  ///负责http请求的未登录客户端
  final EasyClient _httpGuestClient;

  ///负责http请求的已登录客户端
  final EasyClient _httpAliveClient;

  ///负责websocket连接的客户端
  EasyClient _websocketClient;

  ///标记[_sessionState]是否需要重新构建
  bool _dirtySessionState;

  ///标记[_waitshipState]是否需要重新构建
  bool _dirtyWaitshipState;

  ///标记[_usershipState]是否需要重新构建
  bool _dirtyUsershipState;

  ///标记[_teamshipState]是否需要重新构建
  bool _dirtyTeamshipState;

  ///标记[_teamuserStateMap]是否需要重新构建，key为群组id
  final Map<ObjectId, bool> _dirtyTeamuserStateMap;

  NetClient({
    this.logger = EasyLogger.printLogger,
    this.logLevel = EasyLogLevel.debug,
    this.logTag,
    required this.host,
    required this.port,
    required this.bsid,
    required this.secret,
    this.binary = true,
    this.isolate = true,
    this.sslEnable = false,
    required this.onCredentials,
  })  : business = Business(id: DbQueryField.hexstr2ObjectId(bsid), secret: secret),
        user = User(id: DbQueryField.emptyObjectId),
        _sessionState = NetClientAzState(),
        _waitshipState = NetClientAzState(),
        _usershipState = NetClientAzState(),
        _teamshipState = NetClientAzState(),
        _teamuserStateMap = {},
        _userMap = {},
        _teamMap = {},
        _waitshipMap = {},
        _usershipMap = {},
        _teamshipMap = {},
        _teamuserMapMap = {},
        _customXPageMap = {},
        _httpGuestClient = EasyClient(config: EasyClientConfig(logger: logger, logLevel: logLevel, logTag: logTag, host: host, port: port, binary: binary, sslEnable: sslEnable))..bindUser(bsid, token: secret),
        _httpAliveClient = EasyClient(config: EasyClientConfig(logger: logger, logLevel: logLevel, logTag: logTag, host: host, port: port, binary: binary, sslEnable: sslEnable)),
        _websocketClient = EasyClient(config: EasyClientConfig(logger: logger, logLevel: logLevel, logTag: logTag, host: host, port: port, binary: binary, sslEnable: sslEnable)),
        _dirtySessionState = true,
        _dirtyWaitshipState = true,
        _dirtyUsershipState = true,
        _dirtyTeamshipState = true,
        _dirtyTeamuserStateMap = {};

  ///未登录客户端的http请求根地址
  String get guestHttpUrl => _httpGuestClient.httpUrl;

  ///未登录客户端的websocket请求根地址
  String get guestWebsocketUrl => _httpGuestClient.websocketUrl;

  /* **************** http请求 **************** */

  ///获取应用公开配置信息
  Future<EasyPacket<List<CodeFile>>> appManifest({bool codefiles = false, int? codeVersion}) async {
    final response = await _httpGuestClient.httpRequest('/appManifest', data: {'bsid': bsid, 'codefiles': codefiles, 'codeVersion': codeVersion});
    if (response.ok) {
      final configure = response.data!['configure'];
      final codefiles = response.data!['codefiles'] as List;
      business.updateByJson(configure);
      return response.cloneExtra(codefiles.map((e) => CodeFile.fromJson(e)).toList());
    } else {
      return response.cloneExtra(null);
    }
  }

  ///获取应用源码文件详情
  Future<EasyPacket<CodeFile>> appCodeFile({required ObjectId id}) async {
    final response = await _httpGuestClient.httpRequest('/appCodeFile', data: {'bsid': bsid, 'id': id});
    if (response.ok) {
      return response.cloneExtra(CodeFile.fromJson(response.data!['codefile']));
    } else {
      return response.cloneExtra(null);
    }
  }

  ///验证域名是否允许访问
  Future<EasyPacket<bool>> validateHost({required String host}) async {
    final response = await _httpGuestClient.httpRequest('/validateHost', data: {'bsid': bsid, 'host': host});
    if (response.ok) {
      return response.cloneExtra(response.data!['success']);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///群组网页授权获取用户信息
  Future<EasyPacket<DbJsonWraper>> teamUserAuth({required ObjectId tid, required ObjectId uid, required String host, required int millis, required String sign}) async {
    final response = await _httpGuestClient.httpRequest('/teamUserAuth', data: {'bsid': bsid, 'tid': tid, 'uid': uid, 'host': host, 'millis': millis, 'sign': sign});
    if (response.ok) {
      return response.cloneExtra(DbJsonWraper.fromJson(response.data!['userinfo']));
    } else {
      return response.cloneExtra(null);
    }
  }

  ///使用[User.id]和[User.token]进行登录
  Future<EasyPacket<void>> loginByToken({required ObjectId uid, required String token}) async {
    final response = await _httpGuestClient.httpRequest('/loginByToken', data: {'bsid': bsid, 'uid': uid, 'token': token});
    if (response.ok) {
      user.updateByJson(response.data!['user']);
      _resetWebsocketClient(response.data!);
      onCredentials(user, encryptCredentials(user, secret));
    } else if (response.code == 401) {
      onCredentials(user, null);
    }
    return response;
  }

  ///使用[User.no]和[User.pwd]进行登录
  Future<EasyPacket<void>> loginByNoPwd({required String no, required String pwd}) async {
    final response = await _httpGuestClient.httpRequest('/loginByNoPwd', data: {'bsid': bsid, 'no': no, 'pwd': pwd});
    if (response.ok) {
      user.updateByJson(response.data!['user']);
      _resetWebsocketClient(response.data!);
      onCredentials(user, encryptCredentials(user, secret));
    } else if (response.code == 401) {
      onCredentials(user, null);
    }
    return response;
  }

  ///使用[phone]和验证码[code]进行登录。分为三种场景：
  /// * 新账号注册：当[no]非null且[pwd]非null时，服务端会对[phone]与[no]的重复注册情况进行验证，然后注册新账号并登录。
  /// * 忘记了密码：当[no]为null但[pwd]非null时，服务端会对[phone]对应的账号的进行密码重置，然后登录。
  /// * 手机号登录：当[no]为null且[pwd]为null时，服务端会对[phone]对应的账号的进行登录验证，如果不存在[phone]对应的账号则创建一个新账号之后再登录。
  Future<EasyPacket<void>> loginByPhone({required String phone, required String code, String? no, String? pwd}) async {
    final response = await _httpGuestClient.httpRequest('/loginByPhone', data: {'bsid': bsid, 'phone': phone, 'code': code, 'no': no, 'pwd': pwd});
    if (response.ok) {
      user.updateByJson(response.data!['user']);
      _resetWebsocketClient(response.data!);
      onCredentials(user, encryptCredentials(user, secret));
    } else if (response.code == 401) {
      onCredentials(user, null);
    }
    return response;
  }

  ///通过Apple账号登录
  Future<EasyPacket<void>> loginByApple({required String appleUid, required String appleUname, required String authorizationCode, String? identityToken}) async {
    final response = await _httpGuestClient.httpRequest('/loginByApple', data: {'bsid': bsid, 'appleUid': appleUid, 'appleUname': appleUname, 'authorizationCode': authorizationCode, 'identityToken': identityToken});
    if (response.ok) {
      user.updateByJson(response.data!['user']);
      _resetWebsocketClient(response.data!);
      onCredentials(user, encryptCredentials(user, secret));
    } else if (response.code == 401) {
      onCredentials(user, null);
    }
    return response;
  }

  ///通过Wechat账号登录
  Future<EasyPacket<void>> loginByWechat({required String wechatCode}) async {
    final response = await _httpGuestClient.httpRequest('/loginByWechat', data: {'bsid': bsid, 'wechatCode': wechatCode});
    if (response.ok) {
      user.updateByJson(response.data!['user']);
      _resetWebsocketClient(response.data!);
      onCredentials(user, encryptCredentials(user, secret));
    } else if (response.code == 401) {
      onCredentials(user, null);
    }
    return response;
  }

  ///发送验证码到[phone]
  Future<EasyPacket<void>> sendRandcode({required String phone}) async {
    final response = await _httpGuestClient.httpRequest('/sendRandcode', data: {'bsid': bsid, 'phone': phone});
    return response;
  }

  ///高德IP解析，当[requestIp]为true时，返回对当前网络请求客户端的解析结果
  Future<EasyPacket<Location?>> amapIpParse({required String specifyIp, bool requestIp = false}) async {
    final response = await _httpAliveClient.httpRequest('/amapIpParse', data: {'bsid': bsid, 'specifyIp': specifyIp, 'requestIp': requestIp});
    if (response.ok) {
      return response.cloneExtra(Location.fromJson(response.data!['location']));
    } else {
      return response.cloneExtra(null);
    }
  }

  ///微信充值下单
  Future<EasyPacket<String?>> wechatStart({required int goodsNo}) async {
    final response = await _httpAliveClient.httpRequest('/wechatStart', data: {'bsid': bsid, 'uid': user.id, 'goodsNo': goodsNo});
    if (response.ok) {
      return response.cloneExtra(response.data!['result']);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///支付宝充值下单
  Future<EasyPacket<String?>> alipayStart({required int goodsNo}) async {
    final response = await _httpAliveClient.httpRequest('/alipayStart', data: {'bsid': bsid, 'uid': user.id, 'goodsNo': goodsNo});
    if (response.ok) {
      return response.cloneExtra(response.data!['result']);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///苹果充值下单
  Future<EasyPacket<void>> iospayStart({required int goodsNo, required String inpayId, required String verifyData}) async {
    final response = await _httpAliveClient.httpRequest('/iospayStart', data: {'bsid': bsid, 'uid': user.id, 'goodsNo': goodsNo, 'inpayId': inpayId, 'verifyData': verifyData});
    return response;
  }

  ///文件上传，[type]为[Constant.metaTypeMessage]或[Constant.metaTypeForever]
  Future<EasyPacket<List<Metadata>>> attachUpload({required int type, required List<List<int>> fileBytes, required MediaType mediaType}) async {
    final response = await _httpAliveClient.httpRequest('/attachUpload', data: {'bsid': bsid, 'uid': user.id, 'type': type}, fileBytes: fileBytes, mediaType: mediaType);
    if (response.ok) {
      final metaList = response.data!['metaList'] as List;
      return response.cloneExtra(metaList.map((e) => Metadata.fromJson(e)).toList());
    } else {
      return response.cloneExtra(null);
    }
  }

  /* **************** websocket请求-用户 **************** */

  ///登录后连接到服务器，请确保在登录之后再调用这个方法
  void connect({void Function()? onopen, void Function(int code, String reason)? onclose, void Function(String error)? onerror, void Function(int count)? onretry, void Function(int second, int delay)? onheart}) {
    _websocketClient.connect(
      onopen: onopen,
      onclose: (code, reason) {
        _httpAliveClient.unbindUser(); //立即解绑口令信息
        _websocketClient.unbindUser(); //立即解绑口令信息
        if (onclose != null) onclose(code, reason);
      },
      onerror: onerror,
      onretry: onretry,
      onheart: onheart,
    );
  }

  ///销毁长连接，释放缓存
  void release() {
    //解绑口令信息
    _httpAliveClient.unbindUser();
    _websocketClient.unbindUser();
    //销毁长连接
    _websocketClient.destroy();
    //释放缓存
    _sessionState.clear();
    _waitshipState.clear();
    _usershipState.clear();
    _teamshipState.clear();
    _teamuserStateMap.clear();
    _userMap.clear();
    _teamMap.clear();
    _waitshipMap.clear();
    _usershipMap.clear();
    _teamshipMap.clear();
    _teamuserMapMap.clear();
    _customXPageMap.clear();
    _dirtySessionState = true;
    _dirtyWaitshipState = true;
    _dirtyUsershipState = true;
    _dirtyTeamshipState = true;
    _dirtyTeamuserStateMap.clear();
  }

  ///清除自定义数据的缓存
  void clearCustomX() {
    _customXPageMap.clear();
  }

  ///长连接登入
  Future<EasyPacket<void>> userEnter() async {
    final mill = DateTime.now().millisecondsSinceEpoch;
    final sign = ComTools.generateUserEnterSign(secret, user.token, user.id.toHexString(), mill);
    final response = await _websocketClient.websocketRequest('userEnter', data: {'bsid': bsid, 'uid': user.id, 'mill': mill, 'sign': sign});
    if (response.ok) {
      //更新用户缓存
      user.updateByJson(response.data!['user']);
      _httpAliveClient.bindUser(user.id.toHexString(), token: user.token); //立即绑定口令信息
      _websocketClient.bindUser(user.id.toHexString(), token: user.token); //立即绑定口令信息
      onCredentials(user, encryptCredentials(user, secret));
      //更新其他缓存
      final waitshipKeys = <ObjectId>{};
      final usershipKeys = <ObjectId>{};
      final teamshipKeys = <ObjectId>{};
      _cacheUserShipList(response.data!['waitships'], saveKeys: waitshipKeys);
      _cacheUserShipList(response.data!['userships'], saveKeys: usershipKeys);
      _cacheTeamShipList(response.data!['teamships'], saveKeys: teamshipKeys);
      _cacheUserList(response.data!['userList']);
      _cacheTeamList(response.data!['teamList']);
      //清除废弃数据
      _waitshipMap.removeWhere((key, value) => !waitshipKeys.contains(key));
      _usershipMap.removeWhere((key, value) => !usershipKeys.contains(key));
      _teamshipMap.removeWhere((key, value) => !teamshipKeys.contains(key));
      //清除废弃数据-群组成员相关
      _teamuserStateMap.removeWhere((key, value) => !teamshipKeys.contains(key));
      _teamuserMapMap.removeWhere((key, value) => !teamshipKeys.contains(key));
      _dirtyTeamuserStateMap.removeWhere((key, value) => !teamshipKeys.contains(key));
    } else if (response.code == 401) {
      onCredentials(user, null);
    }
    return response;
  }

  ///长连接登出
  Future<EasyPacket<void>> userLeave() async {
    final response = await _websocketClient.websocketRequest('userLeave', data: {'bsid': bsid});
    if (response.ok) {
      _httpAliveClient.unbindUser();
      _websocketClient.unbindUser();
    }
    return response;
  }

  ///永久注销账号
  Future<EasyPacket<void>> userDestroy() async {
    final response = await _websocketClient.websocketRequest('userDestroy', data: {'bsid': bsid});
    if (response.ok) {
      _httpAliveClient.unbindUser();
      _websocketClient.unbindUser();
    }
    return response;
  }

  ///批量获取用户
  Future<EasyPacket<List<User>>> userFetch({required List<ObjectId> uids}) async {
    final response = await _websocketClient.websocketRequest('userFetch', data: {'bsid': bsid, 'uids': uids});
    if (response.ok) {
      final userList = _cacheUserList(response.data!['userList']);
      _websocketClient.triggerEvent(EasyPacket.pushdata(route: 'onUserFetchedEvent', data: response.data));
      return response.cloneExtra(userList);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///获取[User.no]为[keywords] 或 [User.phone]为[keywords]的用户列表
  Future<EasyPacket<List<User>>> userSearch({required String keywords}) async {
    final response = await _websocketClient.websocketRequest('userSearch', data: {'bsid': bsid, 'keywords': keywords});
    if (response.ok) {
      return response.cloneExtra(_cacheUserList(response.data!['userList']));
    } else {
      return response.cloneExtra(null);
    }
  }

  ///更新我的信息
  Future<EasyPacket<void>> userUpdate({required ObjectId uid, required Map<String, dynamic> fields, String? code, String? newcode}) async {
    final response = await _websocketClient.websocketRequest('userUpdate', data: {'bsid': bsid, 'uid': uid, 'fields': fields, 'code': code, 'newcode': newcode});
    return response;
  }

  ///查询好友关系
  Future<EasyPacket<UserShip>> userShipQuery({required ObjectId uid, ObjectId? fid, required int from}) async {
    final response = await _websocketClient.websocketRequest('userShipQuery', data: {'bsid': bsid, 'uid': uid, 'fid': fid ?? user.id, 'from': from});
    if (response.ok) {
      _cacheUser(response.data!['user']);
      return response.cloneExtra(_cacheUserShip(response.data!['ship']));
    } else {
      return response.cloneExtra(null);
    }
  }

  ///发起好友申请
  Future<EasyPacket<void>> userShipApply({required ObjectId uid, ObjectId? fid, required int from, String apply = ''}) async {
    final response = await _websocketClient.websocketRequest('userShipApply', data: {'bsid': bsid, 'uid': uid, 'fid': fid ?? user.id, 'from': from, 'apply': apply});
    return response;
  }

  ///拒绝好友申请 或 解除好友关系
  Future<EasyPacket<void>> userShipNone({required ObjectId uid}) async {
    final response = await _websocketClient.websocketRequest('userShipNone', data: {'bsid': bsid, 'uid': uid});
    return response;
  }

  ///同意好友申请
  Future<EasyPacket<void>> userShipPass({required ObjectId uid}) async {
    final response = await _websocketClient.websocketRequest('userShipPass', data: {'bsid': bsid, 'uid': uid});
    return response;
  }

  ///更新用户关系
  Future<EasyPacket<void>> userShipUpdate({required ObjectId id, required Map<String, dynamic> fields}) async {
    final response = await _websocketClient.websocketRequest('userShipUpdate', data: {'bsid': bsid, 'id': id, 'fields': fields});
    return response;
  }

  ///创建新的群组
  Future<EasyPacket<void>> teamCreate({required List<ObjectId> uids}) async {
    final response = await _websocketClient.websocketRequest('teamCreate', data: {'bsid': bsid, 'uids': uids});
    return response;
  }

  ///获取群组成员
  Future<EasyPacket<List<TeamShip>>> teamMember({required ObjectId tid}) async {
    final response = await _websocketClient.websocketRequest('teamMember', data: {'bsid': bsid, 'tid': tid});
    if (response.ok) {
      _cacheUserList(response.data!['userList']);
      //更新成员缓存
      final teamuserKeys = <ObjectId>{};
      final teamshipList = _cacheTeamUserList(tid, response.data!['shipList'], saveKeys: teamuserKeys);
      //清除废弃数据
      _teamuserMapMap[tid]?.removeWhere((key, value) => !teamuserKeys.contains(key));
      return response.cloneExtra(teamshipList);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///批量获取群组
  Future<EasyPacket<List<Team>>> teamFetch({required List<ObjectId> tids}) async {
    final response = await _websocketClient.websocketRequest('teamFetch', data: {'bsid': bsid, 'tids': tids});
    if (response.ok) {
      final teamList = _cacheTeamList(response.data!['teamList']);
      _websocketClient.triggerEvent(EasyPacket.pushdata(route: 'onTeamFetchedEvent', data: response.data));
      return response.cloneExtra(teamList);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///获取[Team.no]为[keywords] 或 [Team.nick]为[keywords]的群组列表
  Future<EasyPacket<List<Team>>> teamSearch({required String keywords}) async {
    final response = await _websocketClient.websocketRequest('teamSearch', data: {'bsid': bsid, 'keywords': keywords});
    if (response.ok) {
      return response.cloneExtra(_cacheTeamList(response.data!['teamList']));
    } else {
      return response.cloneExtra(null);
    }
  }

  ///更新群组信息
  Future<EasyPacket<void>> teamUpdate({required ObjectId tid, required Map<String, dynamic> fields}) async {
    final response = await _websocketClient.websocketRequest('teamUpdate', data: {'bsid': bsid, 'tid': tid, 'fields': fields});
    return response;
  }

  ///查询群组关系
  Future<EasyPacket<TeamShip>> teamShipQuery({required ObjectId tid, ObjectId? fid, required int from}) async {
    final response = await _websocketClient.websocketRequest('teamShipQuery', data: {'bsid': bsid, 'tid': tid, 'fid': fid ?? user.id, 'from': from});
    if (response.ok) {
      _cacheTeam(response.data!['team']);
      return response.cloneExtra(_cacheTeamShip(response.data!['ship']));
    } else {
      return response.cloneExtra(null);
    }
  }

  ///主动加入群组
  Future<EasyPacket<void>> teamShipApply({required ObjectId tid, ObjectId? fid, required int from, String apply = ''}) async {
    final response = await _websocketClient.websocketRequest('teamShipApply', data: {'bsid': bsid, 'tid': tid, 'fid': fid ?? user.id, 'from': from, 'apply': apply});
    return response;
  }

  ///主动退出群组 或 将成员移除群组
  Future<EasyPacket<void>> teamShipNone({required Object tid, required ObjectId uid}) async {
    final response = await _websocketClient.websocketRequest('teamShipNone', data: {'bsid': bsid, 'tid': tid, 'uid': uid});
    return response;
  }

  ///拉人进入群组
  Future<EasyPacket<void>> teamShipPass({required Object tid, required List<ObjectId> uids}) async {
    final response = await _websocketClient.websocketRequest('teamShipPass', data: {'bsid': bsid, 'tid': tid, 'uids': uids});
    return response;
  }

  ///更新群组关系
  Future<EasyPacket<void>> teamShipUpdate({required ObjectId id, required Map<String, dynamic> fields}) async {
    final response = await _websocketClient.websocketRequest('teamShipUpdate', data: {'bsid': bsid, 'id': id, 'fields': fields});
    return response;
  }

  ///发送消息-文本消息
  Future<EasyPacket<void>> messageSendText({required ObjectId sid, required int from, required String body}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeText, 'body': body});
    return response;
  }

  ///发送消息-图片消息，[mediaMillis]为图片播放毫秒时长
  Future<EasyPacket<void>> messageSendImage({required ObjectId sid, required int from, required String shareLinkUrl, int mediaMillis = 0}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeImage, 'shareLinkUrl': shareLinkUrl, 'mediaMillis': mediaMillis});
    return response;
  }

  ///发送消息-语音消息，[mediaMillis]为语音播放毫秒时长
  Future<EasyPacket<void>> messageSendVoice({required ObjectId sid, required int from, required String shareLinkUrl, int mediaMillis = 0}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeVoice, 'shareLinkUrl': shareLinkUrl, 'mediaMillis': mediaMillis});
    return response;
  }

  ///发送消息-视频消息，[mediaMillis]为视频播放毫秒时长
  Future<EasyPacket<void>> messageSendVideo({required ObjectId sid, required int from, required String shareLinkUrl, int mediaMillis = 0}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeVideo, 'shareLinkUrl': shareLinkUrl, 'mediaMillis': mediaMillis});
    return response;
  }

  ///发送消息-实时语音电话
  Future<EasyPacket<void>> messageSendRealtimeVoice({required ObjectId sid, required int from, required List<ObjectId> mediaUids}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeRealtimeVoice, 'mediaUids': mediaUids});
    return response;
  }

  ///发送消息-实时视频电话
  Future<EasyPacket<void>> messageSendRealtimeVideo({required ObjectId sid, required int from, required List<ObjectId> mediaUids}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeRealtimeVideo, 'mediaUids': mediaUids});
    return response;
  }

  ///发送消息-实时屏幕共享
  Future<EasyPacket<void>> messageSendRealtimeShare({required ObjectId sid, required int from, required List<ObjectId> mediaUids}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeRealtimeShare, 'mediaUids': mediaUids});
    return response;
  }

  ///发送消息-实时位置电话
  Future<EasyPacket<void>> messageSendRealtimeLocal({required ObjectId sid, required int from, required List<ObjectId> mediaUids}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeRealtimeLocal, 'mediaUids': mediaUids});
    return response;
  }

  ///发送消息-网页分享
  Future<EasyPacket<void>> messageSendShareHtmlPage({required ObjectId sid, required int from, required String title, required String body, required String shareIconUrl, required String shareLinkUrl}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeShareHtmlPage, 'title': title, 'body': body, 'shareIconUrl': shareIconUrl, 'shareLinkUrl': shareLinkUrl});
    return response;
  }

  ///发送消息-位置分享
  Future<EasyPacket<void>> messageSendShareLocation({required ObjectId sid, required int from, required Location shareLocation}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeShareLocation, 'shareLocation': shareLocation});
    return response;
  }

  ///发送消息-用户名片
  Future<EasyPacket<void>> messageSendShareCardUser({required ObjectId sid, required int from, required String title, required String body, required ObjectId shareCardId, required String shareIconUrl, required List<String> shareHeadUrl}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeShareCardUser, 'title': title, 'body': body, 'shareCardId': shareCardId, 'shareIconUrl': shareIconUrl, 'shareHeadUrl': shareHeadUrl});
    return response;
  }

  ///发送消息-群组名片
  Future<EasyPacket<void>> messageSendShareCardTeam({required ObjectId sid, required int from, required String title, required String body, required ObjectId shareCardId, required String shareIconUrl, required List<String> shareHeadUrl}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeShareCardTeam, 'title': title, 'body': body, 'shareCardId': shareCardId, 'shareIconUrl': shareIconUrl, 'shareHeadUrl': shareHeadUrl});
    return response;
  }

  ///发送消息-普通红包，[rmbfenTotal]为红包总金额，[rmbfenCount]为红包个数
  Future<EasyPacket<void>> messageSendRedpackNormal({required ObjectId sid, required int from, required String body, required int rmbfenTotal, required int rmbfenCount, String? cashPassword}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeRedpackNormal, 'body': body, 'rmbfenTotal': rmbfenTotal, 'rmbfenCount': rmbfenCount, 'cashPassword': cashPassword});
    return response;
  }

  ///发送消息-幸运红包，[rmbfenTotal]为红包总金额，[rmbfenCount]为红包个数
  Future<EasyPacket<void>> messageSendRedpackLuckly({required ObjectId sid, required int from, required String body, required int rmbfenTotal, required int rmbfenCount, String? cashPassword}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {'bsid': bsid, 'sid': sid, 'from': from, 'type': Constant.msgTypeRedpackLuckly, 'body': body, 'rmbfenTotal': rmbfenTotal, 'rmbfenCount': rmbfenCount, 'cashPassword': cashPassword});
    return response;
  }

  ///发送消息-自定义消息，[customType]为自定义类型，[customExtra]为扩展数据
  Future<EasyPacket<void>> messageSendCustomContent({required ObjectId sid, required int from, String? title, String? body, ObjectId? shareCardId, String? shareIconUrl, List<String>? shareHeadUrl, String? shareLinkUrl, required int customType, String? customShort, Map<String, dynamic>? customExtra}) async {
    final response = await _websocketClient.websocketRequest('messageSend', data: {
      'bsid': bsid,
      'sid': sid,
      'from': from,
      'type': Constant.msgTypeCustom,
      'title': title,
      'body': body,
      'shareCardId': shareCardId,
      'shareIconUrl': shareIconUrl,
      'shareHeadUrl': shareHeadUrl,
      'shareLinkUrl': shareLinkUrl,
      'customType': customType,
      'customShort': customShort,
      'customExtra': customExtra,
    });
    return response;
  }

  ///加载会话消息列表，[reload]为true时重置加载状态后再加载，返回值[EasyPacket.extra]字段为true时表示已加载全部数据
  Future<EasyPacket<bool>> messageLoad({required Session session, required bool reload}) async {
    if (reload) session.resetMsgStates(); //重置状态
    final last = session.msgcache.isEmpty ? 3742732800000 : session.msgcache.last.time; //2088-08-08 00:00:00 毫秒值 3742732800000
    final nin = <ObjectId>[]; //排除重复
    for (int i = session.msgcache.length - 1; i >= 0; i--) {
      final item = session.msgcache[i];
      if (item.time != last) break;
      nin.add(item.id);
    }
    session.msgasync = DateTime.now().microsecondsSinceEpoch; //设置最近一次异步加载的识别号（防止并发加载导致数据混乱）
    final response = await _websocketClient.websocketRequest('messageLoad', data: {'bsid': bsid, 'sid': session.sid, 'from': session.msgfrom, 'last': last, 'nin': nin, 'msgasync': session.msgasync});
    if (response.ok) {
      final msgasync = response.data!['msgasync'] as int;
      final msgList = response.data!['msgList'] as List;
      final shipList = response.data!['shipList'] as List?;
      final userList = response.data!['userList'] as List?;
      if (shipList != null && session.msgfrom == Constant.msgFromTeam) {
        _cacheTeamUserList(session.rid, shipList);
      }
      if (userList != null) {
        _cacheUserList(userList);
      }
      if (msgasync == session.msgasync) {
        for (var data in msgList) {
          final message = Message.fromJson(data);
          _fillMessage(message);
          session.msgcache.add(message);
        }
        session.msgloaded = msgList.isEmpty;
        return response.cloneExtra(session.msgloaded); //是否已加载全部数据
      } else {
        _websocketClient.logError(['messageLoad =>', '远程响应号已过期 $msgasync']);
        return response.requestTimeoutError().cloneExtra(null); //说明本次响应不是最近一次异步加载，直接遗弃数据，当成超时错误处理
      }
    } else {
      return response.cloneExtra(null);
    }
  }

  ///加载消息详细信息
  Future<EasyPacket<Message>> messageDetail({required ObjectId id}) async {
    final response = await _websocketClient.websocketRequest('messageDetail', data: {'bsid': bsid, 'id': id});
    if (response.ok) {
      final messageData = response.data!['message'] as Map<String, dynamic>;
      final shipData = response.data!['ship'] as Map<String, dynamic>?;
      final userData = response.data!['user'] as Map<String, dynamic>?;
      final message = Message.fromJson(messageData);
      if (shipData != null && message.from == Constant.msgFromTeam) {
        _cacheTeamUser(message.sid, shipData);
      }
      if (userData != null) {
        _cacheUser(userData);
      }
      _fillMessage(message);
      return response.cloneExtra(message);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///更新消息交互数据，[mediaPlayed]为true表示标记媒体附件已播放，[redpackGrab]为true表示本次操作为抢红包，[realtimeStart]为true表示实时媒体电话开始，[realtimeEnd]为true表示实时媒体电话结束
  Future<EasyPacket<void>> messageUpdate({required ObjectId id, bool mediaPlayed = false, bool redpackGrab = false, bool realtimeStart = false, bool realtimeEnd = false}) async {
    final response = await _websocketClient.websocketRequest('messageUpdate', data: {'bsid': bsid, 'id': id, 'mediaPlayed': mediaPlayed, 'redpackGrab': redpackGrab, 'realtimeStart': realtimeStart, 'realtimeEnd': realtimeEnd});
    return response;
  }

  ///发送实时媒体信令，[toUid]为null时将信令广播给全部参与者，[toUid]不为null时将信令发送给指定参与者
  Future<EasyPacket<void>> messageWebrtc({required ObjectId id, required ObjectId? toUid, required Map<String, dynamic> signals}) async {
    final response = await _websocketClient.websocketRequest('messageWebtrc', data: {'bsid': bsid, 'id': id, 'toUid': toUid, 'signals': signals});
    return response;
  }

  ///创建提现交易订单
  Future<EasyPacket<void>> paymentCashout({required int rmbfen, required String accountTp, required String accountNo, required String accountName, String? cashPassword}) async {
    final response = await _websocketClient.websocketRequest('paymentCashout', data: {'bsid': bsid, 'rmbfen': rmbfen, 'accountTp': accountTp, 'accountNo': accountNo, 'accountName': accountName, 'cashPassword': cashPassword});
    return response;
  }

  ///创建虚拟交易订单
  Future<EasyPacket<void>> paymentVirtual({required int customXNo, required ObjectId customXId, required int customXTp, int? goodsNo, String? cashPassword}) async {
    final response = await _websocketClient.websocketRequest('paymentVirtual', data: {'bsid': bsid, 'customXNo': customXNo, 'customXId': customXId, 'customXTp': customXTp, 'goodsNo': goodsNo, 'cashPassword': cashPassword});
    return response;
  }

  ///统计虚拟交易订单
  Future<EasyPacket<void>> paymentUpdate({required ObjectId id, required String accountTp, required String accountNo, required String accountName}) async {
    final response = await _websocketClient.websocketRequest('paymentUpdate', data: {'bsid': bsid, 'id': id, 'accountTp': accountTp, 'accountNo': accountNo, 'accountName': accountName});
    return response;
  }

  ///加载交易账单列表，[reload]为true时重置加载状态后再加载，返回值[EasyPacket.extra]字段为true时表示已加载全部数据
  Future<EasyPacket<bool>> paymentLoad({required ComPage<Payment> comPage, required bool reload, required int start, required int end}) async {
    if (reload) comPage.resetPgStates(); //重置状态
    final last = comPage.pgcache.isEmpty ? 3742732800000 : comPage.pgcache.last.time; //2088-08-08 00:00:00 毫秒值 3742732800000
    final nin = <ObjectId>[]; //排除重复
    for (int i = comPage.pgcache.length - 1; i >= 0; i--) {
      final item = comPage.pgcache[i];
      if (item.time != last) break;
      nin.add(item.id);
    }
    comPage.pgasync = DateTime.now().microsecondsSinceEpoch; //设置最近一次异步加载的识别号（防止并发加载导致数据混乱）
    final response = await _websocketClient.websocketRequest('paymentLoad', data: {'bsid': bsid, 'last': last, 'nin': nin, 'pgasync': comPage.pgasync, 'start': start, 'end': end});
    if (response.ok) {
      final pgasync = response.data!['pgasync'] as int;
      final totalcnt = response.data!['totalcnt'] as int;
      final paymentList = response.data!['paymentList'] as List;
      if (pgasync == comPage.pgasync) {
        for (var data in paymentList) {
          comPage.pgcache.add(Payment.fromJson(data));
        }
        comPage.total = totalcnt;
        comPage.pgloaded = paymentList.isEmpty || comPage.total == comPage.pgcache.length;
        return response.cloneExtra(comPage.pgloaded); //是否已加载全部数据
      } else {
        _websocketClient.logError(['paymentLoad =>', '远程响应号已过期 $pgasync']);
        return response.requestTimeoutError().cloneExtra(null); //说明本次响应不是最近一次异步加载，直接遗弃数据，当成超时错误处理
      }
    } else {
      return response.cloneExtra(null);
    }
  }

  ///创建自定义数据，[no]为数据集合分类序号，返回数据包含全部字段
  Future<EasyPacket<CustomX>> customXInsert({
    required int no,
    DbJsonWraper? extra,
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
    int? rno1,
    int? rno2,
    int? rno3,
    ObjectId? pathId,
    ObjectId? target,
    ObjectId? earner,
    int? rmbfen,
    int? virval,
  }) async {
    final response = await _websocketClient.websocketRequest('customXInsert', data: {
      'bsid': bsid,
      'no': no,
      'extra': extra?.toJson(),
      'rid1': rid1,
      'rid2': rid2,
      'rid3': rid3,
      'int1': int1,
      'int2': int2,
      'int3': int3,
      'str1': str1,
      'str2': str2,
      'str3': str3,
      'body1': body1?.toJson(),
      'body2': body2?.toJson(),
      'body3': body3?.toJson(),
      'state1': state1,
      'state2': state2,
      'state3': state3,
      'rno1': rno1,
      'rno2': rno2,
      'rno3': rno3,
      'pathId': pathId,
      'target': target,
      'earner': earner,
      'rmbfen': rmbfen,
      'virval': virval,
    });
    if (response.ok) {
      return response.cloneExtra(
        CustomX.fromJson(response.data!['customx'])
          ..cusmark = response.data!['cusmark'] == null ? null : Cusmark.fromJson(response.data!['cusmark'])
          ..cusstar = response.data!['cusstar'] == null ? null : Cusstar.fromJson(response.data!['cusstar'])
          ..cuspaid = response.data!['cuspaid'] == null ? null : Payment.fromJson(response.data!['cuspaid']),
      );
    } else {
      return response.cloneExtra(null);
    }
  }

  ///删除自定义数据，[no]为数据集合分类序号，该操作是永久删除数据
  Future<EasyPacket<void>> customXDelete({required int no, required ObjectId id, int? rno1, int? rno2, int? rno3}) async {
    final response = await _websocketClient.websocketRequest('customXDelete', data: {'bsid': bsid, 'no': no, 'id': id, 'rno1': rno1, 'rno2': rno2, 'rno3': rno3});
    return response;
  }

  ///更新自定义数据，[no]为数据集合分类序号，该操作是批量更新路径
  Future<EasyPacket<void>> customXPathId({required int no, required ObjectId pathId, required ObjectId newPathId}) async {
    final response = await _websocketClient.websocketRequest('customXPathId', data: {'bsid': bsid, 'no': no, 'pathId': pathId, 'newPathId': newPathId});
    return response;
  }

  ///更新自定义数据，[no]为数据集合分类序号，[update]为true时，会将[CustomX.update]字段更新为当前时间
  ///
  ///[body1]为false时返回数据不包含[CustomX.body1]字段，[body2]为false时返回数据不包含[CustomX.body2]字段，[body3]为false时返回数据不包含[CustomX.body3]字段
  Future<EasyPacket<CustomX>> customXUpdate({required int no, required ObjectId id, required Map<String, dynamic> fields, bool update = false, bool body1 = false, bool body2 = false, bool body3 = false}) async {
    final response = await _websocketClient.websocketRequest('customXUpdate', data: {'bsid': bsid, 'no': no, 'id': id, 'fields': fields, 'update': update, 'body1': body1, 'body2': body2, 'body3': body3});
    if (response.ok) {
      return response.cloneExtra(
        CustomX.fromJson(response.data!['customx'])
          ..cusmark = response.data!['cusmark'] == null ? null : Cusmark.fromJson(response.data!['cusmark'])
          ..cusstar = response.data!['cusstar'] == null ? null : Cusstar.fromJson(response.data!['cusstar'])
          ..cuspaid = response.data!['cuspaid'] == null ? null : Payment.fromJson(response.data!['cuspaid']),
      );
    } else {
      return response.cloneExtra(null);
    }
  }

  ///读取自定义数据，[no]为数据集合分类序号，[hot1]不为0时[CustomX.hot1]自增减1，[hot2]不为0时[CustomX.hot2]自增减1，[hotx]不为0时[CustomX.hotx]自增减[hotx]
  ///
  ///[body1]为false时返回数据不包含[CustomX.body1]字段，[body2]为false时返回数据不包含[CustomX.body2]字段，[body3]为false时返回数据不包含[CustomX.body3]字段
  Future<EasyPacket<CustomX>> customXDetail({required int no, required ObjectId id, int hot1 = 0, int hot2 = 0, hotx = 0, bool body1 = false, bool body2 = false, bool body3 = false}) async {
    final response = await _websocketClient.websocketRequest('customXDetail', data: {'bsid': bsid, 'no': no, 'id': id, 'hot1': hot1, 'hot2': hot2, 'hotx': hotx, 'body1': body1, 'body2': body2, 'body3': body3});
    if (response.ok) {
      return response.cloneExtra(
        CustomX.fromJson(response.data!['customx'])
          ..cusmark = response.data!['cusmark'] == null ? null : Cusmark.fromJson(response.data!['cusmark'])
          ..cusstar = response.data!['cusstar'] == null ? null : Cusstar.fromJson(response.data!['cusstar'])
          ..cuspaid = response.data!['cuspaid'] == null ? null : Payment.fromJson(response.data!['cuspaid']),
      );
    } else {
      return response.cloneExtra(null);
    }
  }

  ///标记自定义数据，[no]为数据集合分类序号，[score]为null时存在对应标记则删除否则添加，[score]不为null时会将[Cusmark.score]字段设置为[score]
  ///
  ///[body1]为false时返回数据不包含[CustomX.body1]字段，[body2]为false时返回数据不包含[CustomX.body2]字段，[body3]为false时返回数据不包含[CustomX.body3]字段
  Future<EasyPacket<CustomX>> customXMark({required int no, required ObjectId id, required int tp, double? score, bool body1 = false, bool body2 = false, bool body3 = false}) async {
    final response = await _websocketClient.websocketRequest('customXMark', data: {'bsid': bsid, 'no': no, 'id': id, 'tp': tp, 'score': score, 'body1': body1, 'body2': body2, 'body3': body3});
    if (response.ok) {
      return response.cloneExtra(
        CustomX.fromJson(response.data!['customx'])
          ..cusmark = response.data!['cusmark'] == null ? null : Cusmark.fromJson(response.data!['cusmark'])
          ..cusstar = response.data!['cusstar'] == null ? null : Cusstar.fromJson(response.data!['cusstar'])
          ..cuspaid = response.data!['cuspaid'] == null ? null : Payment.fromJson(response.data!['cuspaid']),
      );
    } else {
      return response.cloneExtra(null);
    }
  }

  ///收藏自定义数据，[no]为数据集合分类序号，数据存在则删除否则添加
  ///
  ///[body1]为false时返回数据不包含[CustomX.body1]字段，[body2]为false时返回数据不包含[CustomX.body2]字段，[body3]为false时返回数据不包含[CustomX.body3]字段
  Future<EasyPacket<CustomX>> customXStar({required int no, required ObjectId id, required int tp, bool body1 = false, bool body2 = false, bool body3 = false}) async {
    final response = await _websocketClient.websocketRequest('customXStar', data: {'bsid': bsid, 'no': no, 'id': id, 'tp': tp, 'body1': body1, 'body2': body2, 'body3': body3});
    if (response.ok) {
      return response.cloneExtra(
        CustomX.fromJson(response.data!['customx'])
          ..cusmark = response.data!['cusmark'] == null ? null : Cusmark.fromJson(response.data!['cusmark'])
          ..cusstar = response.data!['cusstar'] == null ? null : Cusstar.fromJson(response.data!['cusstar'])
          ..cuspaid = response.data!['cuspaid'] == null ? null : Payment.fromJson(response.data!['cuspaid']),
      );
    } else {
      return response.cloneExtra(null);
    }
  }

  ///加载自定义数据列表，[reload]为true时重置加载状态后再加载，返回值[EasyPacket.extra]字段为true时表示已加载全部数据。
  ///
  ///[body1]为false时返回数据不包含[CustomX.body1]字段，[body2]为false时返回数据不包含[CustomX.body2]字段，[body3]为false时返回数据不包含[CustomX.body3]字段
  ///
  ///[referNo]与[referKey]均不为null时，先对[referNo]对应的集合执行查询后，再将查询结果关联到[comPage]对应的集合
  ///
  ///[clearLoadedPage]为true时如果对应查询参数的全部数据已经缓存在内存中，则将其从内存移除。适用于需要拉取全部数据的场景，优先级一
  ///
  ///[checkLoadedPage]为true时如果对应查询参数的全部数据已经缓存在内存中，则直接从内存读取。适用于需要拉取全部数据的场景，优先级二
  ///
  ///[cacheLoadedPage]为true时如果对应查询参数的全部数据从服务器加载完毕，则将其缓存到内存。适用于需要拉取全部数据的场景，优先级三
  Future<EasyPacket<bool>> customXLoad({
    required ComPage<CustomX> comPage,
    required bool reload,
    int? referNo,
    String? referKey,
    List<int>? incxIds,
    Map<String, dynamic> eqFilter = const {},
    Map<String, dynamic> neFilter = const {},
    Map<String, dynamic> matchFilter = const {},
    Map<String, dynamic> sorter = const {},
    bool body1 = false,
    bool body2 = false,
    bool body3 = false,
    bool clearLoadedPage = false,
    bool checkLoadedPage = false,
    bool cacheLoadedPage = false,
  }) async {
    //处理内存缓存
    final cacheKey = EasySecurity.getMd5(jsonEncode({
      'route': 'customXLoad',
      'bsid': bsid,
      'no': comPage.no,
      'referNo': referNo,
      'referKey': referKey,
      'incxIds': incxIds,
      'eqFilter': eqFilter,
      'neFilter': neFilter,
      'matchFilter': matchFilter,
      'sorter': sorter,
      'body1': body1,
      'body2': body2,
      'body3': body3,
    }));
    if (clearLoadedPage) {
      _customXPageMap.remove(cacheKey);
    } else if (checkLoadedPage) {
      final memoryPage = _customXPageMap[cacheKey];
      if (memoryPage != null && ComPage.copyCustomXPage(memoryPage, comPage)) {
        return EasyPacket.request(route: '', id: -1, desc: '', data: const {}).responseOk(desc: 'Memory Page Loaded: $cacheKey').cloneExtra(true);
      }
    }
    //从服务器加载
    if (reload) comPage.resetPgStates(); //重置状态
    comPage.pgasync = DateTime.now().microsecondsSinceEpoch; //设置最近一次异步加载的识别号（防止并发加载导致数据混乱）
    final response = await _websocketClient.websocketRequest('customXLoad', data: {
      'bsid': bsid,
      'no': comPage.no,
      'pgskip': comPage.pgskip,
      'pgasync': comPage.pgasync,
      'referNo': referNo,
      'referKey': referKey,
      'incxIds': incxIds,
      'eqFilter': eqFilter,
      'neFilter': neFilter,
      'matchFilter': matchFilter,
      'sorter': sorter,
      'body1': body1,
      'body2': body2,
      'body3': body3,
    });
    if (response.ok) {
      final pgskip = response.data!['pgskip'] as int;
      final pgasync = response.data!['pgasync'] as int;
      final totalcnt = response.data!['totalcnt'] as int;
      final customxList = response.data!['customxList'] as List;
      final cusmarkList = response.data!['cusmarkList'] as List;
      final cusstarList = response.data!['cusstarList'] as List;
      final cuspaidList = response.data!['cuspaidList'] as List;
      if (pgasync == comPage.pgasync) {
        final cusmarkMap = <ObjectId, Cusmark>{};
        for (var data in cusmarkList) {
          final cusmark = Cusmark.fromJson(data);
          cusmarkMap[cusmark.rid] = cusmark;
        }
        final cusstarMap = <ObjectId, Cusstar>{};
        for (var data in cusstarList) {
          final cusstar = Cusstar.fromJson(data);
          cusstarMap[cusstar.rid] = cusstar;
        }
        final cuspaidMap = <ObjectId, Payment>{};
        for (var data in cuspaidList) {
          final cuspaid = Payment.fromJson(data);
          cuspaidMap[cuspaid.virtualCustomXId] = cuspaid;
        }
        for (var data in customxList) {
          final customx = CustomX.fromJson(data);
          customx.cusmark = cusmarkMap[customx.id];
          customx.cusstar = cusstarMap[customx.id];
          customx.cuspaid = cuspaidMap[customx.id];
          comPage.append(customx, (a, b) => a.id == b.id);
        }
        comPage.total = totalcnt;
        comPage.pgskip = pgskip;
        comPage.pgloaded = customxList.isEmpty || comPage.total == comPage.pgcache.length;
        //缓存到内存中
        if (cacheLoadedPage && comPage.pgloaded) {
          final memoryPage = ComPage<CustomX>(no: comPage.no);
          ComPage.copyCustomXPage(comPage, memoryPage);
          _customXPageMap[cacheKey] = memoryPage;
        }
        return response.cloneExtra(comPage.pgloaded); //是否已加载全部数据
      } else {
        _websocketClient.logError(['customXLoad =>', '远程响应号已过期 $pgasync']);
        return response.requestTimeoutError().cloneExtra(null); //说明本次响应不是最近一次异步加载，直接遗弃数据，当成超时错误处理
      }
    } else {
      return response.cloneExtra(null);
    }
  }

  ///加载自定义标记列表，[reload]为true时重置加载状态后再加载，返回值[EasyPacket.extra]字段为true时表示已加载全部数据。
  ///
  ///[body1]为false时返回数据不包含[CustomX.body1]字段，[body2]为false时返回数据不包含[CustomX.body2]字段，[body3]为false时返回数据不包含[CustomX.body3]字段
  Future<EasyPacket<bool>> cusmarkLoad({required ComPage<CustomX> comPage, required bool reload, int? tp, bool body1 = false, bool body2 = false, bool body3 = false}) async {
    if (reload) comPage.resetPgStates(); //重置状态
    comPage.pgasync = DateTime.now().microsecondsSinceEpoch; //设置最近一次异步加载的识别号（防止并发加载导致数据混乱）
    final response = await _websocketClient.websocketRequest('cusmarkLoad', data: {'bsid': bsid, 'no': comPage.no, 'tp': tp, 'pgskip': comPage.pgskip, 'pgasync': comPage.pgasync, 'body1': body1, 'body2': body2, 'body3': body3});
    if (response.ok) {
      final pgskip = response.data!['pgskip'] as int;
      final pgasync = response.data!['pgasync'] as int;
      final totalcnt = response.data!['totalcnt'] as int;
      final customxList = response.data!['customxList'] as List;
      final cusmarkList = response.data!['cusmarkList'] as List;
      final cusstarList = response.data!['cusstarList'] as List;
      final cuspaidList = response.data!['cuspaidList'] as List;
      if (pgasync == comPage.pgasync) {
        final cusmarkMap = <ObjectId, Cusmark>{};
        for (var data in cusmarkList) {
          final cusmark = Cusmark.fromJson(data);
          cusmarkMap[cusmark.rid] = cusmark;
        }
        final cusstarMap = <ObjectId, Cusstar>{};
        for (var data in cusstarList) {
          final cusstar = Cusstar.fromJson(data);
          cusstarMap[cusstar.rid] = cusstar;
        }
        final cuspaidMap = <ObjectId, Payment>{};
        for (var data in cuspaidList) {
          final cuspaid = Payment.fromJson(data);
          cuspaidMap[cuspaid.virtualCustomXId] = cuspaid;
        }
        for (var data in customxList) {
          final customx = CustomX.fromJson(data);
          customx.cusmark = cusmarkMap[customx.id];
          customx.cusstar = cusstarMap[customx.id];
          customx.cuspaid = cuspaidMap[customx.id];
          comPage.append(customx, (a, b) => a.id == b.id);
        }
        comPage.total = totalcnt;
        comPage.pgskip = pgskip;
        comPage.pgloaded = customxList.isEmpty || comPage.total == comPage.pgcache.length;
        return response.cloneExtra(comPage.pgloaded); //是否已加载全部数据
      } else {
        _websocketClient.logError(['cusmarkLoad =>', '远程响应号已过期 $pgasync']);
        return response.requestTimeoutError().cloneExtra(null); //说明本次响应不是最近一次异步加载，直接遗弃数据，当成超时错误处理
      }
    } else {
      return response.cloneExtra(null);
    }
  }

  ///加载自定义收藏列表，[reload]为true时重置加载状态后再加载，返回值[EasyPacket.extra]字段为true时表示已加载全部数据。
  ///
  ///[body1]为false时返回数据不包含[CustomX.body1]字段，[body2]为false时返回数据不包含[CustomX.body2]字段，[body3]为false时返回数据不包含[CustomX.body3]字段
  Future<EasyPacket<bool>> cusstarLoad({required ComPage<CustomX> comPage, required bool reload, int? tp, bool body1 = false, bool body2 = false, bool body3 = false}) async {
    if (reload) comPage.resetPgStates(); //重置状态
    comPage.pgasync = DateTime.now().microsecondsSinceEpoch; //设置最近一次异步加载的识别号（防止并发加载导致数据混乱）
    final response = await _websocketClient.websocketRequest('cusstarLoad', data: {'bsid': bsid, 'no': comPage.no, 'tp': tp, 'pgskip': comPage.pgskip, 'pgasync': comPage.pgasync, 'body1': body1, 'body2': body2, 'body3': body3});
    if (response.ok) {
      final pgskip = response.data!['pgskip'] as int;
      final pgasync = response.data!['pgasync'] as int;
      final totalcnt = response.data!['totalcnt'] as int;
      final customxList = response.data!['customxList'] as List;
      final cusmarkList = response.data!['cusmarkList'] as List;
      final cusstarList = response.data!['cusstarList'] as List;
      final cuspaidList = response.data!['cuspaidList'] as List;
      if (pgasync == comPage.pgasync) {
        final cusmarkMap = <ObjectId, Cusmark>{};
        for (var data in cusmarkList) {
          final cusmark = Cusmark.fromJson(data);
          cusmarkMap[cusmark.rid] = cusmark;
        }
        final cusstarMap = <ObjectId, Cusstar>{};
        for (var data in cusstarList) {
          final cusstar = Cusstar.fromJson(data);
          cusstarMap[cusstar.rid] = cusstar;
        }
        final cuspaidMap = <ObjectId, Payment>{};
        for (var data in cuspaidList) {
          final cuspaid = Payment.fromJson(data);
          cuspaidMap[cuspaid.virtualCustomXId] = cuspaid;
        }
        for (var data in customxList) {
          final customx = CustomX.fromJson(data);
          customx.cusmark = cusmarkMap[customx.id];
          customx.cusstar = cusstarMap[customx.id];
          customx.cuspaid = cuspaidMap[customx.id];
          comPage.append(customx, (a, b) => a.id == b.id);
        }
        comPage.total = totalcnt;
        comPage.pgskip = pgskip;
        comPage.pgloaded = customxList.isEmpty || comPage.total == comPage.pgcache.length;
        return response.cloneExtra(comPage.pgloaded); //是否已加载全部数据
      } else {
        _websocketClient.logError(['cusstarLoad =>', '远程响应号已过期 $pgasync']);
        return response.requestTimeoutError().cloneExtra(null); //说明本次响应不是最近一次异步加载，直接遗弃数据，当成超时错误处理
      }
    } else {
      return response.cloneExtra(null);
    }
  }

  ///加载自定义已购列表，[reload]为true时重置加载状态后再加载，返回值[EasyPacket.extra]字段为true时表示已加载全部数据。
  ///
  ///[body1]为false时返回数据不包含[CustomX.body1]字段，[body2]为false时返回数据不包含[CustomX.body2]字段，[body3]为false时返回数据不包含[CustomX.body3]字段
  Future<EasyPacket<bool>> cuspaidLoad({required ComPage<CustomX> comPage, required bool reload, int? tp, bool body1 = false, bool body2 = false, bool body3 = false}) async {
    if (reload) comPage.resetPgStates(); //重置状态
    comPage.pgasync = DateTime.now().microsecondsSinceEpoch; //设置最近一次异步加载的识别号（防止并发加载导致数据混乱）
    final response = await _websocketClient.websocketRequest('cuspaidLoad', data: {'bsid': bsid, 'no': comPage.no, 'tp': tp, 'pgskip': comPage.pgskip, 'pgasync': comPage.pgasync, 'body1': body1, 'body2': body2, 'body3': body3});
    if (response.ok) {
      final pgskip = response.data!['pgskip'] as int;
      final pgasync = response.data!['pgasync'] as int;
      final totalcnt = response.data!['totalcnt'] as int;
      final customxList = response.data!['customxList'] as List;
      final cusmarkList = response.data!['cusmarkList'] as List;
      final cusstarList = response.data!['cusstarList'] as List;
      final cuspaidList = response.data!['cuspaidList'] as List;
      if (pgasync == comPage.pgasync) {
        final cusmarkMap = <ObjectId, Cusmark>{};
        for (var data in cusmarkList) {
          final cusmark = Cusmark.fromJson(data);
          cusmarkMap[cusmark.rid] = cusmark;
        }
        final cusstarMap = <ObjectId, Cusstar>{};
        for (var data in cusstarList) {
          final cusstar = Cusstar.fromJson(data);
          cusstarMap[cusstar.rid] = cusstar;
        }
        final cuspaidMap = <ObjectId, Payment>{};
        for (var data in cuspaidList) {
          final cuspaid = Payment.fromJson(data);
          cuspaidMap[cuspaid.virtualCustomXId] = cuspaid;
        }
        for (var data in customxList) {
          final customx = CustomX.fromJson(data);
          customx.cusmark = cusmarkMap[customx.id];
          customx.cusstar = cusstarMap[customx.id];
          customx.cuspaid = cuspaidMap[customx.id];
          comPage.append(customx, (a, b) => a.id == b.id);
        }
        comPage.total = totalcnt;
        comPage.pgskip = pgskip;
        comPage.pgloaded = customxList.isEmpty || comPage.total == comPage.pgcache.length;
        return response.cloneExtra(comPage.pgloaded); //是否已加载全部数据
      } else {
        _websocketClient.logError(['cuspaidLoad =>', '远程响应号已过期 $pgasync']);
        return response.requestTimeoutError().cloneExtra(null); //说明本次响应不是最近一次异步加载，直接遗弃数据，当成超时错误处理
      }
    } else {
      return response.cloneExtra(null);
    }
  }

  ///记录登录日志
  Future<EasyPacket<void>> doLogLogin({int clientVersion = 0, String deviceType = 'terminal', String deviceVersion = '0.0', Map<String, dynamic> deviceDetail = const {}, int onlineMillis = 0}) async {
    final response = await _websocketClient.websocketRequest('doLogLogin', data: {'bsid': bsid, 'clientVersion': clientVersion, 'deviceType': deviceType, 'deviceVersion': deviceVersion, 'deviceDetail': deviceDetail, 'onlineMillis': onlineMillis});
    return response;
  }

  ///记录异常日志
  Future<EasyPacket<void>> doLogError({int clientVersion = 0, String deviceType = 'terminal', String deviceVersion = '0.0', Map<String, dynamic> deviceDetail = const {}, Map<String, dynamic> errorDetail = const {}, int errorTime = 0}) async {
    final response = await _websocketClient.websocketRequest('doLogError', data: {'bsid': bsid, 'clientVersion': clientVersion, 'deviceType': deviceType, 'deviceVersion': deviceVersion, 'deviceDetail': deviceDetail, 'errorDetail': errorDetail, 'errorTime': errorTime});
    return response;
  }

  ///记录反馈日志
  Future<EasyPacket<void>> doLogReport({required int type, String image = '', ObjectId? relation, String? host, String? href, int? customXNo, ObjectId? customXId, String desc = ''}) async {
    final response = await _websocketClient.websocketRequest('doLogReport', data: {'bsid': bsid, 'type': type, 'image': image, 'relation': relation, 'host': host, 'href': href, 'customXNo': customXNo, 'customXId': customXId, 'desc': desc});
    return response;
  }

  /* **************** websocket请求-管理 **************** */

  ///管理员获取用户列表
  Future<EasyPacket<ComPage<User>>> adminUserList({required int page, int deny = 0, String keywords = ''}) async {
    final response = await _websocketClient.websocketRequest('adminUserList', data: {'bsid': bsid, 'page': page, 'deny': deny, 'keywords': keywords});
    if (response.ok) {
      final userList = response.data!['userList'] as List;
      final userCount = response.data!['userCount'] as int;
      final result = ComPage<User>(page: page, total: userCount);
      for (var element in userList) {
        result.pgcache.add(User.fromJson(element));
      }
      return response.cloneExtra(result);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员设置用户状态
  Future<EasyPacket<void>> adminUserDeny({required ObjectId uid, required int deny}) async {
    final response = await _websocketClient.websocketRequest('adminUserDeny', data: {'bsid': bsid, 'uid': uid, 'deny': deny});
    return response;
  }

  ///管理员获取群组列表
  Future<EasyPacket<ComPage<Team>>> adminTeamList({required int page, int deny = 0, String keywords = ''}) async {
    final response = await _websocketClient.websocketRequest('adminTeamList', data: {'bsid': bsid, 'page': page, 'deny': deny, 'keywords': keywords});
    if (response.ok) {
      final teamList = response.data!['teamList'] as List;
      final teamCount = response.data!['teamCount'] as int;
      final result = ComPage<Team>(page: page, total: teamCount);
      for (var element in teamList) {
        result.pgcache.add(Team.fromJson(element));
      }
      return response.cloneExtra(result);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员设置群组状态
  Future<EasyPacket<void>> adminTeamDeny({required ObjectId tid, required int deny}) async {
    final response = await _websocketClient.websocketRequest('adminTeamDeny', data: {'bsid': bsid, 'tid': tid, 'deny': deny});
    return response;
  }

  ///管理员设置群组图标
  Future<EasyPacket<void>> adminTeamIcon({required ObjectId tid, required String icon}) async {
    final response = await _websocketClient.websocketRequest('adminTeamIcon', data: {'bsid': bsid, 'tid': tid, 'icon': icon});
    return response;
  }

  ///管理员获取数据列表
  Future<EasyPacket<ComPage<CustomX>>> adminCustomXList({required int no, required int page, int deny = 0, String keywords = '', Map<String, dynamic> eqFilter = const {}}) async {
    final response = await _websocketClient.websocketRequest('adminCustomXList', data: {'bsid': bsid, 'no': no, 'page': page, 'deny': deny, 'keywords': keywords, 'eqFilter': eqFilter});
    if (response.ok) {
      final customxList = response.data!['customxList'] as List;
      final customxCount = response.data!['customxCount'] as int;
      final result = ComPage<CustomX>(page: page, total: customxCount);
      for (var element in customxList) {
        result.pgcache.add(CustomX.fromJson(element));
      }
      return response.cloneExtra(result);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员设置数据状态
  Future<EasyPacket<void>> adminCustomXDeny({required int no, required ObjectId xid, required int deny, Map<String, dynamic> fields = const {}, bool update = false}) async {
    final response = await _websocketClient.websocketRequest('adminCustomXDeny', data: {'bsid': bsid, 'no': no, 'xid': xid, 'deny': deny, 'fields': fields, 'update': update});
    return response;
  }

  ///管理员获取登录列表
  Future<EasyPacket<ComPage<LogLogin>>> adminLoginList({required int page, required int start, required int end}) async {
    final response = await _websocketClient.websocketRequest('adminLoginList', data: {'bsid': bsid, 'page': page, 'start': start, 'end': end});
    if (response.ok) {
      final loginList = response.data!['loginList'] as List;
      final loginCount = response.data!['loginCount'] as int;
      final result = ComPage<LogLogin>(page: page, total: loginCount);
      for (var element in loginList) {
        result.pgcache.add(LogLogin.fromJson(element));
      }
      return response.cloneExtra(result);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员获取异常列表
  Future<EasyPacket<ComPage<LogError>>> adminErrorList({required int page, required bool finished}) async {
    final response = await _websocketClient.websocketRequest('adminErrorList', data: {'bsid': bsid, 'page': page, 'finished': finished});
    if (response.ok) {
      final errorList = response.data!['errorList'] as List;
      final errorCount = response.data!['errorCount'] as int;
      final result = ComPage<LogError>(page: page, total: errorCount);
      for (var element in errorList) {
        result.pgcache.add(LogError.fromJson(element));
      }
      return response.cloneExtra(result);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员设置异常状态
  Future<EasyPacket<void>> adminErrorState({required ObjectId id, required bool finished}) async {
    final response = await _websocketClient.websocketRequest('adminErrorState', data: {'bsid': bsid, 'id': id, 'finished': finished});
    return response;
  }

  ///管理员获取反馈列表
  Future<EasyPacket<ComPage<LogReport>>> adminReportList({required int page, required int type, required int state, int? customXNo}) async {
    final response = await _websocketClient.websocketRequest('adminReportList', data: {'bsid': bsid, 'page': page, 'type': type, 'state': state, 'customXNo': customXNo});
    if (response.ok) {
      final reportList = response.data!['reportList'] as List;
      final reportCount = response.data!['reportCount'] as int;
      final result = ComPage<LogReport>(page: page, total: reportCount);
      for (var element in reportList) {
        result.pgcache.add(LogReport.fromJson(element));
      }
      return response.cloneExtra(result);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员设置反馈状态
  Future<EasyPacket<void>> adminReportState({required ObjectId id, required int state}) async {
    final response = await _websocketClient.websocketRequest('adminReportState', data: {'bsid': bsid, 'id': id, 'state': state});
    return response;
  }

  ///管理员获取订单列表
  Future<EasyPacket<ComPage<Payment>>> adminPaymentList({required int page, required List<int> types, required List<int> states, int? substate}) async {
    final response = await _websocketClient.websocketRequest('adminPaymentList', data: {'bsid': bsid, 'page': page, 'types': types, 'states': states, 'substate': substate});
    if (response.ok) {
      final paymentList = response.data!['paymentList'] as List;
      final paymentCount = response.data!['paymentCount'] as int;
      final result = ComPage<Payment>(page: page, total: paymentCount);
      for (var element in paymentList) {
        result.pgcache.add(Payment.fromJson(element));
      }
      return response.cloneExtra(result);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员设置订单状态（仅支持已完成事务的提现订单设置substate状态，后续实现自动提现转账功能后后会禁用此功能）
  Future<EasyPacket<void>> adminPaymentState({required ObjectId id, required int substate}) async {
    final response = await _websocketClient.websocketRequest('adminPaymentState', data: {'bsid': bsid, 'id': id, 'substate': substate});
    return response;
  }

  ///管理员加载消息详情
  Future<EasyPacket<Message>> adminMessageDetail({required ObjectId id}) async {
    final response = await _websocketClient.websocketRequest('adminMessageDetail', data: {'bsid': bsid, 'id': id});
    if (response.ok) {
      final message = Message.fromJson(response.data!['message']);
      _fillMessage(message);
      return response.cloneExtra(message);
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员创建源码文件
  Future<EasyPacket<void>> adminCodeFileInsert({required String name, required int version, required String content, required int order}) async {
    final response = await _websocketClient.websocketRequest('adminCodeFileInsert', data: {'bsid': bsid, 'name': name, 'version': version, 'content': content, 'order': order});
    return response;
  }

  ///管理员删除源码文件，[id]不为null时删除单个文件，否则删除对应[version]的全部文件
  Future<EasyPacket<void>> adminCodeFileDelete({ObjectId? id, int? version}) async {
    final response = await _websocketClient.websocketRequest('adminCodeFileDelete', data: {'bsid': bsid, 'id': id, 'version': version});
    return response;
  }

  ///管理员加载商户详情，[cache]为true时更新本地[business]缓存
  Future<EasyPacket<Business>> adminBusinessDetail({required bool cache}) async {
    final response = await _websocketClient.websocketRequest('adminBusinessDetail', data: {'bsid': bsid});
    if (response.ok) {
      if (cache) business.updateByJson(response.data!['configure']); //刷新缓存
      return response.cloneExtra(Business.fromJson(response.data!['configure']));
    } else {
      return response.cloneExtra(null);
    }
  }

  ///管理员更新商户信息
  Future<EasyPacket<void>> adminBusinessUpdate({required Map<String, dynamic> fields, String? code, String? newcode}) async {
    final response = await _websocketClient.websocketRequest('adminBusinessUpdate', data: {'bsid': bsid, 'fields': fields, 'code': code, 'newcode': newcode});
    return response;
  }

  /* **************** 工具方法 **************** */

  ///创建会话
  Session createSession({UserShip? usership, TeamShip? teamship}) {
    if (usership != null) return Session.fromUserShip(usership, getUser(usership.rid));
    if (teamship != null) return Session.fromTeamShip(teamship, getTeam(teamship.rid));
    throw 'usership == null && teamship == null';
  }

  ///获取昵称
  String getNickForMsgShip({required ObjectId sid, required int from, required ObjectId uid}) {
    final target = uid == user.id ? user : getUser(uid);
    if (from == Constant.msgFromUser) {
      final ship = getUserShip(uid);
      return ship == null ? ComTools.formatUserNick(target) : ComTools.formatUserShipNick(ship, target);
    } else if (from == Constant.msgFromTeam) {
      final ship = getTeamUser(sid, uid);
      return ship == null ? ComTools.formatUserNick(target) : ComTools.formatTeamUserNick(ship, target);
    }
    return ComTools.formatUserNick(target);
  }

  ///读取用户
  User getUser(ObjectId uid) {
    var item = _userMap[uid];
    if (item == null) {
      //创建一个临时用户实例
      item = User(bsid: DbQueryField.hexstr2ObjectId(bsid), id: uid);
      _userMap[uid] = item;
      //获取未缓存的用户信息
      userFetch(uids: [uid]);
    }
    return item;
  }

  ///读取群组
  Team getTeam(ObjectId tid) {
    var item = _teamMap[tid];
    if (item == null) {
      //创建一个临时群组实例
      item = Team(bsid: DbQueryField.hexstr2ObjectId(bsid), id: tid);
      _teamMap[tid] = item;
      //获取未缓存的群组信息
      teamFetch(tids: [tid]);
    }
    return item;
  }

  ///读取好友申请
  UserShip? getWaitShip(ObjectId uid) => _waitshipMap[uid];

  ///读取好友关系
  UserShip? getUserShip(ObjectId uid) => _usershipMap[uid];

  ///读取群组关系
  TeamShip? getTeamShip(ObjectId tid) => _teamshipMap[tid];

  ///读取群组成员
  TeamShip? getTeamUser(ObjectId tid, ObjectId uid) => _teamuserMapMap[tid]?[uid];

  ///读取激活会话状态
  NetClientAzState get sessionState {
    if (_dirtySessionState) {
      //构建列表
      final okList = <Object>[];
      int unread = 0;
      _usershipMap.forEach((key, value) {
        if (value.dialog) {
          okList.add(value);
          unread += value.unread;
          //计算展示信息
          final target = getUser(value.rid);
          value.displayNick = ComTools.formatUserShipNick(value, target);
          value.displayIcon = target.icon;
          value.displayHead = target.head;
        }
      });
      _teamshipMap.forEach((key, value) {
        if (value.dialog) {
          okList.add(value);
          unread += value.unread;
          //计算展示信息
          final target = getTeam(value.rid);
          value.displayNick = ComTools.formatTeamNick(target);
          value.displayIcon = target.icon;
          value.displayHead = target.head;
        }
      });
      //按最近消息时间降序排列（注意使用的是动态类型）
      okList.sort((dynamic a, dynamic b) {
        if (a.top && !b.top) {
          return -1;
        } else if (!a.top && b.top) {
          return 1;
        } else {
          return a.update > b.update ? -1 : 1;
        }
      });
      //更新状态
      _sessionState.update(okList: okList, unread: unread);
      _dirtySessionState = false;
    }
    return _sessionState;
  }

  ///读取好友申请状态
  NetClientAzState get waitshipState {
    if (_dirtyWaitshipState) {
      //构建列表
      final okList = <Object>[];
      _waitshipMap.forEach((key, value) {
        okList.add(value);
        //计算展示信息
        final target = getUser(value.uid);
        value.displayNick = ComTools.formatUserNick(target);
        value.displayIcon = target.icon;
        value.displayHead = target.head;
      });
      //按发起申请时间降序排列
      okList.sort((a, b) => (a as UserShip).time > (b as UserShip).time ? -1 : 1);
      //最后插入数量
      okList.add(_waitshipMap.length);
      //更新状态
      _waitshipState.update(okList: okList, unread: _waitshipMap.length);
      _dirtyWaitshipState = false;
    }
    return _waitshipState;
  }

  ///读取好友关系状态
  NetClientAzState get usershipState {
    if (_dirtyUsershipState) {
      //构建列表
      final azList = <Object>[...NetClientAzState.letters];
      _usershipMap.forEach((key, value) {
        azList.add(value);
        //计算展示信息
        final target = getUser(value.rid);
        value.displayNick = ComTools.formatUserShipNick(value, target);
        value.displayIcon = target.icon;
        value.displayHead = target.head;
        value.displayPinyin = PinyinHelper.getPinyinE(value.displayNick, separator: '', defPinyin: '#', format: PinyinFormat.WITHOUT_TONE).toUpperCase();
        if (value.displayPinyin.isEmpty || !NetClientAzState.letters.contains(value.displayPinyin[0])) value.displayPinyin = '#${value.displayPinyin}';
      });
      //字母列表排序
      azList.sort((a, b) {
        final pyA = a is UserShip ? a.displayPinyin : (a as String);
        final pyB = b is UserShip ? b.displayPinyin : (b as String);
        if (pyA.startsWith('#') && !pyB.startsWith('#')) {
          return 1;
        } else if (!pyA.startsWith('#') && pyB.startsWith('#')) {
          return -1;
        } else {
          return Comparable.compare(pyA, pyB);
        }
      });
      //生成字母索引
      final azMap = <String, int>{};
      for (int i = 0; i < azList.length;) {
        final item = azList[i];
        if (item is String) {
          if (i == azList.length - 1) {
            azList.removeAt(i); //此字母分组无内容，索引i无需自增
          } else {
            final nextItem = azList[i + 1];
            if (nextItem is String) {
              azList.removeAt(i); //此字母分组无内容，索引i无需自增
            } else {
              azMap[item] = i;
              i++;
            }
          }
        } else {
          i++;
        }
      }
      //最后插入数量
      azList.add(_usershipMap.length);
      //更新状态
      _usershipState.update(azMap: azMap, azList: azList);
      _dirtyUsershipState = false;
    }
    return _usershipState;
  }

  ///读取群组关系状态
  NetClientAzState get teamshipState {
    if (_dirtyTeamshipState) {
      //构建列表
      final azList = <Object>[...NetClientAzState.letters];
      _teamshipMap.forEach((key, value) {
        azList.add(value);
        //计算展示信息
        final target = getTeam(value.rid);
        value.displayNick = ComTools.formatTeamNick(target);
        value.displayIcon = target.icon;
        value.displayHead = target.head;
        value.displayPinyin = PinyinHelper.getPinyinE(value.displayNick, separator: '', defPinyin: '#', format: PinyinFormat.WITHOUT_TONE).toUpperCase();
        if (value.displayPinyin.isEmpty || !NetClientAzState.letters.contains(value.displayPinyin[0])) value.displayPinyin = '#${value.displayPinyin}';
      });
      //字母列表排序
      azList.sort((a, b) {
        final pyA = a is TeamShip ? a.displayPinyin : (a as String);
        final pyB = b is TeamShip ? b.displayPinyin : (b as String);
        if (pyA.startsWith('#') && !pyB.startsWith('#')) {
          return 1;
        } else if (!pyA.startsWith('#') && pyB.startsWith('#')) {
          return -1;
        } else {
          return Comparable.compare(pyA, pyB);
        }
      });
      //生成字母索引
      final azMap = <String, int>{};
      for (int i = 0; i < azList.length;) {
        final item = azList[i];
        if (item is String) {
          if (i == azList.length - 1) {
            azList.removeAt(i); //此字母分组无内容，索引i无需自增
          } else {
            final nextItem = azList[i + 1];
            if (nextItem is String) {
              azList.removeAt(i); //此字母分组无内容，索引i无需自增
            } else {
              azMap[item] = i;
              i++;
            }
          }
        } else {
          i++;
        }
      }
      //最后插入数量
      azList.add(_teamshipMap.length);
      //更新状态
      _teamshipState.update(azMap: azMap, azList: azList);
      _dirtyTeamshipState = false;
    }
    return _teamshipState;
  }

  ///读取群组成员状态
  NetClientAzState getTeamuserState(ObjectId tid) {
    final teamuserState = _teamuserStateMap[tid];
    final teamuserMap = _teamuserMapMap[tid];
    final dirtyTeamuserState = _dirtyTeamuserStateMap[tid];
    if (teamuserState == null || teamuserMap == null || dirtyTeamuserState == null) {
      return NetClientAzState()..update(azList: [0]); //这种情况说明没有加入这个群组
    }
    if (dirtyTeamuserState) {
      //构建列表
      final team = getTeam(tid);
      final admins = <Object>[];
      final azList = <Object>[...NetClientAzState.letters];
      teamuserMap.forEach((key, value) {
        if (ComTools.isTeamSuperAdmin(team, value.uid)) {
          admins.insert(0, value);
        } else if (ComTools.isTeamNormalAdmin(team, value.uid)) {
          admins.add(value);
        } else {
          azList.add(value);
        }
        //计算展示信息
        final target = getUser(value.uid);
        value.displayNick = ComTools.formatTeamUserNick(value, target);
        value.displayIcon = target.icon;
        value.displayHead = target.head;
        value.displayPinyin = PinyinHelper.getPinyinE(value.displayNick, separator: '', defPinyin: '#', format: PinyinFormat.WITHOUT_TONE).toUpperCase();
        if (value.displayPinyin.isEmpty || !NetClientAzState.letters.contains(value.displayPinyin[0])) value.displayPinyin = '#${value.displayPinyin}';
      });
      //字母列表排序
      azList.sort((a, b) {
        final pyA = a is TeamShip ? a.displayPinyin : (a as String);
        final pyB = b is TeamShip ? b.displayPinyin : (b as String);
        if (pyA.startsWith('#') && !pyB.startsWith('#')) {
          return 1;
        } else if (!pyA.startsWith('#') && pyB.startsWith('#')) {
          return -1;
        } else {
          return Comparable.compare(pyA, pyB);
        }
      });
      //生成字母索引
      final azMap = <String, int>{};
      for (int i = 0; i < azList.length;) {
        final item = azList[i];
        if (item is String) {
          if (i == azList.length - 1) {
            azList.removeAt(i); //此字母分组无内容，索引i无需自增
          } else {
            final nextItem = azList[i + 1];
            if (nextItem is String) {
              azList.removeAt(i); //此字母分组无内容，索引i无需自增
            } else {
              azMap[item] = i;
              i++;
            }
          }
        } else {
          i++;
        }
      }
      //插入管理员
      admins.insert(0, NetClientAzState.header);
      azMap.forEach((key, value) => azMap[key] = value + admins.length);
      azMap[NetClientAzState.header] = 0;
      azList.insertAll(0, admins);
      //最后插入数量
      azList.add(teamuserMap.length);
      //更新状态
      teamuserState.update(azMap: azMap, azList: azList);
      _dirtyTeamuserStateMap[tid] = false;
    }
    return teamuserState;
  }

  ///设置用户信息获取完成的监听器---此事件由本地触发
  void setOnUserFetchedWatcher(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onUserFetchedEvent', ondata: ondata);
    } else {
      _websocketClient.addListener('onUserFetchedEvent', ondata);
    }
  }

  ///设置群组信息获取完成的监听器---此事件由本地触发
  void setOnTeamFetchedWatcher(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onTeamFetchedEvent', ondata: ondata);
    } else {
      _websocketClient.addListener('onTeamFetchedEvent', ondata);
    }
  }

  ///设置我的信息发生变化的监听器
  void setOnUserUpdateListener(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onUserUpdate', ondata: ondata);
    } else {
      _websocketClient.addListener('onUserUpdate', ondata);
    }
  }

  ///设置群组信息发生变化的监听器
  void setOnTeamUpdateListener(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onTeamUpdate', ondata: ondata);
    } else {
      _websocketClient.addListener('onTeamUpdate', ondata);
    }
  }

  ///设置好友申请发生变化的监听器
  void setOnWaitShipUpdateListener(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onWaitShipUpdate', ondata: ondata);
    } else {
      _websocketClient.addListener('onWaitShipUpdate', ondata);
    }
  }

  ///设置用户关系发生变化的监听器
  void setOnUserShipUpdateListener(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onUserShipUpdate', ondata: ondata);
    } else {
      _websocketClient.addListener('onUserShipUpdate', ondata);
    }
  }

  ///设置群组关系发生变化的监听器
  void setOnTeamShipUpdateListener(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onTeamShipUpdate', ondata: ondata);
    } else {
      _websocketClient.addListener('onTeamShipUpdate', ondata);
    }
  }

  ///设置收到新的聊天消息的监听器
  void setOnMessageSendListener(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onMessageSend', ondata: ondata);
    } else {
      _websocketClient.addListener('onMessageSend', ondata);
    }
  }

  ///设置消息数据发生变化的监听器
  void setOnMessageUpdateListener(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onMessageUpdate', ondata: ondata);
    } else {
      _websocketClient.addListener('onMessageUpdate', ondata);
    }
  }

  ///设置收到实时媒体信令的监听器
  void setOnMessageWebrtcListener(void Function(EasyPacket packet) ondata, {required bool remove}) {
    if (remove) {
      _websocketClient.removeListener('onMessageWebrtc', ondata: ondata);
    } else {
      _websocketClient.addListener('onMessageWebrtc', ondata);
    }
  }

  ///是否为用户信息获取完成的数据包
  bool isUserFetchedPacket(EasyPacket packet) => packet.route == 'onUserFetchedEvent';

  ///是否为群组信息获取完成的数据包
  bool isTeamFetchedPacket(EasyPacket packet) => packet.route == 'onTeamFetchedEvent';

  ///是否为我的信息发生变化的数据包
  bool isUserUpdatePacket(EasyPacket packet) => packet.route == 'onUserUpdate';

  ///是否为群组信息发生变化的数据包
  bool isTeamUpdatePacket(EasyPacket packet) => packet.route == 'onTeamUpdate';

  ///是否为好友申请发生变化的数据包
  bool isWaitShipUpdatePacket(EasyPacket packet) => packet.route == 'onWaitShipUpdate';

  ///是否为用户关系发生变化的数据包
  bool isUserShipUpdatePacket(EasyPacket packet) => packet.route == 'onUserShipUpdate';

  ///是否为群组关系发生变化的数据包
  bool isTeamShipUpdatePacket(EasyPacket packet) => packet.route == 'onTeamShipUpdate';

  ///是否为收到新的聊天消息的数据包
  bool isMessageSendPacket(EasyPacket packet) => packet.route == 'onMessageSend';

  ///是否为消息数据发生变化的数据包
  bool isMessageUpdatePacket(EasyPacket packet) => packet.route == 'onMessageUpdate';

  ///是否为收到实时媒体信令的数据包
  bool isMessageWebrtcPacket(EasyPacket packet) => packet.route == 'onMessageWebrtc';

  ///[packet]是否为对应[session]的消息推送
  bool isMessageSendForSession(Session session, EasyPacket packet) => isMessageSendPacket(packet) && parseMessageFromSendOrUpdate(packet).sid == session.sid;

  ///从[packet]中解析出[Message]实例
  Message parseMessageFromSendOrUpdate(EasyPacket packet) => packet.data!['_parsedMessage'] ?? Message.fromJson(packet.data!['message']);

  ///从[packet]中解析出[UserShip]实例
  UserShip parseUserShipFromSendOrUpdate(EasyPacket packet) => packet.data!['_parsedShip'] ?? UserShip.fromJson(packet.data!['ship']);

  ///从[packet]中解析出[TeamShip]实例
  TeamShip parseTeamShipFromSendOrUpdate(EasyPacket packet) => packet.data!['_parsedShip'] ?? TeamShip.fromJson(packet.data!['ship']);

  /* **************** 缓存方法 **************** */

  ///重新创建websocket连接的客户端
  void _resetWebsocketClient(Map<String, dynamic> config) {
    //解绑口令信息
    _httpAliveClient.unbindUser();
    _websocketClient.unbindUser();
    //先销毁旧的
    _websocketClient.destroy();
    //创建新的
    _websocketClient = EasyClient(config: EasyClientConfig(logger: logger, logLevel: logLevel, logTag: logTag, host: config['host'], port: config['port'], pwd: config['pwd'], binary: binary, sslEnable: sslEnable));
    //启用多线程进行数据编解码
    if (isolate) _websocketClient.initThread(_isolateHandler);
    //绑定推送数据的事件监听器
    _websocketClient.addListener('onUserUpdate', (packet) => user.updateByJson(packet.data!));
    _websocketClient.addListener('onTeamUpdate', (packet) => _cacheTeam(packet.data));
    _websocketClient.addListener('onWaitShipUpdate', (packet) => _cacheUserShip(packet.data));
    _websocketClient.addListener('onUserShipUpdate', (packet) => _cacheUserShip(packet.data));
    _websocketClient.addListener('onTeamShipUpdate', (packet) => _cacheTeamShip(packet.data));
    _websocketClient.addListener('onMessageSend', (packet) {
      final userData = packet.data!['user'];
      final shipData = packet.data!['ship'];
      final messageData = packet.data!['message'];
      //更新发送者缓存
      final user = _cacheUser(userData);
      //更新关系与消息缓存
      final message = Message.fromJson(messageData);
      if (message.from == Constant.msgFromUser) {
        final ship = _cacheUserShip(shipData);
        ship.msgcache.insert(0, message);
        _fillMessage(message);
        //保存解析结果
        packet.data!['_parsedUser'] = user;
        packet.data!['_parsedShip'] = ship;
        packet.data!['_parsedMessage'] = message;
      } else if (message.from == Constant.msgFromTeam) {
        final ship = _cacheTeamShip(shipData);
        ship.msgcache.insert(0, message);
        _fillMessage(message);
        //保存解析结果
        packet.data!['_parsedUser'] = user;
        packet.data!['_parsedShip'] = ship;
        packet.data!['_parsedMessage'] = message;
      }
    });
    _websocketClient.addListener('onMessageUpdate', (packet) {
      final userData = packet.data!['user'];
      final shipData = packet.data!['ship'];
      final messageData = packet.data!['message'];
      //更新发送者缓存
      final user = _cacheUser(userData);
      //更新关系与消息缓存
      final message = Message.fromJson(messageData);
      if (message.from == Constant.msgFromUser) {
        final ship = _cacheUserShip(shipData);
        for (var element in ship.msgcache) {
          if (element.id == message.id) {
            element.updateByJson(messageData, parser: message);
            _fillMessage(element);
            //保存解析结果
            packet.data!['_parsedUser'] = user;
            packet.data!['_parsedShip'] = ship;
            packet.data!['_parsedMessage'] = element;
            break;
          }
        }
      } else if (message.from == Constant.msgFromTeam) {
        final ship = _cacheTeamShip(shipData);
        for (var element in ship.msgcache) {
          if (element.id == message.id) {
            element.updateByJson(messageData, parser: message);
            _fillMessage(element);
            //保存解析结果
            packet.data!['_parsedUser'] = user;
            packet.data!['_parsedShip'] = ship;
            packet.data!['_parsedMessage'] = element;
            break;
          }
        }
      }
    });
  }

  ///填充消息展示字段
  void _fillMessage(Message message) {
    final target = message.uid == user.id ? user : getUser(message.uid);
    if (message.from == Constant.msgFromUser) {
      final ship = getUserShip(message.uid);
      message.displayNick = ship == null ? ComTools.formatUserNick(target) : ComTools.formatUserShipNick(ship, target);
      message.displayIcon = target.icon;
      message.displayHead = target.head;
    } else if (message.from == Constant.msgFromTeam) {
      final ship = getTeamUser(message.sid, message.uid);
      message.displayNick = ship == null ? ComTools.formatUserNick(target) : ComTools.formatTeamUserNick(ship, target);
      message.displayIcon = target.icon;
      message.displayHead = target.head;
    }
  }

  ///更新[_userMap]缓存
  User _cacheUser(dynamic data) {
    final item = User.fromJson(data);
    //更新用户缓存
    final key = item.id; //uid is key
    if (_userMap.containsKey(key)) {
      _userMap[key]?.updateByJson(data, parser: item);
    } else {
      _userMap[key] = item;
    }
    //标记要刷新的状态
    if (_waitshipMap.containsKey(key)) {
      _dirtySessionState = true;
      _dirtyWaitshipState = true;
    }
    if (_usershipMap.containsKey(key)) {
      _dirtySessionState = true;
      _dirtyUsershipState = true;
    }
    return _userMap[key] ?? item;
  }

  ///更新[_teamMap]缓存
  Team _cacheTeam(dynamic data) {
    final item = Team.fromJson(data);
    //更新群组缓存
    final key = item.id; //tid is key
    if (_teamMap.containsKey(key)) {
      _teamMap[key]?.updateByJson(data, parser: item);
    } else {
      _teamMap[key] = item;
    }
    //标记要刷新的状态
    if (_teamshipMap.containsKey(key)) {
      _dirtySessionState = true;
      _dirtyTeamshipState = true;
    }
    return _teamMap[key] ?? item;
  }

  ///更新[_waitshipMap] 或 [_usershipMap]缓存，如果数据仍然被缓存则将key放入[saveKeys]中
  UserShip _cacheUserShip(dynamic data, {Set<ObjectId>? saveKeys}) {
    final item = UserShip.fromJson(data);
    if (item.rid == user.id) {
      //更新好友申请缓存
      final key = item.uid; //uid is key
      if (item.state == Constant.shipStateWait) {
        if (_waitshipMap.containsKey(key)) {
          _waitshipMap[key]?.updateByJson(data, parser: item);
        } else {
          _waitshipMap[key] = item;
        }
        saveKeys?.add(key);
      } else {
        _waitshipMap.remove(key);
      }
      //标记要刷新的状态
      _dirtySessionState = true;
      _dirtyWaitshipState = true;
      return _waitshipMap[key] ?? item;
    } else if (item.uid == user.id) {
      //更新好友关系缓存
      final key = item.rid; //rid is key
      if (item.state == Constant.shipStatePass) {
        if (_usershipMap.containsKey(key)) {
          _usershipMap[key]?.updateByJson(data, parser: item);
        } else {
          _usershipMap[key] = item;
        }
        saveKeys?.add(key);
      } else {
        _usershipMap.remove(key);
      }
      //标记要刷新的状态
      _dirtySessionState = true;
      _dirtyUsershipState = true;
      return _usershipMap[key] ?? item;
    } else {
      return item;
    }
  }

  ///更新[_teamshipMap]缓存，如果数据仍然被缓存则将key放入[saveKeys]中
  TeamShip _cacheTeamShip(dynamic data, {Set<ObjectId>? saveKeys}) {
    final item = TeamShip.fromJson(data);
    //更新群组关系缓存
    final key = item.rid; //rid is key
    if (item.state == Constant.shipStatePass) {
      if (_teamshipMap.containsKey(key)) {
        _teamshipMap[key]?.updateByJson(data, parser: item);
      } else {
        _teamshipMap[key] = item;
      }
      saveKeys?.add(key);
      //添加群组成员相关
      _teamuserStateMap[key] = _teamuserStateMap[key] ?? NetClientAzState();
      _teamuserMapMap[key] = _teamuserMapMap[key] ?? {};
      _dirtyTeamuserStateMap[key] = _dirtyTeamuserStateMap[key] ?? true;
    } else {
      _teamshipMap.remove(key);
      //移除群组成员相关
      _teamuserStateMap.remove(key);
      _teamuserMapMap.remove(key);
      _dirtyTeamuserStateMap.remove(key);
    }
    //标记要刷新的状态
    _dirtySessionState = true;
    _dirtyTeamshipState = true;
    return _teamshipMap[key] ?? item;
  }

  ///更新[_teamuserMapMap]的[teamId]子项缓存，如果数据仍然被缓存则将key放入[saveKeys]中
  TeamShip _cacheTeamUser(ObjectId teamId, dynamic data, {Set<ObjectId>? saveKeys}) {
    final teamuserMap = _teamuserMapMap[teamId];
    final item = TeamShip.fromJson(data);
    if (teamuserMap != null && item.rid == teamId) {
      //更新群组成员缓存
      final key = item.uid; //uid is key
      if (item.state == Constant.shipStatePass) {
        if (teamuserMap.containsKey(key)) {
          teamuserMap[key]?.updateByJson(data, parser: item);
        } else {
          teamuserMap[key] = item;
        }
        saveKeys?.add(key);
      } else {
        teamuserMap.remove(key);
      }
      //标记要刷新的状态
      _dirtyTeamuserStateMap[teamId] = true;
      return teamuserMap[key] ?? item;
    } else {
      return item;
    }
  }

  ///批量更新[_userMap]缓存
  List<User> _cacheUserList(List dataList) => dataList.map((e) => _cacheUser(e)).toList();

  ///批量更新[_teamMap]缓存
  List<Team> _cacheTeamList(List dataList) => dataList.map((e) => _cacheTeam(e)).toList();

  ///批量更新[_waitshipMap] 或 [_usershipMap]缓存，如果数据仍然被缓存则将key放入[saveKeys]中
  List<UserShip> _cacheUserShipList(List dataList, {Set<ObjectId>? saveKeys}) => dataList.map((e) => _cacheUserShip(e, saveKeys: saveKeys)).toList();

  ///批量更新[_teamshipMap]缓存，如果数据仍然被缓存则将key放入[saveKeys]中
  List<TeamShip> _cacheTeamShipList(List dataList, {Set<ObjectId>? saveKeys}) => dataList.map((e) => _cacheTeamShip(e, saveKeys: saveKeys)).toList();

  ///批量更新[_teamuserMapMap]的[teamId]子项缓存，如果数据仍然被缓存则将key放入[saveKeys]中
  List<TeamShip> _cacheTeamUserList(ObjectId teamId, List dataList, {Set<ObjectId>? saveKeys}) => dataList.map((e) => _cacheTeamUser(teamId, e, saveKeys: saveKeys)).toList();

  /* **************** 静态方法 **************** */

  ///加密登录凭据
  static String? encryptCredentials(User user, String secret) {
    final packet = EasyPacket.pushdata(route: 'credentials', data: {'user': user});
    return EasySecurity.encrypt(packet, secret, false);
  }

  ///解密登录凭据
  static User? decryptCredentials(String data, String secret) {
    final packet = EasySecurity.decrypt(data, secret);
    if (packet == null || packet.data == null || !packet.data!.containsKey('user')) return null;
    return User.fromJson(packet.data!['user']);
  }

  ///密集计算处理
  static Future<dynamic> _isolateHandler(String taskType, dynamic taskData) async {
    return null;
  }
}

///
///字母索引列表状态
///
class NetClientAzState {
  static const header = '↑';
  static const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'];

  ///字母索引映射
  final Map<String, int> azMap;

  ///字母索引列表，示例数据: [ String A, Object, Object, ... , String B, Object, Object, ... , String Z, Object, Object, ... , int total ]
  final List<Object> azList;

  ///定制数据列表
  final List<Object> okList;

  ///未读消息数量 或 未处理申请数量
  int _unread;

  int get unread => _unread;

  NetClientAzState()
      : azMap = {},
        azList = [],
        okList = [],
        _unread = 0;

  ///更新字段
  void update({Map<String, int>? azMap, List<Object>? azList, List<Object>? okList, int? unread}) {
    if (azMap != null) {
      this.azMap.clear();
      this.azMap.addAll(azMap);
    }
    if (azList != null) {
      this.azList.clear();
      this.azList.addAll(azList);
    }
    if (okList != null) {
      this.okList.clear();
      this.okList.addAll(okList);
    }
    if (unread != null) {
      _unread = unread;
    }
  }

  ///清空字段
  void clear() {
    azMap.clear();
    azList.clear();
    okList.clear();
    _unread = 0;
  }
}
