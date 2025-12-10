import 'dart:io';

Future<void> main() async{
    final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  );

  print('Server running on http://${server.address.address}:${server.port}/');
  await for (HttpRequest request in server) {
    request.response
      ..headers.contentType = ContentType.html
      ..write('<h1>Hello from Dart HTTP server!</h1>')
      ..close();
  }

}