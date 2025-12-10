import 'package:mysql_client/mysql_client.dart';


// TODO: change db password to .env variable

Future<void> main() async {
  // Create a connection settings object
  final conn = await MySQLConnection.createConnection(
    host: "127.0.0.1",
    port: 3306,
    userName: "root",
    password: "root",
    databaseName: "capsule_closet", 
  );


  await conn.connect();

  var tables = await conn.execute('SHOW TABLES;');
    // Print the database name

    for (var row in tables.rows) {
      // The table name will be in the first column of each row
      print(row.assoc());
    }
  
  // Close connection
  await conn.close();
}