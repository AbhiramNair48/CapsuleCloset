// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:mime/mime.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http_parser/http_parser.dart';

class ApiHandlers {
  final MySQLConnectionPool pool;

  ApiHandlers(this.pool);

  Future<Response> handleSignup(Request request) async {
    try {
      final content = await request.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final username = data['username'];
      final email = data['email'];
      final password = data['password'];
      final gender = data['gender'];
      final favoriteStyle = data['favorite_style'];

      if (username == null || email == null || password == null) {
        return Response.badRequest(body: 'Missing required fields');
      }

      final passwordHash = sha256.convert(utf8.encode(password)).toString();

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

      return Response.ok('User registered successfully');
    } catch (e) {
      print('Error during signup: $e');
      if (e.toString().contains('Duplicate entry')) {
        return Response(409, body: 'Username or email already exists'); // Conflict
      } else {
        return Response.internalServerError(body: 'Error registering user: $e');
      }
    }
  }

  Future<Response> handleLogin(Request request) async {
    try {
      final content = await request.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final email = data['email'];
      final password = data['password'];

      if (email == null || password == null) {
        return Response.badRequest(body: 'Missing email or password');
      }

      final result = await pool.execute(
        'SELECT id, email, username, password_hash FROM users WHERE email = :email LIMIT 1',
        {"email": email},
      );

      if (result.rows.isEmpty) {
        return Response.forbidden('Invalid email or password');
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
        return Response.ok(
          jsonEncode({'message': 'Successful login!', 'user': user}),
          headers: {'content-type': 'application/json'},
        );
      } else {
        return Response.forbidden('Invalid email or password');
      }
    } catch (e) {
      print('Error during login: $e');
      return Response.internalServerError(body: 'Error Logging In: $e');
    }
  }

  Future<Response> handleSearchUsers(Request request) async {
    final query = request.url.queryParameters['q'];
    if (query == null || query.isEmpty) {
      return Response.badRequest(body: 'Missing query parameter q');
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

      return Response.ok(
        jsonEncode(users),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('Error searching users: $e');
      return Response.internalServerError(body: 'Error searching users');
    }
  }

  Future<Response> handleSendFriendRequest(Request request) async {
    try {
      final content = await request.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final userEmail = data['user_email'];
      final friendId = data['friend_id'];

      if (userEmail == null || friendId == null) {
        return Response.badRequest(body: 'Missing required fields');
      }

      final userResult = await pool.execute(
        'SELECT id FROM users WHERE email = :email',
        {"email": userEmail},
      );

      if (userResult.rows.isEmpty) {
        return Response.notFound('User not found');
      }

      final userId = userResult.rows.first.colByName('id');

      if (userId.toString() == friendId.toString()) {
        return Response.badRequest(body: 'Cannot add yourself as a friend');
      }

      await pool.execute(
        "INSERT INTO friendships (user_id, friend_id, status) VALUES (:user_id, :friend_id, 'pending')",
        {"user_id": userId, "friend_id": friendId},
      );

      return Response.ok('Friend request sent');
    } catch (e) {
      print('Error sending friend request: $e');
      if (e.toString().contains('Duplicate entry')) {
        return Response(409, body: 'Friend request already sent or exists');
      } else {
        return Response.internalServerError(body: 'Error sending friend request: $e');
      }
    }
  }

  Future<Response> handleUpdateFriendRequest(Request request) async {
    try {
      final friendshipIdString = request.params['friendshipId'];
      if (friendshipIdString == null) return Response.badRequest(body: 'Missing friendshipId');

      final ids = friendshipIdString.split('_');
      if (ids.length != 2) {
        return Response.badRequest(body: 'Invalid friendshipId format. Expected "senderId_receiverId".');
      }
      final senderId = ids[0];
      final receiverId = ids[1];

      final content = await request.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status == null || !['accepted', 'rejected'].contains(status)) {
        return Response.badRequest(body: 'Invalid status provided. Must be "accepted" or "rejected".');
      }

      await pool.execute(
        'UPDATE friendships SET status = :status WHERE user_id = :sender_id AND friend_id = :receiver_id',
        {'status': status, 'sender_id': senderId, 'receiver_id': receiverId},
      );

      return Response.ok('Friend request status updated successfully');
    } catch (e) {
      print('Error updating friend request status: $e');
      return Response.internalServerError(body: 'Error updating friend request status: $e');
    }
  }

