import 'dart:async';
import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_storyboard/flutter_instagram_storyboard.dart';
import 'package:flutter_instagram_storyboard/src/first_build_mixin.dart';

class StoryPageContainerView extends StatefulWidget {
  final StoryButtonData buttonData;
  final Function() onStoryComplete;
  final PageController? pageController;
  final VoidCallback? onClosePressed;

  const StoryPageContainerView({
    Key? key,
    required this.buttonData,
    required this.onStoryComplete,
    this.pageController,
    this.onClosePressed,
  }) : super(key: key);

  @override
  State<StoryPageContainerView> createState() => _StoryPageContainerViewState();
}

class _StoryPageContainerViewState extends State<StoryPageContainerView>
    with FirstBuildMixin {
  late StoryTimelineController _storyController;
  final Stopwatch _stopwatch = Stopwatch();
  Offset _pointerDownPosition = Offset.zero;
  int _pointerDownMillis = 0;
  double _pageValue = 0.0;
  static const double bottomZoneHeight = 60.0; // Bottom 60 pixels area

  @override
  void initState() {
    _storyController =
        widget.buttonData.storyController ?? StoryTimelineController();
    _stopwatch.start();
    _storyController.addListener(_onTimelineEvent);
    super.initState();
  }

  @override
  void didFirstBuildFinish(BuildContext context) {
    widget.pageController?.addListener(_onPageControllerUpdate);
  }

  void _onPageControllerUpdate() {
    if (widget.pageController?.hasClients != true) {
      return;
    }
    _pageValue = widget.pageController?.page ?? 0.0;
    _storyController._setTimelineAvailable(_timelineAvailable);
  }

  bool get _timelineAvailable {
    return _pageValue % 1.0 == 0.0;
  }

  void _onTimelineEvent(StoryTimelineEvent event, String storyId) {
    if (event == StoryTimelineEvent.storyComplete) {
      widget.onStoryComplete.call();
    }
    setState(() {});
  }

  Widget _buildCloseButton() {
    Widget closeButton;
    if (widget.buttonData.closeButton != null) {
      closeButton = widget.buttonData.closeButton!;
    } else {
      closeButton = SizedBox(
        height: 40.0,
        width: 40.0,
        child: MaterialButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (widget.onClosePressed != null) {
              widget.onClosePressed!.call();
            } else {
              Navigator.of(context).pop();
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              40.0,
            ),
          ),
          child: SizedBox(
            height: 40.0,
            width: 40.0,
            child: Icon(
              Icons.close,
              size: 28.0,
              color: widget.buttonData.defaultCloseButtonColor,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10.0,
      ),
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          closeButton,
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Padding(
      padding: EdgeInsets.only(
        top: widget.buttonData.timlinePadding?.top ?? 15.0,
        left: widget.buttonData.timlinePadding?.left ?? 15.0,
        right: widget.buttonData.timlinePadding?.left ?? 15.0,
        bottom: widget.buttonData.timlinePadding?.bottom ?? 5.0,
      ),
      child: StoryTimeline(
        controller: _storyController,
        buttonData: widget.buttonData,
      ),
    );
  }

  set _curSegmentIndex(int value) {
    if (value >= _numSegments) {
      value = _numSegments - 1;
    } else if (value < 0) {
      value = 0;
    }
    widget.buttonData.currentSegmentIndex = value;
  }

  int get _curSegmentIndex {
    return widget.buttonData.currentSegmentIndex;
  }

  Widget _buildPageContent() {
    if (widget.buttonData.storyPages.isEmpty) {
      return Container(
        color: Colors.orange,
        child: const Center(
          child: Text('No pages'),
        ),
      );
    }
    return widget.buttonData.storyPages[_curSegmentIndex];
  }

  bool _isLeftPartOfStory(Offset position) {
    if (!mounted) {
      return false;
    }
    final storyWidth = context.size!.width;
    return position.dx <=
        (storyWidth * 0.25); // Reduce the touchable width to 25%
  }

  bool _isRightPartOfStory(Offset position) {
    if (!mounted) {
      return false;
    }
    final storyWidth = context.size!.width;
    // Define a smaller touchable area for the right side
    return position.dx >=
        (storyWidth * 0.75); // Reduce the touchable width to 25%
  }

  // Checks if the position is within the bottom 60 pixels
  bool _isInBottomZone(Offset position) {
    final storyHeight = context.size?.height ?? 0.0;
    return position.dy >= (storyHeight - bottomZoneHeight);
  }

//latest
  Widget _buildPageStructure() {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (!_isInBottomZone(event.position)) {
          _pointerDownMillis = _stopwatch.elapsedMilliseconds;
          _pointerDownPosition = event.position;
          _storyController.pause();
        } else {
          _storyController.unpause();
        }
      },
      onPointerUp: (PointerUpEvent event) {
        final pointerUpMillis = _stopwatch.elapsedMilliseconds;
        final maxPressMillis = kPressTimeout.inMilliseconds * 2;
        final diffMillis = pointerUpMillis - _pointerDownMillis;

        if (_isInBottomZone(event.position)) {
          return;
        }

        if (diffMillis <= maxPressMillis) {
          final position = event.position;
          final distance = (position - _pointerDownPosition).distance;

          if (distance < 5.0) {
            if (_isLeftPartOfStory(position)) {
              _handleLeftTap();
              // _storyController.previousSegment();
            } else if (_isRightPartOfStory(position)) {
              _handleRightTap();
            }
          }
        }

        _storyController.unpause();
      },
      child: Stack(
        children: [
          _buildPageContent(),
          _buildTimeline(),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: _buildCloseButton(),
          ),
        ],
      ),
    );
  }

  void _handleRightTap() {
    if (_storyController._state != null) {
      if (_curSegmentIndex == widget.buttonData.storyPages.length - 1) {
        // Last segment of current story
        _storyController._state!._accumulatedTime =
            _storyController._state!._maxAccumulator;
        _storyController._state!._onStoryComplete();
        widget.onStoryComplete();
      } else {
        // Move to next segment
        _storyController._state!._accumulatedTime =
            _storyController._state!._maxAccumulator;
        _storyController._state!._onSegmentComplete();
        _curSegmentIndex++;
        _storyController._state!._maxAccumulator =
            widget.buttonData.segmentDuration[_curSegmentIndex].inMilliseconds;
        _storyController._state!._accumulatedTime = 0;
      }
      if (_storyController._state!.mounted) {
        _storyController._state!.setState(() {});
      }
    }
  }

  //left-tap
  void _handleLeftTap() {
    if (_storyController._state != null) {
      if (_curSegmentIndex == 0) {
        // ✅ First segment of current story, move to the last segment of the previous story
        if (_moveToPreviousUserStory()) {
          return;
        }
      } else {
        //  Move to the previous segment within the same story
        _storyController._state!._accumulatedTime = 0;
        _storyController._state!._onSegmentComplete();
        _curSegmentIndex--;
        _storyController._state!._maxAccumulator =
            widget.buttonData.segmentDuration[_curSegmentIndex].inMilliseconds;
      }

      if (_storyController._state!.mounted) {
        _storyController._state!.setState(() {});
      }
    }
  }

  bool _moveToPreviousUserStory() {
    final pageController = widget.pageController;
    if (pageController != null && pageController.hasClients) {
      final currentPage = pageController.page?.round() ?? 0;

      if (currentPage > 0) {
        // ✅ Move to the previous user story
        pageController.animateToPage(
          currentPage - 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        Future.delayed(Duration(milliseconds: 350), () {
          if (mounted) {
            setState(() {
              // ✅ Move to the last segment of the previous story
              _curSegmentIndex = widget.buttonData.storyPages.length - 1;
             
              
            });
          }
        });

        return true; // ✅ Successfully moved to previous user story
      }
    }
    return false; // ❌ No previous user story available
  }

  bool get isLastSegment {
    return _curSegmentIndex == _numSegments - 1;
  }

  int get _numSegments {
    return widget.buttonData.storyPages.length;
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_onPageControllerUpdate);
    _stopwatch.stop();
    _storyController.removeListener(_onTimelineEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildPageStructure(),
    );
  }
}

