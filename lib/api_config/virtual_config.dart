class VirtualTryOnConfig {
  // Replace this with your actual API key from fashn.ai
  static const String apiKey = 'YOUR_API_KEY';

  // API endpoint
  static const String apiUrl = 'https://api.fashn.ai/v1/run';

  // Model name for virtual try-on
  static const String modelName = 'tryon-v1.6';

  // Timeout settings
  static const int requestTimeoutSeconds = 60;
  static const int downloadTimeoutSeconds = 30;

  // Check if API key is properly configured
  static bool get isApiKeyConfigured {
    return apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY';
  }

  // Get API key with validation
  static String getApiKey() {
    if (!isApiKeyConfigured) {
      throw Exception('API key not configured. Please update the apiKey in virtual_config.dart');
    }
    return apiKey;
  }
}