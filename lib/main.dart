import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  StateMachineController? stateMachineController;
  Artboard? mainArtBoard;
  SMIBool? check, handsUp;
  SMINumber? lookNum;
  SMITrigger? failTrigger, successTrigger;

  @override
  void initState() {
    super.initState();
    rootBundle
        .load("assets/rive/login_screen_character.riv")
        .then((riveByteData) async {
      await RiveFile.initialize();
      var riveFile = RiveFile.import(riveByteData);
      var mArtBoard = riveFile.mainArtboard;
      stateMachineController =
          StateMachineController.fromArtboard(mArtBoard, "State Machine 1");
      if (stateMachineController != null) {
        mArtBoard.addController(stateMachineController!);
        setState(() {
          mainArtBoard = mArtBoard;
        });
        check = stateMachineController!.findSMI("Check");
        handsUp = stateMachineController!.findSMI("hands_up");
        failTrigger = stateMachineController!.findSMI("fail");
        successTrigger = stateMachineController!.findSMI("success");
        lookNum = stateMachineController!.findSMI("Look");
      }
    });
  }

  checking() {
    check!.change(true);
    handsUp!.change(false);
    lookNum!.change(0);
  }

  moveEyes(value) {
    lookNum!.change(value.length.toDouble());
  }

  handUp() {
    check!.change(false);
    handsUp!.change(true);
  }

  login() {
    print("login tapped");
    check!.change(false);
    handsUp!.change(false);
    if (emailController.text == "admin" && passwordController.text == "admin") {
      successTrigger!.fire();
    } else {
      failTrigger!.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mainArtBoard != null
              ? SizedBox(
                  height: 200,
                  child: Rive(artboard: mainArtBoard!),
                )
              : Container(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(20),
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  width: 350,
                  child: TextField(
                    onTap: checking,
                    onChanged: (value) => moveEyes(value),
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 350,
                  child: TextField(
                    onTap: handUp,
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CupertinoButton(
                  color: Colors.blueAccent,
                  onPressed: login,
                  child: const Text("Log In"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
