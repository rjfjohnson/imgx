library;

import 'package:flutter/cupertino.dart';
import 'package:imgx/src/cache/img_x_cache.dart';
import 'package:imgx/src/image_widget/img_x_widget.dart';

export 'src/cache/cache_type.dart';
export 'src/config/img_x_config.dart';

class ImgX extends ImgXLoader {
  const ImgX(
      {super.key,
      required super.imageUri,
      super.width,
      super.height,
      super.fit = BoxFit.cover,
      super.headers,
      super.retryCount,
      super.progressWidget,
      super.errorWidget,
      super.cacheType,
      super.cacheDuration,
      super.onProgress});

  void removeCacheWhere({required String key}) {
    ImgXCache.instance.remove(key);
  }

  void removeAllCache() {
    ImgXCache.instance.removeAll();
  }
}
