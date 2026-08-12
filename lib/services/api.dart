import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:selena/session/user_session.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class API {
  // Use String.fromEnvironment to allow overriding via --dart-define
  static const String _baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://sejenak.miomidev.com');
  
  static const String endpoint = "$_baseUrl/api";
  static const String endpointImage = "$_baseUrl/";


  // Authentication
  static const String login = "$endpoint/login";
  static const String register = "$endpoint/register";
  static const String googleAuth = "$endpoint/googleAuth";
  static const String getProfile = "$endpoint/me";
  static const String refreshToken = "$endpoint/refresh";
  static const String logout = "$endpoint/logout";

  // Verification
  static const String verification = "$endpoint/verify-code";
  static const String resendCode = "$endpoint/resend-verification";

  // Journal
  static const String journal = "$endpoint/journal";
  static String journalDetail(int id) => "$journal/$id";
  static const String journalSearch = "$journal/search";
  static const String journalStats = "$journal/stats";

  // Moods
  static const String moods = "$endpoint/moods";
  static String moodDetail(int id) => "$moods/$id";
  static const String moodStatistics = "$moods/statistics";

  // Audios
  static const String audios = "$endpoint/audios";
  static String audioDetail(int id) => "$audios/$id";
  static String audioByCategory(String category) =>
      "$audios/category/$category";
  static String playAudio(int id) => "$audios/$id/play";

  // Community (Note: ada typo di Postman - 'comunity' seharusnya 'community')
  static const String community = "$endpoint/comunity";
  static const String communityComments = "$community/comments";
  static String communityCommentDetail(int id) => "$communityComments/post/$id";
  static const String communityReplies = "$community/replies";
  static const String communityLikes = "$community/likes";
  static String communityLikeDetail(int id) => "$communityLikes/$id";
  static const String communityLikeToggle = "$communityLikes/toggle";
  static const String allPost = "$community/getPost";
  static const String communityCreatePost = "$community/posts"; 
   static const String myPosts = "$community/posts/my-posts";
static String communityDetailPost(int id) => "$community/posts/$id";  
static String communityUpdatePost(int id) => "$community/posts/$id"; 
static String communityDeletePost(int id) => "$community/posts/$id";

  // Konselor & Counseling
  static const String counselors = "$endpoint/counselors";
  static const String sessionRequest = "$endpoint/sessions/request";
  static const String mySessions = "$endpoint/sessions";

  // Proposals
  static const String proposals = "$endpoint/proposals";
  static const String myProposal = "$endpoint/proposals/my";

  // Counseling additional
  static const String sessionPrice = '$endpoint/sessions/price';
  
  // Transactions
  static const String tokenPackages = '$endpoint/transactions/token-packages';
  static const String checkout = '$endpoint/transactions/checkout';
  static const String myTransactions = "$endpoint/transactions";

  // Dashboard & Profile
  static const String dashboard = "$endpoint/dashboard";
  static const String profile = "$endpoint/profile";
  static const String updateProfile = "$profile/update";

  // Meditation
  static const String meditationDaily = "$endpoint/meditation/daily";
  static const String meditationAudios = "$endpoint/meditation/audios";
  static const String chatBot = "$endpoint/chat-bot";

  // Midtrans
  static const String midtransCallback = "$endpoint/midtrans/callback";

  // V2 - Human Capacity AI Engine
  static const String v2SyncSensors = "$endpoint/v2/human-capacity/sync-sensors";
  static const String v2CapacityIndex = "$endpoint/v2/human-capacity/index";
  static const String v2CapacityExplain = "$endpoint/v2/human-capacity/explain";
  static const String v2CapacityForecast = "$endpoint/v2/human-capacity/forecast";
  static const String v2Recommendations = "$endpoint/v2/recommendations/adaptive";
  static const String v2Notifications = "$endpoint/v2/notifications/smart";
  static const String v2AiChat = "$endpoint/v2/ai-chat";
}

