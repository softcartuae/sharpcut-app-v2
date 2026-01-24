class ServerPrinter {
  final String? name;
  final int? width;

  ServerPrinter({this.name, this.width});

  factory ServerPrinter.fromJson(Map<String, dynamic> json) {
    return ServerPrinter(name: json['name'], width: json['width']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'width': width};
  }
}
