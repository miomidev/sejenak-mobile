import 'package:flutter/foundation.dart';

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
        id: json['id'] as int?,
        googleId: json['google_id'] as dynamic,
        googleToken: json['google_token'] as dynamic,
        googleRefreshToken: json['google_refresh_token'] as dynamic,
        avatar: json['avatar'] as String?,
        username: json['username'] as String?,
        email: json['email'] as String?,
        emailVerifiedAt: json['email_verified_at'] as dynamic,
        premium: json['premium'] as int?,
        profil: json['profil'] as dynamic,
        deskripsiProfil: json['deskripsi_profil'] as dynamic,
        name: json['name'] as String?,
        isAhli: json['is_ahli'] as int?,
        role: json['role'] as String?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'google_id': googleId,
        'google_token': googleToken,
        'google_refresh_token': googleRefreshToken,
        'avatar': avatar,
        'username': username,
        'email': email,
        'email_verified_at': emailVerifiedAt,
        'premium': premium,
        'profil': profil,
        'deskripsi_profil': deskripsiProfil,
        'name': name,
        'is_ahli': isAhli,
        'role': role,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  User copyWith({
    int? id,
    dynamic googleId,
    dynamic googleToken,
    dynamic googleRefreshToken,
    String? avatar,
    String? username,
    String? email,
    dynamic emailVerifiedAt,
    int? premium,
    dynamic profil,
    dynamic deskripsiProfil,
    String? name,
    int? isAhli,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      googleId: googleId ?? this.googleId,
      googleToken: googleToken ?? this.googleToken,
      googleRefreshToken: googleRefreshToken ?? this.googleRefreshToken,
      avatar: avatar ?? this.avatar,
      username: username ?? this.username,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      premium: premium ?? this.premium,
      profil: profil ?? this.profil,
      deskripsiProfil: deskripsiProfil ?? this.deskripsiProfil,
      name: name ?? this.name,
      isAhli: isAhli ?? this.isAhli,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
    return 'User(id: $id, googleId: $googleId, googleToken: $googleToken, googleRefreshToken: $googleRefreshToken, avatar: $avatar, username: $username, email: $email, emailVerifiedAt: $emailVerifiedAt, premium: $premium, profil: $profil, deskripsiProfil: $deskripsiProfil, name: $name, isAhli: $isAhli, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! User) return false;
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
