import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/service_request.dart';
import '../models/vendor.dart';
import '../models/property.dart';
import '../models/vehicle.dart';
import '../models/vendor_work.dart';
import '../models/platform_stats.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? id;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.id,
  });
}

class ApiService {
  final Dio _dio = ApiClient().dio;

  Future<String?> loginAdmin(String username, String password) async {
    final response = await _dio.post(
      ApiEndpoints.adminLogin,
      data: {'username': username, 'password': password},
    );
    if (response.statusCode == 200 && response.data is Map) {
      final data = response.data as Map;
      if (data['success'] == true) return data['token']?.toString();
    }
    return null;
  }

  Future<ApiResponse<String>> requestEmailOtp({
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.otpRequest,
        data: {'email': email, 'phone': phone},
      );
      final data = response.data is Map ? response.data as Map : const {};
      if (response.statusCode == 200 &&
          data['success'] == true &&
          data['challengeId'] != null) {
        return ApiResponse(
          success: true,
          data: data['challengeId'].toString(),
          message: data['message']?.toString(),
        );
      }
      return ApiResponse(
        success: false,
        message: data['error']?.toString() ??
            'We could not send a verification code.',
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map ? data['error']?.toString() : null;
      return ApiResponse(
        success: false,
        message: message ??
            'We could not send a code. Check your connection and try again.',
      );
    } catch (_) {
      return const ApiResponse(
        success: false,
        message:
            'We could not send a code. Check your connection and try again.',
      );
    }
  }

  Future<ApiResponse<String>> verifyEmailOtp({
    required String challengeId,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.otpVerify,
        data: {'challengeId': challengeId, 'code': code},
      );
      final data = response.data is Map ? response.data as Map : const {};
      final success = response.statusCode == 200 && data['verified'] == true;
      return ApiResponse(
        success: success,
        data: success ? data['verificationToken']?.toString() : null,
        message: data['message']?.toString() ??
            (success
                ? 'Email address verified.'
                : 'That code is incorrect or expired.'),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map ? data['error']?.toString() : null;
      return ApiResponse(
        success: false,
        data: null,
        message: message ??
            'We could not verify that code. Check your connection and try again.',
      );
    } catch (_) {
      return const ApiResponse(
        success: false,
        data: null,
        message:
            'We could not verify that code. Check your connection and try again.',
      );
    }
  }

