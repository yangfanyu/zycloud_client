import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:zycloud_client/zycloud_client.dart';

///
///控制台客户端
///
class ZyCloudClientConsole extends EasyLogger {
  ///操作后控制台输出的延迟时间
  static const delayDuration = Duration(microseconds: 500);

  ///网络客户端的实例
  final NetClient _netClient;

  ///标准输入流接收器
  final Stream<String> _stdinLStream = stdin.transform<String>(utf8.decoder).transform<String>(const LineSplitter()).asBroadcastStream();

  ///控制台历史页面栈
  final List<Function> _pageRouteStack = [];

  ///登录凭据保存目录
  static String get _cerFolder => '${Directory.current.path}/credentials';

  ///登录凭据保存方法
  static void onCredentials(User user, String? credentials) {
    final cerFile = File('$_cerFolder/${ComTools.formatUserNick(user)}.cer');
    if (credentials == null) {
      if (cerFile.existsSync()) cerFile.deleteSync();
    } else {
      if (!cerFile.existsSync()) cerFile.createSync(recursive: true);
      cerFile.writeAsStringSync(credentials);
    }
  }

  ZyCloudClientConsole({
    EasyLogLevel logLevel = EasyLogLevel.info,
    required String host,
    required int port,
    bool binary = true,
    bool sslEnable = false,
    required String bsid,
    required String secret,
    bool isolate = true,
  })  : _netClient = NetClient(
          config: EasyClientConfig(
            logLevel: logLevel,
            host: host,
            port: port,
            binary: binary,
            sslEnable: sslEnable,
          ),
          bsid: bsid,
          secret: secret,
          isolate: isolate,
          onCredentials: onCredentials,
        ),
        super(logTag: '');

  ///导航到新页面
  void navigationTo({required Function from, required Function to}) {
    if (!_pageRouteStack.contains(from)) {
      _pageRouteStack.add(from);
    }
    to();
  }

  ///登录页
  void loginPage() {
    renderPage(
      '登录',
      [
        MenuItem('口令登录', () async {
          final List<FileSystemEntity> entityList = Directory(_cerFolder).existsSync() ? Directory(_cerFolder).listSync() : [];
          if (entityList.isEmpty) {
            logWarn(['未找到口令证书，请用其他方式登录!']);
            Future.delayed(delayDuration, () => loginPage());
          } else {
            logDebug(['证书目录下发现口令证书:']);
            entityList.sort((a, b) => a.path.compareTo(b.path));
            final pathMap = <String, String>{};
            for (var i = 0; i < entityList.length; i++) {
              logDebug(['    $i -> ${entityList[i].path.replaceFirst(_cerFolder, '')}']);
              pathMap['$i'] = entityList[i].path;
            }
            logInfo(['请输入口令证书序号:']);
            final key = (await readStdinLine()).trim();
            if (!pathMap.containsKey(key)) {
              logWarn(['没有这个证书选项!']);
              Future.delayed(delayDuration, () => loginPage());
            } else {
              try {
                final file = File(pathMap[key]!);
                final user = NetClient.decryptCredentials(file.readAsStringSync(), _netClient.secret)!;
                final result = await _netClient.loginByToken(uid: user.id, token: user.token);
                if (result.ok) {
                  onLoginSuccess();
                } else {
                  logWarn([result.desc]);
                  Future.delayed(delayDuration, () => loginPage());
                }
              } catch (error) {
                logError(['读取证书出错', error]);
                Future.delayed(delayDuration, () => loginPage());
              }
            }
          }
        }),
        MenuItem('账号密码登录', () async {
          logInfo(['请输入用户账号:']);
          final no = (await readStdinLine()).trim();
          logInfo(['请输入用户密码:']);
          final pwd = (await readStdinLine()).trim();
          final result = await _netClient.loginByNoPwd(no: no, pwd: pwd);
          if (result.ok) {
            onLoginSuccess();
          } else {
            logWarn([result.desc]);
            Future.delayed(delayDuration, () => loginPage());
          }
        }),
        MenuItem('手机号码登录', () async {
          logInfo(['请输入手机号码:']);
          final phone = (await readStdinLine()).trim();
          final sendres = await _netClient.sendRandcode(phone: phone);
          if (sendres.ok) {
            logDebug([sendres.desc]);
            logInfo(['请输入验证码:']);
            final code = (await readStdinLine()).trim();
            final result = await _netClient.loginByPhone(phone: phone, code: code);
            if (result.ok) {
              onLoginSuccess();
            } else {
              logWarn([result.desc]);
              Future.delayed(delayDuration, () => loginPage());
            }
          } else {
            logWarn([sendres.desc]);
            Future.delayed(delayDuration, () => loginPage());
          }
        }),
        MenuItem('重置密码', () async {
          logInfo(['请输入手机号码:']);
          final phone = (await readStdinLine()).trim();
          final sendres = await _netClient.sendRandcode(phone: phone);
          if (sendres.ok) {
            logDebug([sendres.desc]);
            logInfo(['请输入验证码:']);
            final code = (await readStdinLine()).trim();
            logInfo(['请输入新密码:']);
            final pwd = (await readStdinLine()).trim();
            final result = await _netClient.loginByPhone(phone: phone, code: code, pwd: pwd);
            if (result.ok) {
              onLoginSuccess();
            } else {
              logWarn([result.desc]);
              Future.delayed(delayDuration, () => loginPage());
            }
          } else {
            logWarn([sendres.desc]);
            Future.delayed(delayDuration, () => loginPage());
          }
        }),
        MenuItem('注册账号', () async {
          logInfo(['请输入手机号码:']);
          final phone = (await readStdinLine()).trim();
          final sendres = await _netClient.sendRandcode(phone: phone);
          if (sendres.ok) {
            logDebug([sendres.desc]);
            logInfo(['请输入验证码:']);
            final code = (await readStdinLine()).trim();
            logInfo(['请输入账号:']);
            final no = (await readStdinLine()).trim();
            logInfo(['请输入密码:']);
            final pwd = (await readStdinLine()).trim();
            final result = await _netClient.loginByPhone(phone: phone, code: code, no: no, pwd: pwd);
            if (result.ok) {
              onLoginSuccess();
            } else {
              logWarn([result.desc]);
              Future.delayed(delayDuration, () => loginPage());
            }
          } else {
            logWarn([sendres.desc]);
            Future.delayed(delayDuration, () => loginPage());
          }
        }),
        MenuItem('加载配置', () async {
          final result = await _netClient.appManifest();
          if (result.ok) {
            logDebug([_netClient.business]);
          } else {
            logWarn([result.desc]);
          }
          Future.delayed(delayDuration, () => loginPage());
        }),
        MenuItem('域名验证', () async {
          logInfo(['请输入验证域名:']);
          final host = (await readStdinLine()).trim();
          final result = await _netClient.validateHost(host: host);
          if (result.ok) {
            logDebug([result.extra]);
          } else {
            logWarn([result.desc]);
          }
          Future.delayed(delayDuration, () => loginPage());
        }),
      ],
    );
  }

