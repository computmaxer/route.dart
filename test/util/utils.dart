library route.test.util.utils;

import 'dart:async';

import 'package:route_hierarchical/client.dart';

Future nextTick() {
  return new Future.delayed(new Duration(milliseconds: 1));
}

String nameFromRouteList(List<Route> routeList) {
  String delimitedName = '';
  routeList.forEach((route) => delimitedName += '.${route.name}');
  if (delimitedName.length > 0) {
    delimitedName = delimitedName.substring(1);
  }
  return delimitedName;
}
