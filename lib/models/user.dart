class AppUser {
  final String name;
  final String email;
  final String password;

  const AppUser({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: json['name'],
        email: json['email'],
        password: json['password'],
      );
}
