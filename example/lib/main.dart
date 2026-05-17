import 'package:concert_example/fake_concert_host.dart';
import 'package:concert_mini_app/concert_mini_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Concert Mini App - Dev',
      debugShowCheckedModeBanner: false,
      home: ConcertMiniApp.create(host: FakeConcertHost()),
    ),
  );
}
