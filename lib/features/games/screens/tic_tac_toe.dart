import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'package:isapp/features/games/widgets/action_button.dart';

export 'package:isapp/features/games/widgets/action_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<String> board;
  String currentPlayer = "X";
  bool gameOver = false;
  int turn = 0;
  String result = "";
  List<int> scoreboard = [0, 0, 0, 0, 0, 0, 0, 0];
  List<int>? winningLine;
  
  // Enhanced features
  int playerXWins = 0;
  int playerOWins = 0;
  int draws = 0;
  bool isVsAI = false;
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  List<Map<String, dynamic>> moveHistory = [];
  
  @override
  void initState() {
    super.initState();
    board = List.filled(9, "");
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void makeMove(int index) {
    if (gameOver || board[index].isNotEmpty) return;

    setState(() {
      // Record move
      moveHistory.add({
        'player': currentPlayer,
        'position': index,
        'board': List<String>.from(board),
      });

      // Make move
      board[index] = currentPlayer;
      turn++;
      
      // Check for win
      winningLine = _checkWinWithLine(currentPlayer);
      gameOver = winningLine != null || turn == 9;

      if (winningLine != null) {
        result = "$currentPlayer Wins! 🎉";
        _confettiController.play();
        
        if (currentPlayer == "X") {
          playerXWins++;
        } else {
          playerOWins++;
        }
      } else if (turn == 9) {
        result = "It's a Draw! 🤝";
        gameOver = true;
        draws++;
      }

      // Switch player
      currentPlayer = currentPlayer == "X" ? "O" : "X";
      
      // AI move if enabled and it's AI's turn
      if (!gameOver && isVsAI && currentPlayer == "O") {
        _makeAIMove();
      }
    });
  }

  List<int>? _checkWinWithLine(String player) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (final pattern in winPatterns) {
      if (board[pattern[0]] == player &&
          board[pattern[1]] == player &&
          board[pattern[2]] == player) {
        return pattern;
      }
    }
    return null;
  }

  void _makeAIMove() {
    // Simple AI: Try to win, block, or take center/corners
    Future.delayed(const Duration(milliseconds: 500), () {
      // Find empty cells
      List<int> emptyCells = [];
      for (int i = 0; i < board.length; i++) {
        if (board[i].isEmpty) emptyCells.add(i);
      }

      if (emptyCells.isEmpty) return;

      // Try to win
      for (int cell in emptyCells) {
        board[cell] = "O";
        if (_checkWinWithLine("O") != null) {
          makeMove(cell);
          return;
        }
        board[cell] = "";
      }

      // Block player
      for (int cell in emptyCells) {
        board[cell] = "X";
        if (_checkWinWithLine("X") != null) {
          board[cell] = "";
          makeMove(cell);
          return;
        }
        board[cell] = "";
      }

      // Take center
      if (emptyCells.contains(4)) {
        makeMove(4);
        return;
      }

      // Take corners
      List<int> corners = [0, 2, 6, 8];
      for (int corner in corners) {
        if (emptyCells.contains(corner)) {
          makeMove(corner);
          return;
        }
      }

      // Take any available cell
      makeMove(emptyCells[0]);
    });
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      currentPlayer = "X";
      gameOver = false;
      turn = 0;
      result = "";
      scoreboard = [0, 0, 0, 0, 0, 0, 0, 0];
      winningLine = null;
      moveHistory.clear();
      _animationController.reset();
      _animationController.forward();
    });
  }

  void newSession() {
    setState(() {
      resetGame();
      playerXWins = 0;
      playerOWins = 0;
      draws = 0;
    });
  }

  void undoMove() {
    if (moveHistory.isEmpty || gameOver) return;

    setState(() {
      Map<String, dynamic> lastMove = moveHistory.removeLast();
      board = List<String>.from(lastMove['board']);
      currentPlayer = lastMove['player'];
      turn--;
      gameOver = false;
      result = "";
      winningLine = null;
      scoreboard = [0, 0, 0, 0, 0, 0, 0, 0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),

          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.blue,
              Colors.red,
              Colors.green,
              Colors.yellow,
              Colors.purple,
            ],
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TIC TAC TOE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            "Game ${playerXWins + playerOWins + draws + 1}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      _buildGameModeSwitch(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Score Board
                  _buildScoreBoard(),

                  const SizedBox(height: 32),

                  // Turn indicator
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: currentPlayer == "X" 
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: currentPlayer == "X" ? Colors.blue : Colors.red,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentPlayer == "X"
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          currentPlayer == "X" ? Icons.person : Icons.smart_toy,
                          color: currentPlayer == "X" ? Colors.blue : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isVsAI && currentPlayer == "O"
                              ? "AI's Turn"
                              : "Player $currentPlayer's Turn",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Game Board
                  ScaleTransition(
                    scale: Tween(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: Container(
                      width: isPortrait ? size.width * 0.9 : size.width * 0.5,
                      height: isPortrait ? size.width * 0.9 : size.width * 0.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return _GameCell(
                            symbol: board[index],
                            isWinningCell: winningLine?.contains(index) ?? false,
                            onTap: () => makeMove(index),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Result display
                  if (result.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      decoration: BoxDecoration(
                        color: winningLine != null 
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: winningLine != null ? Colors.green : Colors.orange,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        result,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  if (result.isNotEmpty) const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(),

                  // Move history
                  if (moveHistory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Move History",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: moveHistory.length,
                              itemBuilder: (context, index) {
                                final move = moveHistory[index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: move['player'] == "X"
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: move['player'] == "X"
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Move ${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        move['player'],
                                        style: TextStyle(
                                          color: move['player'] == "X"
                                              ? Colors.blue
                                              : Colors.red,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              isVsAI = false;
              resetGame();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !isVsAI ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.group, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "PvP",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              isVsAI = true;
              resetGame();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isVsAI ? Colors.purple : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.smart_toy, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "vs AI",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PlayerScore(
            player: "X",
            score: playerXWins,
            color: Colors.blue,
            icon: Icons.person,
            isAI: false,
          ),
          _DrawScore(draws: draws),
          _PlayerScore(
            player: "O",
            score: playerOWins,
            color: Colors.red,
            icon: isVsAI ? Icons.smart_toy : Icons.person,
            isAI: isVsAI,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        if (moveHistory.isNotEmpty && !gameOver)
          ActionButton(
            icon: Icons.undo,
            label: "Undo",
            color: Colors.orange,
            onPressed: undoMove,
          ),
        
        ActionButton(
          icon: Icons.refresh,
          label: "Restart",
          color: Colors.red,
          onPressed: resetGame,
        ),
        
        ActionButton(
          icon: Icons.new_releases,
          label: "New Session",
          color: Colors.green,
          onPressed: newSession,
        ),
      ],
    );
  }
}

class _GameCell extends StatelessWidget {
  final String symbol;
  final bool isWinningCell;
  final VoidCallback onTap;

  const _GameCell({
    required this.symbol,
    required this.isWinningCell,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isWinningCell
              ? (symbol == "X"
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3))
              : const Color(0xFF0A0E21),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isWinningCell ? Colors.yellow : Colors.white24,
            width: isWinningCell ? 3 : 1,
          ),
          boxShadow: isWinningCell
              ? [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: symbol.isEmpty
                ? Container()
                : Text(
                    symbol,
                    key: ValueKey(symbol),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: symbol == "X" ? Colors.blue : Colors.red,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: (symbol == "X" ? Colors.blue : Colors.red)
                              .withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final String player;
  final int score;
  final Color color;
  final IconData icon;
  final bool isAI;

  const _PlayerScore({
    required this.player,
    required this.score,
    required this.color,
    required this.icon,
    required this.isAI,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          isAI ? "AI (O)" : "Player $player",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$score",
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DrawScore extends StatelessWidget {
  final int draws;

  const _DrawScore({required this.draws});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: const Icon(Icons.handshake, color: Colors.orange, size: 28),
        ),
        const SizedBox(height: 8),
        const Text(
          "Draws",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$draws",
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
