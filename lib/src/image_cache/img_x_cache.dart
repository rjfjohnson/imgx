import 'package:imgx/src/cache_type.dart';
import 'package:imgx/src/image_cache/preferences.dart';

import 'cache_item.dart';

/// Created by Lovepreet Singh on 20/12/22.

class DiskCacheModel {
  dynamic data;
  int cacheTime;
  int expiryDuration; //in days

  DiskCacheModel({required this.data, required this.cacheTime, this.expiryDuration = 2});

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'cacheTime': cacheTime,
      'expiryDuration': expiryDuration,
    };
  }
}

class ImgXCache with Preferences{
  ImgXCache._();
  static ImgXCache instance = ImgXCache._();
  final _defaultDuration = const Duration(hours: 1).inMilliseconds;

  Map<String, dynamic> cacheMap = {};

  void putCache(String key, dynamic data,
      {CacheType cacheType = CacheType.memory}) {
    if (cacheType == CacheType.memory) {
      cacheMap[key] = CacheItem(DateTime.now().millisecondsSinceEpoch, data);
      return;
    }
    /** save in disk */
    super.saveImageCache(
        key,
        DiskCacheModel(
          data: data,
          cacheTime: DateTime.now().millisecondsSinceEpoch,
        ));
  }

  dynamic getCache(String key) => _getFromMemory(key);

  Future<dynamic> getCacheAsync(String key) async {
    dynamic data = _getFromMemory(key);
    if (data != null) {
      return data;
    }
    return await _getFromDisk(key);
  }

  dynamic _getFromMemory(String key) {
    var item = cacheMap[key];
    if (item == null) {
      return null;
    }
    item = item as CacheItem;
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    bool hasCacheExpired = nowTime > item.cacheTime + _defaultDuration;
    if (hasCacheExpired) {
      cacheMap.remove(key);
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
    bool hasCacheExpired = nowTime >
        (cachedData.cacheTime +
            (cachedData.expiryDuration * 24 * 60 * 60 * 1000));
    if (hasCacheExpired) {
      super.remove(key);
      return null;
    }
    return cachedData.data;
  }

  void removeWhere(String keyword) {
    cacheMap.removeWhere((key, value) => key.contains(keyword));
  }

  void removeAll() {
    cacheMap.clear();
  }
}
