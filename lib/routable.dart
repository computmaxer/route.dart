part of route.client;

/// If a [Routable] class is specified in the [Router.addRoute] method's mount
/// parameter, the [configureRoute] method will be executed to initialize routes
/// at that mounting point.
abstract class Routable {
  void configureRoute(Route router);
}

/// Deferred loading of routes can be achieved by specifying a RoutableFactory
/// in the [Router.addRoute] method's mount parameter.
typedef Future<Routable> RoutableFactory();