enum StoryTimelineEvent {
  storyComplete,
  segmentComplete,
}

typedef StoryTimelineCallback = Function(StoryTimelineEvent, String);

class StoryTimelineController {
  _StoryTimelineState? _state;
  bool _isPaused = false;
  static bool isTyping = false; // ✅ Global flag to track typing

  // Public getter for _isPaused
  bool get isPaused => _isPaused;
//new
  bool get isLastSegment {
    return _state?._isLastSegment ?? false; // Delegate to `_StoryTimelineState`
  }

  final HashSet<StoryTimelineCallback> _listeners =
      HashSet<StoryTimelineCallback>();

  void addListener(StoryTimelineCallback callback) {
    _listeners.add(callback);
  }

  void removeListener(StoryTimelineCallback callback) {
    _listeners.remove(callback);
  }

  void _onStoryComplete(String storyId) {
    _notifyListeners(StoryTimelineEvent.storyComplete, storyId: storyId);
  }

  void _onSegmentComplete(String storyId) {
    _notifyListeners(StoryTimelineEvent.segmentComplete, storyId: storyId);
  }

  void _notifyListeners(StoryTimelineEvent event, {required String storyId}) {
    for (var e in _listeners) {
      e.call(event, storyId);
    }
  }

  void nextSegment() {
    if (!isTyping) {
      _state?.nextSegment();
    }
  }

