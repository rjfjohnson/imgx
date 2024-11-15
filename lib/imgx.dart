library;

import 'package:flutter/cupertino.dart';
import 'package:imgx/src/image_loader.dart';

export 'src/img_x_cache_type.dart';
export 'src/img_x_config.dart';

class ImgX extends ImageLoader {
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
      super.cacheDuration});
}
