import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wingx_shop/utils/splash_screen.dart';
import 'package:wingx_shop/utils/detail_page.dart';
import 'package:wingx_shop/utils/privacy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '鸚鵡用品購物平臺',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> menus = [];
  int selectedMenuIndex = 0;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    final response =
        await http.get(Uri.parse('https://wingx.shop/api/product/order'));
    if (response.statusCode == 200) {
      setState(() {
        menus = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 适配不同设备的字体大小
    double textSize = 16;
    double textSizeTablet = 20;
    double textSizePrice = 18;
    double textSizePriceTablet = 24;
    // 适配不同设备的商品显示数量
    int widthGrid = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    double widthTextSize =
        MediaQuery.of(context).size.width > 600 ? textSizeTablet : textSize;
    double widthTextSizePrice = MediaQuery.of(context).size.width > 600
        ? textSizePriceTablet
        : textSizePrice;
    double width = MediaQuery.of(context).size.width / widthGrid; // 获取设备宽度的一半

    return Scaffold(
      appBar: AppBar(
        title: const Text('寵物用品'),
        backgroundColor:const Color(0xFFFF5F42), // 修改AppBar的背景颜色
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 60.0),
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(menus[index]['name'],
                        style: TextStyle(fontSize: textSizePrice)),
                    onTap: () {
                      setState(() {
                        selectedMenuIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            ListTile(
              title: Text("隱私權政策",
                  style: TextStyle(
                      fontSize: textSizePrice, color: Colors.blueGrey)),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                Navigator.pop(context); // 關閉抽屜
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: menus.isNotEmpty
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widthGrid, // 控制一行显示的商品数
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: menus[selectedMenuIndex]['product'].length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            product: menus[selectedMenuIndex]['product'][index],
                          ),
                        ),
                      );
                    },
                    child: GridTile(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 120, // 设置高度为150
                              width: width, // 设置宽度为设备宽度的一半
                              child: Image.network(
                                'https://down-tw.img.susercontent.com/file/' +
                                    menus[selectedMenuIndex]['product'][index]
                                        ['image'], // 这里仅为演示，应替换为实际图片 URL
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              menus[selectedMenuIndex]['product'][index]
                                  ['name'],
                              maxLines: 1, // 限制行数为1
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: widthTextSize,
                              ),
                              // 超出的文本替换为省略号
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                                'NT\$${menus[selectedMenuIndex]['product'][index]['price'].toString()}',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: widthTextSizePrice,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(),
      ),
    );
  }
}

