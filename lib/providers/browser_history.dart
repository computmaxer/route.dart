part of route.history_provider;

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
