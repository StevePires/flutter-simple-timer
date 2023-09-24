import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_timer/theme/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Timer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.cyan.shade900).copyWith(
          background: ThemeColors.primaryBackground,
          primary: ThemeColors.primaryElement,
          onPrimary: ThemeColors.secondaryElement,
          secondary: ThemeColors.primaryElement,
          onSecondary: ThemeColors.onSecondary,
          surface: ThemeColors.onSecondary,
          onSurface: ThemeColors.secondaryElement,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Simple Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _timerInitialValue = 0;
  int _seconds = 0;
  Timer? timer;

  late FixedExtentScrollController timerHours;
  late FixedExtentScrollController timerMinutes;
  late FixedExtentScrollController timerSeconds;

  @override
  void initState() {
    super.initState();
    _seconds = _timerInitialValue;

    timerHours = FixedExtentScrollController(initialItem: 0);
    timerMinutes = FixedExtentScrollController(initialItem: 0);
    timerSeconds = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    timer?.cancel();
    timerHours.dispose();
    timerMinutes.dispose();
    timerSeconds.dispose();

    super.dispose();
  }

  void _startPauseTimer() {
    if (timer == null || !timer!.isActive) {
      if (timer == null && _seconds > 0) {
        setState(() {
          // The initial value is set to 1 second less than the actual value
          _seconds--;
        });
      }
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _seconds > 0 ? _seconds-- : timer?.cancel();
        });
      });
    } else {
      setState(() {
        timer?.cancel();
      });
    }
  }

  void _resetTimer() {
    setState(() {
      timer?.cancel();
      timer = null;
      _seconds = _timerInitialValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
                color: ThemeColors.onSecondary,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: _buildTimer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            timer?.cancel();
          });

          _showTimerDialog();
        },
        tooltip: 'Set timer',
        child: const Icon(Icons.timelapse),
      ),
    );
  }

  Widget _buildTimer(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          (_seconds == 0 && timer != null)
              ? const Column(
                  children: [
                    SizedBox(height: 25),
                    Icon(
                      Icons.celebration,
                      size: 250,
                      color: ThemeColors.secondaryElement,
                    ),
                    SizedBox(height: 25),
                  ],
                )
              : SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _timerInitialValue != 0
                            ? (_seconds / _timerInitialValue)
                            : 0,
                        strokeWidth: 12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary),
                        backgroundColor: ThemeColors.primaryBackground,
                      ),
                      Center(
                        child: Text(
                          '${getTimeNumberString(_seconds ~/ 3600)}:${getTimeNumberString((_seconds % 3600) ~/ 60)}:${getTimeNumberString(_seconds % 60)}',
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 40),
          (_seconds == 0 && timer != null)
              ? IconButton(
                  onPressed: _resetTimer,
                  icon: Icon(Icons.refresh,
                      color: Theme.of(context).colorScheme.secondary))
              : ((_seconds > 0)
                  ? Column(
                      children: [
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: _startPauseTimer,
                                color: Theme.of(context).colorScheme.secondary,
                                icon: Icon(
                                  timer == null
                                      ? Icons.play_arrow
                                      : (timer!.isActive == true
                                          ? Icons.pause
                                          : Icons.play_arrow),
                                )),
                            const SizedBox(width: 10),
                            IconButton(
                                color: Theme.of(context).colorScheme.secondary,
                                icon: const Icon(Icons.stop),
                                onPressed: _resetTimer),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(timer == null
                            ? '( Timer is stopped )'
                            : timer!.isActive == true
                                ? '( Timer is running )'
                                : '( Timer is paused )'),
                      ],
                    )
                  : const Text('( Please set a timer )')),
        ],
      ),
    );
  }

  getTimeNumberString(int number) {
    return number.toString().padLeft(2, '0');
  }

  _showTimerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text('Set timer'),
          content: SizedBox(
            height: 450,
            width: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: ListWheelScrollView(
                          controller: timerHours,
                          useMagnifier: true,
                          magnification: 1.5,
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: null,
                          children: List.generate(
                            10,
                            (index) => Text(
                              '${getTimeNumberString(index)}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 80,
                        child: ListWheelScrollView(
                          controller: timerMinutes,
                          useMagnifier: true,
                          magnification: 1.5,
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: null,
                          children: List.generate(
                            60,
                            (index) => Text(
                              '${getTimeNumberString(index)}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 80,
                        child: ListWheelScrollView(
                          controller: timerSeconds,
                          useMagnifier: true,
                          magnification: 1.5,
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: null,
                          children: List.generate(
                            60,
                            (index) => Text(
                              '${getTimeNumberString(index)}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Text('Hours'),
                      SizedBox(width: 50),
                      Text('Minutes'),
                      SizedBox(width: 50),
                      Text('Seconds'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (timerHours.selectedItem == 0 &&
                    timerMinutes.selectedItem == 0 &&
                    timerSeconds.selectedItem == 0) {
                  return;
                }

                setState(() {
                  _timerInitialValue = timerHours.selectedItem * 3600 +
                      timerMinutes.selectedItem * 60 +
                      timerSeconds.selectedItem;

                  _seconds = _timerInitialValue;
                });

                Navigator.pop(context);
                _startPauseTimer();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
