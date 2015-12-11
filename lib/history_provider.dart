library route.history_provider;

import 'dart:async';
import 'dart:html';

import 'package:uuid/uuid.dart';

import 'link_matcher.dart';

abstract class HistoryProvider {
  Stream get onChange;
  String get path;
  String get urlStub;

  void clickHandler(
      Event e, RouterLinkMatcher linkMatcher, Future<bool> gotoUrl(String url));
  void go(String path, String title, bool replace);
  void back();
}

//TODO - split HistoryProvider implementations into 3 separate files?

class BrowserHistory implements HistoryProvider {
  Window _window;

  BrowserHistory({Window windowImpl}) {
    _window = windowImpl ?? window;
  }

  Stream get onChange => _window.onPopState;

  String get path => '${_window.location.pathname}${_window.location.search}'
      '${_window.location.hash}';

  String get urlStub => '';

  void clickHandler(Event e, RouterLinkMatcher linkMatcher,
      Future<bool> gotoUrl(String url)) {
    Element el = e.target;
    while (el != null && el is! AnchorElement) {
      el = el.parent;
    }

    if (el == null) return;
    assert(el is AnchorElement);
    AnchorElement anchor = el;
    if (!linkMatcher.matches(anchor)) {
      return;
    }
    if (anchor.host == _window.location.host) {
      e.preventDefault();
      gotoUrl('${anchor.pathname}${anchor.search}');
    }
  }

  void go(String path, String title, bool replace) {
    if (title == null) {
      title = (_window.document as HtmlDocument).title;
    }
    if (replace) {
      _window.history.replaceState(null, title, path);
    } else {
      _window.history.pushState(null, title, path);
    }
    (_window.document as HtmlDocument).title = title;
  }

  void back() {
    _window.history.back();
  }
}

class HashHistory implements HistoryProvider {
  Window _window;

  HashHistory({Window windowImpl}) {
    _window = windowImpl ?? window;
  }

  Stream get onChange => _window.onHashChange;

  String get path => _normalizeHash(_window.location.hash);

  String get urlStub => '#';

  void clickHandler(Event e, RouterLinkMatcher linkMatcher,
      Future<bool> gotoUrl(String url)) {
    Element el = e.target;
    while (el != null && el is! AnchorElement) {
      el = el.parent;
    }

    if (el == null) return;
    assert(el is AnchorElement);
    AnchorElement anchor = el;
    if (!linkMatcher.matches(anchor)) {
      return;
    }
    if (anchor.host == _window.location.host) {
      e.preventDefault();
      gotoUrl(_normalizeHash(anchor.hash));
    }
  }

  void go(String path, String title, bool replace) {
    if (replace) {
      _window.location.replace('#$path');
    } else {
      _window.location.assign('#$path');
    }
    if (title != null) {
      (_window.document as HtmlDocument).title = title;
    }
  }

  void back() {
    _window.history.back();
  }

  String _normalizeHash(String hash) => hash.isEmpty ? '' : hash.substring(1);
}

class MemoryHistory implements HistoryProvider {
  // keep a list of urls
  List<String> _urlList;

  // keep track of a unique namespace for internal urls
  final String _namespace = 'router${new Uuid().v4()}:';

  // broadcast changes to url
  StreamController<String> _urlStreamController;
  Stream<String> _urlStream;

  MemoryHistory() {
    _urlList = [''];
    _urlStreamController = new StreamController<String>();
    _urlStream = _urlStreamController.stream.asBroadcastStream();
  }

  Stream get onChange => _urlStream;

  String get path => _urlList.isNotEmpty ? _urlList.last : '';

  String get urlStub => _namespace;

  void clickHandler(Event e, RouterLinkMatcher linkMatcher,
      Future<bool> gotoUrl(String url)) {
    Element el = e.target;
    while (el != null && el is! AnchorElement) {
      el = el.parent;
    }

    if (el == null) return;
    assert(el is AnchorElement);
    AnchorElement anchor = el;
    if (!linkMatcher.matches(anchor)) {
      return;
    }
    if (anchor.origin.startsWith(urlStub)) {
      e.preventDefault();
      gotoUrl(anchor.pathname);
    }
  }

  void go(String path, String title, bool replace) {
    if (replace) {
      _urlList.removeLast();
    }
    _urlList.add(path);
    _urlStreamController.add(path);
  }

  void back() {
    if (_urlList.length > 1) {
      _urlList.removeLast();
      _urlStreamController.add(_urlList.last);
    }
  }

  String _normalizeHash(String hash) => hash.isEmpty ? '' : hash.substring(1);
}