  ///登录成功
  void onLoginSuccess() {
    _netClient.connect(
      onopen: () {
        _netClient.userEnter().then((value) {
          if (value.ok) {
            _netClient.doLogLogin(); //登录日志
            // _netClient.doLogError(); //异常日志
            // _netClient.doLogReport(type: Constant.reportTypeHost); //反馈日志
            _pageRouteStack.clear(); //清空路由栈
            homePage();
          }
        });
      },
      onclose: (code, reason) {
        logError(['网络已断开']);
        _netClient.release();
        Future.delayed(delayDuration, () => exit(0));
      },
    );
  }

  void homePage() {
    renderPage('首页', [
      MenuItem('会话模块', () {
        navigationTo(from: homePage, to: sessionsPage);
      }),
      MenuItem('好友模块', () {
        navigationTo(from: homePage, to: usershipsPage);
      }),
      MenuItem('群组模块', () {
        navigationTo(from: homePage, to: teamshipsPage);
      }),
      MenuItem('申请模块', () {
        navigationTo(from: homePage, to: waitshipsPage);
      }),
      MenuItem('我的信息', () {
        navigationTo(from: homePage, to: infomationPage);
      }),
      MenuItem('交易模块', () {
        navigationTo(from: homePage, to: paymentPage);
      }),
      MenuItem('数据模块', () {
        navigationTo(from: homePage, to: customxPage);
      }),
      MenuItem('管理模块', () {
        navigationTo(from: homePage, to: adminPage);
      }),
    ]);
  }