  Future<bool> isAdminSessionValid(String token) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.adminAuthCheck,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200 &&
          response.data is Map &&
          (response.data as Map)['authenticated'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logoutAdmin() async {
    try {
      await _dio.post(ApiEndpoints.adminLogout);
    } catch (_) {
      // Clear local credentials even when the server cannot be reached.
    }
  }

  // Keep only records returned by the API in memory.
  static final List<ServiceRequest> _localRequests = [];
  static final List<Property> _localProperties = [];

  /// 1. Submit Customer Service Request
  Future<ApiResponse<ServiceRequest>> submitServiceRequest(
    ServiceRequest request, {
    String? contactVerificationToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.requests,
        data: {
          ...request.toJson(),
          if (contactVerificationToken != null)
            'contactVerificationToken': contactVerificationToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map ? response.data as Map : const {};
        final savedRequest = request.copyWith(
          id: data['requestId']?.toString() ?? data['id']?.toString(),
          agreementId: data['agreementId']?.toString(),
        );
        _localRequests.insert(0, savedRequest);
        return ApiResponse(
          success: true,
          data: savedRequest,
          id: savedRequest.id,
          message: data['message'] ?? 'Service request submitted successfully!',
        );
      }
    } catch (_) {
      return const ApiResponse(
        success: false,
        message:
            'We could not submit your request. Check your connection and try again.',
      );
    }

    return const ApiResponse(
      success: false,
      message: 'The server did not confirm your request. Please try again.',
    );
  }

  Future<List<ServiceRequest>> getAdminRequests() async {
    final response = await _dio.get(ApiEndpoints.requests);
    final payload = response.data;
    final rows = payload is Map ? payload['data'] : null;
    if (response.statusCode != 200 || rows is! List) {
      throw StateError('The dispatch queue returned an invalid response.');
    }
    final requests = rows
        .whereType<Map>()
        .map((row) => ServiceRequest.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    _localRequests
      ..clear()
      ..addAll(requests);
    return requests;
  }

  Future<bool> updateAdminRequestStatus(String requestId, String status) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.requests}/update',
        data: {'id': requestId, 'status': status},
      );
      if (response.statusCode != 200) return false;
      final index =
          _localRequests.indexWhere((request) => request.id == requestId);
      if (index >= 0) {
        _localRequests[index] = _localRequests[index].copyWith(status: status);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 2. Register Vendor (Artisan KYC)
  Future<ApiResponse<Vendor>> registerVendor(Vendor vendor) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.vendors,
        data: vendor.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: vendor.copyWith(
              id: response.data['vendorId']?.toString() ??
                  response.data['id']?.toString()),
          id: response.data['vendorId']?.toString() ??
              response.data['id']?.toString(),
          message: 'Vendor application submitted for verification!',
        );
      }
    } catch (_) {
      return const ApiResponse(
        success: false,
        message:
            'We could not submit your application. Check your connection and try again.',
      );
    }

    return const ApiResponse(
      success: false,
      message: 'The server did not confirm your application. Please try again.',
    );
  }

  Future<ApiResponse<String>> submitMarketingRequest(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.marketingRequests,
        data: payload,
      );
      final data = response.data is Map ? response.data as Map : const {};
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final id = data['requestId']?.toString() ?? data['id']?.toString();
        return ApiResponse(
          success: true,
          data: id,
          id: id,
          message: data['message']?.toString() ?? 'Submission received.',
        );
      }
      return ApiResponse(
        success: false,
        message: data['error']?.toString() ??
            'The server did not confirm your submission.',
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map ? data['error']?.toString() : null;
      return ApiResponse(
        success: false,
        message: message ??
            'We could not submit your listing. Check your connection and try again.',
      );
    } catch (_) {
      return const ApiResponse(
        success: false,
        message:
            'We could not submit your listing. Check your connection and try again.',
      );
    }
  }

  /// 3. Get Properties
  Future<List<Property>> getProperties() async {
    final response = await _dio.get(ApiEndpoints.properties);
    if (response.statusCode != 200 || response.data == null) {
      throw StateError('The properties service returned an invalid response.');
    }
    final payload = response.data;
    final list = payload is List ? payload : payload['properties'];
    if (list is! List) {
      throw StateError('The properties service returned an invalid response.');
    }
    final fetched = list
        .whereType<Map>()
        .map((item) => Property.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    _localProperties
      ..clear()
      ..addAll(fetched);
    return fetched;
  }

  Future<List<Vehicle>> getVehicles() async {
    final response = await _dio.get(ApiEndpoints.vehicles);
    if (response.statusCode != 200 || response.data == null) {
      throw StateError('The vehicles service returned an invalid response.');
    }
    final payload = response.data;
    final list = payload is List ? payload : payload['vehicles'];
    if (list is! List) {
      throw StateError('The vehicles service returned an invalid response.');
    }
    return list
        .whereType<Map>()
        .map((item) => Vehicle.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<VendorWork>> getVendorWorks() async {
    final response = await _dio.get(
      ApiEndpoints.vendorWorks,
      queryParameters: const {'status': 'active'},
    );
    if (response.statusCode != 200 || response.data == null) {
      throw StateError('The work gallery returned an invalid response.');
    }
    final payload = response.data;
    final list = payload is List ? payload : payload['works'];
    if (list is! List) {
      throw StateError('The work gallery returned an invalid response.');
    }
    return list
        .whereType<Map>()
        .map((item) => VendorWork.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// 4. Create Property (Admin)
  Future<ApiResponse<Property>> createProperty(Property property) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.properties,
        data: property.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = response.data;
        final serverProperty = payload is Map && payload['property'] is Map
            ? Property.fromJson(
                Map<String, dynamic>.from(payload['property'] as Map),
              )
            : property;
        _localProperties.insert(0, serverProperty);
        return ApiResponse(
          success: true,
          data: serverProperty,
          id: serverProperty.id,
        );
      }
    } catch (_) {
      return const ApiResponse(
        success: false,
        message:
            'The property could not be saved. Check your connection and try again.',
      );
    }
    return const ApiResponse(
      success: false,
      message: 'The server did not confirm the property. Please try again.',
    );
  }

  /// 5. Delete Property (Admin)
  Future<bool> deleteProperty(String id) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.properties}/delete',
        data: {'id': id},
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        _localProperties.removeWhere((p) => p.id == id);
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// 6. Get Platform Stats
  Future<PlatformStats> getPlatformStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.stats);
      if (response.statusCode == 200 && response.data != null) {
        final statsMap = response.data['stats'];
        if (statsMap != null) {
          return PlatformStats.fromJson(statsMap);
        }
      }
    } catch (_) {
      rethrow;
    }
    throw StateError('The statistics service returned an invalid response.');
  }

  /// Get Local/Cached Requests for Admin Portal
  List<ServiceRequest> getCachedRequests() {
    return List.unmodifiable(_localRequests);
  }

  /// Update Request Status in Admin Portal
}
