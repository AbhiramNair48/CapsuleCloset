import 'package:mysql_client/mysql_client.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  var env = DotEnv(includePlatformEnvironment: true);
  if (File('backend/.env').existsSync()) {
    env.load(['backend/.env']);
    print('Loaded environment from backend/.env');
  } else if (File('.env').existsSync()) {
    env.load(['.env']);
    print('Loaded environment from .env');
  } else {
    print('Warning: No .env file found. Using defaults.');
  }
  
  final dbIp = "127.0.0.1";
  final dbPort = 3306;
  // Create a connection settings object
  final pool = MySQLConnectionPool(
    host: dbIp,
    port: dbPort,
    userName: "root",
    password: env['DB_PASSWORD'] ?? "root",
    databaseName: "capsule_closet",
    maxConnections: 10,
  );

  final server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server running on http://${server.address.address}:${server.port}/');

  await for (HttpRequest request in server) {
    // Add CORS headers
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.close();
      continue;
    }

    if (request.method == 'POST' && request.uri.path == '/signup') {
      try {
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content) as Map<String, dynamic>;
        
        final username = data['username'];
        final email = data['email'];
        final password = data['password'];

        if (username == null || email == null || password == null) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Missing required fields')
            ..close();
          continue;
        }

        final passwordHash = sha256.convert(utf8.encode(password)).toString();

        // Signup User
        await pool.execute(
          'INSERT INTO users (username, email, password_hash) VALUES (:username, :email, :password_hash)',
          {"username": username, "email": email, "password_hash": passwordHash},
        );

        request.response
          ..statusCode = HttpStatus.ok
          ..write('User registered successfully')
          ..close();
      } catch (e) {
        print('Error during signup: $e');
        // Check for duplicate entry
        if (e.toString().contains('Duplicate entry')) {
           request.response
            ..statusCode = HttpStatus.conflict
            ..write('Username or email already exists')
            ..close();
        } else {
          request.response
            ..statusCode = HttpStatus.internalServerError
            ..write('Error registering user: $e')
            ..close();
        }
      }
    } else if (request.method == 'POST' && request.uri.path == '/login') {
       // TODO: Implement login
       request.response
         ..statusCode = HttpStatus.notImplemented
         ..close();
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found')
        ..close();
    }
  }
}