import 'package:flutter/material.dart';
import 'package:flutter_instagram_storyboard/flutter_instagram_storyboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const StoryExamplePage(),
    );
  }
}

class StoryExamplePage extends StatefulWidget {
  const StoryExamplePage({
    Key? key,
  }) : super(key: key);

  @override
  State<StoryExamplePage> createState() => _StoryExamplePageState();
}

class _StoryExamplePageState extends State<StoryExamplePage> {
  static const double _borderRadius = 100.0;
  final StoryTimelineController storyController = StoryTimelineController();

  TextEditingController replayController = TextEditingController();
  final focusNode = FocusNode();

  Widget _createDummyPage({
    required String text,
    required String imageName,
    bool addBottomBar = true,
  }) {
    return StoryPageScaffold(
      // bottomNavigationBar: addBottomBar
      //     ? SizedBox(
      //         width: double.infinity,
      //         child: Padding(
      //           padding:
      //               const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      //           child: SizedBox(
      //             height: 80,
      //             width: double.infinity,
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Expanded(
      //                   child: Padding(
      //                     padding: const EdgeInsets.symmetric(
      //                         horizontal: 8.0, vertical: 8.0),
      //                     child: TextFormField(
      //                       controller: replayController,
      //                       focusNode: focusNode,
      //                       onTap: () {
      //                         debugPrint(
      //                             "Text field tapped. Requesting focus explicitly.");
      //                         Future.delayed(Duration(milliseconds: 100), () {
      //                           focusNode
      //                               .requestFocus(); // Explicitly request focus
      //                         });
      //                         storyController
      //                             .setTypingState(true); // Pause all stories
      //                       },
      //                       onChanged: (value) {
      //                         debugPrint("Typing in text field...");
      //                         storyController
      //                             .setTypingState(true); // Pause all stories
      //                       },
      //                       onTapOutside: (event) {
      //                         debugPrint(
      //                             "Tapped outside. Unfocusing keyboard.");
      //                         focusNode.unfocus();
      //                         storyController
      //                             .setTypingState(false); // Resume all stories
      //                       },
      //                       onEditingComplete: () {
      //                         debugPrint(
      //                             "Editing complete. Unfocusing keyboard.");
      //                         focusNode.unfocus();
      //                         storyController
      //                             .setTypingState(false); // Resume all stories
      //                       },
      //                       style: const TextStyle(color: Colors.black),
      //                       decoration: InputDecoration(
      //                         hintText: 'Type your message...',
      //                         hintStyle: const TextStyle(color: Colors.black54),
      //                         border: OutlineInputBorder(
      //                           borderRadius: BorderRadius.circular(25.0),
      //                           borderSide: BorderSide.none,
      //                         ),
      //                         filled: true,
      //                         fillColor: Colors.grey[200],
      //                         contentPadding: const EdgeInsets.symmetric(
      //                             horizontal: 20, vertical: 10),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(
      //                   height: 65,
      //                   width: 65,
      //                   child: IconButton(
      //                     icon: Icon(Icons.send, color: Colors.red.shade400),
      //                     onPressed: () {
      //                       debugPrint("Message sent.");
      //                       focusNode.unfocus();
      //                       replayController.clear();
      //                       storyController
      //                           .setTypingState(false); // ✅ Resume all stories
      //                     },
      //                   ),
      //                 )
      //               ],
      //             ),
      //           ),
      //         ),
      //       )
      //     : const SizedBox.shrink(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/$imageName.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonChild(String text) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 100.0,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 11.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildButtonDecoration(
    String imageName,
  ) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_borderRadius),
      image: DecorationImage(
        image: AssetImage(
          'assets/images/$imageName.png',
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  BoxDecoration _buildBorderDecoration(Color color) {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(
        Radius.circular(_borderRadius),
      ),
      border: Border.fromBorderSide(
        BorderSide(
          color: color,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    storyController.addListener(_onStoryEvent);
  }

  void _onStoryEvent(StoryTimelineEvent event, String storyId) {
    debugPrint('Story Event: $event, Story ID: $storyId');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        //focusNode.unfocus(); // Unfocus the keyboard when switching stories
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    replayController.dispose();
    storyController.removeListener(_onStoryEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Story Example'),
      ),
      body: Column(
        children: [
          StoryListView(
            listHeight: 180.0,
            pageTransform: const StoryPage3DTransform(),
            buttonDatas: [
              StoryButtonData(
                storyId: "1",
                //showAddButton: true,
                storyController: storyController,
                timelineBackgroundColor: Colors.red,
                buttonDecoration: _buildButtonDecoration('car'),
                child: _buildButtonChild('Want a new car?'),

                borderDecoration: _buildBorderDecoration(Colors.red),
                storyPages: [
                  _createDummyPage(
                    text:
                        'Want to buy a new car? Get our loan for the rest of your life!',
                    imageName: 'car',
                  ),
                  _createDummyPage(
                    text:
                        'Can\'t return the loan? Don\'t worry, we\'ll take your soul as a collateral ;-)',
                    imageName: 'car',
                  ),
                ],
                segmentDuration: [
                  const Duration(seconds: 15),
                  const Duration(seconds: 3)
                ],
              ),
              StoryButtonData(
                storyId: "2",
                storyController: storyController,
                timelineBackgroundColor: Colors.blue,
                buttonDecoration: _buildButtonDecoration('travel_1'),
                borderDecoration: _buildBorderDecoration(
                    const Color.fromARGB(255, 134, 119, 95)),
                child: _buildButtonChild('Travel whereever'),
                storyPages: [
                  _createDummyPage(
                    text: 'Get a loan',
                    imageName: 'travel_1',
                  ),
                  _createDummyPage(
                    text: 'Select a place where you want to go',
                    imageName: 'travel_2',
                    //addBottomBar: false,
                  ),
                  _createDummyPage(
                    text: 'Dream about the place and pay our interest',
                    imageName: 'travel_3',
                    //addBottomBar: false,
                  ),
                ],
                segmentDuration: [
                  const Duration(seconds: 3),
                  const Duration(seconds: 3),
                  const Duration(seconds: 3),
                ],
              ),
              StoryButtonData(
                storyId: "3",
                storyController: storyController,
                timelineBackgroundColor: Colors.orange,
                borderDecoration: _buildBorderDecoration(Colors.orange),
                buttonDecoration: _buildButtonDecoration('house'),
                child: _buildButtonChild('Buy a house anywhere'),
                storyPages: [
                  _createDummyPage(
                    text: 'You cannot buy a house. Live with it',
                    imageName: 'house',
                  ),
                ],
                segmentDuration: [const Duration(seconds: 5)],
              ),
              StoryButtonData(
                storyId: "4",
                storyController: storyController,
                timelineBackgroundColor: Colors.red,
                buttonDecoration: _buildButtonDecoration('car'),
                child: _buildButtonChild('Want a new car?'),
                borderDecoration: _buildBorderDecoration(Colors.red),
                storyPages: [
                  _createDummyPage(
                    text:
                        'Want to buy a new car? Get our loan for the rest of your life!',
                    imageName: 'car',
                  ),
                  _createDummyPage(
                    text:
                        'Can\'t return the loan? Don\'t worry, we\'ll take your soul as a collateral ;-)',
                    imageName: 'car',
                  ),
                ],
                segmentDuration: [
                  const Duration(seconds: 3),
                  const Duration(seconds: 3)
                ],
              ),
              StoryButtonData(
                storyId: "5",
                storyController: storyController,
                buttonDecoration: _buildButtonDecoration('travel_1'),
                borderDecoration: _buildBorderDecoration(
                    const Color.fromARGB(255, 134, 119, 95)),
                child: _buildButtonChild('Travel whereever'),
                storyPages: [
                  _createDummyPage(
                    text: 'Get a loan',
                    imageName: 'travel_1',
                    //addBottomBar: false,
                  ),
                  _createDummyPage(
                    text: 'Select a place where you want to go',
                    imageName: 'travel_2',
                    //addBottomBar: false,
                  ),
                  _createDummyPage(
                    text: 'Dream about the place and pay our interest',
                    imageName: 'travel_3',
                    //addBottomBar: false,
                  ),
                ],
                segmentDuration: [
                  const Duration(seconds: 3),
                  const Duration(seconds: 3),
                  const Duration(seconds: 3)
                ],
              ),
              StoryButtonData(
                storyId: "6",
                isVisibleCallback: () {
                  return false;
                },
                timelineBackgroundColor: Colors.orange,
                borderDecoration: _buildBorderDecoration(Colors.orange),
                buttonDecoration: _buildButtonDecoration('house'),
                child: _buildButtonChild('Buy a house anywhere'),
                storyPages: [
                  _createDummyPage(
                    text: 'You cannot buy a house. Live with it',
                    imageName: 'house',
                  ),
                ],
                segmentDuration: [
                  const Duration(seconds: 5),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