  void previousSegment() {
    _state?.previousSegment();
  }

  void pause() {
    _state?.pause();
    _isPaused = true;
    debugPrint("_isPaused: $_isPaused");
  }

  void _setTimelineAvailable(bool value) {
    _state?._setTimelineAvailable(value);
  }

  void unpause() {
    if (!isTyping) {
      // ✅  typing
      _state?.unpause();
      _isPaused = false;
      debugPrint("_isPaused: $_isPaused");
    }
  }

  void setTypingState(bool typing) {
    isTyping = typing;
    if (isTyping) {
      pause();
    } else {
      unpause();
    }
  }

  void dispose() {
    _listeners.clear();
  }
}

class StoryTimeline extends StatefulWidget {
  final StoryTimelineController controller;
  final StoryButtonData buttonData;

  const StoryTimeline({
    Key? key,
    required this.controller,
    required this.buttonData,
  }) : super(key: key);

  @override
  State<StoryTimeline> createState() => _StoryTimelineState();
}

class _StoryTimelineState extends State<StoryTimeline> {
  late Timer _timer;
  int _accumulatedTime = 0;
  int _maxAccumulator = 0;
  bool _isPaused = false;
  bool _isTimelineAvailable = true;

  @override
  void initState() {
    _maxAccumulator = widget.buttonData
        .segmentDuration[widget.buttonData.currentSegmentIndex].inMilliseconds;
    _timer = Timer.periodic(
      const Duration(
        milliseconds: kStoryTimerTickMillis,
      ),
      _onTimer,
    );
    widget.controller._state = this;
    super.initState();
    if (widget.buttonData.storyWatchedContract ==
        StoryWatchedContract.onStoryStart) {
      widget.buttonData.markAsWatched();
    }
  }

  void _setTimelineAvailable(bool value) {
    _isTimelineAvailable = value;
  }

  void _onTimer(timer) {
    if (_isPaused ||
        !_isTimelineAvailable ||
        StoryTimelineController.isTyping) {
      //if (_isPaused || StoryTimelineController.isTyping) { // ✅ Global flag to track typing
      return;
    }
    if (_accumulatedTime + kStoryTimerTickMillis <= _maxAccumulator) {
      _accumulatedTime += kStoryTimerTickMillis;
      if (_accumulatedTime >= _maxAccumulator) {
        if (_isLastSegment) {
          _maxAccumulator = widget
              .buttonData
              .segmentDuration[widget.buttonData.currentSegmentIndex]
              .inMilliseconds;
          _onStoryComplete();
        } else {
          _accumulatedTime = 0;
          _onSegmentComplete();
          _curSegmentIndex++;
          _maxAccumulator = widget
              .buttonData
              .segmentDuration[widget.buttonData.currentSegmentIndex]
              .inMilliseconds;
        }
      }
      setState(() {});
    }
  }

