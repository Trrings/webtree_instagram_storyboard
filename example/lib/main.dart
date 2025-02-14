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
  const StoryExamplePage({Key? key}) : super(key: key);

  @override
  State<StoryExamplePage> createState() => _StoryExamplePageState();
}

class _StoryExamplePageState extends State<StoryExamplePage> {
  final StoryTimelineController storyController = StoryTimelineController();
  final TextEditingController replayController = TextEditingController();

  List<dynamic> storiesList = []; // Store dynamic stories

  @override
  void initState() {
    super.initState();
    storyController.addListener(_onStoryEvent);
    fetchStories(); // Fetch the stories dynamically
  }

  void fetchStories() {
    setState(() {
      storiesList = [
        {
          "storyId": "1",
          "title": "Want a new car?",
          "image": "car",
          "pages": [
            {
              "text":
                  "Want to buy a new car? Get our loan for the rest of your life!",
              "image": "car"
            },
            {
              "text":
                  "Can't return the loan? Don't worry, we’ll take your soul as collateral ;-)",
              "image": "car"
            }
          ]
        },
        {
          "storyId": "2",
          "title": "Travel Anywhere",
          "image": "travel_1",
          "pages": [
            {"text": "Get a loan", "image": "travel_1"},
            {
              "text": "Select a place where you want to go",
              "image": "travel_2"
            },
            {
              "text": "Dream about the place and pay our interest",
              "image": "travel_3"
            }
          ]
        },
        {
          "storyId": "3",
          "title": "Buy a house anywhere",
          "image": "house",
          "pages": [
            {"text": "You cannot buy a house. Live with it", "image": "house"}
          ]
        }
      ];
    });
  }

  void _onStoryEvent(StoryTimelineEvent event, String storyId) {
    debugPrint('Story Event: $event, Story ID: $storyId');
  }

  @override
  void dispose() {
    replayController.dispose();
    storyController.removeListener(_onStoryEvent);
    super.dispose();
  }

  Widget _buildReplayBar(int storyIndex, int pageIndex) {
    FocusNode focusNode =
        FocusNode(); // Create a new FocusNode for each replay bar

    return StoryReplayBar(
      storyIndex: storyIndex,
      replayBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context)
                      .requestFocus(focusNode); // Ensure focus is requested
                },
                child: TextFormField(
                  controller: replayController,
                  focusNode: focusNode, // Assign a fresh FocusNode
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Reply to story $storyIndex, page $pageIndex...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (replayController.text.isNotEmpty) {
                  print(
                      "Reply to story $storyIndex, page $pageIndex: ${replayController.text}");
                  replayController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _createStoryPage({
    required int storyIndex,
    required int pageIndex,
    required String text,
    required String imageName,
  }) {
    return Stack(
      children: [
        StoryPageScaffold(
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
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: _buildReplayBar(storyIndex, pageIndex),
        ),
      ],
    );
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
          if (storiesList.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            StoryListView(
              listHeight: 180.0,
              pageTransform: const StoryPage3DTransform(),
              buttonDatas: List.generate(
                storiesList.length,
                (storyIndex) {
                  final story = storiesList[storyIndex];
                  return StoryButtonData(
                    storyId: story["storyId"],
                    storyController: storyController,
                    timelineBackgroundColor: Colors.red,
                    buttonDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.0),
                      image: DecorationImage(
                        image:
                            AssetImage('assets/images/${story["image"]}.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    borderDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                      border: Border.all(color: Colors.red, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 100.0),
                          Text(
                            story["title"],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 11.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    storyPages: List.generate(
                      story["pages"].length,
                      (pageIndex) => _createStoryPage(
                        storyIndex: storyIndex,
                        pageIndex: pageIndex,
                        text: story["pages"][pageIndex]["text"],
                        imageName: story["pages"][pageIndex]["image"],
                      ),
                    ),
                    segmentDuration: List.generate(
                      story["pages"].length,
                      (_) => const Duration(seconds: 5),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class StoryReplayBar extends StatelessWidget {
  final int storyIndex;
  final Widget replayBar;

  const StoryReplayBar(
      {Key? key, required this.storyIndex, required this.replayBar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return replayBar;
  }
}
