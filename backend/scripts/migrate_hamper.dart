// ignore_for_file: avoid_print

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
  
  print("Connecting to database at $dbIp:$dbPort...");

  // Create a connection settings object
  final pool = MySQLConnectionPool(
    host: dbIp,
    port: dbPort,
    userName: "root",
    password: env['DB_PASSWORD'] ?? "root",
    databaseName: "capsule_closet",
    maxConnections: 1,
  );

  try {
    // Check if column exists
    final checkResult = await pool.execute(
      "SELECT count(*) as count FROM information_schema.columns WHERE table_schema = 'capsule_closet' AND table_name = 'closet' AND column_name = 'is_clean'"
    );
    
    final count = checkResult.rows.first.colByName('count');
    if (count == '0') {
      print("Adding is_clean column to closet table...");
      await pool.execute("ALTER TABLE closet ADD COLUMN is_clean TINYINT(1) DEFAULT 1");
      print("Column added successfully.");
    } else {
      print("Column is_clean already exists.");
    }

  } catch (e) {
    print("Error during migration: $e");
  } finally {
    await pool.close();
  }
}
