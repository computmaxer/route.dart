Route Hierarchical
=====
[![Build Status](https://travis-ci.org/Workiva/route.dart.svg?branch=master)](https://travis-ci.org/Workiva/route.dart) [![codecov.io](http://codecov.io/github/Workiva/route.dart/coverage.svg?branch=master)](http://codecov.io/github/Workiva/route.dart?branch=master)

Route Hierarchical is a client-side routing library for Dart single-page web apps. This router supports a hierarchical tree of routes and provides methods for handling specified URL paths, listening to web browser history events, and creating HTML event handlers that navigate to a URL.

Installation
------------

Add this package to your pubspec.yaml file:

    dependencies:
      route_hierarchical: any

Then, run `pub get` to download the package.

UrlMatcher
----------
Route Hierarchical is built around `UrlMatcher`, an interface that defines URL template parsing, matching and reversing.

UrlTemplate
-----------
The default implementation of the `UrlMatcher` is `UrlTemplate`. `UrlTemplate` supports both static and parameterized route segments. For example, a URL of the form `/article/1234` can be matched by the template `/article/:articleId` to activate an `article` route with an `articleId` parameter value of `1234`.

Router
--------------
Router is a stateful object that contains routes and can perform URL routing operations on those routes.

The `Router` can listen to web browser history events and invoke the correct handlers so that the browser's back and forward buttons work seamlessly.

Example Usage:

```dart
import 'package:route_hierarchical/client.dart';

main() {
  var router = new Router();
  router.root
    ..addRoute(name: 'article', path: '/article/:articleId', enter: showArticle)
    ..addRoute(name: 'home', defaultRoute: true, path: '/', enter: showHome);
  router.listen();
}

void showHome(RouteEvent e) {
  // Display the Home page
  // (there is no data to parse from this path)
}

void showArticle(RouteEvent e) {
  // Display an Article page
  var articleId = e.parameters['articleId'];
  // Show article page with loading indicator
  // Load article from server, then render article
}
```

`Router` supports nested routes:

```dart
var router = new Router();
router.root
  ..addRoute(
     name: 'usersList',
     path: '/users',
     defaultRoute: true,
     enter: showUsersList)
  ..addRoute(
     name: 'user',
     path: '/user/:userId',
     mount: (router) =>
       router
         ..addRoute(
             name: 'articleList',
             path: '/acticles',
             defaultRoute: true,
             enter: showArticlesList)
         ..addRoute(
             name: 'article',
             path: '/article/:articleId',
             mount: (router) =>
               router
                 ..addRoute(
                     name: 'view',
                     path: '/view',
                     defaultRoute: true,
                     enter: viewArticle)
                 ..addRoute(
                     name: 'edit',
                     path: '/edit',
                     enter: editArticle)))
```

The `mount` parameter accepts either a function that accepts an instance of a new
child router as the only parameter, or an instance of an object that implements
Routable interface.


  /// An additional level of child nodes can be [mount]ed as children of this
  /// new [Route] by supplying a [Routable] object, a [RoutableFactory], or a
  /// simple [Function](Route router).



In either case, the child router is instantiated by the parent router an
injected into the mount point, at which point child router can be configured
with new routes.

Routing with hierarchical router: when the parent router performs a prefix
match on the URL, it removes the matched part from the URL and invokes the
child router with the remaining tail.

For instance, with the above example lets consider this URL: `/user/jsmith/article/1234`.
Route "user" will match `/user/jsmith` and invoke the child router with `/article/1234`.
Route "article" will match `/article/1234` and invoke the child router with ``.
Route "view" will be matched as the default route.
The resulting route path will be: `user -> article -> view`, or simply `user.article.view`

Named Routes in Hierarchical Routers
------------------------------------

```dart
router.go('usersList');
router.go('user.articles', {'userId': 'jsmith'});
router.go('user.article.view', {
  'userId': 'jsmith',
  'articleId', 1234}
);
router.go('user.article.edit', {
  'userId': 'jsmith',
  'articleId', 1234}
);
```

If "go" is invoked on child routers, the router can automatically reconstruct
and generate the new URL from the state in the parent routers.
