import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:imgx/src/img_x_cache_type.dart';
import 'package:imgx/src/image_cache/img_x_cache.dart';
import 'package:logger/logger.dart';

/// Created by lovepreetsingh on 14, November, 2024

mixin ImageSource {
  final logger = Logger(
      printer: PrettyPrinter(
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.dateAndTime,
  ));

  Uint8List? data;

  Future<Uint8List?> getImage(String url, Map<String, String> headers,
      ImgXCacheType cacheType, Duration cacheDuration, int retryCount) async {
    /**return if present from cache*/
    List<dynamic>? data =
        await ImgXCache.instance.getCacheAsync(url, cacheDuration);
    List<int>? dataInt = data?.map((e) => e as int).toList();
    if (dataInt != null) {
      this.data = Uint8List.fromList(dataInt);
      return this.data!;
    }

    for(int i = 0; i <= retryCount; i++) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        );

        if (response.statusCode == 200) {
          var imageData = response.bodyBytes;
          if (cacheType != ImgXCacheType.none) {
            ImgXCache.instance.putCache(url, imageData,
                cacheType: cacheType, cacheDuration: cacheDuration);
          }
          this.data = imageData;
          break;
        } else {
          logger.e("Error: ${response.statusCode} - ${response.reasonPhrase}");
        }
      } catch (e) {
        logger.e("Error fetching image : $e",
            error: e, stackTrace: StackTrace.current);
      }
    }

    logger.e("Exhausted all retries");
    return this.data;
  }
}
