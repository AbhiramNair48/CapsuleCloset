import 'package:mysql1/mysql1.dart';



// TODO: change db password to .env variable


class Database {
  // Change these to your MySQL credentials
  static final _settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'dev',
    db: 'capsule_closet',
  );
  
  
    // print('Database "$dbName" is ready');
  /// Connect to the database
  static Future<MySqlConnection> connect() async {
    final conn = await MySqlConnection.connect(_settings);
    print('✅ Connected to MySQL');
    return conn;
  }

  /// Initialize the database schema (tables)
  static Future<void> initSchema() async {
    MySqlConnection? conn;
    
    try {
      conn = await connect();

      // Users table
      await conn.query('''
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          username VARCHAR(50) UNIQUE NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          friends TEXT,
          pending_friend_requests TEXT
        )
      ''');

      // Closet table
      await conn.query('''
        CREATE TABLE IF NOT EXISTS closet (
          id INT AUTO_INCREMENT PRIMARY KEY,
          user_id INT NOT NULL,
          clothing_type VARCHAR(100),
          color VARCHAR(100),
          material VARCHAR(100),
          style VARCHAR(100),
          description TEXT,
          img_filename VARCHAR(255) NOT NULL,
          public BOOLEAN DEFAULT FALSE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      print('✅ Database schema initialized');
    } catch (e) {
      print('❌ Error initializing schema: $e');
    } finally {
      await conn?.close();
    }
  }
}
