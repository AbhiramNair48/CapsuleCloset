import 'package:mysql_client/mysql_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

// TODO: change db password to .env variable, hashing password for user signup
Future<void> main() async {

  // final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));

  // if (response.statusCode == 200) {
  //   print('Your public IP: ${response.body}');
  // } else {
  //   print('Failed to get public IP');
  // }

  final db_ip = "127.0.0.1"; 
  final db_port = 3306;
  // Create a connection settings object
  final pool = MySQLConnectionPool(
    host: db_ip,
    port: db_port,
    userName: "root",
    password: "root",
    databaseName: "capsule_closet", 
    maxConnections:  10
  );

    final server = await HttpServer.bind(
    InternetAddress.anyIPv4, // NOTE: change to InternetAddress.anyIPv4 or ur ip address
    8080,
  );

  print('Server running on http://${server.address.address}:${server.port}/');
  await for (HttpRequest request in server) {
    if (request.method == 'POST' && request.uri.path == '/signup') {
      var username = request.uri.queryParameters['username'];
      var password = request.uri.queryParameters['password'];

      // Signup User
      await pool.execute('INSERT INTO users (username, password_hash) VALUES(:username, :password_hash)',
      {"username": username, "password": password});
        
     
     }
    if (request.method == 'POST' && request.uri.path == '/login') {
     
     
     }
    // request.response
    //   ..headers.contentType = ContentType.text
    //   ..write('Hello')
    //   ..close();
  }

}