  Future<Response> handleGetPendingFriendRequests(Request request) async {
    final userId = request.url.queryParameters['user_id'];
    if (userId == null) {
      return Response.badRequest(body: 'Missing user_id query parameter');
    }

    try {
      final results = await pool.execute(
        "SELECT f.user_id as sender_id, u.username as sender_username, u.email as sender_email, f.friend_id as receiver_id FROM friendships f JOIN users u ON f.user_id = u.id WHERE f.friend_id = :user_id AND f.status = 'pending'",
        {'user_id': userId},
      );

      final pendingRequests = results.rows.map((row) => {
        'friendshipId': '${row.colByName('sender_id')}_${row.colByName('receiver_id')}',
        'senderId': row.colByName('sender_id').toString(),
        'senderUsername': row.colByName('sender_username'),
        'senderEmail': row.colByName('sender_email'),
      }).toList();

      return Response.ok(
        jsonEncode(pendingRequests),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching pending friend requests: $e');
      return Response.internalServerError(body: 'Error fetching pending friend requests: $e');
    }
  }

  Future<Response> handleGetFriends(Request request) async {
    final userId = request.url.queryParameters['user_id'];
    if (userId == null) {
      return Response.badRequest(body: 'Missing user_id query parameter');
    }

    try {
      final rawFriendships = await pool.execute(
        "SELECT user_id, friend_id FROM friendships WHERE (user_id = :user_id OR friend_id = :user_id) AND status = 'accepted'",
        {'user_id': userId},
      );

      if (rawFriendships.rows.isEmpty) {
        return Response.ok(jsonEncode([]), headers: {'content-type': 'application/json'});
      }

      final Set<String> friendIds = {};
      for (final row in rawFriendships.rows) {
        final uId = row.colByName('user_id').toString();
        final fId = row.colByName('friend_id').toString();
        if (uId == userId) {
          friendIds.add(fId);
        } else {
          friendIds.add(uId);
        }
      }

      if (friendIds.isEmpty) {
        return Response.ok(jsonEncode([]), headers: {'content-type': 'application/json'});
      }

      final friendsResult = await pool.execute(
        'SELECT id, username FROM users WHERE id IN (${friendIds.join(',')})',
      );

      final itemsResult = await pool.execute(
        'SELECT id, user_id, img_link, clothing_type, material, color, style, description, public FROM closet WHERE user_id IN (${friendIds.join(',')}) AND public = TRUE',
      );

      final Map<String, List<Map<String, dynamic>>> itemsByFriendId = {};
      for (final row in itemsResult.rows) {
        final friendId = row.colByName('user_id').toString();
        final imgLink = row.colByName('img_link');
        final imagePath = (imgLink != null && imgLink.startsWith('http'))
            ? imgLink
            : (imgLink != null) ? 'http://10.0.2.2:8080/images/$imgLink' : '';

        final item = {
          'id': row.colByName('id').toString(),
          'imagePath': imagePath,
          'type': row.colByName('clothing_type'),
          'material': row.colByName('material'),
          'color': row.colByName('color'),
          'style': row.colByName('style'),
          'description': row.colByName('description'),
          'public': row.colByName('public') == '1',
        };

        if (!itemsByFriendId.containsKey(friendId)) {
          itemsByFriendId[friendId] = [];
        }
        itemsByFriendId[friendId]!.add(item);
      }

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

      return Response.ok(
        jsonEncode(friendsJson),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching friends: $e');
      return Response.internalServerError(body: 'Error fetching friends: $e');
    }
  }

  Future<Response> handleClosetUpload(Request request) async {
    final contentType = request.headers['content-type'];
    if (contentType == null) return Response.badRequest(body: 'Missing Content-Type header');
    
    final mediaType = MediaType.parse(contentType);
    final boundary = mediaType.parameters['boundary'];
    
    if (boundary == null) {
      return Response.badRequest(body: 'Missing multipart boundary');
    }

    try {
      String? savedFilename;
      final itemData = <String, String>{};
      final transformer = MimeMultipartTransformer(boundary);
      final stream = request.read().transform(transformer);

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
          await file.create(recursive: true);
          await part.pipe(file.openWrite());
        } else {
          final value = await utf8.decodeStream(part);
          if (partName != null) {
            itemData[partName] = value;
          }
        }
      }

      final finalImgLink = savedFilename ?? itemData['img_url'];

      if (finalImgLink == null || itemData['user_id'] == null) {
        return Response.badRequest(body: 'Missing image (file or img_url) or user_id');
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
          'img_link': finalImgLink,
          'public': (itemData['public'] == 'true') ? 1 : 0,
        },
      );

      final newId = insertResult.lastInsertID;

      final newItemResult = await pool.execute(
          'SELECT id, img_link, clothing_type, material, color, style, description, public FROM closet WHERE id = :id',
          {'id': newId});

      if (newItemResult.rows.isEmpty) {
        throw Exception('Failed to fetch newly created item.');
      }

      final row = newItemResult.rows.first;
      final imgLink = row.colByName('img_link');
      final imagePath = (imgLink != null && imgLink.startsWith('http'))
          ? imgLink
          : (imgLink != null)
              ? 'http://10.0.2.2:8080/images/$imgLink'
              : '';

      final newItemJson = {
        'id': row.colByName('id').toString(),
        'imagePath': imagePath,
        'type': row.colByName('clothing_type'),
        'material': row.colByName('material'),
        'color': row.colByName('color'),
        'style': row.colByName('style'),
        'description': row.colByName('description'),
        'public': row.colByName('public') == '1',
      };

      return Response(
        201, // Created
        body: jsonEncode(newItemJson),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('Error during upload: $e');
      return Response.internalServerError(body: 'Error during upload: $e');
    }
  }

