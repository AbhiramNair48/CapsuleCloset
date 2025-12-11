import 'package:mysql_client/mysql_client.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mime/mime.dart';


//TODO: move response closes to the end 
Future<void> main() async {
  print('Server starting...');
  print('Current working directory: ${Directory.current.path}');

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
    } else if (request.method == 'GET' && request.uri.path.startsWith('/images/')) {
      final filename = request.uri.pathSegments.last;

      // Sanitize filename to prevent path traversal attacks
      if (filename.contains('..') || filename.contains('/')) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Invalid filename')
          ..close();
        continue;
      }

      final filePath = 'assets/images/clothes/$filename';
      final file = File(filePath);

      if (await file.exists()) {
        final contentType = lookupMimeType(filename) ?? 'application/octet-stream';
        request.response.headers.contentType = ContentType.parse(contentType);
        print('Serving image $filename with Content-Type: $contentType');
        try {
          await request.response.addStream(file.openRead());
          await request.response.close();
        } catch (e) {
          print('Error serving file: $e');
        }
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Image not found')
          ..close();
      }
    } else if (request.method == 'POST' && request.uri.path == '/closet/upload') {
      final boundary = request.headers.contentType?.parameters['boundary'];
      if (boundary == null) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing multipart boundary')
          ..close();
        continue;
      }

      try {
        String? savedFilename;
        final itemData = <String, String>{};
        final transformer = MimeMultipartTransformer(boundary);
        final stream = request.cast<List<int>>().transform(transformer);

        await for (final part in stream) {
          final contentDisposition = part.headers['content-disposition'];
          final disposition = HeaderValue.parse(contentDisposition!);
          final partName = disposition.parameters['name'];

          if (partName == 'image') {
            final originalFilename = disposition.parameters['filename'];
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final extension = originalFilename?.split('.').last ?? 'jpg';
            savedFilename = '$timestamp.$extension';
            
            final filePath = 'assets/images/clothes/$savedFilename';
            final file = File(filePath);
            print('Attempting to save image to absolute path: ${file.absolute.path}');
            await file.create(recursive: true);
            await part.pipe(file.openWrite());
          } else {
            final value = await utf8.decodeStream(part);
            if(partName != null) {
              itemData[partName] = value;
            }
          }
        }

        if (savedFilename == null || itemData['user_id'] == null) {
            request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Missing image or user_id')
            ..close();
            continue;
        }

        final insertResult = await pool.execute(
          '''
          INSERT INTO closet (user_id, clothing_type, color, material, style, description, img_link, public)
          VALUES (:user_id, :type, :color, :material, :style, :description, :img_link, :public)
          ''',
          {
            'user_id': itemData['user_id'],
            'type': itemData['type'],
            'color': itemData['color'],
            'material': itemData['material'],
            'style': itemData['style'],
            'description': itemData['description'],
            'img_link': savedFilename,
            'public': (itemData['public'] == 'true') ? 1 : 0,
          },
        );
        
        final newId = insertResult.lastInsertID;

        final newItemResult = await pool.execute(
            'SELECT id, img_link, clothing_type, material, color, style, description, public FROM closet WHERE id = :id',
            {'id': newId}
        );

        if (newItemResult.rows.isEmpty) {
            throw Exception('Failed to fetch newly created item.');
        }

        final row = newItemResult.rows.first;
        final imgLink = row.colByName('img_link');
        final imagePath = (imgLink != null) ? 'http://10.0.2.2:8080/images/$imgLink' : '';
        print('Generated imagePath for new item: $imagePath');
        
        final newItemJson = {
          'id': row.colByName('id').toString(),
          'imagePath': imagePath,
          'type': row.colByName('clothing_type'),
          'material': row.colByName('material'),
          'color': row.colByName('color'),
          'style': row.colByName('style'),
          'description': row.colByName('description'),
          'public': row.colByName('public') == 1,
        };

        request.response
          ..statusCode = HttpStatus.created
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(newItemJson))
          ..close();

      } catch (e) {
        print('Error during upload: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error during upload: $e')
          ..close();
      }
    } else if (request.method == 'PATCH' && request.uri.path.contains('/closet/') && request.uri.path.endsWith('/public')) {
      try {
        final pathSegments = request.uri.pathSegments;
        final itemId = pathSegments[pathSegments.length - 2];
        
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content) as Map<String, dynamic>;
        final isPublic = data['public'] as bool;

        await pool.execute(
          'UPDATE closet SET public = :public WHERE id = :id',
          {'public': isPublic ? 1 : 0, 'id': itemId},
        );

        request.response
          ..statusCode = HttpStatus.ok
          ..write('Updated successfully')
          ..close();

      } catch (e) {
        print('Error updating public status: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error updating public status: $e')
          ..close();
      }
    } else if (request.method == 'PATCH' && request.uri.path.contains('/closet/') && !request.uri.path.endsWith('/public')) {
      try {
        final pathSegments = request.uri.pathSegments;
        final itemId = pathSegments[pathSegments.length - 1]; // Get the ID from the URL

        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content) as Map<String, dynamic>;

        // Build the update query dynamically
        final updates = <String, dynamic>{};
        if (data.containsKey('type')) updates['clothing_type'] = data['type'];
        if (data.containsKey('material')) updates['material'] = data['material'];
        if (data.containsKey('color')) updates['color'] = data['color'];
        if (data.containsKey('style')) updates['style'] = data['style'];
        if (data.containsKey('description')) updates['description'] = data['description'];

        if (updates.isEmpty) {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('No fields to update')
            ..close();
          continue;
        }

        final updateQueryParts = updates.keys.map((key) => '$key = :$key').join(', ');
        
        await pool.execute(
          'UPDATE closet SET $updateQueryParts WHERE id = :id',
          {...updates, 'id': itemId},
        );

        request.response
          ..statusCode = HttpStatus.ok
          ..write('Clothing item updated successfully')
          ..close();

      } catch (e) {
        print('Error updating clothing item: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error updating clothing item: $e')
          ..close();
      }
    } else if (request.method == 'DELETE' && request.uri.path.startsWith('/closet/')) {
      try {
        final pathSegments = request.uri.pathSegments;
        final itemId = pathSegments.last;

        await pool.execute(
          'DELETE FROM closet WHERE id = :id',
          {'id': itemId},
        );

        request.response
          ..statusCode = HttpStatus.ok
          ..write('Clothing item deleted successfully')
          ..close();

      } catch (e) {
        print('Error deleting clothing item: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error deleting clothing item: $e')
          ..close();
      }
    } else if (request.method == 'GET' && request.uri.path == '/friends') {
      final userId = request.uri.queryParameters['user_id'];
      if (userId == null) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing user_id query parameter')
          ..close();
        continue;
      }

      try {
        // 1. Get all accepted friend IDs
        final friendIdsResult = await pool.execute(
          'SELECT friend_id FROM friendships WHERE user_id = :user_id AND status = \'accepted\'',
          {'user_id': userId},
        );

        if (friendIdsResult.rows.isEmpty) {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode([]))
            ..close();
          continue;
        }

        final friendIds = friendIdsResult.rows.map((row) => row.colByName('friend_id')).toList();

        if (friendIds.isEmpty) {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode([]))
            ..close();
          continue;
        }

        // 2. Get friend details from users table
        final friendsResult = await pool.execute(
          'SELECT id, username FROM users WHERE id IN (${friendIds.join(',')})',
        );

        // 3. Get all public clothing items for all friends
        final itemsResult = await pool.execute(
          'SELECT id, user_id, img_link, clothing_type, material, color, style, description, public FROM closet WHERE user_id IN (${friendIds.join(',')}) AND public = TRUE',
        );

        // 4. Group items by friend
        final Map<String, List<Map<String, dynamic>>> itemsByFriendId = {};
        for (final row in itemsResult.rows) {
          final friendId = row.colByName('user_id').toString();
          final imgLink = row.colByName('img_link');
          final imagePath = (imgLink != null) ? 'http://10.0.2.2:8080/images/$imgLink' : '';

          final item = {
            'id': row.colByName('id').toString(),
            'imagePath': imagePath,
            'type': row.colByName('clothing_type'),
            'material': row.colByName('material'),
            'color': row.colByName('color'),
            'style': row.colByName('style'),
            'description': row.colByName('description'),
            'public': row.colByName('public') == 1,
          };

          if (!itemsByFriendId.containsKey(friendId)) {
            itemsByFriendId[friendId] = [];
          }
          itemsByFriendId[friendId]!.add(item);
        }

        // 5. Construct final JSON
        final friendsJson = friendsResult.rows.map((row) {
          final friendId = row.colByName('id').toString();
          final allItems = itemsByFriendId[friendId] ?? [];
          final previewItems = allItems.take(4).toList();

          return {
            'id': friendId,
            'name': row.colByName('username'),
            'previewItems': previewItems,
            'closetItems': allItems,
          };
        }).toList();

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(friendsJson))
          ..close();

      } catch (e) {
        print('Error fetching friends: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error fetching friends: $e')
          ..close();
      }
    } else if (request.method == 'GET' && request.uri.path == '/outfits') {
      final userId = request.uri.queryParameters['user_id'];
      if (userId == null) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing user_id query parameter')
          ..close();
        continue;
      }

      try {
        // 1. Get all outfits for the user
        final outfitsResult = await pool.execute(
          'SELECT id, outfit_name, description, created_at FROM outfits WHERE user_id = :user_id',
          {'user_id': userId},
        );

        if (outfitsResult.rows.isEmpty) {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode([]))
            ..close();
          continue;
        }

        final outfitIds = outfitsResult.rows.map((row) => row.colByName('id')).toList();

        // 2. Get all clothing items for those outfits in one query
        final itemsResult = await pool.execute(
          '''
          SELECT
              oi.outfit_id,
              c.id, c.img_link, clothing_type, c.material, c.color, c.style, c.description
          FROM outfit_items oi
          JOIN closet c ON oi.clothing_item_id = c.id
          WHERE oi.outfit_id IN (${outfitIds.join(',')})
          ''',
        );

        // 3. Group clothing items by outfit_id
        final Map<String, List<Map<String, dynamic>>> itemsByOutfitId = {};
        for (final row in itemsResult.rows) {
          final outfitId = row.colByName('outfit_id').toString();
          final imgLink = row.colByName('img_link');
          final imagePath = (imgLink != null) ? 'http://10.0.2.2:8080/images/$imgLink' : '';

          final item = {
            'id': row.colByName('id').toString(),
            'imagePath': imagePath,
            'type': row.colByName('clothing_type'),
            'material': row.colByName('material'),
            'color': row.colByName('color'),
            'style': row.colByName('style'),
            'description': row.colByName('description'),
          };

          if (!itemsByOutfitId.containsKey(outfitId)) {
            itemsByOutfitId[outfitId] = [];
          }
          itemsByOutfitId[outfitId]!.add(item);
        }

        // 4. Construct the final JSON response
        final outfitsJson = outfitsResult.rows.map((row) {
          final outfitId = row.colByName('id').toString();
          return {
            'id': outfitId,
            'name': row.colByName('outfit_name'),
            'savedDate': (row.colByName('created_at') as DateTime).toIso8601String(),
            'items': itemsByOutfitId[outfitId] ?? [],
          };
        }).toList();

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(outfitsJson))
          ..close();

      } catch (e) {
        print('Error fetching outfits: $e');
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Error fetching outfits: $e')
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
          'SELECT id, img_link, clothing_type, material, color, style, description, public FROM closet WHERE user_id = :user_id',
          {'user_id': userId},
        );

        final items = results.rows.map((row) {
          final imgLink = row.colByName('img_link');
          final imagePath = (imgLink != null) ? 'http://10.0.2.2:8080/images/$imgLink' : '';
          
          return {
            'id': row.colByName('id').toString(),
            'imagePath': imagePath,
            'type': row.colByName('clothing_type'),
            'material': row.colByName('material'),
            'color': row.colByName('color'),
            'style': row.colByName('style'),
            'description': row.colByName('description'),
            'public': row.colByName('public') == 1,
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
