import 'package:dio/dio.dart';

/// The contract the Core App must satisfy to embed the Concert Mini App.
///
/// `/concert` endpoints are public, but `/booking` is protected, so the Mini
/// App still relies on the host's authenticated `Dio`. It never sees login or
/// token logic.
abstract interface class ConcertHost {
  /// A Dio instance with auth + auto-refresh already wired by the host.
  Dio get httpClient;

  /// Base URL of the API (used for resolving relative image paths).
  String get apiBaseUrl;

  /// Ask the host to leave the Mini App and return to its launcher.
  void onExit();
}
