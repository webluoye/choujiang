import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:desktop_window/desktop_window.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '抽奖',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Happy New Year 2022'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _timer;
  bool runStatus = false;
  List<String> userItemTemp = [];
  List<String> goodUser = []; //中奖用户索引
  Widget btn = const Text("Start");
  String imgPath = "";
  List<String> fileName = [];
  String okUser = ""; //记录谁中奖
  var c1 = Container();
  var c2 = Container();
  var c3 = Container();
  var c4 = Container();
  var c5 = Container();
  void _incrementCounter() {
    if (runStatus == false) {
      runStatus = true;
      btn = const Text("End");
    } else {
      runStatus = false;
      btn = const Text("Start");
    }
    setState(() {
      setChoose();
    });
  }

  @override
  void initState() {
    super.initState();
    WindowFunctions();
    deleteFile();
    startTimer();
  }

  startTimer() {
    const period = Duration(milliseconds: 10);
    _timer = Timer.periodic(period, (timer) {
      if (runStatus == false) {
        return;
      }
      if (userItemTemp.length < 5) {
        for (var obj in fileName) {
          //排除已经在中奖队列的数字
          if (!goodUser.contains(obj)) {
            userItemTemp.add(obj);
          }
        }
      }
      if (userItemTemp.length < 5) {
        _timer!.cancel();
        return;
      }
      //更新界面
      setState(() {
        c1 = loadContainer(userItemTemp[0], 200.00, 200.00);
        c2 = loadContainer(userItemTemp[1], 200.00, 200.00);
        c3 = loadContainer(userItemTemp[2], 220.00, 220.00);
        c4 = loadContainer(userItemTemp[3], 200.00, 200.00);
        c5 = loadContainer(userItemTemp[4], 200.00, 200.00);
        okUser = userItemTemp[2];
        userItemTemp.remove(userItemTemp[0]);
      });
    });
  }

  setChoose() {
    if (runStatus == true) {
    } else {
      c3 = Container(
          decoration: const BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          ),
          width: 220,
          height: 220,
          child: c3);
      goodUser.add(okUser);
      userItemTemp.remove(okUser);
      //把中奖用户写入本地文件
      writeCounter(goodUser.toString());
    }
  }

  loadContainer(String name, double width, height) {
    return Container(
      width: width,
      height: height,
      child: loadImg(imgPath + '/' + name),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imgPath.isEmpty) {
      return Container(
        color: Colors.blue[400],
        child: Column(
          children: [
            const SizedBox(height: 200),
            Container(
              width: 400,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
              ),
              child: TextButton(
                  child: const Text("Open User folder"),
                  onPressed: () async {
                    String? selectedDirectory =
                        await FilePicker.platform.getDirectoryPath();

                    if (selectedDirectory != null) {
                      imgPath = selectedDirectory;
                      List<FileSystemEntity> list =
                          Directory(selectedDirectory).listSync();
                      if (list.length > 5) {
                        for (var i in list) {
                          fileName.add(basename(i.path));
                        }
                        setState(() {
                          c1 = loadContainer(fileName[0], 200.00, 200.00);
                          c2 = loadContainer(fileName[1], 200.00, 200.00);
                          c3 = loadContainer(fileName[2], 220.00, 220.00);
                          c4 = loadContainer(fileName[3], 200.00, 200.00);
                          c5 = loadContainer(fileName[4], 200.00, 200.00);
                        });
                      }
                    }
                  }),
            )
          ],
        ),
      );
    } else {
      // This method is rerun every time setState is called, for instance as done
      // by the _incrementCounter method above.
      //
      // The Flutter framework has been optimized to make rerunning build methods
      // fast, so that you can just rebuild anything that needs updating rather
      // than having to individually change instances of widgets.
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Row(
            children: [c1, c2, c3, c4, c5],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          child: btn,
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }
  }
}

loadImg(String name) {
  return Image(
    image: Image.file(File(name)).image,
    width: 200,
    height: 200,
  );
}

Future WindowFunctions() async {
  Size size = await DesktopWindow.getWindowSize();
  await DesktopWindow.setWindowSize(Size(1100, 520));
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/counter.txt');
}

Future<File> writeCounter(String counter) async {
  final file = await _localFile;
  return file.writeAsString(counter);
}

Future<FileSystemEntity> deleteFile() async {
  final path = await _localPath;
  return File('$path/counter.txt').delete();
}
