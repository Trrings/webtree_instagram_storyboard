import 'package:flutter/material.dart';

/// This scaffold has a transparent background and
/// rounded corners around its body. You don't necessarily
/// have to use this scaffold. You can use your own page structure
/// but if you're ok with this, feel free to use it as a base for
/// your story pages
class StoryPageScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final BorderRadius? borderRadius;
  final bool showReplyBar;
  final Widget? replyBarWidget;

  const StoryPageScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.borderRadius,
    this.showReplyBar = false,
    this.replyBarWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: borderRadius ??
              BorderRadius.circular(
                12.0,
              ),
          child: Stack(
            children: [
              body,
              IgnorePointer(
                child: GradientTransition(
                  width: double.infinity,
                  height: 100.0,
                  baseColor: Colors.black.withOpacity(.7),
                  isReversed: true,
                ),
              ),
              if (showReplyBar &&
                  replyBarWidget != null) // ✅ Use external reply bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: replyBarWidget!,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  // Reply Bar Widget
  Widget _buildReplyBar() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: SizedBox(
          height: 80,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 65,
                width: 65,
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.red.shade400),
                  onPressed: () {
                    // Send button action
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum GradientTransitionDirection {
  vertical,
  horizontal,
}

class GradientTransition extends StatelessWidget {
  final double width;
  final double height;
  final bool isReversed;
  final Color baseColor;
  final bool bottomPositioned;
  final GradientTransitionDirection gradientTransitionDirection;

  const GradientTransition({
    Key? key,
    required this.width,
    required this.height,
    this.bottomPositioned = false,
    required this.baseColor,
    this.isReversed = false,
    this.gradientTransitionDirection = GradientTransitionDirection.vertical,
  }) : super(key: key);

  AlignmentGeometry get _begin {
    if (gradientTransitionDirection == GradientTransitionDirection.vertical) {
      return Alignment.topCenter;
    }
    return Alignment.centerLeft;
  }

  AlignmentGeometry get _end {
    if (gradientTransitionDirection == GradientTransitionDirection.vertical) {
      return Alignment.bottomCenter;
    }
    return Alignment.centerRight;
  }

  List<Color> _getColors() {
    if (isReversed) {
      return [
        baseColor,
        baseColor.withOpacity(0.0),
      ];
    }
    return [
      baseColor.withOpacity(0.0),
      baseColor,
    ];
  }

  @override
  Widget build(BuildContext context) {
    var container = IgnorePointer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getColors(),
            begin: _begin,
            end: _end,
          ),
        ),
      ),
    );
    if (bottomPositioned) {
      return Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: container,
      );
    }
    return container;
  }
}
