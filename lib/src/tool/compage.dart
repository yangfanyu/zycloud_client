import '../model/all.dart';

///
///通用数据分页
///
class ComPage<T> {
  ///数据排除重复的窗口数量，不建议过大。场景：按照时间逆序排列时，有新数据添加，则加载会返回重复的数据项。
  static int repeatWindowSize = 0;

  ///集合序号（如查询CustomX时的集合序号）
  final int no;

  ///当前页码
  int page;

  ///数据总数
  int total;

  ///跳过数量
  int pgskip = 0;

  ///加载序号
  int pgasync = 0;

  ///缓存列表
  final List<T> pgcache = [];

  ///加载完毕
  bool pgloaded = false;

  ComPage({this.no = 0, this.page = 0, this.total = 0});

  ///排重插入到缓存列表末尾
  bool append(T item, bool Function(T a, T b) isRepeat) {
    for (int i = pgcache.length - 1, n = 0; i >= 0 && n < repeatWindowSize; i--, n++) {
      if (isRepeat(pgcache[i], item)) return false;
    }
    pgcache.add(item);
    return true;
  }

  ///清空缓存并重置加载状态
  void resetPgStates() {
    page = 0;
    total = 0;
    pgskip = 0;
    pgasync = 0;
    pgcache.clear();
    pgloaded = false;
  }

  static bool copyCustomXPage(ComPage<CustomX> fromPage, ComPage<CustomX> toPage) {
    if (toPage.no != fromPage.no) return false;
    toPage.page = fromPage.page;
    toPage.total = fromPage.total;
    toPage.pgskip = fromPage.pgskip;
    toPage.pgasync = fromPage.pgasync;
    toPage.pgcache.clear();
    toPage.pgcache.addAll(fromPage.pgcache);
    toPage.pgloaded = fromPage.pgloaded;
    return true;
  }

  static ComPage<Business> newBusinessPage({int no = 0, int page = 0, int total = 0}) => ComPage<Business>(no: no, page: page, total: total);

  static ComPage<Constant> newConstantPage({int no = 0, int page = 0, int total = 0}) => ComPage<Constant>(no: no, page: page, total: total);

  static ComPage<CusincX> newCusincXPage({int no = 0, int page = 0, int total = 0}) => ComPage<CusincX>(no: no, page: page, total: total);

  static ComPage<Cusmark> newCusmarkPage({int no = 0, int page = 0, int total = 0}) => ComPage<Cusmark>(no: no, page: page, total: total);

  static ComPage<Cusstar> newCusstarPage({int no = 0, int page = 0, int total = 0}) => ComPage<Cusstar>(no: no, page: page, total: total);

  static ComPage<CustomX> newCustomXPage({int no = 0, int page = 0, int total = 0}) => ComPage<CustomX>(no: no, page: page, total: total);

  static ComPage<Location> newLocationPage({int no = 0, int page = 0, int total = 0}) => ComPage<Location>(no: no, page: page, total: total);

  static ComPage<LogError> newLogErrorPage({int no = 0, int page = 0, int total = 0}) => ComPage<LogError>(no: no, page: page, total: total);

  static ComPage<LogLogin> newLogLoginPage({int no = 0, int page = 0, int total = 0}) => ComPage<LogLogin>(no: no, page: page, total: total);

  static ComPage<LogReport> newLogReportPage({int no = 0, int page = 0, int total = 0}) => ComPage<LogReport>(no: no, page: page, total: total);

  static ComPage<Message> newMessagePage({int no = 0, int page = 0, int total = 0}) => ComPage<Message>(no: no, page: page, total: total);

  static ComPage<Metadata> newMetadataPage({int no = 0, int page = 0, int total = 0}) => ComPage<Metadata>(no: no, page: page, total: total);

  static ComPage<PayGoods> newPayGoodsPage({int no = 0, int page = 0, int total = 0}) => ComPage<PayGoods>(no: no, page: page, total: total);

  static ComPage<Payment> newPaymentPage({int no = 0, int page = 0, int total = 0}) => ComPage<Payment>(no: no, page: page, total: total);

  static ComPage<Randcode> newRandcodePage({int no = 0, int page = 0, int total = 0}) => ComPage<Randcode>(no: no, page: page, total: total);

  static ComPage<Team> newTeamPage({int no = 0, int page = 0, int total = 0}) => ComPage<Team>(no: no, page: page, total: total);

  static ComPage<TeamShip> newTeamShipPage({int no = 0, int page = 0, int total = 0}) => ComPage<TeamShip>(no: no, page: page, total: total);

  static ComPage<User> newUserPage({int no = 0, int page = 0, int total = 0}) => ComPage<User>(no: no, page: page, total: total);

  static ComPage<UserShip> newUserShipPage({int no = 0, int page = 0, int total = 0}) => ComPage<UserShip>(no: no, page: page, total: total);

  static ComPage<Validator> newValidatorPage({int no = 0, int page = 0, int total = 0}) => ComPage<Validator>(no: no, page: page, total: total);
}
