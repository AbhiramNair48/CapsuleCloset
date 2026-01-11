// ignore_for_file: avoid_print

import 'package:capsule_closet_backend/api_handlers.dart';
import 'package:mysql_client/mysql_client.dart';
import 'dart:io';
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
  
  const dbIp = "127.0.0.1";
  const dbPort = 3306;
  // Create a connection settings object
  final pool = MySQLConnectionPool(
    host: dbIp,
    port: dbPort,
    userName: "root",
    password: env['DB_PASSWORD'] ?? "root",
    databaseName: "capsule_closet",
    maxConnections: 10,
  );

  final apiHandlers = ApiHandlers(pool);

  final server = await HttpServer.bind(
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server running on http://${server.address.address}:${server.port}/');

  await for (HttpRequest request in server) {
    try {
      // Add CORS headers
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.add('Access-Control-Allow-Methods', 'POST, GET, OPTIONS, PATCH, DELETE');
      request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

      if (request.method == 'OPTIONS') {
        request.response.close();
        continue;
      }

      print('Request: ${request.method} ${request.uri.path}');

      if (request.method == 'POST' && request.uri.path == '/signup') {
        await apiHandlers.handleSignup(request);
      } else if (request.method == 'POST' && request.uri.path == '/login') {
        await apiHandlers.handleLogin(request);
      } else if (request.method == 'GET' && request.uri.path == '/users/search') {
        await apiHandlers.handleSearchUsers(request);
      } else if (request.method == 'POST' && request.uri.path == '/friends/request') {
        await apiHandlers.handleSendFriendRequest(request);
      } else if (request.method == 'PATCH' && request.uri.path.startsWith('/friends/request/')) {
        await apiHandlers.handleUpdateFriendRequest(request);
      } else if (request.method == 'GET' && request.uri.path == '/friends/pending') {
        await apiHandlers.handleGetPendingFriendRequests(request);
      } else if (request.method == 'GET' && request.uri.path == '/friends') {
        await apiHandlers.handleGetFriends(request);
      } else if (request.method == 'POST' && request.uri.path == '/closet/upload') {
        await apiHandlers.handleClosetUpload(request);
      } else if (request.method == 'PATCH' && request.uri.path.contains('/closet/') && request.uri.path.endsWith('/public')) {
        await apiHandlers.handleClosetUpdatePublic(request);
      } else if (request.method == 'PATCH' && request.uri.path.contains('/closet/') && !request.uri.path.endsWith('/public')) {
        await apiHandlers.handleClosetUpdateDetails(request);
      } else if (request.method == 'DELETE' && request.uri.path.startsWith('/closet/')) {
        await apiHandlers.handleClosetDelete(request);
      } else if (request.method == 'GET' && request.uri.path == '/closet') {
        await apiHandlers.handleGetCloset(request);
      } else if (request.method == 'GET' && request.uri.path == '/outfits') {
        await apiHandlers.handleGetOutfits(request);
      } else if (request.method == 'GET' && request.uri.path.startsWith('/images/')) {
        await apiHandlers.handleServeImage(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found')
          ..close();
      }
    } catch (e) {
      print('Unhandled exception: $e');
      if (request.response.statusCode == HttpStatus.ok) {
         request.response.statusCode = HttpStatus.internalServerError;
      }
      request.response.close();
    }
  }
}