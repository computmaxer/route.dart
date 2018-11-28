@TestOn('browser')
library route.url_template_test;

import 'package:test/test.dart';
import 'package:route_hierarchical/url_template.dart';
import 'package:route_hierarchical/url_matcher.dart';

main() {
  group('UrlTemplate', () {
    test('toString should return stringified url pattern', () {
      final tmpl = new UrlTemplate('/foo/bar:baz/aux');
      expect(tmpl.urlParameterNames, equals(['baz']));
      expect(
          tmpl.toString(),
          allOf(startsWith('UrlTemplate('), contains('^/foo/bar([^/?]+)/aux'),
              endsWith(')')));
    });

    test('should work with simple templates', () {
      UrlTemplate tmpl = new UrlTemplate('/foo/bar:baz/aux');
      expect(tmpl.urlParameterNames, equals(['baz']));
      expect(tmpl.match('/foo/bar123/aux'),
          new UrlMatch('/foo/bar123/aux', '', {'baz': '123'}));

      tmpl = new UrlTemplate('/foo/:bar');
      expect(tmpl.urlParameterNames, equals(['bar']));
      expect(
          tmpl.match('/foo/123'), new UrlMatch('/foo/123', '', {'bar': '123'}));

      tmpl = new UrlTemplate('/:foo/bar');
      expect(tmpl.urlParameterNames, equals(['foo']));
      expect(
          tmpl.match('/123/bar'), new UrlMatch('/123/bar', '', {'foo': '123'}));

      tmpl = new UrlTemplate('/user/:userId/article/:articleId/view');
      expect(tmpl.urlParameterNames, equals(['userId', 'articleId']));
      UrlMatch params =
          tmpl.match('/user/jsmith/article/1234/view/someotherstuff');
      expect(
          params,
          new UrlMatch('/user/jsmith/article/1234/view', '/someotherstuff',
              {'userId': 'jsmith', 'articleId': '1234'}));

      params = tmpl.match('/user/jsmith/article/1234/edit');
      expect(params, isNull);

      tmpl = new UrlTemplate(r'/foo/:bar$123/aux');
      expect(tmpl.urlParameterNames, equals(['bar']));
      expect(tmpl.match(r'/foo/123$123/aux'),
          new UrlMatch(r'/foo/123$123/aux', '', {'bar': '123'}));
    });

    test('should work with special characters', () {
      UrlTemplate tmpl = new UrlTemplate(r'\^\|+[]{}()');
      expect(tmpl.match(r'\^\|+[]{}()'), new UrlMatch(r'\^\|+[]{}()', '', {}));

      tmpl = new UrlTemplate(r'/:foo/^\|+[]{}()');
      expect(tmpl.urlParameterNames, equals(['foo']));
      expect(tmpl.match(r'/123/^\|+[]{}()'),
          new UrlMatch(r'/123/^\|+[]{}()', '', {'foo': '123'}));
    });

    test('should only match prefix', () {
      final tmpl = new UrlTemplate(r'/foo');
      expect(
          tmpl.match(r'/foo/foo/bar'), new UrlMatch(r'/foo', '/foo/bar', {}));
    });

    test('should match without leading slashes', () {
      final tmpl = new UrlTemplate(r'foo');
      expect(tmpl.match(r'foo'), new UrlMatch(r'foo', '', {}));
    });

    test('should reverse', () {
      UrlTemplate tmpl = new UrlTemplate('/:a/:b/:c');
      expect(tmpl.urlParameterNames, equals(['a', 'b', 'c']));
      expect(tmpl.reverse(), '/null/null/null');
      expect(tmpl.reverse(parameters: {'a': 'foo', 'b': 'bar', 'c': 'baz'}),
          '/foo/bar/baz');

      tmpl = new UrlTemplate(':a/bar/baz');
      expect(tmpl.urlParameterNames, equals(['a']));
      expect(tmpl.reverse(), 'null/bar/baz');
      expect(
          tmpl.reverse(parameters: {
            'a': '/foo',
          }),
          '/foo/bar/baz');

      tmpl = new UrlTemplate('/foo/bar/:c');
      expect(tmpl.urlParameterNames, equals(['c']));
      expect(tmpl.reverse(), '/foo/bar/null');
      expect(
          tmpl.reverse(parameters: {
            'c': 'baz',
          }),
          '/foo/bar/baz');

      tmpl = new UrlTemplate('/foo/bar/:c');
      expect(tmpl.urlParameterNames, equals(['c']));
      expect(
          tmpl.reverse(tail: '/tail', parameters: {
            'c': 'baz',
          }),
          '/foo/bar/baz/tail');
    });

    test('should conditionally allow slashes in parameters', () {
      UrlTemplate tmpl = new UrlTemplate('/foo/:bar');
      expect(tmpl.urlParameterNames, equals(['bar']));
      expect(tmpl.match('/foo/123/456'),
          new UrlMatch('/foo/123', '/456', {'bar': '123'}));

      tmpl = new UrlTemplate('/foo/:bar*');
      expect(tmpl.urlParameterNames, equals(['bar*']));
      expect(tmpl.match('/foo/123/456'),
          new UrlMatch('/foo/123/456', '', {'bar*': '123/456'}));

      tmpl = new UrlTemplate('/foo/:bar*/baz');
      expect(tmpl.urlParameterNames, equals(['bar*']));
      expect(tmpl.match('/foo/123/456/baz'),
          new UrlMatch('/foo/123/456/baz', '', {'bar*': '123/456'}));
    });
  });
}
