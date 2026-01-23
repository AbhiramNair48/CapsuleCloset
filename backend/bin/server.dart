// ignore_for_file: avoid_print

import 'package:capsule_closet_backend/api_handlers.dart';
import 'package:mysql_client/mysql_client.dart';
import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

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
  final app = Router();

  // CORS Middleware
  Middleware corsHeaders() {
    return (innerHandler) {
      return (request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PATCH, DELETE',
            'Access-Control-Allow-Headers': 'Content-Type',
          });
        }
        final response = await innerHandler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PATCH, DELETE',
          'Access-Control-Allow-Headers': 'Content-Type',
        });
      };
    };
  }

  Middleware logRequests() {
    return (innerHandler) {
      return (request) async {
        print('Request: ${request.method} ${request.url}');
        return innerHandler(request);
      };
    };
  }

  // Routes
  app.post('/signup', (Request request) => _handleRequest(request, apiHandlers.handleSignup));
  app.post('/login', (Request request) => _handleRequest(request, apiHandlers.handleLogin));
  app.get('/users/search', (Request request) => _handleRequest(request, apiHandlers.handleSearchUsers));
  app.post('/friends/request', (Request request) => _handleRequest(request, apiHandlers.handleSendFriendRequest));
  app.patch('/friends/request/<friendshipId>', (Request request) => _handleRequest(request, apiHandlers.handleUpdateFriendRequest));
  app.get('/friends/pending', (Request request) => _handleRequest(request, apiHandlers.handleGetPendingFriendRequests));
  app.get('/friends', (Request request) => _handleRequest(request, apiHandlers.handleGetFriends));
  app.post('/closet/upload', (Request request) => _handleRequest(request, apiHandlers.handleClosetUpload));
  app.patch('/closet/<itemId>/public', (Request request) => _handleRequest(request, apiHandlers.handleClosetUpdatePublic));
  app.patch('/closet/<itemId>', (Request request) => _handleRequest(request, apiHandlers.handleClosetUpdateDetails));
  app.delete('/closet/<itemId>', (Request request) => _handleRequest(request, apiHandlers.handleClosetDelete));
  app.get('/closet', (Request request) => _handleRequest(request, apiHandlers.handleGetCloset));
  app.get('/outfits', (Request request) => _handleRequest(request, apiHandlers.handleGetOutfits));
  app.get('/images/<filename>', (Request request) => _handleRequest(request, apiHandlers.handleServeImage));

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(app.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Server running on http://${server.address.address}:${server.port}/');
}

// Adapter to adapt ApiHandlers methods (which take HttpRequest) to Shelf Request/Response
// But ApiHandlers methods currently return Future<void> and write directly to HttpRequest.response.
// We need to change ApiHandlers to return Response, OR wrap them.
// Since refactoring ApiHandlers is a bigger task, we can wrap the Shelf Request into an adapter if needed,
// OR (better) Refactor ApiHandlers to use Shelf Request/Response.
// Given constraints, I should Refactor ApiHandlers to return Shelf Response.

// Wait, I can't easily change ApiHandlers signature without breaking everything.
// But wait, the original code passed `HttpRequest` (dart:io) to `handleSignup`.
// Shelf Request is DIFFERENT from dart:io HttpRequest.
// So I MUST refactor ApiHandlers to use Shelf Request/Response if I use Shelf Router.
// Otherwise I can't use Shelf Router easily.

// Let's modify ApiHandlers to accept shelf.Request and return Future<shelf.Response>.
// This is cleaner anyway.

Future<Response> _handleRequest(Request request, Future<Response> Function(Request) handler) async {
    try {
        return await handler(request);
    } catch (e) {
        print('Error handling request: $e');
        return Response.internalServerError(body: 'Internal Server Error: $e');
    }
}