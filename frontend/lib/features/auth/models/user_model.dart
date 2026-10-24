/// The signed-in user, as our backend returns it from `GET /auth/me`.
class UserModel {
  const UserModel({required this.id, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'] as String, email: json['email'] as String);
  }

  final String id;
  final String email;
}
