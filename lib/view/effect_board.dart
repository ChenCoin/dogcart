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
  void createEffect(
      (int, int) color, List<ColorPoint> breakList, List<StarGrid> movingList) {
    var cache = cachePair.getAnimationCache();
    cache.using = true;
    var animCache = cache.getAnimationCache();
    // break star animation
    var breakStars = BreakStarList(breakList, animCache.ba, color);
    widget.data.addBreakStarList(breakStars);
    cache.addBreakListener((status) {
      if (status == AnimationStatus.completed) {
        if (UX.breakStarDuration >= UX.moveStarDuration) {
          cache.endAnimation();
        }
        widget.data.removeBreakStarList(breakStars);
      }
    });
    // moving star animation
    var movingAnim = animCache.ma;
    for (var item in movingList) {
      item.willMove(movingAnim);
    }
    cache.addMovingListener((status) {
      if (status == AnimationStatus.completed) {
        if (UX.breakStarDuration < UX.moveStarDuration) {
          cache.endAnimation();
        }
        for (var item in movingList) {
          if (item.anim == movingAnim) {
            item.endMove();
          }
        }
        widget.callback();
      }
    });
    // start animation
    cache.startAnimation();
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
    drawMovingStar(
        canvas, data, path, gridPaint, starPaint, (p) => p.anim?.value ?? 0);
    drawBreakStar(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawBreakStar(Canvas canvas) {
    double grid = data.grid;
    List<BreakStarList> breakStars = data.breakStarList;
    for (var item in breakStars) {
      if (item.anim.status != AnimationStatus.forward) {
        continue;
      }
      int color = item.color.$1;
      List<ColorPoint> list = item.list;
      for (var colorPoint in list) {
        // draw star
        var animValue = 100 - item.anim.value / 2; // 100 -> 50
        double R = (grid / 2 - 2) * animValue / 100;
        double r = (grid / 4) * animValue / 100;
        var rot = 360 * item.anim.value / 100;
        int alpha = 255 * (100 - item.anim.value) ~/ 100;
        starPaint.color = Color(color).withAlpha(alpha);

        for (var end in colorPoint.probability) {
          var dx = colorPoint.start.$1 + end.$1 * item.anim.value / 100;
          var dy = colorPoint.start.$2 + end.$2 * item.anim.value / 100;
          drawStar(path, R, r, dx, dy, rot);
          canvas.drawPath(path, starPaint);
        }
      }
    }
  }
}

class AnimationPair {
  // animation controller of moving star
  AnimationController mc;

  // animation value of moving star
  Animation<double> ma;

  // animation controller of break star
  AnimationController bc;

  // animation value of break star
  Animation<double> ba;

  AnimationPair(this.mc, this.ma, this.bc, this.ba);
}

class _Cache {
  bool using = false;

  TickerProviderStateMixin ticker;

  VoidCallback callback;

  AnimationPair? _cache;

  AnimationStatusListener _mCacheListener = (status) {};

  AnimationStatusListener _bCacheListener = (status) {};

  _Cache(this.ticker, this.callback);

  AnimationPair getAnimationCache() {
    if (_cache == null) {
      Duration duration = const Duration(milliseconds: UX.moveStarDuration);
      var controller = AnimationController(duration: duration, vsync: ticker);
      // animation was using for the dynamically value
      var curve =
          CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);
      var anim = Tween(begin: 0.0, end: 100.0).animate(curve)
        ..addListener(callback);

      Duration duration2 = const Duration(milliseconds: UX.breakStarDuration);
      var controller2 = AnimationController(duration: duration2, vsync: ticker);
      // animation was using for the dynamically value
      var curve2 =
          CurvedAnimation(parent: controller2, curve: Curves.easeOutQuad);
      var anim2 = Tween(begin: 0.0, end: 100.0).animate(curve2)
        ..addListener(callback);
      _cache = AnimationPair(controller, anim, controller2, anim2);
    } else {
      _cache!.mc.reset();
      _cache!.bc.reset();
    }
    return _cache!;
  }

  void addMovingListener(AnimationStatusListener listener) {
    _mCacheListener = listener;
    _cache?.mc.addStatusListener(_mCacheListener);
  }

  void addBreakListener(AnimationStatusListener listener) {
    _bCacheListener = listener;
    _cache?.bc.addStatusListener(_bCacheListener);
  }

  void startAnimation() {
    _cache?.mc.forward();
    _cache?.bc.forward();
  }

  void endAnimation() {
    using = false;
    _cache?.mc.removeStatusListener(_mCacheListener);
    _cache?.bc.removeStatusListener(_bCacheListener);
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
  _Cache getAnimationCache() {
    for (var item in _list) {
      if (!item.using) {
        return item;
      }
    }
    // error case
    return _list[0];
  }

  void dispose() {
    for (var item in _list) {
      item._cache?.mc.dispose();
      item._cache?.bc.dispose();
    }
  }
}
