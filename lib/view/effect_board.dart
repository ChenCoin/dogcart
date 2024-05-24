import 'package:flutter/material.dart';

import '../data/grid_data.dart';
import '../data/grid_point.dart';
import '../ux.dart';
import 'shape_draw.dart';

class EffectBoard extends StatefulWidget {
  final Size size;

  final GridData data;

  final void Function() callback;

  const EffectBoard(
      {super.key,
      required this.size,
      required this.data,
      required this.callback});

  @override
  State<StatefulWidget> createState() => _EffectBoardState();
}

class _EffectBoardState extends State<EffectBoard>
    with TickerProviderStateMixin
    implements EffectCreator {
  late _CachePair cachePair = _CachePair(() => _Cache(this, sync));

  final durationEnter = const Duration(milliseconds: UX.enterSceneDuration);

  final durationExit = const Duration(milliseconds: UX.exitSceneDuration);

  final durationMoving = const Duration(milliseconds: UX.moveStarDuration);

  final durationBreak = const Duration(milliseconds: UX.breakStarDuration);

  @override
  void initState() {
    super.initState();
    widget.data.onViewInit(this);
  }

  @override
  Widget build(BuildContext context) {
    var size = widget.size;
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: _MyPainter(data: widget.data),
      ),
    );
  }

  @override
  void dispose() {
    cachePair.dispose();
    super.dispose();
    widget.data.onDispose();
  }

  @override
  bool isEffectEnable() {
    return cachePair.isAnyEnable();
  }

  @override
  void createEffect(List<ColorPoint> breakList, List<StarGrid> movingList) {
    // break star animation
    var cacheBreak = cachePair.useAnimationCache();
    var breakAnim = cacheBreak.getAnimationCache(durationBreak);
    var breakStars = BreakStarList(breakList, breakAnim);
    widget.data.addBreakStarList(breakStars);
    cacheBreak.addMovingListener((status) {
      if (status != AnimationStatus.completed) {
        return;
      }
      cacheBreak.endAnimation();
      widget.data.removeBreakStarList(breakStars);
    });

    // moving star animation
    var cacheMoving = cachePair.useAnimationCache();
    var movingAnim = cacheMoving.getAnimationCache(durationMoving);
    for (var item in movingList) {
      item.willMove(movingAnim);
    }
    cacheMoving.addMovingListener((status) {
      if (status != AnimationStatus.completed) {
        return;
      }
      cacheMoving.endAnimation();
      for (var item in movingList) {
        if (item.anim == movingAnim) {
          item.endMove();
        }
      }
      widget.callback();
    });

    // start animation
    cacheBreak.startAnimation();
    cacheMoving.startAnimation();
  }

  @override
  void enterScene() {
    var cacheMoving = cachePair.useAnimationCache();
    var movingAnim = cacheMoving.getAnimationCache(durationEnter);
    for (var line in widget.data.grids) {
      for (var item in line) {
        item.willMove(movingAnim);
      }
    }
    cacheMoving.addMovingListener((status) {
      if (status != AnimationStatus.completed) {
        return;
      }
      cacheMoving.endAnimation();
      for (var line in widget.data.grids) {
        for (var item in line) {
          if (item.anim == movingAnim) {
            item.endMove();
          }
        }
      }
      widget.callback();
    });
    cacheMoving.startAnimation();
  }

  @override
  void exitScene(List<ColorPoint> breakList) {
    var cacheBreak = cachePair.useAnimationCache();
    var breakAnim = cacheBreak.getAnimationCache(durationExit);
    var breakStars = BreakStarList(breakList, breakAnim);
    widget.data.addBreakStarList(breakStars);
    cacheBreak.addMovingListener((status) {
      if (status != AnimationStatus.completed) {
        return;
      }
      cacheBreak.endAnimation();
      widget.data.removeBreakStarList(breakStars);
    });
    cacheBreak.startAnimation();
  }

  void sync() {
    setState(() {});
  }
}

class _MyPainter extends CustomPainter {
  final GridData data;

  final path = Path();

  final starPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  final gridPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  _MyPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    drawMovingStar(canvas, data, path, gridPaint, starPaint);
    drawBreakStar(canvas, data, path, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimationPair {
  AnimationController controller;

  Animation<double> anim;

  AnimationPair(this.controller, this.anim);
}

final _nilListener = (status) {};

class _Cache {
  bool using = false;

  TickerProviderStateMixin ticker;

  VoidCallback callback;

  AnimationPair? _cache;

  AnimationStatusListener _mCacheListener = _nilListener;

  _Cache(this.ticker, this.callback);

  Animation<double> getAnimationCache(Duration duration) {
    if (_cache == null) {
      var controller = AnimationController(duration: duration, vsync: ticker);
      // animation was using for the dynamically value
      var curve =
          CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);
      var anim = Tween(begin: 0.0, end: 100.0).animate(curve)
        ..addListener(callback);
      _cache = AnimationPair(controller, anim);
      return anim;
    } else {
      _cache!.controller.reset();
      _cache!.controller.duration = duration;
      return _cache!.anim;
    }
  }

  void addMovingListener(AnimationStatusListener listener) {
    _mCacheListener = listener;
    _cache?.controller.addStatusListener(_mCacheListener);
  }

  void startAnimation() {
    _cache?.controller.forward();
  }

  void endAnimation() {
    using = false;
    _cache?.controller.removeStatusListener(_mCacheListener);
    _mCacheListener = _nilListener;
  }
}

class _CachePair {
  final List<_Cache> _list = <_Cache>[];

  _CachePair(_Cache Function() create) {
    for (int i = 0; i < UX.animationCacheSize; i++) {
      _list.add(create());
    }
  }

  bool isAnyEnable() {
    for (var item in _list) {
      if (!item.using) {
        return true;
      }
    }
    return false;
  }

  // isAnyEnable should be called before called this function.
  // The case of all anim using is not support
  _Cache useAnimationCache() {
    for (var item in _list) {
      if (!item.using) {
        item.using = true;
        return item;
      }
    }
    // error case
    return _list[0];
  }

  void dispose() {
    for (var item in _list) {
      item._cache?.controller.dispose();
    }
  }
}