  Future<Response> handleClosetUpdatePublic(Request request) async {
    try {
      final itemId = request.params['itemId'];
      if (itemId == null) return Response.badRequest(body: 'Missing itemId');

      final content = await request.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final isPublic = data['public'] as bool;

      await pool.execute(
        'UPDATE closet SET public = :public WHERE id = :id',
        {'public': isPublic ? 1 : 0, 'id': itemId},
      );

      return Response.ok('Updated successfully');
    } catch (e) {
      print('Error updating public status: $e');
      return Response.internalServerError(body: 'Error updating public status: $e');
    }
  }

  Future<Response> handleClosetUpdateDetails(Request request) async {
    try {
      final itemId = request.params['itemId'];
      if (itemId == null) return Response.badRequest(body: 'Missing itemId');

      final content = await request.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final updates = <String, dynamic>{};
      if (data.containsKey('type')) updates['clothing_type'] = data['type'];
      if (data.containsKey('material')) updates['material'] = data['material'];
      if (data.containsKey('color')) updates['color'] = data['color'];
      if (data.containsKey('style')) updates['style'] = data['style'];
      if (data.containsKey('description')) {
        updates['description'] = data['description'];
      }

      if (updates.isEmpty) {
        return Response.badRequest(body: 'No fields to update');
      }

      final updateQueryParts =
          updates.keys.map((key) => '$key = :$key').join(', ');

      await pool.execute(
        'UPDATE closet SET $updateQueryParts WHERE id = :id',
        {...updates, 'id': itemId},
      );

      return Response.ok('Clothing item updated successfully');
    } catch (e) {
      print('Error updating clothing item: $e');
      return Response.internalServerError(body: 'Error updating clothing item: $e');
    }
  }

