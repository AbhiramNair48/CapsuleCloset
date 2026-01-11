// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:mime/mime.dart';
import 'package:mysql_client/mysql_client.dart';

class ApiHandlers {
  final MySQLConnectionPool pool;

  ApiHandlers(this.pool);

  Future<void> handleSignup(HttpRequest request) async {
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
        return;
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

      request.response
        ..statusCode = HttpStatus.ok
        ..write('User registered successfully')
        ..close();
    } catch (e) {
      print('Error during signup: $e');
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
  }

  Future<void> handleLogin(HttpRequest request) async {
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
        return;
      }

      final result = await pool.execute(
        'SELECT id, email, username, password_hash FROM users WHERE email = :email LIMIT 1',
        {"email": email},
      );

      if (result.rows.isEmpty) {
        request.response
          ..statusCode = HttpStatus.unauthorized
          ..write('Invalid email or password')
          ..close();
        return;
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
  }

  Future<void> handleSearchUsers(HttpRequest request) async {
    final query = request.uri.queryParameters['q'];
    if (query == null || query.isEmpty) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Missing query parameter q')
        ..close();
      return;
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
  }

  Future<void> handleSendFriendRequest(HttpRequest request) async {
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
        return;
      }

      final userResult = await pool.execute(
        'SELECT id FROM users WHERE email = :email',
        {"email": userEmail},
      );

      if (userResult.rows.isEmpty) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('User not found')
          ..close();
        return;
      }

      final userId = userResult.rows.first.colByName('id');

      // Ensure explicit String comparison
      if (userId.toString() == friendId.toString()) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Cannot add yourself as a friend')
          ..close();
        return;
      }

      await pool.execute(
        "INSERT INTO friendships (user_id, friend_id, status) VALUES (:user_id, :friend_id, 'pending')",
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
  }

  Future<void> handleUpdateFriendRequest(HttpRequest request) async {
    try {
      final pathSegments = request.uri.pathSegments;
      // Expecting /friends/request/<friendshipId>
      final friendshipIdString = pathSegments.last; 

      final ids = friendshipIdString.split('_');
      if (ids.length != 2) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Invalid friendshipId format. Expected "senderId_receiverId".')
          ..close();
        return;
      }
      final senderId = ids[0];
      final receiverId = ids[1];

      final content = await utf8.decoder.bind(request).join();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status == null || !['accepted', 'rejected'].contains(status)) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Invalid status provided. Must be "accepted" or "rejected".')
          ..close();
        return;
      }

      await pool.execute(
        'UPDATE friendships SET status = :status WHERE user_id = :sender_id AND friend_id = :receiver_id',
        {'status': status, 'sender_id': senderId, 'receiver_id': receiverId},
      );

      request.response
        ..statusCode = HttpStatus.ok
        ..write('Friend request status updated successfully')
        ..close();
    } catch (e) {
      print('Error updating friend request status: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error updating friend request status: $e')
        ..close();
    }
  }

  Future<void> handleGetPendingFriendRequests(HttpRequest request) async {
    final userId = request.uri.queryParameters['user_id'];
    if (userId == null) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Missing user_id query parameter')
        ..close();
      return;
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

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(pendingRequests))
        ..close();
    } catch (e) {
      print('Error fetching pending friend requests: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error fetching pending friend requests: $e')
        ..close();
    }
  }

  Future<void> handleGetFriends(HttpRequest request) async {
    final userId = request.uri.queryParameters['user_id'];
    if (userId == null) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Missing user_id query parameter')
        ..close();
      return;
    }

    try {
      // 1. Get all accepted friend IDs (bidirectional)
      final rawFriendships = await pool.execute(
        "SELECT user_id, friend_id FROM friendships WHERE (user_id = :user_id OR friend_id = :user_id) AND status = 'accepted'",
        {'user_id': userId},
      );

      if (rawFriendships.rows.isEmpty) {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode([]))
          ..close();
        return;
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
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode([]))
          ..close();
        return;
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
  }

  Future<void> handleClosetUpload(HttpRequest request) async {
    final boundary = request.headers.contentType?.parameters['boundary'];
    if (boundary == null) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Missing multipart boundary')
        ..close();
      return;
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
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing image (file or img_url) or user_id')
          ..close();
        return;
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

      print('Generated imagePath for new item: $imagePath');

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
  }

  Future<void> handleClosetUpdatePublic(HttpRequest request) async {
    try {
      final pathSegments = request.uri.pathSegments;
      // Expecting /closet/<itemId>/public
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
  }

  Future<void> handleClosetUpdateDetails(HttpRequest request) async {
    try {
      final pathSegments = request.uri.pathSegments;
      final itemId = pathSegments.last;

      final content = await utf8.decoder.bind(request).join();
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
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('No fields to update')
          ..close();
        return;
      }

      final updateQueryParts =
          updates.keys.map((key) => '$key = :$key').join(', ');

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
  }

  Future<void> handleClosetDelete(HttpRequest request) async {
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
  }

  Future<void> handleGetCloset(HttpRequest request) async {
    final userId = request.uri.queryParameters['user_id'];
    if (userId == null) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Missing user_id query parameter')
        ..close();
      return;
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
  }

  Future<void> handleGetOutfits(HttpRequest request) async {
    final userId = request.uri.queryParameters['user_id'];
    if (userId == null) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Missing user_id query parameter')
        ..close();
      return;
    }

    try {
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
        return;
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
  }

  Future<void> handleServeImage(HttpRequest request) async {
    final filename = request.uri.pathSegments.last;

    if (filename.contains('..') || filename.contains('/')) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Invalid filename')
        ..close();
      return;
    }

    final filePath = 'assets/images/clothes/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      final contentType =
          lookupMimeType(filename) ?? 'application/octet-stream';
      request.response.headers.contentType = ContentType.parse(contentType);
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
  }
}