part of route.history_provider;

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
