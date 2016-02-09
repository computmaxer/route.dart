part of route.client;

abstract class Routable {
  void configureRoute(Route router);
}

typedef Future<Routable> RoutableFactory();
