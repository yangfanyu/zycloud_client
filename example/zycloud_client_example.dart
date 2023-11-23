import 'zycloud_client_console.dart';

void main() {
  ZyCloudClientConsole(
    host: '<zycloud_server_host>',
    port: 6789,
    bsid: '61da2b54285650ba5034ada4',
    secret: '3beea6bf-7e88-694e-7754-aa4d38bf7595',
  ).loginPage();
}