  Future<Response> handleClosetDelete(Request request) async {
    try {
      final itemId = request.params['itemId'];
      if (itemId == null) return Response.badRequest(body: 'Missing itemId');

      await pool.execute(
        'DELETE FROM closet WHERE id = :id',
        {'id': itemId},
      );

      return Response.ok('Clothing item deleted successfully');
    } catch (e) {
      print('Error deleting clothing item: $e');
      return Response.internalServerError(body: 'Error deleting clothing item: $e');
    }
  }

  Future<Response> handleGetCloset(Request request) async {
    final userId = request.url.queryParameters['user_id'];
    if (userId == null) {
      return Response.badRequest(body: 'Missing user_id query parameter');
    }

    try {
      final results = await pool.execute(
        'SELECT id, img_link, clothing_type, material, color, style, description, public FROM closet WHERE user_id = :user_id',
        {'user_id': userId},
      );

      final items = results.rows.map((row) {
        final imgLink = row.colByName('img_link');
        final imagePath = (imgLink != null && imgLink.startsWith('http'))
            ? imgLink
            : (imgLink != null)
                ? 'http://10.0.2.2:8080/images/$imgLink'
                : '';

        return {
          'id': row.colByName('id').toString(),
          'imagePath': imagePath,
          'type': row.colByName('clothing_type'),
          'material': row.colByName('material'),
          'color': row.colByName('color'),
          'style': row.colByName('style'),
          'description': row.colByName('description'),
          'public': row.colByName('public') == '1',
        };
      }).toList();

      return Response.ok(
        jsonEncode(items),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching closet items: $e');
      return Response.internalServerError(body: 'Error fetching closet items: $e');
    }
  }

  Future<Response> handleGetOutfits(Request request) async {
    final userId = request.url.queryParameters['user_id'];
    if (userId == null) {
      return Response.badRequest(body: 'Missing user_id query parameter');
    }

    try {
      final outfitsResult = await pool.execute(
        'SELECT id, outfit_name, description, created_at FROM outfits WHERE user_id = :user_id',
        {'user_id': userId},
      );

      if (outfitsResult.rows.isEmpty) {
        return Response.ok(jsonEncode([]), headers: {'content-type': 'application/json'});
      }

      final outfitIds =
          outfitsResult.rows.map((row) => row.colByName('id')).toList();

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

      final Map<String, List<Map<String, dynamic>>> itemsByOutfitId = {};
      for (final row in itemsResult.rows) {
        final outfitId = row.colByName('outfit_id').toString();
        final imgLink = row.colByName('img_link');
        final imagePath = (imgLink != null && imgLink.startsWith('http'))
            ? imgLink
            : (imgLink != null)
                ? 'http://10.0.2.2:8080/images/$imgLink'
                : '';

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

      final outfitsJson = outfitsResult.rows.map((row) {
        final outfitId = row.colByName('id').toString();
        return {
          'id': outfitId,
          'name': row.colByName('outfit_name'),
          'savedDate':
              (row.colByName('created_at') as DateTime).toIso8601String(),
          'items': itemsByOutfitId[outfitId] ?? [],
        };
      }).toList();

      return Response.ok(
        jsonEncode(outfitsJson),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching outfits: $e');
      return Response.internalServerError(body: 'Error fetching outfits: $e');
    }
  }

  Future<Response> handleServeImage(Request request) async {
    final filename = request.params['filename'];

    if (filename == null || filename.contains('..') || filename.contains('/')) {
      return Response.badRequest(body: 'Invalid filename');
    }

    final filePath = 'assets/images/clothes/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      final contentType =
          lookupMimeType(filename) ?? 'application/octet-stream';
      return Response.ok(
        file.openRead(),
        headers: {'content-type': contentType},
      );
    } else {
      return Response.notFound('Image not found');
    }
  }
}