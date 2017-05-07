/// Provides url history data and operations that aid in [Router]'s url routing.
/// This library supplies [HistoryProvider] implementations ([BrowserHistory],
/// [HashHistory], and [MemoryHistory]) that rely on different underlying
/// web browser / memory APIs.
library route.history_provider;

import 'dart:async';
import 'dart:html';

import 'package:uuid/uuid.dart';

import 'link_matcher.dart';

part 'providers/browser_history.dart';
part 'providers/hash_history.dart';
part 'providers/memory_history.dart';

abstract class HistoryProvider {
  /// Stream that receives an event whenever the url changes.
  Stream get onChange;

  /// Current url path.
  String get path;

  /// Current url stub.
  String get urlStub;

  /// Current page title.
  String pageTitle;

  /// Handler for mouse clicks within the web browser window. Default mouse
  /// click handling can be circumvented via e.preventDefault();
  void clickHandler(
      Event e, RouterLinkMatcher linkMatcher, Future<bool> gotoUrl(String url));

  /// Navigates to the specified url. [replace] indicates whether the url should
  /// append to the existing url history or replace the most recent entry.
  void go(String path, bool replace);

  /// Navigates to the previous url.
  void back();
}
