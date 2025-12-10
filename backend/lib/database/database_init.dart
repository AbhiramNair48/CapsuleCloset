import 'package:mysql_client/mysql_client.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'dart:io';



// TODO: change db password to .env variable




Future<void> main() async {

  // final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));

  // if (response.statusCode == 200) {
  //   print('Your public IP: ${response.body}');
  // } else {
  //   print('Failed to get public IP');
  // }


  final ip = "104.190.141.175"; 
  final db_port = 3306;
  // Create a connection settings object
  final conn = MySQLConnectionPool(
    host: ip,
    port: db_port,
    userName: "root",
    password: "root",
    databaseName: "capsule_closet", 
    maxConnections:  10
  );

    final server = await HttpServer.bind(
    InternetAddress.anyIPv4, // NOTE: change to InternetAddress.loopvackIPv4 or ur ip address
    8080,
  );

  print('Server running on http://${server.address.address}:${server.port}/');
  await for (HttpRequest request in server) {
    request.response
      ..headers.contentType = ContentType.text
      ..write('Test from Dart HTTP server')
      ..close();
  }

}
