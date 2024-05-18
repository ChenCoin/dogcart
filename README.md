# dogcart

## 星星王国

一个用Flutter编写的小游戏。在 10 x 10 的格子中，每个格子随机出现不同颜色的星星格子。点击相连的相同颜色的格子，就可以消除星星。

## 版本计划
- [x] 1.0.0 完成基本的星星点击，统计本局分数。
- [ ] 2.0.0 完善游戏界面，加入动画

### 命令行备忘

1. 命令行编译Web：  
   flutter build web --web-renderer canvaskit --release --base-href=/dogcart/
     --web-renderer html
     --no-web-resources-cdn --no-tree-shake-icons --pwa-strategy none
   flutter build web --web-renderer html --release --base-href=/dogcart/
   flutter build web --web-renderer skwasm --release --base-href=/dogcart/
     --no-web-resources-cdn --no-tree-shake-icons --no-source-maps --csp --optimization-level=4
   flutter build web --release --base-href=/dogcart/ --no-web-resources-cdn --no-tree-shake-icons --no-source-maps --csp --optimization-level=4 --wasm

2. 修改hosts文件  
   windows上hosts文件路径为
   C:\Windows\System32\drivers\etc\hosts  
   刷新本地dns数据  
   ipconfig /flushdns

3. 语言文本文件更新  
   C:\flutter\bin\flutter gen-l10n

### todo

- [ ] 适配不同分辨率的屏幕
- [ ] grid数值固定，不动态计算，优化性能
