import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqms_app/services/api_service.dart';

class SyncService extends ChangeNotifier {
  ApiService _apiService;
  Timer? _pollingTimer;
  bool _isActive = false;

  // Stored state
  List<dynamic> activeTokens = [];
  bool isLoading = true;

  SyncService(this._apiService);
 
  void updateApi(ApiService newApi) {
    _apiService = newApi;
    if (_isActive) _fetchData();
  }

  void startSyncing() {
    if (_isActive) return;
    _isActive = true;
    _fetchData(); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
  }

  void stopSyncing() {
    _isActive = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchData() async {
    try {
      final response = await _apiService.get('/tokens/active');
      if (response != null && response is List) {
        activeTokens = response;
      } else if (response != null && response['tokens'] is List) {
        activeTokens = response['tokens'];
      } else {
        activeTokens = [];
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("SyncService Error: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopSyncing();
    super.dispose();
  }
}
