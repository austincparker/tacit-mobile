enum Flavor {
  production(
    title: 'Flutter App Base',
    apiUrl: 'https://api.example.com',
  ),
  staging(
    title: 'Flutter App Base (Staging)',
    apiUrl: 'https://staging-api.example.com',
  );

  const Flavor({
    required this.title,
    required this.apiUrl,
  });

  final String title;
  final String apiUrl;
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;
  static String get title => appFlavor.title;
  static String get apiUrl => appFlavor.apiUrl;
}
