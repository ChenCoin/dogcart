class Content {
  static const title = '星星王国';

  static const version = 'v1.5.0';

  static const startGame = '开始游戏';

  static goToNextLevel(int second) => '$second 秒后进入下一关';

  static const pass = '通关';

  static levelScore(int score) => '本局得分: $score';

  static collectStar(int star, int score) => '收集星星: $star, 得分: $score';

  static lastStar(int star, int score) => '剩余星星: $star, 得分: $score';

  static const nextLevel = '下一关';

  static target(int goal) => '目标 $goal';

  static const gameOver = '游戏结束';

  static gameScore(int score) => '本轮游戏得分：$score';

  static highestScore(int score) => '最高得分：$score';

  static const backHome = '回到首页';

  static const restart = '重新开始';

  static theHighestScore(int score) => '最高分: $score';

  static const score = '分数: ';

  static levelAndGoal(int level, int goal) => '关卡: $level  目标: $goal';

  static const gameTip = '消除连在一起的相同颜色的星星。';

  static const endGame = '结束';

  static const playAgain = '再次挑战';
}
