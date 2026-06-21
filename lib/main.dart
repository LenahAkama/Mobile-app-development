import 'package:flutter/material.dart';

import 'app.dart';
import 'services/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService.init();
  runApp(const EventManagerApp());
}
