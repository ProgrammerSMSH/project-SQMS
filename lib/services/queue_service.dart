import 'api_service.dart';

class QueueService {
  final ApiService api;

  QueueService(this.api);

  Future<List<dynamic>> getQueues() async {
    final response = await api.get('/queues');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> generateToken(String queueId, {String priority = 'NORMAL'}) async {
    final response = await api.post('/tokens/generate', {
      'queueId': queueId,
      'priority': priority,
    });
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getActiveTokens() async {
    final response = await api.get('/tokens/active');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getHistoryTokens() async {
    final response = await api.get('/tokens/history');
    return response as List<dynamic>;
  }
}
