// ignore_for_file: avoid_types_on_closure_parameters

import 'dart:async' show Future;
import 'dart:convert';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:engine/engine.dart';

class GameService {
  Handler get handler {
    final router = Router();

    router.put('/create_lobby', (Request request) async {
      final payload = await request.readAsString();
      var modelJson = jsonDecode(payload) as Map<String, dynamic>;

      var gameModelType = gameModelTypeFromJson(modelJson);
      if (gameModelType != GameModelType.createLobbyRequest) {
        return Response.badRequest(body: 'Bad model type');
      }

      var model = CreateLobbyRequest.fromJson(modelJson);

      var body = '';

      return Response.ok(body, headers: {'Content-Type': 'application/json'});
    });

    // Handlers can be added with `router.<verb>('<route>', handler)`, the
    // '<route>' may embed URL-parameters, and these may be taken as parameters
    // by the handler (but either all URL parameters or no URL parameters, must
    // be taken parameters by the handler).
    router.get('/say-hi/<name>', (Request request, String name) {
      return Response.ok('hi $name');
    });

    // Embedded URL parameters may also be associated with a regular-expression
    // that the pattern must match.
    router.get('/user/<userId|[0-9]+>', (Request request, String userId) {
      return Response.ok('User has the user-number: $userId');
    });

    // Handlers can be asynchronous (returning `FutureOr` is also allowed).
    router.get('/wave', (Request request) async {
      await Future<dynamic>.delayed(Duration(milliseconds: 100));
      return Response.ok('_o/');
    });

    // You can catch all verbs and use a URL-parameter with a regular expression
    // that matches everything to catch app.
    router.all('/<ignored|.*>', (Request request) {
      return Response.notFound('Page not found');
    });

    return router;
  }
}
