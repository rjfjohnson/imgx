import 'package:flutter/material.dart';
import 'package:imgx/imgx.dart';

/// Created by lovepreetsingh on 14,November,2024

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        title: Text(
          "ImgX Flutter Example",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ImgX(
              width: 200,
              height: 200,
              imageUri:
                  "https://www.loudegg.com/wp-content/uploads/2020/10/Fred-Flintstone.jpg",
              fit: BoxFit.fitHeight,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
