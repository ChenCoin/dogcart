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
        painter: _MyPainter(width: size.width, data: widget.data),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.data.onDispose();
    cachePair.dispose();
  }

  @override
  bool isEffectEnable() {
    return cachePair.isAnyEnable();
  }

  @override
  void createEffect(List<ColorPoint> breakList, List<StarGrid> movingList) {
    var cache = cachePair.getAnimationCache();
    cache.using = true;
    var animCache = cache.getAnimationCache();
    var controller = animCache.$1;
    var anim = animCache.$2;

    var breakStars = BreakStarList(breakList, anim);
    widget.data.addBreakStarList(breakStars);
    for (var item in movingList) {
      item.willMove(anim);
    }
    cache.addListener((status) {
      if (status == AnimationStatus.completed) {
        cache.using = false;
        cache.removeListener();
        widget.data.removeBreakStarList(breakStars);
        // 结束移动星星的动画
        for (var item in movingList) {
          if (item.anim == anim) {
            item.endMove();
          }
        }
        widget.callback();
        debugPrint('anim end');
      }
    });
    controller.addStatusListener(cache._cacheListener);
    controller.forward();
    debugPrint('anim start');
  }

  void sync() {
    setState(() {});
  }
}

class _MyPainter extends CustomPainter {
  final double width;

  final GridData data;

  final path = Path();

  final numberDrawer = NumberDrawer();

  final starPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  final gridPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  _MyPainter({required this.width, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    int gap = GridData.gap;
    double grid = data.obtainGrid(width);
    drawMovingStar(canvas, gap, grid);
    drawBreakStar(canvas, gap, grid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawBreakStar(Canvas canvas, int gap, double grid) {
    List<BreakStarList> breakStars = data.breakStarList;
    for (var item in breakStars) {
      if (item.anim.status != AnimationStatus.forward) {
        continue;
      }
      var animValue = 100 - item.anim.value;
      List<ColorPoint> list = item.list;
      double textDx = 0;
      double textDy = 0;
      for (var colorPoint in list) {
        int i = colorPoint.y;
        int j = colorPoint.x;
        textDx += j;
        textDy += i;
        // 画五角星
        var left = grid * j + gap * (j + 1);
        var top = grid * i + gap * (i + 1);
        double R = (grid / 2 - 2) * animValue / 100;
        double r = (grid / 4) * animValue / 100;
        drawStar(path, R, r, left + grid / 2, top + grid / 2, 0);
        starPaint.color = Color(colorPoint.color.$1);
        canvas.drawPath(path, starPaint);
      }
      textDx /= list.length;
      textDx = grid * (textDx + 0.5) + gap * (textDx + 1);
      textDy /= list.length;
      textDy = grid * (textDy) + gap * (textDy + 1) + 24 / 2;
      var score = list.length * list.length * 5;
      numberDrawer.drawNumber(canvas, textDx, textDy, '+$score');
    }
  }

  void drawMovingStar(Canvas canvas, int gap, double grid) {
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
        starPaint.color = Color(color.$1);
        canvas.drawPath(path, starPaint);
      }
    }
  }
}

class _Cache {
  bool using = false;

  TickerProviderStateMixin ticker;

  VoidCallback callback;

  (AnimationController, Animation<double>)? _cache;

  AnimationStatusListener _cacheListener = (status) {};

  _Cache(this.ticker, this.callback);

  (AnimationController, Animation<double>) getAnimationCache() {
    if (_cache == null) {
      Duration duration = const Duration(milliseconds: UX.animationDuration);
      var controller = AnimationController(duration: duration, vsync: ticker);
      // animation用于获取数值
      var curve =
          CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);
      var anim = Tween(begin: 0.0, end: 100.0).animate(curve)
        ..addListener(callback);
      _cache = (controller, anim);
    } else {
      _cache!.$1.reset();
    }
    return _cache!;
  }

  void addListener(AnimationStatusListener listener) {
    _cacheListener = listener;
  }

  void removeListener() {
    getAnimationCache().$1.removeStatusListener(_cacheListener);
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
      var cache = item.getAnimationCache();
      cache.$1.dispose();
    }
  }
}
