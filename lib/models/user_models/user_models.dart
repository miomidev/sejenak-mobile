import 'package:collection/collection.dart';
import 'user.dart';

class UserModels {
  final int? code;
  final String? status;
  final String? token;
  final String? refreshToken;
  final int? expiresIn;
  final int? refreshExpiresIn;
  final User? user;
  final int? totalPost;
  final int? totalJournal;
  final int? totalLike;
  final int? journalThisMonth;
  final int? journalStreak;
  final int? postStreak;

  const UserModels({
    this.code,
    this.status,
    this.token,
    this.refreshToken,
    this.expiresIn,
    this.refreshExpiresIn,
    this.user,
    this.totalPost,
    this.totalJournal,
    this.totalLike,
    this.journalThisMonth,
    this.journalStreak,
    this.postStreak,
  });

  factory UserModels.fromJson(Map<String, dynamic> json) => UserModels(
        code: json['code'] as int?,
        status: json['status'] as String?,
        token: json['access_token'] as String? ?? json['token'] as String?,
        refreshToken: json['refresh_token'] as String?,
        expiresIn: json['expires_in'] as int?,
        refreshExpiresIn: json['refresh_expires_in'] as int?,
        user: json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>),
        totalPost: json['total_post'] as int?,
        totalJournal: json['total_journal'] as int?,
        totalLike: json['total_like'] as int?,
        journalThisMonth: json['journal_this_month'] as int?,
        journalStreak: json['journal_streak'] as int?,
        postStreak: json['post_streak'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'status': status,
        'access_token': token,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'refresh_expires_in': refreshExpiresIn,
        'user': user?.toJson(),
        'total_post': totalPost,
        'total_journal': totalJournal,
        'total_like': totalLike,
        'journal_this_month': journalThisMonth,
        'journal_streak': journalStreak,
        'post_streak': postStreak,
      };

  static List<UserModels> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => UserModels.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! UserModels) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }
  
@override
String toString() {
  return '''
UserModels(
  code: $code,
  status: $status,
  token: $token,
  refreshToken: $refreshToken,
  expiresIn: $expiresIn,
  refreshExpiresIn: $refreshExpiresIn,
  user: ${user?.toString()},
  totalPost: $totalPost,
  totalJournal: $totalJournal,
  totalLike: $totalLike,
  journalThisMonth: $journalThisMonth,
  journalStreak: $journalStreak,
  postStreak: $postStreak
)
''';
}

  @override
  int get hashCode =>
      code.hashCode ^
      status.hashCode ^
      token.hashCode ^
      user.hashCode ^
      totalPost.hashCode ^
      totalJournal.hashCode ^
      totalLike.hashCode ^
      journalThisMonth.hashCode ^
      journalStreak.hashCode ^
      postStreak.hashCode;
}
