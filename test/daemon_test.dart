import 'dart:async';

import 'package:firmware_updater/daemon.dart';
import 'package:firmware_updater/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fwupd/fwupd.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'daemon_test.mocks.dart';

@GenerateMocks([FwupdService])
void main() {
  test('initializes service', () async {
    final service = MockFwupdService();
    when(service.propertiesChanged).thenAnswer((_) => const Stream.empty());

    final daemon = FwupdDaemon(service);
    await daemon.init();

    verify(service.init()).called(1);
  });

  test('daemon properties', () async {
    final service = MockFwupdService();
    final daemon = FwupdDaemon(service);

    when(service.status).thenReturn(FwupdStatus.idle);
    expect(daemon.status, FwupdStatus.idle);
    expect(daemon.isBusy, isFalse);

    when(service.status).thenReturn(FwupdStatus.loading);
    expect(daemon.status, FwupdStatus.loading);
    expect(daemon.isBusy, isTrue);

    when(service.percentage).thenReturn(75);
    expect(daemon.percentage, 75);

    when(service.daemonVersion).thenReturn('foo');
    expect(daemon.version, 'foo');
  });

  test('notifies property changes', () async {
    final service = MockFwupdService();
    when(service.status).thenReturn(FwupdStatus.loading);

    final daemon = FwupdDaemon(service);
    expect(daemon.status, FwupdStatus.loading);

    final propertiesChanged = StreamController<List<String>>(sync: true);
    when(service.propertiesChanged).thenAnswer((_) => propertiesChanged.stream);

    await daemon.init();

    var wasNotified = 0;
    daemon.addListener(() => wasNotified++);

    propertiesChanged.add(['foo']);

    expect(wasNotified, 1);
  });

  test('cancels subscription', () async {
    var wasListened = 0;
    var wasCanceled = 0;
    final propertiesChanged = StreamController<List<String>>(
      sync: true,
      onListen: () => ++wasListened,
      onCancel: () => ++wasCanceled,
    );
    final service = MockFwupdService();
    when(service.propertiesChanged).thenAnswer((_) => propertiesChanged.stream);

    final daemon = FwupdDaemon(service);
    await daemon.init();

    expect(wasListened, 1);
    expect(wasCanceled, 0);

    await daemon.dispose();

    expect(wasListened, 1);
    expect(wasCanceled, 1);
  });
}