abstract class HttpClient {
  Future<Response> post(String url, {dynamic data});
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters});
  Future<Response> put(String url, {dynamic data});
  Future<Response> delete(String url, {dynamic data});
  Future<Response> postFormData(String url, FormData formData);
  Future<Response> patch(String url, {dynamic data});
}

class DioHttpClient implements HttpClient {
  static final DioHttpClient _instance = DioHttpClient._internal();
  final Dio _dio;
  String _authToken = '';

  DioHttpClient._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: API.endpoint,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )) {
    _setupInterceptors();
  }

  factory DioHttpClient.getInstance() {
    return _instance;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Sending ${options.method} request to ${options.uri}');
        
        if (options.data is FormData) {
          print('FormData with fields: ${(options.data as FormData).fields}');
          if ((options.data as FormData).files.isNotEmpty) {
            print('Files: ${(options.data as FormData).files.map((f) => f.key).toList()}');
          }
        } else {
          var logData = options.data;
          if (logData is Map) {
            logData = Map.from(logData);
            if (logData.containsKey('password')) {
              logData['password'] = '***';
            }
            if (logData.containsKey('password_confirmation')) {
              logData['password_confirmation'] = '***';
            }
          }
          print('Data: $logData');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response received: ${response.statusCode}');
        print('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Dio Error: ${e.type}');
        print('Message: ${e.message}');
        print('Response: ${e.response?.data}');
        print('Status: ${e.response?.statusCode}');

        // Jika status 401, lakukan redirect ke landing page
        if (e.response?.statusCode == 401) {
          _handleUnauthorized();
        }

        return handler.next(e);
      },
    ));
  }

  void _handleUnauthorized() async {
    await UserSession().clearUser();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/landing-page',
      (route) => false,
    );
  }

  void setToken(String token) {
    _authToken = token;
    _dio.options.headers["Authorization"] = "Bearer $token";
    print('Authentication token set');
  }

  void clearToken() {
    _authToken = '';
    _dio.options.headers.remove("Authorization");
    print('🔒 Authentication token cleared');
  }
 @override
  Future<Response> patch(String url, {dynamic data}) async {
    try {
      return await _dio.patch(url, data: data, options: _getOptions());
    } on DioException catch (e) {
      _logDetailedError(e, url, 'PATCH');
      rethrow;
    }
  }
  @override
  Future<Response> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(url,
          queryParameters: queryParameters, options: _getOptions());
    } on DioException catch (e) {
      _logDetailedError(e, url, 'GET');
      rethrow;
    }
  }

  @override
  Future<Response> post(String url, {dynamic data}) async {
    
    try {
      return await _dio.post(url, data: data, options: _getOptions());
    } on DioException catch (e) {
      _logDetailedError(e, url, 'POST');
      rethrow;
    }
  }

  @override
  Future<Response> postFormData(String url, FormData formData) async {
    try {
      return await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $_authToken",
            "Content-Type": "multipart/form-data",
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
    } on DioException catch (e) {
      _logDetailedError(e, url, 'POST FormData');
      rethrow;
    }
  }

  @override
  Future<Response> put(String url, {dynamic data}) async {
    try {
      return await _dio.put(url, data: data, options: _getOptions());
    } on DioException catch (e) {
      _logDetailedError(e, url, 'PUT');
      rethrow;
    }
  }

  @override
  Future<Response> delete(String url, {dynamic data}) async {
    try {
      return await _dio.delete(url, data: data, options: _getOptions());
    } on DioException catch (e) {
      _logDetailedError(e, url, 'DELETE');
      rethrow;
    }
  }

  Options _getOptions() {
    return Options(
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (_authToken.isNotEmpty) "Authorization": "Bearer $_authToken"
      },
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  void _logDetailedError(DioException e, String url, String method) {
    print('''
🚨 HTTP ERROR DETAILS
=====================
Request: $method $url
Error Type: ${e.type}
Message: ${e.message}
Status Code: ${e.response?.statusCode ?? 'N/A'}
Response Data: ${e.response?.data ?? 'No response data'}
Request Data: ${e.requestOptions.data}
    ''');
  }
}
