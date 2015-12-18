// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library route.test_mocks;

import 'dart:async';
import 'dart:html';

import 'package:mockito/mockito.dart';
import 'package:route_hierarchical/client.dart';

class MockWindow extends Mock implements Window {
  final history = new MockHistory();
  final location = new MockLocation();
  final document = new MockDocument();

  StreamController _onHashChangeController;

  MockWindow() {
    when(location.host).thenReturn(window.location.host);
    when(location.hash).thenReturn('');
    when(document.title).thenReturn('page title');

    _onHashChangeController = new StreamController();
    when(this.onHashChange).thenReturn(_onHashChangeController.stream);
  }
}

class MockHistory extends Mock implements History {}

class MockLocation extends Mock implements Location {}

class MockDocument extends Mock implements HtmlDocument {}

class MockMouseEvent extends Mock implements MouseEvent {
  MockMouseEvent({EventTarget target, List<Node> path}) {
    when(this.target).thenReturn(target);
    when(this.path).thenReturn(path);
  }

  MockMouseEvent.withAnchor({String target: '', String href: ''}) {
    AnchorElement anchor = new AnchorElement();
    anchor.href = href;
    anchor.target = target;

    when(this.target).thenReturn(anchor);
    when(this.path).thenReturn([anchor]);
  }
}

class MockRouter extends Mock implements Router {}
