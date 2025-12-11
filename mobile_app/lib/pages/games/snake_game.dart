import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  static const int gridSize = 20;
  static const int cellSize = 20;
  List<Point> _snake = [];
  Point? _food;
  Direction _direction = Direction.right;
  Direction _nextDirection = Direction.right;
  Timer? _gameTimer;
  int _score = 0;
  bool _isGameOver = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _snake = [
      Point(5, 5),
      Point(4, 5),
      Point(3, 5),
    ];
    _direction = Direction.right;
    _nextDirection = Direction.right;
    _score = 0;
    _isGameOver = false;
    _isPaused = false;
    _generateFood();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_isPaused && !_isGameOver) {
        _moveSnake();
      }
    });
  }

  void _generateFood() {
    final random = Random();
    Point newFood;
    do {
      newFood = Point(
        random.nextInt(gridSize),
        random.nextInt(gridSize),
      );
    } while (_snake.contains(newFood));
    _food = newFood;
  }

  void _moveSnake() {
    setState(() {
      _direction = _nextDirection;
      final head = _snake.first;
      Point newHead;

      switch (_direction) {
        case Direction.up:
          newHead = Point(head.x, head.y - 1);
          break;
        case Direction.down:
          newHead = Point(head.x, head.y + 1);
          break;
        case Direction.left:
          newHead = Point(head.x - 1, head.y);
          break;
        case Direction.right:
          newHead = Point(head.x + 1, head.y);
          break;
      }

      // Duvar kontrolü
      if (newHead.x < 0 ||
          newHead.x >= gridSize ||
          newHead.y < 0 ||
          newHead.y >= gridSize) {
        _gameOver();
        return;
      }

      // Kendine çarpma kontrolü
      if (_snake.contains(newHead)) {
        _gameOver();
        return;
      }

      _snake.insert(0, newHead);

      // Yemek yeme kontrolü
      if (newHead == _food) {
        _score++;
        _generateFood();
      } else {
        _snake.removeLast();
      }
    });
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
    });
    _gameTimer?.cancel();
  }

  void _pauseGame() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _restartGame() {
    _gameTimer?.cancel();
    _startGame();
  }

  void _changeDirection(Direction newDirection) {
    // Ters yöne gitmeyi engelle
    if ((_direction == Direction.up && newDirection == Direction.down) ||
        (_direction == Direction.down && newDirection == Direction.up) ||
        (_direction == Direction.left && newDirection == Direction.right) ||
        (_direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    _nextDirection = newDirection;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Oyunu'),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _pauseGame,
            tooltip: _isPaused ? 'Devam Et' : 'Duraklat',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Skor',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$_score',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_isGameOver)
                  ElevatedButton.icon(
                    onPressed: _restartGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeniden Başla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (_isPaused && !_isGameOver)
                  Text(
                    'DURAKLADI',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    color: Colors.grey[100],
                  ),
                  child: CustomPaint(
                    painter: SnakeGamePainter(
                      snake: _snake,
                      food: _food,
                      gridSize: gridSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isGameOver)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Column(
                children: [
                  Text(
                    'Oyun Bitti!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Skorunuz: $_score',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Yukarı butonu
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, size: 40),
            onPressed: () => _changeDirection(Direction.up),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.all(16),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sol butonu
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_left, size: 40),
                onPressed: () => _changeDirection(Direction.left),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(width: 80),
              // Sağ butonu
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_right, size: 40),
                onPressed: () => _changeDirection(Direction.right),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
          // Aşağı butonu
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 40),
            onPressed: () => _changeDirection(Direction.down),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

enum Direction { up, down, left, right }

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class SnakeGamePainter extends CustomPainter {
  final List<Point> snake;
  final Point? food;
  final int gridSize;

  SnakeGamePainter({
    required this.snake,
    required this.food,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    // Yılanı çiz
    final snakePaint = Paint()
      ..color = Colors.green[700]!
      ..style = PaintingStyle.fill;

    for (var i = 0; i < snake.length; i++) {
      final point = snake[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          point.x * cellWidth,
          point.y * cellHeight,
          cellWidth,
          cellHeight,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, snakePaint);

      // Baş için gözler
      if (i == 0) {
        final eyePaint = Paint()..color = Colors.white;
        canvas.drawCircle(
          Offset(point.x * cellWidth + cellWidth * 0.3, point.y * cellHeight + cellHeight * 0.3),
          3,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(point.x * cellWidth + cellWidth * 0.7, point.y * cellHeight + cellHeight * 0.3),
          3,
          eyePaint,
        );
      }
    }

    // Yemeği çiz
    if (food != null) {
      final foodPaint = Paint()
        ..color = Colors.red[600]!
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          food!.x * cellWidth,
          food!.y * cellHeight,
          cellWidth,
          cellHeight,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, foodPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

