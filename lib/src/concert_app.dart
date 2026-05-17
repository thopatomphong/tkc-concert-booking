import 'package:concert_mini_app/src/concert_host.dart';
import 'package:concert_mini_app/src/host_provider.dart';
import 'package:concert_mini_app/src/ui/concert_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Public entry point for the Concert Mini App.
///
/// The Core App calls `ConcertMiniApp.create(host: ...)` and places the
/// returned widget on its own navigation stack. The Mini App runs under its
/// own ProviderScope and Navigator; the host is the only shared surface.
class ConcertMiniApp {
  const ConcertMiniApp._();

  static Widget create({required ConcertHost host}) {
    return ProviderScope(
      overrides: <Override>[
        concertHostProvider.overrideWithValue(host),
      ],
      child: _ConcertRoot(host: host),
    );
  }
}

class _ConcertRoot extends StatelessWidget {
  const _ConcertRoot({required this.host});

  final ConcertHost host;

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = navigatorKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else {
          host.onExit();
        }
      },
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => const ConcertListScreen(),
        ),
      ),
    );
  }
}
