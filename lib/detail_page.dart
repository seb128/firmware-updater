import 'package:flutter/material.dart';
import 'package:fwupd/fwupd.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'device_model.dart';
import 'device_page.dart';
import 'device_store.dart';
import 'fwupd_service.dart';
import 'release_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
  });

  static Widget create(
    BuildContext context, {
    required FwupdDevice device,
  }) {
    return ChangeNotifierProvider<DeviceModel>(
      key: ValueKey(device.hashCode),
      create: (_) => DeviceModel(device, getService<FwupdService>()),
      child: const DetailPage(),
    );
  }

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<DeviceModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final deviceModel = context.watch<DeviceModel>();
    final store = context.watch<DeviceStore>();
    final navigator = Navigator.of(context);
    final release = deviceModel.findRelease(store.selectedReleaseVersion);
    if (release != null) deviceModel.selectedRelease = release;
    return ClipRect(
      child: Theme(
        data: Theme.of(context).copyWith(
          pageTransitionsTheme: YaruPageTransitionsTheme.horizontal,
        ),
        child: Navigator(
          pages: [
            MaterialPage(
              child: DevicePage(parentNavigator: navigator),
            ),
            if (deviceModel.selectedRelease != null)
              const MaterialPage(
                child: ReleasePage(),
              )
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ),
    );
  }
}
