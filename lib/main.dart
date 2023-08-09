import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_html/flutter_html.dart';

void main() => runApp(MyApp());

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
        title: Text('寵物用品'),
        backgroundColor: Color(0xFFFF5F42), // 修改AppBar的背景颜色
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 60.0),
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
              trailing: Icon(Icons.navigate_next),
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
                            Container(
                              height: 120, // 设置高度为150
                              width: width, // 设置宽度为设备宽度的一半
                              child: Image.network(
                                'https://down-tw.img.susercontent.com/file/' +
                                    menus[selectedMenuIndex]['product'][index]
                                        ['image'], // 这里仅为演示，应替换为实际图片 URL
                              ),
                            ),
                            SizedBox(height: 5.0),
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
                            SizedBox(height: 5.0),
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

class DetailPage extends StatefulWidget {
  final dynamic product;

  DetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<String>? imageUrls;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  void fetchImages() async {
    int productId = widget.product['id'];

    // 替换为你的 API URL
    final response = await http.get(
        Uri.parse('https://wingx.shop/api/product/order/image/$productId'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
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
        backgroundColor: Color(0xFFFF5F42),
      ),
      body: (imageUrls == null)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 250, // 設定你需要的高度
                    margin: EdgeInsets.all(10), // 新增這一行，設定外邊距為10
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
                            icon: FaIcon(FontAwesomeIcons.chevronLeft),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: FaIcon(FontAwesomeIcons.chevronRight),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 23),
                  Text(
                    widget.product['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'NT\$${widget.product['price'].toString()}',
                    style: TextStyle(fontSize: 24, color: Colors.red),
                  ),
                ],
              ),
            ),
    );
  }
}

// splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Lottie.asset(
        'assets/splash_screen.json',
        controller: _controller,
        height: MediaQuery.of(context).size.height * 1,
        animate: true,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..forward().whenComplete(() => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                ));
        },
      ),
    );
  }
}

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String? _privacyPolicyContent;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    final response = await http
        .get(Uri.parse('https://wingx.shop/api/get_policy/1')); // 替换为您的隐私策略URL

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _privacyPolicyContent = responseData['content']; // 提取content字段
      });
    } else {
      setState(() {
        _privacyPolicyContent = 'Failed to load privacy policy.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('隱私權政策'),
        backgroundColor: Color(0xFFFF5F42),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _privacyPolicyContent != null
            ? Html(data: _privacyPolicyContent!)
            : CircularProgressIndicator(), // 在加载内容时显示一个加载指示器
      ),
    );
  }
}
