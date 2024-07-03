import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'model/user.dart';
import 'newRegisterList/new_register_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => AppState(),
    child: MaterialApp(
      title: 'Welcome To SODA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    ),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/image/soda_logo.png',
                  width: size.width,
                  height: size.height * 0.4,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Title(),
                ),
                AnimatedOpacity(
                  opacity:
                      Provider.of<AppState>(context).isTitleAnimationFinished
                          ? 1.0
                          : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      NameTextField(
                        size: size,
                        textEditingController: _textEditingController,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const RegisterButton(),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: size.height * 0.4,
                  child: const NewRegisterList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !Provider.of<AppState>(context).isTextFieldEmpty,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider.of<AppState>(context).isSubmitted
              ? FutureBuilder(
                  future: CloudRegister().createRegister(
                      name: Provider.of<AppState>(context, listen: false).name),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        return Row(children: [
                          const Icon(Icons.check),
                          const SizedBox(
                            width: 10,
                          ),
                          Text("Hi ${snapshot.data!.name} register completed!"),
                        ]);
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                )
              : AnimatedTextKit(
                  pause: Duration.zero,
                  repeatForever: true,
                  animatedTexts: [
                    FlickerAnimatedText('Register To SODA',
                        textStyle: const TextStyle(color: Colors.blue)),
                  ],
                  onTap: () {
                    Provider.of<AppState>(context, listen: false)
                        .toggleIsSubmitted();
                  },
                ),
        ),
      ),
    );
  }
}

class NameTextField extends StatelessWidget {
  const NameTextField({
    Key? key,
    required this.size,
    required TextEditingController textEditingController,
  })  : _textEditingController = textEditingController,
        super(key: key);

  final Size size;
  final TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.8,
      child: TextField(
        decoration: const InputDecoration(
          hintText: "Enter your name!",
        ),
        controller: _textEditingController,
        onChanged: (value) {
          Provider.of<AppState>(context, listen: false)
              .setIsTextFieldEmpty(value.isEmpty);
          Provider.of<AppState>(context, listen: false).name = value;
        },
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({
    Key? key,
  }) : super(key: key);

  final TextStyle _textStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 25,
    color: Colors.blueGrey,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      totalRepeatCount: 1,
      onFinished: () => Provider.of<AppState>(context, listen: false)
          .setTitleAnimationFinished(true),
      animatedTexts: [
        TypewriterAnimatedText(
          'Welcome to SODA',
          cursor: '|',
          textStyle: _textStyle,
        ),
        TypewriterAnimatedText(
          'Congrats to start your first flutter app!',
          cursor: '|',
          textStyle: _textStyle,
        ),
        TypewriterAnimatedText(
          'Please fill the blank below to register!',
          cursor: '|',
          textStyle: _textStyle,
        ),
      ],
    );
  }
}

class AppState extends ChangeNotifier {
  bool _disposed = false;
  bool _isTextFieldEmpty = true;
  bool _isSubmitted = false;
  String name = '';

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  bool _isTitleAnimationFinished = false;
  bool get isTitleAnimationFinished => _isTitleAnimationFinished;
  void setTitleAnimationFinished(bool newVal) {
    _isTitleAnimationFinished = newVal;
    notifyListeners();
  }

  bool get isTextFieldEmpty => _isTextFieldEmpty;
  void setIsTextFieldEmpty(bool newVal) {
    if (_isTextFieldEmpty == newVal) return;
    _isTextFieldEmpty = !_isTextFieldEmpty;
    notifyListeners();
  }

  bool get isSubmitted => _isSubmitted;
  void toggleIsSubmitted() {
    _isSubmitted = !_isSubmitted;
    notifyListeners();
  }
}
