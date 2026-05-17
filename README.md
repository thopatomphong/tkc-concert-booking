# Concert Mini App (Vendor B)

A self-contained Flutter package providing concert browsing, ticket booking,
and a bookings list.

## How the Core App integrates it

This package exports exactly two things:

- `ConcertHost` - the interface the Core App must implement.
- `ConcertMiniApp.create({required ConcertHost host})` - returns the Mini App
  widget.

The Core App implements `ConcertHost`, provides an authenticated `Dio`, and
places `ConcertMiniApp.create(...)` on its navigation stack. The Mini App
handles no login or token logic and is integrated without modifying this
package's code.

Delivery to the Core App is by Git tag: the Core App depends on this repo via a
`git:` dependency pinned to a release tag, for example `v1.0.0`.

## Standalone development

`example/` runs the Mini App with a `FakeConcertHost`:

```bash
docker compose up -d
cd example
flutter run
```

## Tests

```bash
flutter test
```