  void _onStoryComplete() {
    if (widget.buttonData.storyWatchedContract ==
        StoryWatchedContract.onStoryEnd) {
      widget.buttonData.markAsWatched();
    }
    widget.buttonData.currentSegmentIndex = 0;
    widget.controller._onStoryComplete(
        "${widget.buttonData.storyId}-${widget.buttonData.currentSegmentIndex}");
  }

  void _onSegmentComplete() {
    if (widget.buttonData.storyWatchedContract ==
        StoryWatchedContract.onSegmentEnd) {
      widget.buttonData.markAsWatched();
    }
    widget.controller._onSegmentComplete(
        "${widget.buttonData.storyId}-${widget.buttonData.currentSegmentIndex}");
  }

  bool get _isLastSegment {
    return _curSegmentIndex == _numSegments - 1;
  }

  int get _numSegments {
    return widget.buttonData.storyPages.length;
  }

  set _curSegmentIndex(int value) {
    if (value >= _numSegments) {
      value = _numSegments - 1;
    } else if (value < 0) {
      value = 0;
    }
    widget.buttonData.currentSegmentIndex = value;
  }

  int get _curSegmentIndex {
    return widget.buttonData.currentSegmentIndex;
  }

  int currentSegmentIndex() => _curSegmentIndex;

  void nextSegment() {
    if (_isLastSegment) {
      _accumulatedTime = _maxAccumulator;
      widget.buttonData.currentSegmentIndex = 0;
      widget.controller._onStoryComplete(
          "${widget.buttonData.storyId}-${widget.buttonData.currentSegmentIndex}");
    } else {
      _accumulatedTime = 0;
      _onSegmentComplete();
      _curSegmentIndex++;
      _maxAccumulator = widget
          .buttonData
          .segmentDuration[widget.buttonData.currentSegmentIndex]
          .inMilliseconds;
    }
  }

  void previousSegment() {
    if (_accumulatedTime == _maxAccumulator) {
      _accumulatedTime = 0;
    } else {
      _accumulatedTime = 0;
      _curSegmentIndex--;
      _maxAccumulator = widget
          .buttonData
          .segmentDuration[widget.buttonData.currentSegmentIndex]
          .inMilliseconds;
      _onSegmentComplete();
    }
  }

  void pause() {
    _isPaused = true;
  }

  void unpause() {
    _isPaused = false;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.0,
      width: double.infinity,
      child: !_isPaused
          ? CustomPaint(
              painter: _TimelinePainter(
                fillColor: widget.buttonData.timelineFillColor,
                backgroundColor: widget.buttonData.timelineBackgroundColor,
                curSegmentIndex: _curSegmentIndex,
                numSegments: _numSegments,
                percent: _accumulatedTime / _maxAccumulator,
                spacing: widget.buttonData.timelineSpacing,
                thikness: widget.buttonData.timelineThikness,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final Color fillColor;
  final Color backgroundColor;
  final int curSegmentIndex;
  final int numSegments;
  final double percent;
  final double spacing;
  final double thikness;

  _TimelinePainter({
    required this.fillColor,
    required this.backgroundColor,
    required this.curSegmentIndex,
    required this.numSegments,
    required this.percent,
    required this.spacing,
    required this.thikness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thikness
      ..color = backgroundColor
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thikness
      ..color = fillColor
      ..style = PaintingStyle.stroke;

    final maxSpacing = (numSegments - 1) * spacing;
    final maxSegmentLength = (size.width - maxSpacing) / numSegments;

    for (var i = 0; i < numSegments; i++) {
      final start = Offset(
        ((maxSegmentLength + spacing) * i),
        0.0,
      );
      final end = Offset(
        start.dx + maxSegmentLength,
        0.0,
      );

      canvas.drawLine(
        start,
        end,
        bgPaint,
      );
    }

    for (var i = 0; i < numSegments; i++) {
      final start = Offset(
        ((maxSegmentLength + spacing) * i),
        0.0,
      );
      var endValue = start.dx;
      if (curSegmentIndex > i) {
        endValue = start.dx + maxSegmentLength;
      } else if (curSegmentIndex == i) {
        endValue = start.dx + (maxSegmentLength * percent);
      }
      final end = Offset(
        endValue,
        0.0,
      );
      if (endValue == start.dx) {
        continue;
      }
      canvas.drawLine(
        start,
        end,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
