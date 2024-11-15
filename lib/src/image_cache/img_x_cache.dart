import 'package:imgx/src/img_x_cache_type.dart';
import 'package:imgx/src/image_cache/preferences.dart';

import 'cache_item.dart';

/// Created by Lovepreet Singh on 20/12/22.

class DiskCacheModel {
  dynamic data;
  int cacheTime;
  int expiryDuration; //in days

  DiskCacheModel(
      {required this.data,
      required this.cacheTime,
      required this.expiryDuration});

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'cacheTime': cacheTime,
      'expiryDuration': expiryDuration,
    };
  }
}

class ImgXCache with Preferences {
  ImgXCache._();
  static ImgXCache instance = ImgXCache._();

  Map<String, dynamic> cacheMemoryMap = {};

  void putCache(String key, dynamic data,
      {required ImgXCacheType cacheType, required Duration cacheDuration}) {
    if (cacheType == ImgXCacheType.memory) {
      cacheMemoryMap[key] = CacheItem(DateTime.now().millisecondsSinceEpoch, data);
      return;
    }
    /** save in disk */
    super.saveImageCache(
        key,
        DiskCacheModel(
            data: data,
            cacheTime: DateTime.now().millisecondsSinceEpoch,
            expiryDuration: cacheDuration.inMilliseconds));
  }

  dynamic getCache(String key, Duration cacheDuration) =>
      _getFromMemory(key, cacheDuration);

  Future<dynamic> getCacheAsync(String key, Duration cacheDuration) async {
    dynamic data = _getFromMemory(key, cacheDuration);
    if (data != null) {
      return data;
    }
    return await _getFromDisk(key);
  }

  dynamic _getFromMemory(String key, Duration cacheDuration) {
    var item = cacheMemoryMap[key];
    if (item == null) {
      return null;
    }
    item = item as CacheItem;
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    bool hasCacheExpired =
        nowTime > item.cacheTime + cacheDuration.inMilliseconds;
    if (hasCacheExpired) {
      cacheMemoryMap.remove(key);
      return null;
    }
    return item.data;
  }

  dynamic _getFromDisk(String key) async {
    DiskCacheModel? cachedData = await super.getImageCache(key);
    if (cachedData == null) {
      return null;
    }
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    bool hasCacheExpired =
        nowTime > (cachedData.cacheTime + cachedData.expiryDuration);
    if (hasCacheExpired) {
      super.remove(key);
      return null;
    }
    return cachedData.data;
  }

  void removeWhere(String keyword) {
    cacheMemoryMap.removeWhere((key, value) => key.contains(keyword));
  }

  void removeAll() {
    cacheMemoryMap.clear();
  }
}
