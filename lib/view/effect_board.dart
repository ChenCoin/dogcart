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

    var breakController = animCache.bc;
    var breakAnim = animCache.ba;

    // anim duration of 'moving star' should short than 'break star'
    var breakStars = BreakStarList(breakList, breakAnim, color);
    widget.data.addBreakStarList(breakStars);
    cache.addBreakListener((status) {
      if (status == AnimationStatus.completed) {
        cache.using = false;
        cache.removeListener();
        widget.data.removeBreakStarList(breakStars);
      }
    });

    var movingController = animCache.mc;
    var movingAnim = animCache.ma;
    for (var item in movingList) {
      item.willMove(movingAnim);
    }
    cache.addMovingListener((status) {
      if (status == AnimationStatus.completed) {
        // 结束移动星星的动画
        for (var item in movingList) {
          if (item.anim == movingAnim) {
            item.endMove();
          }
        }
        widget.callback();
      }
    });

    breakController.forward();
    movingController.forward();
  }

  void sync() {
    setState(() {});
  }
}

class _MyPainter extends CustomPainter {
  final GridData data;

  final path = Path();

  final numberDrawer = NumberDrawer();

  final starPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  final gridPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  _MyPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    drawMovingStar(canvas);
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
        // 画五角星
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

  void drawMovingStar(Canvas canvas) {
    int gap = GridData.gap;
    double grid = data.grid;
    // 绘制格子
    for (int dy = 0; dy < UX.row; dy++) {
      for (int dx = 0; dx < UX.col; dx++) {
        var gridPoint = data.grids[dy][dx];
        if (!gridPoint.isMoving()) {
          continue;
        }
        var anim = gridPoint.anim?.value ?? 0;
        var posY = gridPoint.getPosition().y;
        var i = posY + (dy - posY) * anim / 100;
        var posX = gridPoint.getPosition().x;
        var j = posX + (dx - posX) * anim / 100;

        (int, int) color = gridPoint.color;
        gridPaint.color = Color(color.$2);
        starPaint.color = Color(color.$1);

        // 画圆角方块
        var left = grid * j + gap * (j + 1);
        var top = grid * i + gap * (i + 1);
        drawSmoothRoundRect(path, left, top, grid, grid, 12);
        canvas.drawPath(path, gridPaint);

        // 画五角星
        left = left + grid / 2;
        top = top + grid / 2;
        drawStar(path, grid / 2 - 2, grid / 4, left, top, 0);
        canvas.drawShadow(path, const Color(0xFF808080), 3, false);
        canvas.drawPath(path, starPaint);
      }
    }
  }
}

class AnimationPair {
  AnimationController mc;

  Animation<double> ma;

  AnimationController bc;

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
      // animation用于获取数值
      var curve =
          CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);
      var anim = Tween(begin: 0.0, end: 100.0).animate(curve)
        ..addListener(callback);

      Duration duration2 = const Duration(milliseconds: UX.breakStarDuration);
      var controller2 = AnimationController(duration: duration2, vsync: ticker);
      // animation用于获取数值
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

  void removeListener() {
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

  // 调用这个接口前，先用isAnyEnable判断存在一个可用的anim，不考虑所有anim都使用中的场景
  _Cache getAnimationCache() {
    for (var item in _list) {
      if (!item.using) {
        return item;
      }
    }
    // 这个返回值会导致异常
    return _list[0];
  }

  void dispose() {
    for (var item in _list) {
      item._cache?.mc.dispose();
      item._cache?.bc.dispose();
    }
  }
}
