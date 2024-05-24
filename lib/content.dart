class Content {
  static const title = '星星王国';

  static const startGame = '开始游戏';

  static goToNextLevel(int second) => '$second 秒后进入下一关';

  static const pass = '通关';

  static levelScore(int score) => '本局得分: $score';

  static collectStar(int star, int score) => '收集星星: $star, 得分: $score';

  static lastStar(int star, int score) => '剩余星星: $star, 得分: $score';

  static const nextLevel = '下一关';

  static target(int goal) => '目标 $goal';
}
