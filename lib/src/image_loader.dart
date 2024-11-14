import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imgx/src/cache_type.dart';
import 'package:imgx/src/image_source.dart';

/// Created by lovepreetsingh on 14,November,2024

class ImageLoader extends StatefulWidget {
  final String imageUri;
  final BoxFit fit;
  final Widget? progressIndicatorBuilder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final CacheType cacheType;
  final Map<String, String> headers;
  final int retryCount;

  const ImageLoader(
      {required this.imageUri,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
      this.progressIndicatorBuilder,
      this.errorWidget,
      this.cacheType = CacheType.none,
      this.headers = const {},
      this.retryCount = 0,
      super.key});

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> with ImageSource {

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return _imageWidget();
    }
    if (kIsWeb) {
      return _imageWebWidget();
    }
    return FutureBuilder<Uint8List?>(
        future: getImage(widget.imageUri, widget.headers, widget.cacheType,
            widget.retryCount),
        builder: (ctx, snapshot) {
          data = snapshot.data;
          return AnimatedCrossFade(
              firstChild: widget.progressIndicatorBuilder ??
                  Center(child: CircularProgressIndicator()),
              secondChild: Builder(
                builder: (ctx) {
                  if (snapshot.hasError || data == null) {
                    return widget.errorWidget ?? _errorWidget();
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

  Widget _imageWebWidget() => Image.network(widget.imageUri,
          fit: widget.fit,
          width: widget.width,
          height: widget.height, errorBuilder: (context, error, stackTrace) {
        logger.e(error.toString());
        return widget.errorWidget ?? _errorWidget();
      });

  Widget _imageWidget() => Image.memory(data!,
          fit: widget.fit,
          width: widget.width,
          height: widget.height, errorBuilder: (context, error, stackTrace) {
        logger.e(error.toString());
        return widget.errorWidget ?? _errorWidget();
      });

  Widget _errorWidget() => Icon(
        Icons.error_outline,
        size: 36,
        color: Colors.red,
      );
}
