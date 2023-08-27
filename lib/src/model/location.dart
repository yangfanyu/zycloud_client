import 'dart:convert';

import 'package:shelf_easy/shelf_easy.dart';

///
///位置信息
///
class Location extends DbBaseModel {
  ///纬度
  double latitude;

  ///经度
  double longitude;

  ///精确度
  double accuracy;

  ///海拔
  double altitude;

  ///角度
  double bearing;

  ///速度
  double speed;

  ///国家
  String country;

  ///省
  String province;

  ///城市
  String city;

  ///城镇（区）
  String district;

  ///街道
  String street;

  ///门牌号
  String streetNumber;

  ///城市编码
  String cityCode;

  ///区域编码
  String adCode;

  ///地址信息
  String address;

  ///位置语义
  String description;

  ///作为位置消息时的截图地址
  String snapshotUrl;

  ///作为位置消息时的缩放比例
  double zoomLevel;

  ///作为POI搜索结果的距离
  double distance;

  Location({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? bearing,
    double? speed,
    String? country,
    String? province,
    String? city,
    String? district,
    String? street,
    String? streetNumber,
    String? cityCode,
    String? adCode,
    String? address,
    String? description,
    String? snapshotUrl,
    double? zoomLevel,
    double? distance,
  })  : latitude = latitude ?? 39.909187,
        longitude = longitude ?? 116.397451,
        accuracy = accuracy ?? 0,
        altitude = altitude ?? 0,
        bearing = bearing ?? 0,
        speed = speed ?? 0,
        country = country ?? '',
        province = province ?? '',
        city = city ?? '',
        district = district ?? '',
        street = street ?? '',
        streetNumber = streetNumber ?? '',
        cityCode = cityCode ?? '',
        adCode = adCode ?? '',
        address = address ?? '',
        description = description ?? '',
        snapshotUrl = snapshotUrl ?? '',
        zoomLevel = zoomLevel ?? 16.0,
        distance = distance ?? 0;

  factory Location.fromString(String data) {
    return Location.fromJson(jsonDecode(data.substring(data.indexOf('(') + 1, data.lastIndexOf(')'))));
  }

  factory Location.fromJson(Map<String, dynamic> map) {
    return Location(
      latitude: DbQueryField.tryParseDouble(map['latitude']),
      longitude: DbQueryField.tryParseDouble(map['longitude']),
      accuracy: DbQueryField.tryParseDouble(map['accuracy']),
      altitude: DbQueryField.tryParseDouble(map['altitude']),
      bearing: DbQueryField.tryParseDouble(map['bearing']),
      speed: DbQueryField.tryParseDouble(map['speed']),
      country: DbQueryField.tryParseString(map['country']),
      province: DbQueryField.tryParseString(map['province']),
      city: DbQueryField.tryParseString(map['city']),
      district: DbQueryField.tryParseString(map['district']),
      street: DbQueryField.tryParseString(map['street']),
      streetNumber: DbQueryField.tryParseString(map['streetNumber']),
      cityCode: DbQueryField.tryParseString(map['cityCode']),
      adCode: DbQueryField.tryParseString(map['adCode']),
      address: DbQueryField.tryParseString(map['address']),
      description: DbQueryField.tryParseString(map['description']),
      snapshotUrl: DbQueryField.tryParseString(map['snapshotUrl']),
      zoomLevel: DbQueryField.tryParseDouble(map['zoomLevel']),
      distance: DbQueryField.tryParseDouble(map['distance']),
    );
  }

