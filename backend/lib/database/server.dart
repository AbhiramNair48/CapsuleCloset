import 'package:mysql_client/mysql_client.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';


//TODO: move response closes to the end 
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
        final gender = data['gender'];
        final favoriteStyle = data['favorite_style'];

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
          'INSERT INTO users (username, email, password_hash, gender, favorite_style) VALUES (:username, :email, :password_hash, :gender, :favorite_style)',
          {
            "username": username,
            "email": email,
            "password_hash": passwordHash,
            "gender": gender,
            "favorite_style": favoriteStyle
          },
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
    } else if (request.method == 'GET' && request.uri.path == '/users/search') {
      final query = request.uri.queryParameters['q'];
      if (query == null || query.isEmpty) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing query parameter q')
          ..close();
        continue;
      }

      try {
        final results = await pool.execute(
          'SELECT id, username, favorite_style FROM users WHERE username LIKE :query',
          {"query": "%$query%"},
        );

        final users = results.rows.map((row) => {
          'id': row.colByName('id'),
          'username': row.colByName('username'),
          'favorite_style': row.colByName('favorite_style'),
        }).toList();

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(users))
          ..close();
      } catch (e) {
        print('Error searching users: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error searching users')
          ..close();
      }
    } else if (request.method == 'POST' && request.uri.path == '/friends/request') {
      try {
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content) as Map<String, dynamic>;
        
        final userEmail = data['user_email'];
        final friendId = data['friend_id'];

        if (userEmail == null || friendId == null) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Missing required fields')
            ..close();
          continue;
        }

        // Get user ID from email
        final userResult = await pool.execute(
          'SELECT id FROM users WHERE email = :email',
          {"email": userEmail},
        );

        if (userResult.rows.isEmpty) {
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('User not found')
            ..close();
          continue;
        }

        final userId = userResult.rows.first.colByName('id');

        if (userId == friendId) {
             request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Cannot add yourself as a friend')
            ..close();
            continue;
        }

        // Insert friendship
        await pool.execute(
          'INSERT INTO friendships (user_id, friend_id, status) VALUES (:user_id, :friend_id, \'pending\')',
          {"user_id": userId, "friend_id": friendId},
        );

        request.response
          ..statusCode = HttpStatus.ok
          ..write('Friend request sent')
          ..close();
      } catch (e) {
        print('Error sending friend request: $e');
         if (e.toString().contains('Duplicate entry')) {
           request.response
            ..statusCode = HttpStatus.conflict
            ..write('Friend request already sent or exists')
            ..close();
        } else {
          request.response
            ..statusCode = HttpStatus.internalServerError
            ..write('Error sending friend request: $e')
            ..close();
        }
      }

      // login
    } else if (request.method == 'POST' && request.uri.path == '/login') {
      try {
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content) as Map<String, dynamic>;

        final email = data['email'];
        final password = data['password'];

        if (email == null || password == null) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Missing email or password')
            ..close();
          continue;
        }

        // Attempt Login
        final result = await pool.execute(
          'SELECT id, email, username, password_hash FROM users WHERE email = :email LIMIT 1',
          {"email": email},
        );

        if (result.rows.isEmpty) {
          request.response
            ..statusCode = HttpStatus.unauthorized
            ..write('Invalid email or password')
            ..close();
          continue;
        }

        final row = result.rows.first;
        final storedHash = row.colByName('password_hash');
        final passwordHash = sha256.convert(utf8.encode(password)).toString();

        if (passwordHash == storedHash) {
          final user = {
            'id': row.colByName('id'),
            'username': row.colByName('username'),
            'email': row.colByName('email'),
          };
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'message': 'Successful login!', 'user': user}))
            ..close();
        } else {
          request.response
            ..statusCode = HttpStatus.unauthorized
            ..write('Invalid email or password')
            ..close();
        }
      } catch (e) {
        print('Error during login: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error Logging In: $e')
          ..close();
      }
    } else if (request.method == 'GET' && request.uri.path == '/closet') {
      final userId = request.uri.queryParameters['user_id'];
      if (userId == null) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing user_id query parameter')
          ..close();
        continue;
      }

      try {
        final results = await pool.execute(
          'SELECT id, img_link, type, material, color, style, description FROM closet WHERE user_id = :user_id',
          {'user_id': userId},
        );

        final items = results.rows.map((row) {
          final imgLink = row.colByName('img_link');
          final imagePath = (imgLink != null) ? 'assets/images/clothes/$imgLink' : '';
          
          return {
            'id': row.colByName('id').toString(),
            'imagePath': imagePath,
            'type': row.colByName('type'),
            'material': row.colByName('material'),
            'color': row.colByName('color'),
            'style': row.colByName('style'),
            'description': row.colByName('description'),
          };
        }).toList();

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(items))
          ..close();
      } catch (e) {
        print('Error fetching closet items: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error fetching closet items: $e')
          ..close();
      }
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found')
        ..close();
    }
  }
}
