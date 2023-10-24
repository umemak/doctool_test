import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'upload_file.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({Key? key, this.token}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Login Page
      home: token == null
          ? const LoginPage()
          : const TopPage(
              title: "Flutter Demo Home Page",
            ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color _backgroundColor = Colors.white;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login(String email, password) async {
    Response response = await post(
      Uri.parse(
          'https://17fbg3o4zf.execute-api.ap-northeast-1.amazonaws.com/Prod/v1/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TopPage(
            title: 'Flutter Demo Home Page',
          ),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(response.body.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Please sign in to continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  {login(emailController.text, passwordController.text)},
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class TopPage extends StatefulWidget {
  final String title;
  const TopPage({Key? key, required this.title}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  @override
  Widget build(BuildContext context) {
    // 記事一覧を表示する
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // マイページに遷移するボタンを表示する
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyPage(),
                ),
              ),
            },
          ),
          // ログアウトボタンを表示する
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: get(
          Uri.parse('http://localhost:8000/articles'),
          headers: <String, String>{'accept': 'application/json'},
        ),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var data = jsonDecode(snapshot.data.body.toString());
            print(data);
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(data[index]['title']),
                  subtitle: Text(data[index]['description']),
                  // リンク先に遷移するボタンを表示する
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(uuid: data[index]['uuid']),
                        ),
                      ),
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final String? uuid;
  const DetailPage({Key? key, this.uuid}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: Center(
        // S3から取得したテキストファイルを表示する
        child: FutureBuilder(
          future:
              get(Uri.parse('http://localhost:8000/articles/${widget.uuid}')),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.body.toString());
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? filename;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
      ),
      body: Center(
          child: Column(
        children: [
          // ファイルセレクターを表示する
          ElevatedButton(
            onPressed: () async {
              File file = await FilePicker.platform.pickFiles().then((value) {
                return File(value!.files.single.path!);
              });
              setState(() {
                filename = file.path;
              });
            },
            child: const Text('Select File'),
          ),
          // タイトルを入力するテキストフィールドを表示する
          const TextField(),
          // アップロードボタンを表示する
          ElevatedButton(
            onPressed: () {
              if (filename != null) {
                uploadFile(filename!);
              }
            },
            child: const Text('Upload'),
          ),
        ],
      )),
    );
  }
}
