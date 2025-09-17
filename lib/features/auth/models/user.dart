class User {
  final String id;
  final String email;
  final String? name;
  final String? token;

  User({required this.id, required this.email, this.name, this.token});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: json['name'] as String?,
        token: json['token'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'token': token,
      };
}
