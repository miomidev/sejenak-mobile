import 'package:collection/collection.dart';

class User {
  final int? id;
  final dynamic googleId;
  final dynamic googleToken;
  final dynamic googleRefreshToken;
  final String? avatar;
  final String? username;
  final String? email;
  final dynamic emailVerifiedAt;
  final int? premium;
  final dynamic profil;
  final dynamic deskripsiProfil;
  final String? name;
  final int? isAhli;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    this.googleId,
    this.googleToken,
    this.googleRefreshToken,
    this.avatar,
    this.username,
    this.email,
    this.emailVerifiedAt,
    this.premium,
    this.profil,
    this.deskripsiProfil,
    this.name,
    this.isAhli,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id'].toString()),
        googleId: json['google_id']?.toString(),
        googleToken: json['google_token']?.toString(),
        googleRefreshToken: json['google_refresh_token']?.toString(),
        username: json['username']?.toString(),
        email: json['email']?.toString(),
        avatar: json['avatar']?.toString(),
        emailVerifiedAt: json['email_verified_at'] == null
            ? null
            : DateTime.tryParse(json['email_verified_at'].toString()),
        premium: json['premium'] is int
            ? json['premium'] as int
            : int.tryParse(json['premium'].toString()),
        profil: json['profil']?.toString(),
        deskripsiProfil: json['deskripsiProfil']?.toString(),
        name: json['name']?.toString(),
        isAhli: json['isAhli'] is int
            ? json['isAhli'] as int
            : int.tryParse(json['isAhli'].toString()),
        role: json['role']?.toString(),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'].toString()),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.tryParse(json['updated_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'google_id': googleId,
        'google_token': googleToken,
        'google_refresh_token': googleRefreshToken,
        'username': username,
        'email': email,
        'avatar': avatar,
        'email_verified_at': emailVerifiedAt,
        'premium': premium,
        'profil': profil,
        'deskripsiProfil': deskripsiProfil,
        'name': name,
        'isAhli': isAhli,
        'role': role,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static List<Map<String, dynamic>> toJsonList(List<User> users) {
    return users.map((user) => user.toJson()).toList();
  }

  static List<User> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() {
    return '''
User(
  id: $id,
  username: $username,
  name: $name,
  email: $email,
  role: $role,
  isAhli: $isAhli,
  premium: $premium,
  profil: $profil,
  deskripsiProfil: $deskripsiProfil,
  avatar: $avatar,
  googleId: $googleId,
  createdAt: $createdAt,
  updatedAt: $updatedAt
)
''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! User) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      id.hashCode ^
      googleId.hashCode ^
      googleToken.hashCode ^
      googleRefreshToken.hashCode ^
      username.hashCode ^
      email.hashCode ^
      emailVerifiedAt.hashCode ^
      premium.hashCode ^
      profil.hashCode ^
      deskripsiProfil.hashCode ^
      name.hashCode ^
      isAhli.hashCode ^
      role.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
