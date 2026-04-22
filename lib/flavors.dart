enum Flavor {
  production(
    title: 'TACIT Mobile',
    tacitUrl: 'http://192.168.1.137:8642',
  ),
  staging(
    title: 'TACIT Mobile (Dev)',
    tacitUrl: 'http://localhost:8642',
  );

  const Flavor({
    required this.title,
    required this.tacitUrl,
  });

  final String title;
  final String tacitUrl;
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;
  static String get title => appFlavor.title;
  static String get tacitUrl => appFlavor.tacitUrl;
}
