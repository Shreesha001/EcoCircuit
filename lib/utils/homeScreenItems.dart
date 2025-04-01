import 'dart:developer';

import 'package:eco_circuit/screens/account_screen.dart';
import 'package:eco_circuit/screens/history/history_screen.dart';
import 'package:eco_circuit/screens/home_screen.dart';
import 'package:eco_circuit/screens/market/market_place.dart';
import 'package:flutter/material.dart';

final List<Widget> HomeScreenItems = [
  const HomeScreen(),
  const MarketplaceScreen(),
  const HistoryScreen(),
  const ProfileScreen(),
];
