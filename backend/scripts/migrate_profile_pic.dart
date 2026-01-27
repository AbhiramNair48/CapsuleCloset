// ignore_for_file: avoid_print
import 'package:mysql_client/mysql_client.dart';
import 'dart:io';
import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  var env = DotEnv(includePlatformEnvironment: true);
  // Try loading from different locations depending on where it's run
  if (File('backend/.env').existsSync()) {
    env.load(['backend/.env']);
  } else if (File('.env').existsSync()) {
    env.load(['.env']);
  }
  
  const dbIp = "127.0.0.1";
  const dbPort = 3306;
  
  print("Connecting to database at $dbIp:$dbPort...");

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
      "SELECT count(*) as count FROM information_schema.columns WHERE table_schema = 'capsule_closet' AND table_name = 'users' AND column_name = 'profile_pic_url'"
    );
    
    final count = checkResult.rows.first.colByName('count');
    if (count == '0') {
      print("Adding profile_pic_url column to users table...");
      await pool.execute("ALTER TABLE users ADD COLUMN profile_pic_url VARCHAR(512) DEFAULT NULL");
      print("Column added successfully.");
    } else {
      print("Column profile_pic_url already exists.");
    }

  } catch (e) {
    print("Error during migration: $e");
  } finally {
    await pool.close();
  }
}
