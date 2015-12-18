library route.click_handler_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:route_hierarchical/click_handler.dart';
import 'package:route_hierarchical/client.dart';
import 'package:route_hierarchical/history_provider.dart';
import 'package:route_hierarchical/link_matcher.dart';

import 'util/mocks.dart';

main() {
  group('DefaultWindowLinkHandler', () {
    WindowClickHandler linkHandler;
    MockRouter router;
    MockWindow mockWindow;
    Element root;

    setUp(() {
      router = new MockRouter();
      mockWindow = new MockWindow();
      root = new DivElement();
      document.body.append(root);
      linkHandler = new DefaultWindowClickHandler(
          new DefaultRouterLinkMatcher(),
          router,
          true,
          mockWindow,
          (String hash) => hash.isEmpty ? '' : hash.substring(1));
    });

    tearDown(() {
      root.remove();
    });

    test('should process AnchorElements which have target set', () {
      MockMouseEvent mockMouseEvent =
          new MockMouseEvent.withAnchor(href: '#test');
      linkHandler(mockMouseEvent);
      List calls = verify(router.gotoUrl(captureAny)).captured;
      expect(calls.length, 1);
      expect(calls.single, equals('test'));
    });

    test(
        'should process AnchorElements which has target set to _blank, _self, _top or _parent',
        () {
      MockMouseEvent mockMouseEvent =
          new MockMouseEvent.withAnchor(href: '#test', target: '_blank');
      linkHandler(mockMouseEvent);

      mockMouseEvent =
          new MockMouseEvent.withAnchor(href: '#test', target: '_self');
      linkHandler(mockMouseEvent);

      mockMouseEvent =
          new MockMouseEvent.withAnchor(href: '#test', target: '_top');
      linkHandler(mockMouseEvent);

      mockMouseEvent =
          new MockMouseEvent.withAnchor(href: '#test', target: '_parent');
      linkHandler(mockMouseEvent);

      // We expect 0 calls to router.gotoUrl
      verifyNever(router.gotoUrl(any));
    });

    test('should process AnchorElements which has a child', () {
      Element anchorChild = new DivElement();

      AnchorElement anchor = new AnchorElement();
      anchor.href = '#test';
      anchor.append(anchorChild);

      MockMouseEvent mockMouseEvent =
          new MockMouseEvent(target: anchorChild, path: [anchorChild, anchor]);

      linkHandler(mockMouseEvent);
      List calls = verify(router.gotoUrl(captureAny)).captured;
      expect(calls.length, 1);
      expect(calls.single, equals('test'));
    });

    test('should be called if event triggered on anchor element', () {
      AnchorElement anchor = new AnchorElement();
      anchor.href = '#test';
      root.append(anchor);

      var router = new Router(
          useFragment: true,
          historyProvider: new HashHistory(windowImpl: mockWindow),
          clickHandler: expectAsync((Event e) {
        e.preventDefault();
      }));
      router.listen(appRoot: root);

      // Trigger handle method in linkHandler
      anchor.dispatchEvent(new MouseEvent('click'));
    });

    test('should be called if event triggered on child of an anchor element',
        () {
      Element anchorChild = new DivElement();
      AnchorElement anchor = new AnchorElement();
      anchor.href = '#test';
      anchor.append(anchorChild);
      root.append(anchor);

      var router = new Router(
          useFragment: true,
          historyProvider: new HashHistory(windowImpl: mockWindow),
          clickHandler: expectAsync((Event e) {
        e.preventDefault();
      }));
      router.listen(appRoot: root);

      // Trigger handle method in linkHandler
      anchorChild.dispatchEvent(new MouseEvent('click'));
    });
  });
}
