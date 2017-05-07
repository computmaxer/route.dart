part of route.history_provider;

/// [HistoryProvider] that uses pure paths (e.g. http://base/my/route) and
/// manages url history via [History.pushState] and [History.replaceState].
class BrowserHistory implements HistoryProvider {
  Window _window;
  String _pageTitle;

  BrowserHistory({Window windowImpl}) {
    _window = windowImpl ?? window;
  }

  Stream get onChange => _window.onPopState;

  String get path => '${_window.location.pathname}${_window.location.search}'
      '${_window.location.hash}';

  String get urlStub => '';

  String get pageTitle =>
      _pageTitle ?? (_window.document as HtmlDocument).title;

  void set pageTitle(String title) {
    if (title != null) {
      _pageTitle = title;
      (_window.document as HtmlDocument).title = _pageTitle;
    }
  }

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
    if (anchor.target != null && anchor.target.isNotEmpty) {
      // Prevent router from swallowing links that should open in another window
      return;
    }
    if (anchor.host == _window.location.host) {
      e.preventDefault();
      gotoUrl('${anchor.pathname}${anchor.search}');
    }
  }

  void go(String path, bool replace) {
    if (replace) {
      _window.history.replaceState(null, pageTitle, path);
    } else {
      _window.history.pushState(null, pageTitle, path);
    }
  }

  void back() {
    _window.history.back();
  }
}
