import 'package:flutter/material.dart';

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
