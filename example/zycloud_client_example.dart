import 'package:zycloud_client/src/client/cmdclient.dart';

void main() {
  CmdClient(
    host: '192.168.2.6',
    port: 8080,
    bsid: '61da2b54285650ba5034ada4',
    secret: '3beea6bf-7e88-694e-7754-aa4d38bf7595',
  ).loginPage();
}
