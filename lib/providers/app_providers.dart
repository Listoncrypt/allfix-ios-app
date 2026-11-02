import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/property.dart';
import '../models/service_request.dart';
import '../models/platform_stats.dart';
import '../models/vehicle.dart';
import '../models/vendor_work.dart';

// Services
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

// Platform Stats FutureProvider
final statsProvider = FutureProvider<PlatformStats>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return await api.getPlatformStats();
});

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getVehicles();
});

final vendorWorksProvider = FutureProvider<List<VendorWork>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getVendorWorks();
});

// Properties StateNotifier
class PropertiesState {
  final List<Property> properties;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String selectedType;

  const PropertiesState({
    this.properties = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedType = 'All',
  });

  PropertiesState copyWith({
    List<Property>? properties,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedType,
  }) {
    return PropertiesState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  List<Property> get filteredProperties {
    return properties.where((p) {
      final matchesQuery = searchQuery.isEmpty ||
          p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.location.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedType == 'All' ||
          p.propertyType.toLowerCase().contains(selectedType.toLowerCase());
      return matchesQuery && matchesType;
    }).toList();
  }
}

class PropertiesNotifier extends StateNotifier<PropertiesState> {
  final ApiService _api;

  PropertiesNotifier(this._api) : super(const PropertiesState()) {
    loadProperties();
  }

  Future<void> loadProperties() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final props = await _api.getProperties();
      state = state.copyWith(properties: props, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedType(String type) {
    state = state.copyWith(selectedType: type);
  }

  Future<bool> addProperty(Property property) async {
    final response = await _api.createProperty(property);
    if (response.success && response.data != null) {
      state = state.copyWith(
        properties: [response.data!, ...state.properties],
      );
      return true;
    }
    return false;
  }

  Future<bool> removeProperty(String id) async {
    final success = await _api.deleteProperty(id);
    if (success) {
      state = state.copyWith(
        properties: state.properties.where((p) => p.id != id).toList(),
      );
      return true;
    }
    return false;
  }
}

final propertiesProvider =
    StateNotifierProvider<PropertiesNotifier, PropertiesState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return PropertiesNotifier(api);
});

// Service Requests Notifier
class RequestsState {
  final List<ServiceRequest> requests;
  final bool isSubmitting;
  final String? lastSubmittedId;
  final String? error;

  const RequestsState({
    this.requests = const [],
    this.isSubmitting = false,
    this.lastSubmittedId,
    this.error,
  });

  RequestsState copyWith({
    List<ServiceRequest>? requests,
    bool? isSubmitting,
    String? lastSubmittedId,
    String? error,
  }) {
    return RequestsState(
      requests: requests ?? this.requests,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastSubmittedId: lastSubmittedId ?? this.lastSubmittedId,
      error: error,
    );
  }
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  final ApiService _api;

  RequestsNotifier(this._api) : super(const RequestsState()) {
    refreshRequests();
  }

  void refreshRequests() {
    state = state.copyWith(requests: _api.getCachedRequests());
  }

  Future<void> loadAdminRequests() async {
    try {
      final requests = await _api.getAdminRequests();
      state = state.copyWith(requests: requests, error: null);
    } catch (_) {
      state = state.copyWith(
        error:
            'Dispatch requests could not be loaded. Check admin access or connection.',
      );
    }
  }

  Future<ApiResponse<ServiceRequest>> submitRequest(
    ServiceRequest request, {
    String? contactVerificationToken,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final response = await _api.submitServiceRequest(
      request,
      contactVerificationToken: contactVerificationToken,
    );
    if (response.success) {
      state = state.copyWith(
        isSubmitting: false,
        lastSubmittedId: response.id,
        requests: [
          if (response.data != null) response.data!,
          ...state.requests
        ],
      );
    } else {
      state = state.copyWith(
        isSubmitting: false,
        error: response.message ?? 'Submission error',
      );
    }
    return response;
  }

  Future<bool> updateStatus(String requestId, String newStatus) async {
    final saved = await _api.updateAdminRequestStatus(requestId, newStatus);
    if (saved) {
      state = state.copyWith(
        requests: state.requests.map((request) {
          return request.id == requestId
              ? request.copyWith(status: newStatus)
              : request;
        }).toList(),
        error: null,
      );
    } else {
      state = state.copyWith(error: 'Request status could not be updated.');
    }
    return saved;
  }
}

final requestsProvider =
    StateNotifierProvider<RequestsNotifier, RequestsState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return RequestsNotifier(api);
});

// Admin Auth Notifier
class AdminAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AdminAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });
}

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  final StorageService _storage;
  final ApiService _api;

  AdminAuthNotifier(this._storage, this._api)
      : super(const AdminAuthState(isLoading: true)) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    try {
      final token = await _storage.getAdminToken();
      if (token == null || token.isEmpty) {
        state = const AdminAuthState(isAuthenticated: false);
        return;
      }
      final valid = await _api.isAdminSessionValid(token);
      if (!valid) await _storage.clearAdminToken();
      state = AdminAuthState(isAuthenticated: valid);
    } catch (_) {
      state = const AdminAuthState(isAuthenticated: false);
    }
  }

  Future<bool> login(String username, String password) async {
    state = const AdminAuthState(isLoading: true);
    try {
      final token = await _api.loginAdmin(username, password);
      if (token == null || token.isEmpty) {
        state = const AdminAuthState(
          isAuthenticated: false,
          error: 'Invalid username or password.',
        );
        return false;
      }
      await _storage.saveAdminToken(token);
      state = const AdminAuthState(isAuthenticated: true);
      return true;
    } catch (_) {
      state = const AdminAuthState(
        isAuthenticated: false,
        error: 'Could not reach admin authentication. Try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logoutAdmin();
    await _storage.clearAdminToken();
    state = const AdminAuthState(isAuthenticated: false);
  }
}

final adminAuthProvider =
    StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final api = ref.watch(apiServiceProvider);
  return AdminAuthNotifier(storage, api);
});
