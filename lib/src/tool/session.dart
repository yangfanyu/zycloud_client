import 'package:shelf_easy/shelf_deps.dart';
import 'package:shelf_easy/shelf_easy.dart';

import '../model/all.dart';
import 'comtools.dart';

///
///聊天会话
///
class Session {
  ///好友关系
  final UserShip? _usership;

  ///用户信息
  final User? _user;

  ///用户关系
  final TeamShip? _teamship;

  ///群组信息
  final Team? _team;

  Session._({UserShip? usership, User? user, TeamShip? teamship, Team? team})
      : _usership = usership,
        _user = user,
        _teamship = teamship,
        _team = team;

  factory Session.fromUserShip(UserShip usership, User user) => Session._(usership: usership, user: user);

  factory Session.fromTeamShip(TeamShip teamship, Team team) => Session._(teamship: teamship, team: team);

  UserShip get usership => _usership!;

  User get user => _user!;

  TeamShip get teamship => _teamship!;

  Team get team => _team!;

  /* **************** 关系字段 **************** */

  ///唯一id
  ObjectId get id => _usership?.id ?? _teamship?.id ?? DbQueryField.createObjectId();

  ///商户id
  ObjectId get bsid => _usership?.bsid ?? _teamship?.bsid ?? DbQueryField.createObjectId();

  ///创建时间
  int get time => _usership?.time ?? _teamship?.time ?? 0;

  ///自定义数据
  DbJsonWraper get extra => _usership?.extra ?? _teamship?.extra ?? DbJsonWraper();

  ///用户id
  ObjectId get uid => _usership?.uid ?? _teamship?.uid ?? DbQueryField.createObjectId();

  ///会话id
  ObjectId get sid => _usership?.sid ?? _teamship?.sid ?? DbQueryField.createObjectId();

  ///关联目标id（用户id或群组id）
  ObjectId get rid => _usership?.rid ?? _teamship?.rid ?? DbQueryField.createObjectId();

  ///关系来源id（用户id或群组id）
  ObjectId get fid => _usership?.fid ?? _teamship?.fid ?? DbQueryField.createObjectId();

  ///关系来源
  int get from => _usership?.from ?? _teamship?.from ?? Constant.empty;

  ///关系状态
  int get state => _usership?.state ?? _teamship?.state ?? Constant.empty;

  ///申请描述
  String get apply => _usership?.apply ?? _teamship?.apply ?? '';

  ///好友备注名 或 群昵称
  String get alias => _usership?.alias ?? _teamship?.alias ?? '';

  ///是否处于对话状态
  bool get dialog => _usership?.dialog ?? _teamship?.dialog ?? false;

  ///消息是否显示通知
  bool get notice => _usership?.notice ?? _teamship?.notice ?? false;

  ///是否置顶聊天
  bool get top => _usership?.top ?? _teamship?.top ?? false;

  ///未读消息数量
  int get unread => _usership?.unread ?? _teamship?.unread ?? 0;

  ///最近消息缩写
  String get recent => _usership?.recent ?? _teamship?.recent ?? '';

  ///最近消息时间
  int get update => _usership?.update ?? _teamship?.update ?? 0;

  ///对话激活时间
  int get active => _usership?.active ?? _teamship?.active ?? 0;

  /* **************** 消息字段 **************** */

  ///消息加载序号
  int get msgasync => _usership?.msgasync ?? _teamship?.msgasync ?? 0;

  ///消息缓存列表
  List<Message> get msgcache => _usership?.msgcache ?? _teamship?.msgcache ?? [];

  ///消息加载完毕
  bool get msgloaded => _usership?.msgloaded ?? _teamship?.msgloaded ?? false;

  ///消息发送来源
  int get msgfrom {
    if (_usership != null) return Constant.msgFromUser;
    if (_teamship != null) return Constant.msgFromTeam;
    return Constant.empty;
  }

  ///设置加载序号
  set msgasync(int value) {
    if (_usership != null) _usership?.msgasync = value;
    if (_teamship != null) _teamship?.msgasync = value;
  }

  ///设置加载完毕
  set msgloaded(bool value) {
    if (_usership != null) _usership?.msgloaded = value;
    if (_teamship != null) _teamship?.msgloaded = value;
  }

  ///重置加载状态
  void resetMsgStates() {
    msgasync = 0;
    msgcache.clear();
    msgloaded = false;
  }

  ///消息聊天标题
  String getChatTitle({required ObjectId self}) {
    if (_usership != null && _user != null) {
      return ComTools.formatUserShipNick(_usership!, _user!);
    }
    if (_teamship != null && _team != null) {
      if (ComTools.isTeamShipFromSystem(_teamship!, team: team, self: self)) {
        return ComTools.formatTeamNick(_team!);
      } else {
        return '${ComTools.formatCNcharacters(ComTools.formatTeamNick(_team!))} (${_team!.member})';
      }
    }

    return sid.toHexString();
  }
}