  @override
  String toString() {
    return 'Location(${jsonEncode(toJson())})';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'latitude': DbQueryField.toBaseType(latitude),
      'longitude': DbQueryField.toBaseType(longitude),
      'accuracy': DbQueryField.toBaseType(accuracy),
      'altitude': DbQueryField.toBaseType(altitude),
      'bearing': DbQueryField.toBaseType(bearing),
      'speed': DbQueryField.toBaseType(speed),
      'country': DbQueryField.toBaseType(country),
      'province': DbQueryField.toBaseType(province),
      'city': DbQueryField.toBaseType(city),
      'district': DbQueryField.toBaseType(district),
      'street': DbQueryField.toBaseType(street),
      'streetNumber': DbQueryField.toBaseType(streetNumber),
      'cityCode': DbQueryField.toBaseType(cityCode),
      'adCode': DbQueryField.toBaseType(adCode),
      'address': DbQueryField.toBaseType(address),
      'description': DbQueryField.toBaseType(description),
      'snapshotUrl': DbQueryField.toBaseType(snapshotUrl),
      'zoomLevel': DbQueryField.toBaseType(zoomLevel),
      'distance': DbQueryField.toBaseType(distance),
    };
  }

  @override
  Map<String, dynamic> toKValues() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'bearing': bearing,
      'speed': speed,
      'country': country,
      'province': province,
      'city': city,
      'district': district,
      'street': street,
      'streetNumber': streetNumber,
      'cityCode': cityCode,
      'adCode': adCode,
      'address': address,
      'description': description,
      'snapshotUrl': snapshotUrl,
      'zoomLevel': zoomLevel,
      'distance': distance,
    };
  }

  @override
  void updateByJson(Map<String, dynamic> map, {Location? parser}) {
    parser = parser ?? Location.fromJson(map);
    if (map.containsKey('latitude')) latitude = parser.latitude;
    if (map.containsKey('longitude')) longitude = parser.longitude;
    if (map.containsKey('accuracy')) accuracy = parser.accuracy;
    if (map.containsKey('altitude')) altitude = parser.altitude;
    if (map.containsKey('bearing')) bearing = parser.bearing;
    if (map.containsKey('speed')) speed = parser.speed;
    if (map.containsKey('country')) country = parser.country;
    if (map.containsKey('province')) province = parser.province;
    if (map.containsKey('city')) city = parser.city;
    if (map.containsKey('district')) district = parser.district;
    if (map.containsKey('street')) street = parser.street;
    if (map.containsKey('streetNumber')) streetNumber = parser.streetNumber;
    if (map.containsKey('cityCode')) cityCode = parser.cityCode;
    if (map.containsKey('adCode')) adCode = parser.adCode;
    if (map.containsKey('address')) address = parser.address;
    if (map.containsKey('description')) description = parser.description;
    if (map.containsKey('snapshotUrl')) snapshotUrl = parser.snapshotUrl;
    if (map.containsKey('zoomLevel')) zoomLevel = parser.zoomLevel;
    if (map.containsKey('distance')) distance = parser.distance;
  }

  @override
  void updateByKValues(Map<String, dynamic> map) {
    if (map.containsKey('latitude')) latitude = map['latitude'];
    if (map.containsKey('longitude')) longitude = map['longitude'];
    if (map.containsKey('accuracy')) accuracy = map['accuracy'];
    if (map.containsKey('altitude')) altitude = map['altitude'];
    if (map.containsKey('bearing')) bearing = map['bearing'];
    if (map.containsKey('speed')) speed = map['speed'];
    if (map.containsKey('country')) country = map['country'];
    if (map.containsKey('province')) province = map['province'];
    if (map.containsKey('city')) city = map['city'];
    if (map.containsKey('district')) district = map['district'];
    if (map.containsKey('street')) street = map['street'];
    if (map.containsKey('streetNumber')) streetNumber = map['streetNumber'];
    if (map.containsKey('cityCode')) cityCode = map['cityCode'];
    if (map.containsKey('adCode')) adCode = map['adCode'];
    if (map.containsKey('address')) address = map['address'];
    if (map.containsKey('description')) description = map['description'];
    if (map.containsKey('snapshotUrl')) snapshotUrl = map['snapshotUrl'];
    if (map.containsKey('zoomLevel')) zoomLevel = map['zoomLevel'];
    if (map.containsKey('distance')) distance = map['distance'];
  }
}

class LocationDirty {
  final Map<String, dynamic> data = {};

  ///纬度
  set latitude(double value) => data['latitude'] = DbQueryField.toBaseType(value);

  ///经度
  set longitude(double value) => data['longitude'] = DbQueryField.toBaseType(value);

  ///精确度
  set accuracy(double value) => data['accuracy'] = DbQueryField.toBaseType(value);

  ///海拔
  set altitude(double value) => data['altitude'] = DbQueryField.toBaseType(value);

  ///角度
  set bearing(double value) => data['bearing'] = DbQueryField.toBaseType(value);

  ///速度
  set speed(double value) => data['speed'] = DbQueryField.toBaseType(value);

  ///国家
  set country(String value) => data['country'] = DbQueryField.toBaseType(value);

  ///省
  set province(String value) => data['province'] = DbQueryField.toBaseType(value);

  ///城市
  set city(String value) => data['city'] = DbQueryField.toBaseType(value);

  ///城镇（区）
  set district(String value) => data['district'] = DbQueryField.toBaseType(value);

  ///街道
  set street(String value) => data['street'] = DbQueryField.toBaseType(value);

  ///门牌号
  set streetNumber(String value) => data['streetNumber'] = DbQueryField.toBaseType(value);

  ///城市编码
  set cityCode(String value) => data['cityCode'] = DbQueryField.toBaseType(value);

  ///区域编码
  set adCode(String value) => data['adCode'] = DbQueryField.toBaseType(value);

  ///地址信息
  set address(String value) => data['address'] = DbQueryField.toBaseType(value);

  ///位置语义
  set description(String value) => data['description'] = DbQueryField.toBaseType(value);

  ///作为位置消息时的截图地址
  set snapshotUrl(String value) => data['snapshotUrl'] = DbQueryField.toBaseType(value);

  ///作为位置消息时的缩放比例
  set zoomLevel(double value) => data['zoomLevel'] = DbQueryField.toBaseType(value);

  ///作为POI搜索结果的距离
  set distance(double value) => data['distance'] = DbQueryField.toBaseType(value);
}
