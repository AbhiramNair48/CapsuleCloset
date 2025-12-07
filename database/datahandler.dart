import 'package:mysql_client/mysql_client.dart';

void main() async {
  final conn = await MySQLConnection.createConnection(
    host: "localhost",
    port: 3306,
    userName: "root",
    password: "password",
    databaseName: "mydb",
  );

  await conn.connect();

  var results = await conn.execute("SELECT * FROM users;");
  for (final row in results.rows) {
    print(row.colAt(0)); // id
  }

  await conn.close();
}