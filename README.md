# Concert Mini App (Vendor B)

A self-contained Flutter package providing concert browsing, ticket booking, and a bookings list. This package is designed to be hosted by a Core App.

## Features

- **Concert List**: Browse upcoming concerts with high-quality images and basic info.
- **Concert Details**: View detailed descriptions, setlists, and availability.
- **Ticket Booking**: Integrated booking flow with quantity validation.
- **My Bookings**: Keep track of purchased tickets.
- **Clean Architecture**: Decoupled domain, data, and presentation layers.
- **State Management**: Powered by Riverpod and Flutter Hooks for reactive, maintainable code.

## Architecture

The project follows Clean Architecture principles:

- **Domain Layer**: Contains entities (`Concert`, `Booking`), repository interfaces, and use cases (e.g., `GetConcertsUseCase`, `CreateBookingUseCase`).
- **Data Layer**: Implements repository interfaces, handles API calls via `Dio`, and performs data mapping.
- **Presentation Layer**: UI widgets and ViewModels (Riverpod providers) that manage screen state.
- **DI**: Manual dependency injection using Riverpod overrides.

## Integration Guide

To host this Mini App, the Core App must implement the `ConcertHost` interface and provide it to the entry point.

### 1. Implement ConcertHost

The host handles networking (providing an authenticated `Dio`) and navigation back to the Core App. **The provided `httpClient` must be pre-configured with necessary interceptors for authentication (e.g., Bearer tokens) and base headers.**

```dart
class MyConcertHost implements ConcertHost {
  @override
  Dio get httpClient {
    // Return a Dio instance with auth + refresh interceptors already wired.
    // The Mini App assumes all requests made via this client are authorized.
    return MyAuthService.authenticatedDio;
  }

  @override
  String get apiBaseUrl => 'https://api.example.com';

  @override
  void onExit() {
    // Navigate away from the Mini App, returning to the Core App's UI.
    // Example: Navigator.of(context).pop();
  }
}
```

### 2. Launch the Mini App

Use the static `create` method to get the Mini App widget:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ConcertMiniApp.create(
      host: MyConcertHost(),
    ),
  ),
);
```

## API Reference

### ConcertHost Interface
- `httpClient`: Must return a `Dio` instance. The Mini App uses this for all API requests. **The host is responsible for injecting auth tokens and handling header requirements via interceptors.**
- `apiBaseUrl`: Used for resolving relative asset paths from the API.
- `onExit()`: Callback triggered when the user wants to leave the Mini App (e.g., back button on the root screen).

### Validation
The package includes a `BookingValidator` for quantity and availability checks, ensuring data integrity before reaching the server.

## Development & Testing

Run the full suite of unit and widget tests:

```bash
flutter test
```

Analysis:

```bash
flutter analyze
```
