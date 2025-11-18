import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int count = 0;
  String? imagePath;
  final picker = ImagePicker();
  List<FallingFlower> flowers = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      count = prefs.getInt("count") ?? 0;
      imagePath = prefs.getString("imagePath");
    });
  }

  Future<void> saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("count", count);
  }

  Future<void> saveImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("imagePath", path);
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        "user_img_${DateTime.now().millisecondsSinceEpoch}.png";
    final savedFile = File("${dir.path}/$fileName");
    await File(picked.path).copy(savedFile.path);

    setState(() {
      imagePath = savedFile.path;
    });

    saveImage(savedFile.path);
  }

  void increment() {
    setState(() {
      count++;
      createFlowerShower();
    });

    saveCount();
  }

  void createFlowerShower() {
    for (int i = 0; i < 5; i++) {
      flowers.add(FallingFlower());
    }

    setState(() {});
  }

  void reset() {
    setState(() => count = 0);
    saveCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flower Counter"),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: pickImage,
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Container(
                height: 200,
                width: double.infinity,
                child: imagePath == null
                    ? Image.asset("assets/default_picture.png",
                        fit: BoxFit.cover)
                    : Image.file(File(imagePath!), fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: increment,
                child: Container(
                  width: 250,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Text(
                    "$count",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: reset,
                child: const Text("Reset"),
              ),
            ],
          ),
          ...flowers.map((f) => f.build()),
        ],
      ),
    );
  }
}

class FallingFlower {
  final double left = Random().nextDouble() * 300;
  final double size = 20 + Random().nextDouble() * 30;

  Widget build() {
    return AnimatedPositioned(
      duration: const Duration(seconds: 2),
      curve: Curves.easeIn,
      left: left,
      top: Random().nextDouble() * 700,
      child: Opacity(
        opacity: 0.8,
        child: Image.asset("assets/flower.png", width: size),
      ),
    );
  }
}
