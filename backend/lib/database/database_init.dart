import 'package:mysql1/mysql1.dart';


// TODO: change db password to .env variable

Future<void> main() async {
  // Create a connection settings object
  final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'root',
    db: 'capsule_closet',
  );

  // Connect to the database
  final conn = await MySqlConnection.connect(settings);

  // Run a query
  // var results = await conn.query('SELECT * FROM users');

  // // Iterate results
  // for (var row in results) {
  //   print('User: ${row[0]}, Email: ${row[1]}');
  // }

  // Close connection
  await conn.close();
}