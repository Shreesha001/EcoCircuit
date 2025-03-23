import 'dart:developer';

import 'package:eco_circuit/screens/account_screen.dart';
import 'package:eco_circuit/screens/activity_screen.dart';
import 'package:eco_circuit/screens/home_screen.dart';
import 'package:eco_circuit/screens/service_screen.dart';
import 'package:flutter/material.dart';

final List<Widget> HomeScreenItems = [
  HomeScreen(),
  ServiceScreen(),
  ActivityScreen(),
  AccountScreen(),
];
