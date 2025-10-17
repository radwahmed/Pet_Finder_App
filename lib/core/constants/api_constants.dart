class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.thecatapi.com/v1/';

  // API Key
  static const String apiKey =
      'live_4wNKz013xDJO8QkiQJ7NgXuM2IZij7Slm3uHTiuyb3MeeP94bIED7toN77xfYYC2';

  // Endpoints
  static const String images = 'images';
  static const String imagesSearch = 'images/search';
  static const String imagesUpload = 'images/upload';
  static const String breeds = 'breeds';
  static const String breedsSearch = 'breeds/search';
  static const String favorites = 'favourites';

  // Headers
  static const String contentType = 'application/json';
  static const String apiKeyHeader = 'x-api-key';

  // Query Parameters
  static const String limitParam = 'limit';
  static const String pageParam = 'page';
  static const String orderParam = 'order';
  static const String sizeParam = 'size';
  static const String mimeTypesParam = 'mime_types';
  static const String formatParam = 'format';
  static const String hasBreedsParam = 'has_breeds';
  static const String queryParam = 'q';
  static const String attachImageParam = 'attach_image';

  // Default Values
  static const int defaultLimit = 10;
  static const int defaultPage = 0;
  static const String defaultOrder = 'RANDOM';
  static const String defaultSize = 'med';
  static const String defaultMimeType = 'jpg';
  static const String defaultFormat = 'json';
  static const int defaultHasBreeds = 1;
}
