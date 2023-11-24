import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gtk/gtk.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'firmware_app.dart';
import 'fwupd_dbus_service.dart';
import 'fwupd_mock_service.dart';

Future<void> main(List<String> args) async {
  Logger.setup(level: LogLevel.fromString(kDebugMode ? 'debug' : 'info'));

  for (final element in args) {
    if (element.startsWith('--simulate=')) {
      registerService<FwupdMockService>(
          () => FwupdMockService(simulateYamlFilePath: element.split('=').last)
            ..init(),
          dispose: (s) => s.dispose());
    }
  }

  registerService<FwupdDbusService>(
    () => FwupdDbusService()..init(),
    dispose: (s) => s.dispose(),
  );

  registerService<GtkApplicationNotifier>(() => GtkApplicationNotifier(args),
      dispose: (s) => s.dispose());

  runApp(
    YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: yaru.theme,
        darkTheme: yaru.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        routes: const {'/': FirmwareApp.create},
      ),
    ),
  );
}