  void sessionsPage() {
    renderPage('首页->会话模块', [
      MenuItem('发送文本消息给好友', () async {
        logInfo(['发送文本消息给好友请输入会话id:']);
        final sid = (await readStdinLine()).trim();
        logInfo(['发送文本消息给好友请输入消息内容:']);
        final body = (await readStdinLine()).trim();
        final result = await _netClient.messageSendText(sid: DbQueryField.hexstr2ObjectId(sid), from: Constant.msgFromUser, body: body);
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        }
      }),
      MenuItem('发送文本消息到群组', () async {
        logInfo(['发送文本消息到群组请输入会话id:']);
        final sid = (await readStdinLine()).trim();
        logInfo(['发送文本消息到群组请输入消息内容:']);
        final body = (await readStdinLine()).trim();
        final result = await _netClient.messageSendText(sid: DbQueryField.hexstr2ObjectId(sid), from: Constant.msgFromTeam, body: body);
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        }
      }),
      MenuItem('发送红包消息给好友', () async {
        logInfo(['发送红包消息给好友请输入会话id:']);
        final sid = (await readStdinLine()).trim();
        logInfo(['发送红包消息给好友请输入消息内容:']);
        final body = (await readStdinLine()).trim();
        final result = await _netClient.messageSendRedpackNormal(sid: DbQueryField.hexstr2ObjectId(sid), from: Constant.msgFromUser, body: body, rmbfenTotal: 100, rmbfenCount: 10, cashPassword: _netClient.user.rmbpwd);
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        }
      }),
      MenuItem('发送红包消息到群组', () async {
        logInfo(['发送红包消息到群组请输入会话id:']);
        final sid = (await readStdinLine()).trim();
        logInfo(['发送红包消息到群组请输入消息内容:']);
        final body = (await readStdinLine()).trim();
        final result = await _netClient.messageSendRedpackLuckly(sid: DbQueryField.hexstr2ObjectId(sid), from: Constant.msgFromTeam, body: body, rmbfenTotal: 100, rmbfenCount: 10, cashPassword: _netClient.user.rmbpwd);
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        }
      }),
      MenuItem('加载会话消息列表', () async {
        logInfo(['加载会话消息列表请输入会话序号:']);
        final no = (await readStdinLine()).trim();
        logInfo(['加载会话消息列表请输入是否重置 (true, false):']);
        final reload = (await readStdinLine()).trim();
        final ship = _netClient.sessionState.okList[int.parse(no)];
        if (ship is UserShip) {
          _netClient.messageLoad(session: _netClient.createSession(usership: ship), reload: reload == 'true');
          _netClient.messageLoad(session: _netClient.createSession(usership: ship), reload: reload == 'true');
          _netClient.messageLoad(session: _netClient.createSession(usership: ship), reload: reload == 'true');
          _netClient.messageLoad(session: _netClient.createSession(usership: ship), reload: reload == 'true');
          final result = await _netClient.messageLoad(session: _netClient.createSession(usership: ship), reload: reload == 'true');
          if (result.ok) {
            for (var message in ship.msgcache) {
              logDebug([message.id, 'sender(${message.displayNick})', message.short, message.body, ComTools.formatDateTime(message.time, yyMMdd: true, hhmmss: true)]);
            }
            if (result.extra == true) logDebug(['加载完毕！']);
            Future.delayed(delayDuration, () => sessionsPage());
          } else {
            logWarn([result.desc]);
            Future.delayed(delayDuration, () => sessionsPage());
          }
        } else if (ship is TeamShip) {
          _netClient.messageLoad(session: _netClient.createSession(teamship: ship), reload: reload == 'true');
          _netClient.messageLoad(session: _netClient.createSession(teamship: ship), reload: reload == 'true');
          _netClient.messageLoad(session: _netClient.createSession(teamship: ship), reload: reload == 'true');
          _netClient.messageLoad(session: _netClient.createSession(teamship: ship), reload: reload == 'true');
          final result = await _netClient.messageLoad(session: _netClient.createSession(teamship: ship), reload: reload == 'true');
          if (result.ok) {
            for (var message in ship.msgcache) {
              logDebug([message.id, 'sender(${message.displayNick})', message.short, message.body, ComTools.formatDateTime(message.time, yyMMdd: true, hhmmss: true)]);
            }
            Future.delayed(delayDuration, () => sessionsPage());
          } else {
            logWarn([result.desc]);
            Future.delayed(delayDuration, () => sessionsPage());
          }
        }
      }),
      MenuItem('加载消息详情', () async {
        logInfo(['加载消息详情请输入消息id:']);
        final id = (await readStdinLine()).trim();
        final result = await _netClient.messageDetail(id: DbQueryField.hexstr2ObjectId(id));
        if (result.ok) {
          logDebug([result.extra]);
          Future.delayed(delayDuration, () => sessionsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        }
      }),
      MenuItem('抢红包的更新', () async {
        logInfo(['抢红包的更新请输入消息id:']);
        final id = (await readStdinLine()).trim();
        final result = await _netClient.messageUpdate(id: DbQueryField.hexstr2ObjectId(id), redpackGrab: true);
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => sessionsPage());
        }
      }),
      MenuItem('打印会话列表', () {
        final okList = _netClient.sessionState.okList;
        final unread = _netClient.sessionState.unread;
        logDebug(['共$unread条未读消息:']);
        int no = 0;
        for (var element in okList) {
          if (element is UserShip) {
            logDebug([
              no++,
              'uid(${element.rid.toHexString()})',
              'sid(${element.sid.toHexString()})',
              'nick(${element.displayNick})',
              'unread(${element.unread})',
              'recent(${element.recent})',
              'top(${element.top})',
              ComTools.formatDateTime(
                element.update,
                yyMMdd: true,
                hhmmss: true,
              )
            ]);
          } else if (element is TeamShip) {
            logDebug([
              no++,
              'tid(${element.rid.toHexString()})',
              'sid(${element.sid.toHexString()})',
              'nick(${element.displayNick})',
              'unread(${element.unread})',
              'recent(${element.recent})',
              'top(${element.top})',
              ComTools.formatDateTime(
                element.update,
                yyMMdd: true,
                hhmmss: true,
              )
            ]);
          }
        }
        Future.delayed(delayDuration, () => sessionsPage());
      }),
    ]);
  }

  void usershipsPage() {
    renderPage('首页->好友模块', [
      MenuItem('批量拉取用户', () async {
        logInfo(['批量拉取用户请输入用户id（多个id用","隔开）:']);
        final uids = (await readStdinLine()).trim();
        final result = await _netClient.userFetch(uids: uids.split(',').map((e) => DbQueryField.hexstr2ObjectId(e)).toList());
        if (result.ok) {
          logDebug(['共${result.extra?.length ?? 0}条用户信息拉取结果:']);
          result.extra?.forEach((element) => logDebug([element]));
          Future.delayed(delayDuration, () => usershipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        }
      }),
      MenuItem('搜索用户信息', () async {
        logInfo(['搜索用户信息请输入关键词（账号、手机号）:']);
        final keywords = (await readStdinLine()).trim();
        final result = await _netClient.userSearch(keywords: keywords);
        if (result.ok) {
          logDebug(['共${result.extra?.length ?? 0}条用户信息搜索结果:']);
          result.extra?.forEach((element) => logDebug([element]));
          Future.delayed(delayDuration, () => usershipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        }
      }),
      MenuItem('搜索好友关系', () async {
        logInfo(['搜索好友关系请输入用户id:']);
        final uid = (await readStdinLine()).trim();
        final result = await _netClient.userShipQuery(uid: DbQueryField.hexstr2ObjectId(uid), from: Constant.shipFromSearch);
        if (result.ok) {
          logDebug(['好友关系搜索结果:']);
          logDebug([result.extra, readConstMap(result.extra!.state)]);
          Future.delayed(delayDuration, () => usershipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        }
      }),
      MenuItem('发起好友申请', () async {
        logInfo(['发起好友申请请输入用户id:']);
        final uid = (await readStdinLine()).trim();
        logInfo(['发起好友申请请输入申请描述:']);
        final apply = (await readStdinLine()).trim();
        final result = await _netClient.userShipApply(uid: DbQueryField.hexstr2ObjectId(uid), from: Constant.shipFromSearch, apply: apply);
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        }
      }),
      MenuItem('解除好友关系', () async {
        logInfo(['解除好友关系请输入用户id:']);
        final uid = (await readStdinLine()).trim();
        final result = await _netClient.userShipNone(uid: DbQueryField.hexstr2ObjectId(uid));
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        }
      }),
      MenuItem('修改好友备注名', () async {
        logInfo(['修改好友备注名请输入关系id:']);
        final id = (await readStdinLine()).trim();
        logInfo(['修改好友备注名请输入新昵称:']);
        final alias = (await readStdinLine()).trim();
        final dirty = UserShipDirty()..alias = alias;
        final result = await _netClient.userShipUpdate(id: DbQueryField.hexstr2ObjectId(id), fields: dirty.data);
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => usershipsPage());
        }
      }),
      MenuItem('打印好友列表', () {
        final azList = _netClient.usershipState.azList;
        logDebug(['共${azList.last}个好友信息:']);
        for (var element in azList) {
          if (element is UserShip) {
            logDebug([
              'id(${element.id.toHexString()})',
              'uid(${element.rid.toHexString()})',
              element.displayNick,
              readConstMap(element.state),
              ComTools.formatDateTime(
                element.time,
                yyMMdd: true,
                hhmmss: true,
              )
            ]);
          } else {
            logDebug([element]);
          }
        }
        Future.delayed(delayDuration, () => usershipsPage());
      }),
    ]);
  }

  void teamshipsPage() {
    renderPage('首页->群组模块', [
      MenuItem('批量拉取群组', () async {
        logInfo(['批量拉取群组请输入群组id（多个id用","隔开）:']);
        final tids = (await readStdinLine()).trim();
        final result = await _netClient.teamFetch(tids: tids.split(',').map((e) => DbQueryField.hexstr2ObjectId(e)).toList());
        if (result.ok) {
          logDebug(['共${result.extra?.length ?? 0}条群组信息拉取结果:']);
          result.extra?.forEach((element) => logDebug([element]));
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('搜索群组信息', () async {
        logInfo(['搜索群组信息请输入关键词（账号、名称）:']);
        final keywords = (await readStdinLine()).trim();
        final result = await _netClient.teamSearch(keywords: keywords);
        if (result.ok) {
          logDebug(['共${result.extra?.length ?? 0}条群组信息搜索结果:']);
          result.extra?.forEach((element) => logDebug([element]));
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('搜索群组关系', () async {
        logInfo(['搜索群组关系请输入群组id:']);
        final tid = (await readStdinLine()).trim();
        final result = await _netClient.teamShipQuery(tid: DbQueryField.hexstr2ObjectId(tid), from: Constant.shipFromSearch);
        if (result.ok) {
          logDebug(['群组关系搜索结果:']);
          logDebug([result.extra, readConstMap(result.extra!.state)]);
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('创建新的群组', () async {
        logInfo(['创建新的群组请输入用户id（多个id用","隔开）:']);
        final uids = (await readStdinLine()).trim();
        final result = await _netClient.teamCreate(uids: uids.split(',').map((e) => DbQueryField.hexstr2ObjectId(e)).toList());
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('主动加入群组', () async {
        logInfo(['主动加入群组请输入群组id:']);
        final tid = (await readStdinLine()).trim();
        logInfo(['主动加入群组请输入加入描述:']);
        final apply = (await readStdinLine()).trim();
        final result = await _netClient.teamShipApply(tid: DbQueryField.hexstr2ObjectId(tid), from: Constant.shipFromSearch, apply: apply);
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('获取群组成员', () async {
        logInfo(['获取群组成员请输入群组id:']);
        final tid = (await readStdinLine()).trim();
        final result = await _netClient.teamMember(tid: DbQueryField.hexstr2ObjectId(tid));
        if (result.ok) {
          final azList = _netClient.getTeamuserState(DbQueryField.hexstr2ObjectId(tid)).azList;
          logDebug(['共${azList.last}个群组成员:']);
          for (var element in azList) {
            if (element is TeamShip) {
              logDebug([
                'id(${element.id.toHexString()})',
                'uid(${element.uid.toHexString()})',
                element.displayNick,
                readConstMap(element.state),
                element.apply,
                ComTools.formatDateTime(
                  element.time,
                  yyMMdd: true,
                  hhmmss: true,
                )
              ]);
            } else {
              logDebug([element]);
            }
          }
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('解除群组关系', () async {
        logInfo(['解除群组关系请输入群组id:']);
        final tid = (await readStdinLine()).trim();
        logInfo(['解除群组关系请输入用户id:']);
        final uid = (await readStdinLine()).trim();
        final result = await _netClient.teamShipNone(tid: DbQueryField.hexstr2ObjectId(tid), uid: DbQueryField.hexstr2ObjectId(uid));
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('拉人进入群组', () async {
        logInfo(['拉人进入群组请输入群组id:']);
        final tid = (await readStdinLine()).trim();
        logInfo(['拉人进入群组请输入用户id（多个id用","隔开）:']);
        final uids = (await readStdinLine()).trim();
        final result = await _netClient.teamShipPass(tid: DbQueryField.hexstr2ObjectId(tid), uids: uids.split(',').map((e) => DbQueryField.hexstr2ObjectId(e)).toList());
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('修改群组名称', () async {
        logInfo(['修改群组名称请输入群组id:']);
        final tid = (await readStdinLine()).trim();
        logInfo(['修改群组名称请输入新昵称:']);
        final nick = (await readStdinLine()).trim();
        final dirty = TeamDirty()..nick = nick;
        final result = await _netClient.teamUpdate(tid: DbQueryField.hexstr2ObjectId(tid), fields: dirty.data);
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('修改我的群昵称', () async {
        logInfo(['修改我的群昵称请输入关系id:']);
        final id = (await readStdinLine()).trim();
        logInfo(['修改我的群昵称请输入新昵称:']);
        final alias = (await readStdinLine()).trim();
        final dirty = TeamShipDirty()..alias = alias;
        final result = await _netClient.teamShipUpdate(id: DbQueryField.hexstr2ObjectId(id), fields: dirty.data);
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => teamshipsPage());
        }
      }),
      MenuItem('打印群组列表', () {
        final azList = _netClient.teamshipState.azList;
        logDebug(['共${azList.last}个群组信息:']);
        for (var element in azList) {
          if (element is TeamShip) {
            logDebug([
              'id(${element.id.toHexString()})',
              'tid(${element.rid.toHexString()})',
              element.displayNick,
              readConstMap(element.state),
              element.apply,
              ComTools.formatDateTime(
                element.time,
                yyMMdd: true,
                hhmmss: true,
              )
            ]);
          } else {
            logDebug([element]);
          }
        }
        Future.delayed(delayDuration, () => teamshipsPage());
      }),
    ]);
  }

  void waitshipsPage() {
    renderPage('首页->申请模块', [
      MenuItem('拒绝好友申请', () async {
        logInfo(['拒绝好友申请请输入用户id:']);
        final uid = (await readStdinLine()).trim();
        final result = await _netClient.userShipNone(uid: DbQueryField.hexstr2ObjectId(uid));
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => waitshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => waitshipsPage());
        }
      }),
      MenuItem('同意好友申请', () async {
        logInfo(['同意好友申请请输入用户id:']);
        final uid = (await readStdinLine()).trim();
        final result = await _netClient.userShipPass(uid: DbQueryField.hexstr2ObjectId(uid));
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => waitshipsPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => waitshipsPage());
        }
      }),
      MenuItem('打印申请列表', () {
        final okList = _netClient.waitshipState.okList;
        final unread = _netClient.waitshipState.unread;
        logDebug(['共$unread条好友申请信息:']);
        for (var element in okList) {
          if (element is UserShip) {
            logDebug(['uid(${element.uid.toHexString()})', element.displayNick, readConstMap(element.state), element.apply, ComTools.formatDateTime(element.time, yyMMdd: true, hhmmss: true)]);
          } else {
            logDebug([element]);
          }
        }
        Future.delayed(delayDuration, () => waitshipsPage());
      }),
    ]);
  }

  void infomationPage() {
    renderPage('首页->我的信息', [
      MenuItem('修改我的昵称', () async {
        logInfo(['修改我的昵称请输入新昵称:']);
        final nick = (await readStdinLine()).trim();
        final dirty = UserDirty()..nick = nick;
        final result = await _netClient.userUpdate(uid: _netClient.user.id, fields: dirty.data);
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => infomationPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => infomationPage());
        }
      }),
      MenuItem('批量上传图片', () async {
        logInfo(['图片上传中...']);
        final filepath = '${Directory.current.path}/flutter_logo.png';
        final result = await _netClient.attachUpload(
          type: Constant.metaTypeForever,
          fileBytes: [
            File(filepath).readAsBytesSync(),
            File(filepath).readAsBytesSync(),
            File(filepath).readAsBytesSync(),
          ],
          mediaType: MediaType.parse('image/png'),
        );
        if (result.ok) {
          logDebug([result.extra]);
          Future.delayed(delayDuration, () => infomationPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => infomationPage());
        }
      }),
      MenuItem('打印我的信息', () {
        logDebug(['我的信息: ']);
        logDebug([_netClient.user]);
        Future.delayed(delayDuration, () => infomationPage());
      }),
    ]);
  }

  void paymentPage() {
    renderPage('首页->交易模块', [
      MenuItem('微信下单', () async {
        logInfo(['微信下单输入商品序号:']);
        final goodsNo = (await readStdinLine()).trim();
        final result = await _netClient.wechatStart(goodsNo: int.parse(goodsNo));
        if (result.ok) {
          logDebug([result.extra!]);
          Future.delayed(delayDuration, () => paymentPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => paymentPage());
        }
      }),
      MenuItem('支付宝下单', () async {
        logInfo(['支付宝下单输入商品序号:']);
        final goodsNo = (await readStdinLine()).trim();
        final result = await _netClient.alipayStart(goodsNo: int.parse(goodsNo));
        if (result.ok) {
          logDebug([result.extra!]);
          Future.delayed(delayDuration, () => paymentPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => paymentPage());
        }
      }),
      MenuItem('苹果下单', () async {
        logInfo(['苹果下单输入商品序号:']);
        final goodsNo = (await readStdinLine()).trim();
        final result = await _netClient.iospayStart(goodsNo: int.parse(goodsNo), inpayId: DbQueryField.createObjectId().toHexString(), verifyData: 'fdsfsdafdsafdsa');
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => paymentPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => paymentPage());
        }
      }),
      MenuItem('模拟微信支付回调', () async {
        logInfo(['模拟微信支付回调输入订单id:']);
        final id = (await readStdinLine()).trim();
        final response = await EasyClient.post('${_netClient.guestHttpUrl}/wechatNotify', body: objMapToXmlStr({'out_trade_no': id}));
        logDebug([response.statusCode, response.body]);
        Future.delayed(delayDuration, () => paymentPage());
      }),
      MenuItem('模拟支付宝支付回调', () async {
        logInfo(['模拟支付宝支付回调输入订单id:']);
        final id = (await readStdinLine()).trim();
        final response = await EasyClient.post('${_netClient.guestHttpUrl}/alipayNotify', body: jsonEncode({'out_trade_no': id, 'trade_status': 'TRADE_SUCCESS'}));
        logDebug([response.statusCode, response.body]);
        Future.delayed(delayDuration, () => paymentPage());
      }),
    ]);
  }

  final datapage = ComPage<CustomX>(no: 0);

  void customxPage() {
    renderPage('首页->数据模块', [
      MenuItem('创建自定义数据', () async {
        logInfo(['创建自定义数据请输入数据内容:']);
        final content = (await readStdinLine()).trim();
        final result = await _netClient.customXInsert(
          no: datapage.no,
          int1: 111,
          int2: 222,
          int3: 333,
          str1: 'str111',
          str2: 'str222',
          str3: 'str333',
          rid1: DbQueryField.hexstr2ObjectId('111111111111111111111111'),
          rid2: DbQueryField.hexstr2ObjectId('222222222222222222222222'),
          rid3: DbQueryField.hexstr2ObjectId('333333333333333333333333'),
          body1: DbJsonWraper.fromJson({'content': content}),
        );
        if (result.ok) {
          logDebug([result.extra, result.extra?.cusmark, result.extra?.cusstar]);
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
      MenuItem('删除自定义数据', () async {
        logInfo(['删除自定义数据请输入数据id:']);
        final id = (await readStdinLine()).trim();
        final result = await _netClient.customXDelete(no: datapage.no, id: DbQueryField.hexstr2ObjectId(id));
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
      MenuItem('更新自定义数据', () async {
        logInfo(['更新自定义数据请输入数据id:']);
        final id = (await readStdinLine()).trim();
        logInfo(['更新自定义数据请输入数据内容:']);
        final content = (await readStdinLine()).trim();
        final result = await _netClient.customXUpdate(
          no: datapage.no,
          id: DbQueryField.hexstr2ObjectId(id),
          fields: (CustomXDirty()
                ..int1 = 1
                ..int2 = 2
                ..int3 = 3
                ..str1 = 'str1'
                ..str2 = 'str2'
                ..str3 = 'str3'
                ..body1 = DbJsonWraper(data: {'content': content}))
              .data,
        );
        if (result.ok) {
          logDebug([result.extra, result.extra?.cusmark, result.extra?.cusstar]);
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
      MenuItem('标记自定义数据', () async {
        logInfo(['标记自定义数据请输入数据id:']);
        final id = (await readStdinLine()).trim();
        logInfo(['标记自定义数据请输入数据分数（可空）:']);
        final score = (await readStdinLine()).trim();
        final result = await _netClient.customXMark(no: datapage.no, id: DbQueryField.hexstr2ObjectId(id), tp: 0, score: score.isEmpty ? null : double.parse(score));
        if (result.ok) {
          logDebug([result.extra, result.extra?.cusmark, result.extra?.cusstar]);
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
      MenuItem('收藏自定义数据', () async {
        logInfo(['收藏自定义数据请输入数据id:']);
        final id = (await readStdinLine()).trim();
        final result = await _netClient.customXStar(no: datapage.no, tp: 0, id: DbQueryField.hexstr2ObjectId(id));
        if (result.ok) {
          logDebug([result.extra, result.extra?.cusmark, result.extra?.cusstar]);
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
      MenuItem('加载自定义数据列表', () async {
        logInfo(['加载自定义数据列表请输入是否重置 (true, false):']);
        final reload = (await readStdinLine()).trim();
        final sorter = CustomXDirty()..update = -1;
        _netClient.customXLoad(comPage: datapage, reload: reload == 'true', sorter: sorter.data);
        _netClient.customXLoad(comPage: datapage, reload: reload == 'true', sorter: sorter.data);
        _netClient.customXLoad(comPage: datapage, reload: reload == 'true', sorter: sorter.data);
        _netClient.customXLoad(comPage: datapage, reload: reload == 'true', sorter: sorter.data);
        final result = await _netClient.customXLoad(comPage: datapage, reload: reload == 'true', sorter: sorter.data);
        if (result.ok) {
          int no = 0;
          for (var customx in datapage.pgcache) {
            logDebug([datapage.total, no++, '=>', customx, customx.cusmark, customx.cusstar, ComTools.formatDateTime(customx.update, yyMMdd: true, hhmmss: true)]);
          }
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
      MenuItem('加载自定义标记列表', () async {
        logInfo(['加载自定义标记列表请输入是否重置 (true, false):']);
        final reload = (await readStdinLine()).trim();
        _netClient.cusmarkLoad(comPage: datapage, reload: reload == 'true');
        _netClient.cusmarkLoad(comPage: datapage, reload: reload == 'true');
        _netClient.cusmarkLoad(comPage: datapage, reload: reload == 'true');
        _netClient.cusmarkLoad(comPage: datapage, reload: reload == 'true');
        final result = await _netClient.cusmarkLoad(comPage: datapage, reload: reload == 'true');
        if (result.ok) {
          int no = 0;
          for (var customx in datapage.pgcache) {
            logDebug([datapage.total, no++, '=>', customx, customx.cusmark, customx.cusstar, ComTools.formatDateTime(customx.update, yyMMdd: true, hhmmss: true)]);
          }
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
      MenuItem('加载自定义收藏列表', () async {
        logInfo(['加载自定义收藏列表请输入是否重置 (true, false):']);
        final reload = (await readStdinLine()).trim();
        _netClient.cusstarLoad(comPage: datapage, reload: reload == 'true');
        _netClient.cusstarLoad(comPage: datapage, reload: reload == 'true');
        _netClient.cusstarLoad(comPage: datapage, reload: reload == 'true');
        _netClient.cusstarLoad(comPage: datapage, reload: reload == 'true');
        final result = await _netClient.cusstarLoad(comPage: datapage, reload: reload == 'true');
        if (result.ok) {
          int no = 0;
          for (var customx in datapage.pgcache) {
            logDebug([datapage.total, no++, '=>', customx, customx.cusmark, customx.cusstar, ComTools.formatDateTime(customx.update, yyMMdd: true, hhmmss: true)]);
          }
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
      MenuItem('加载自定义数据详情', () async {
        logInfo(['加载自定义数据详情请输入数据id:']);
        final id = (await readStdinLine()).trim();
        final result = await _netClient.customXDetail(no: datapage.no, id: DbQueryField.hexstr2ObjectId(id), body1: true);
        if (result.ok) {
          logDebug([result.extra, result.extra?.cusmark, result.extra?.cusstar]);
          Future.delayed(delayDuration, () => customxPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => customxPage());
        }
      }),
    ]);
  }

  void adminPage() {
    renderPage('首页->管理模块', [
      MenuItem('加载用户列表', () async {
        logInfo(['加载用户列表请输入用户状态(deny):']);
        final deny = (await readStdinLine()).trim();
        logInfo(['加载用户列表可选输入关键词(no、nick、phone):']);
        final keyowrds = (await readStdinLine()).trim();
        final result = await _netClient.adminUserList(page: 0, deny: int.parse(deny), keywords: keyowrds);
        if (result.ok) {
          logDebug([result.extra!.page, result.extra!.total]);
          int no = 0;
          for (var user in result.extra!.pgcache) {
            logDebug([no++, '=>', user, user.deny]);
          }
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('加载群组列表', () async {
        logInfo(['加载群组列表请输入群组状态(deny):']);
        final deny = (await readStdinLine()).trim();
        logInfo(['加载群组列表可选输入关键词(no、nick):']);
        final keyowrds = (await readStdinLine()).trim();
        final result = await _netClient.adminTeamList(page: 0, deny: int.parse(deny), keywords: keyowrds);
        if (result.ok) {
          logDebug([result.extra!.page, result.extra!.total]);
          int no = 0;
          for (var user in result.extra!.pgcache) {
            logDebug([no++, '=>', user, user.deny]);
          }
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('加载登录列表', () async {
        final date = DateTime.now();
        final start = ComTools.getDayStartMillisByDateOffset(date);
        final end = ComTools.getDayEndMillisByDateOffset(date);
        final result = await _netClient.adminLoginList(page: 0, start: start, end: end);
        if (result.ok) {
          logDebug([result.extra!.page, result.extra!.total]);
          int no = 0;
          for (var item in result.extra!.pgcache) {
            logDebug([no++, '=>', item]);
          }
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('加载异常列表', () async {
        logInfo(['加载异常列表请输入处理状态(true,false):']);
        final finished = (await readStdinLine()).trim();
        final result = await _netClient.adminErrorList(page: 0, finished: finished == 'true');
        if (result.ok) {
          logDebug([result.extra!.page, result.extra!.total]);
          int no = 0;
          for (var item in result.extra!.pgcache) {
            logDebug([no++, '=>', item]);
          }
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('加载反馈列表', () async {
        logInfo([
          '加载反馈列表请输入反馈类型${[Constant.reportTypeUser, Constant.reportTypeTeam, Constant.reportTypeHost, Constant.reportTypeIdea, Constant.reportTypeData]}:'
        ]);
        final type = (await readStdinLine()).trim();
        logInfo([
          '加载反馈列表请输入处理状态${[Constant.reportStateWait, Constant.reportStateDeny, Constant.reportStatePass]}:'
        ]);
        final state = (await readStdinLine()).trim();
        final result = await _netClient.adminReportList(page: 0, type: int.parse(type), state: int.parse(state));
        if (result.ok) {
          logDebug([result.extra!.page, result.extra!.total]);
          int no = 0;
          for (var item in result.extra!.pgcache) {
            logDebug([no++, '=>', item]);
          }
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('加载订单列表', () async {
        logInfo([
          '加载订单列表请输入订单类型${[Constant.payTypeRechargeWechat, Constant.payTypeRechargeAlipay, Constant.payTypeRechargeApple]}:'
        ]);
        final type = (await readStdinLine()).trim();
        logInfo([
          '加载订单列表请输入处理状态${[Constant.payStateInitial, Constant.payStateFinished, Constant.payStateMaxVerify]}:'
        ]);
        final state = (await readStdinLine()).trim();
        final result = await _netClient.adminPaymentList(page: 0, types: [int.parse(type)], states: [int.parse(state)]);
        if (result.ok) {
          logDebug([result.extra!.page, result.extra!.total]);
          int no = 0;
          for (var item in result.extra!.pgcache) {
            logDebug([no++, '=>', item]);
          }
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('设置用户限制', () async {
        logInfo(['设置用户限制请输入用户id:']);
        final uid = (await readStdinLine()).trim();
        logInfo(['加载用户限制请输入用户限制(deny):']);
        final deny = (await readStdinLine()).trim();
        final result = await _netClient.adminUserDeny(uid: DbQueryField.hexstr2ObjectId(uid), deny: int.parse(deny));
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('设置群组限制', () async {
        logInfo(['设置群组限制请输入群组id:']);
        final tid = (await readStdinLine()).trim();
        logInfo(['加载群组限制请输入群组限制(deny):']);
        final deny = (await readStdinLine()).trim();
        final result = await _netClient.adminTeamDeny(tid: DbQueryField.hexstr2ObjectId(tid), deny: int.parse(deny));
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('设置异常状态', () async {
        logInfo(['设置异常状态请输入异常id:']);
        final id = (await readStdinLine()).trim();
        logInfo(['设置异常状态请输入异常状态(true,false):']);
        final finished = (await readStdinLine()).trim();
        final result = await _netClient.adminErrorState(id: DbQueryField.hexstr2ObjectId(id), finished: finished == 'true');
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('设置反馈状态', () async {
        logInfo(['设置反馈状态请输入反馈id:']);
        final id = (await readStdinLine()).trim();
        logInfo([
          '设置反馈状态请输入处理状态${[Constant.reportStateWait, Constant.reportStateDeny, Constant.reportStatePass]}:'
        ]);
        final state = (await readStdinLine()).trim();
        final result = await _netClient.adminReportState(id: DbQueryField.hexstr2ObjectId(id), state: int.parse(state));
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('设置订单状态', () async {
        logInfo(['设置订单状态请输入订单id:']);
        final id = (await readStdinLine()).trim();
        final result = await _netClient.adminPaymentState(id: DbQueryField.hexstr2ObjectId(id), substate: Constant.payStateFinished);
        if (result.ok) {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('加载消息详情', () async {
        logInfo(['加载消息详情请输入消息id:']);
        final id = (await readStdinLine()).trim();
        final result = await _netClient.adminMessageDetail(id: DbQueryField.hexstr2ObjectId(id));
        if (result.ok) {
          logDebug([result.extra]);
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('加载商户信息', () async {
        final result = await _netClient.adminBusinessDetail(cache: false);
        if (result.ok) {
          logDebug([result.extra]);
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
      MenuItem('修改商户昵称', () async {
        logInfo(['修改商户昵称请输入新昵称:']);
        final nick = (await readStdinLine()).trim();
        final dirty = BusinessDirty()..nick = nick;
        final result = await _netClient.adminBusinessUpdate(fields: dirty.data);
        if (result.ok) {
          logDebug([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        } else {
          logWarn([result.desc]);
          Future.delayed(delayDuration, () => adminPage());
        }
      }),
    ]);
  }

  /* **************** 工具函数 **************** */

  ///渲染页面
  void renderPage(String title, List<MenuItem> menuItems) async {
    //打印标题
    if (_netClient.user.id == DbQueryField.emptyObjectId) {
      logInfo(['---------------- $title <游客> ----------------\n']);
    } else {
      logInfo(['---------------- $title <${ComTools.formatUserNick(_netClient.user)}> ----------------\n']);
    }
    if (_pageRouteStack.isNotEmpty) {
      logInfo(['r、刷新页面   b、返回上级   q、退出程序\n']);
    } else {
      logInfo(['r、刷新页面   q、退出程序\n']);
    }
    //打印菜单
    final cmdMap = <String, MenuItem>{};
    for (var i = 0; i < menuItems.length; i++) {
      logInfo(['$i、${menuItems[i].title}']);
      cmdMap['$i'] = menuItems[i];
    }
    print('');
    //等待输入
    logInfo(['请输入命令选项:']);
    final key = (await readStdinLine()).trim();
    //处理输入
    if (key == 'r') {
      clearConsole();
      renderPage(title, menuItems);
    } else if (key == 'b') {
      if (_pageRouteStack.isNotEmpty) {
        _pageRouteStack.removeLast()();
      } else {
        logDebug(['程序已完成']);
        _netClient.release();
        Future.delayed(delayDuration, () => exit(0));
      }
    } else if (key == 'q') {
      logDebug(['程序已完成']);
      _netClient.release();
      Future.delayed(delayDuration, () => exit(0));
    } else {
      if (cmdMap.containsKey(key)) {
        cmdMap[key]!.execute();
      } else {
        logWarn(['没有这个选项!']);
        Future.delayed(delayDuration, () => renderPage(title, menuItems));
      }
    }
  }

  ///从[stdin]中异步读取数据，避免阻塞进程
  Future<String> readStdinLine() async {
    final lineCompleter = Completer<String>();
    final listener = _stdinLStream.listen((line) {
      if (!lineCompleter.isCompleted) {
        lineCompleter.complete(line);
      }
    });
    return lineCompleter.future.then((line) {
      listener.cancel();
      return line;
    });
  }

  ///清空整个控制台，将光标移动到0;0
  void clearConsole() => print("\x1B[2J\x1B[0;0H");

  ///常量读取
  String readConstMap(int key) => Constant.constMap['zh']![key]!;

  ///Map对象转换为xml字符串
  String objMapToXmlStr(Map<String, dynamic> data) => '<xml>\n${data.keys.toList().map((key) => '<$key>${data[key]}</$key>').toList().join('\n')}\n</xml>';
}

class MenuItem {
  ///菜单项名成
  final String title;

  ///菜单项执行函数
  final Function execute;

  MenuItem(this.title, this.execute);
}
