import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:capsule_closet_app/database/database_init.dart';

void main() async {
  await Database.initSchema(); // Initialize tables

  final router = Router();

  // Get Users Request
  router.get('/users', (Request request) async {
    final conn = await Database.connect();
    final results = await conn.query('SELECT * FROM users');
    final users = results.map((row) => {
      'id': row['id'],
      'username': row['username'],
    }).toList();
    await conn.close();
    return Response.ok(jsonEncode(users), headers: {'Content-Type': 'application/json'});
  });

  // Create new User Request
  router.post('/users', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final username = payload['username'];
    final passwordHash = payload['password_hash'];

    final conn = await Database.connect();
    await conn.query(
      'INSERT INTO users (username, password_hash) VALUES (?, ?)',
      [username, passwordHash]
    );
    await conn.close();
    return Response.ok(jsonEncode({'status': 'success'}), headers: {'Content-Type': 'application/json'});
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}