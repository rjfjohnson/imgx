import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imgx/src/config/img_x_config.dart';
import 'package:imgx/src/cache/cache_type.dart';
import 'package:imgx/src/image_widget/img_x_source.dart';

/// Created by lovepreetsingh on 14,November,2024

class ImgXLoader extends StatefulWidget {
  final String imageUri;
  final BoxFit fit;
  final Widget? progressWidget;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final CacheType? cacheType;
  final Duration? cacheDuration;
  final Map<String, String> headers;
  final int? retryCount;
  final Function(double progress)? onProgress;

  const ImgXLoader(
      {required this.imageUri,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.progressWidget,
      this.errorWidget,
      this.cacheType,
      this.headers = const {},
      this.retryCount,
      this.cacheDuration,
      this.onProgress,
      super.key});

  @override
  State<ImgXLoader> createState() => _ImgXLoaderState();
}

class _ImgXLoaderState extends State<ImgXLoader> with ImgXSource {
  late Widget? progressWidget;
  late Widget? errorWidget;
  late CacheType cacheType;
  late Duration cacheDuration;
  late int retryCount;

  @override
  void initState() {
    cacheType = widget.cacheType ?? ImgXConfig.globalCacheType;
    cacheDuration = widget.cacheDuration ?? ImgXConfig.globalCacheDuration;
    progressWidget = widget.progressWidget ?? ImgXConfig.globalProgressWidget;
    errorWidget = widget.errorWidget ?? ImgXConfig.globalErrorWidget;
    retryCount = widget.retryCount ?? ImgXConfig.globalRetryCount;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return _imageWidget();
    }
    if (kIsWeb) {
      return _imageWebWidget();
    }
    return FutureBuilder<Uint8List?>(
        future: getImage(widget.imageUri, widget.headers, cacheType,
            cacheDuration, retryCount,
            onProgress: widget.onProgress),
        builder: (ctx, snapshot) {
          data = snapshot.data;
          return AnimatedCrossFade(
              firstChild: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: progressWidget ??
                      Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ))),
              secondChild: Builder(
                builder: (ctx) {
                  if (snapshot.hasError || data == null) {
                    return errorWidget ?? _errorWidget();
                  }
                  return _imageWidget();
                },
              ),
              crossFadeState:
                  snapshot.connectionState == ConnectionState.waiting
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 400),
              firstCurve: Curves.ease,
              secondCurve: Curves.ease);
        });
  }

  Widget _imageWebWidget() => SizedBox(
        width: widget.width,
        height: widget.height,
        child: Image.network(widget.imageUri,
            fit: widget.fit,
            width: widget.width,
            height: widget.height, errorBuilder: (context, error, stackTrace) {
          logger.e(error.toString());
          return errorWidget ?? _errorWidget();
        }),
      );

  Widget _imageWidget() => SizedBox(
        width: widget.width,
        height: widget.height,
        child: Image.memory(data!,
            fit: widget.fit,
            width: widget.width,
            height: widget.height, errorBuilder: (context, error, stackTrace) {
          logger.e(error.toString());
          return SizedBox(
              width: widget.width,
              height: widget.height,
              child: errorWidget ?? _errorWidget());
        }),
      );

  Widget _errorWidget() => Icon(
        Icons.error_outline,
        size: 36,
        color: Colors.red,
      );
}
