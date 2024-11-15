import 'package:flutter/material.dart';
import 'package:imgx/imgx.dart';

/// Created by lovepreetsingh on 15,November,2024

class ImgXConfig {
  static ImgXCacheType globalCacheType = ImgXCacheType.none;
  static Duration globalCacheDuration = const Duration(hours: 1);
  static Widget? globalProgressWidget;
  static Widget? globalErrorWidget;
  static int globalRetryCount = 0;
}