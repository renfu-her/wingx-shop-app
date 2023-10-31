import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Dio dio = Dio();

class DetailPage extends StatefulWidget {
  final dynamic product;

  const DetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<String>? imageUrls;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  void fetchImages() async {
    int productId = widget.product['id'];

    // 替换为你的 API URL
    final response =
        await dio.get('https://wingx.shop/api/product/order/image/$productId');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.data);
      setState(() {
        // 根据你的 JSON 结构来获取图片的 URL
        imageUrls =
            data.map<String>((item) => item['image'].toString()).toList();
      });
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name']),
        backgroundColor: const Color(0xFFFF5F42),
      ),
      body: (imageUrls == null)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 250, // 設定你需要的高度
                    margin: const EdgeInsets.all(10), // 新增這一行，設定外邊距為10
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController, // 設定控制器
                          itemCount: imageUrls!.length,
                          itemBuilder: (context, index) {
                            return Image.network(imageUrls![index]);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronLeft),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronRight),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 23),
                  Text(
                    widget.product['name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'NT\$${widget.product['price'].toString()}',
                    style: const TextStyle(fontSize: 24, color: Colors.red),
                  ),
                ],
              ),
            ),
    );
  }
}
