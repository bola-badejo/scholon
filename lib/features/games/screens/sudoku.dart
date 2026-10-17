import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/games/models/difficulty.dart';
import 'package:isapp/features/games/models/sudoku_cell.dart';

export 'package:isapp/features/games/models/difficulty.dart';
export 'package:isapp/features/games/models/sudoku_cell.dart';

class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key});

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  late List<List<SudokuCell>> board;
  late List<List<SudokuCell>> solvedBoard;
  late Stopwatch stopwatch;
  late Timer _timer;
  bool isGameWon = false;
  int selectedNumber = 0;
  int? selectedRow;
  int? selectedCol;
  int mistakes = 0;
  final int maxMistakes = 3;
  Difficulty difficulty = Difficulty.medium;
  int hintsUsed = 0;
  int score = 1000;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    stopwatch = Stopwatch();
    stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void _initializeGame() {
    board = List.generate(9, (row) => List.generate(9, (col) => SudokuCell(row: row, col: col)));
    solvedBoard = _generateSolvedSudoku();
    _createPuzzle();
  }

  List<List<SudokuCell>> _generateSolvedSudoku() {
    final solved = List.generate(9, (i) => List.filled(9, 0));
    _fillDiagonal(solved);
    _fillRemaining(solved, 0, 3);
    return List.generate(9, (row) => 
        List.generate(9, (col) => SudokuCell(
          row: row, 
          col: col, 
          value: solved[row][col],
          isOriginal: true,
        ))
    );
  }

  void _fillDiagonal(List<List<int>> matrix) {
    for (int i = 0; i < 9; i += 3) {
      _fillBox(matrix, i, i);
    }
  }

  void _fillBox(List<List<int>> matrix, int row, int col) {
    final nums = List.generate(9, (i) => i + 1)..shuffle();
    int index = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        matrix[row + i][col + j] = nums[index++];
      }
    }
  }

  bool _fillRemaining(List<List<int>> matrix, int i, int j) {
    if (j >= 9 && i < 8) {
      i += 1;
      j = 0;
    }
    if (i >= 9 && j >= 9) return true;
    if (i < 3) {
      if (j < 3) j = 3;
    } else if (i < 6) {
      if (j == (i ~/ 3) * 3) j += 3;
    } else {
      if (j == 6) {
        i += 1;
        j = 0;
        if (i >= 9) return true;
      }
    }

    for (int num = 1; num <= 9; num++) {
      if (_isSafe(matrix, i, j, num)) {
        matrix[i][j] = num;
        if (_fillRemaining(matrix, i, j + 1)) return true;
        matrix[i][j] = 0;
      }
    }
    return false;
  }

  bool _isSafe(List<List<int>> matrix, int row, int col, int num) {
    for (int x = 0; x < 9; x++) {
      if (matrix[row][x] == num) return false;
    }
    for (int x = 0; x < 9; x++) {
      if (matrix[x][col] == num) return false;
    }
    final startRow = row - row % 3;
    final startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (matrix[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  void _createPuzzle() {
    final cells = List.generate(81, (i) => i);
    cells.shuffle();
    
    int cellsToRemove;
    switch (difficulty) {
      case Difficulty.easy:
        cellsToRemove = 40;
        score = 1000;
        break;
      case Difficulty.medium:
        cellsToRemove = 50;
        score = 1500;
        break;
      case Difficulty.hard:
        cellsToRemove = 60;
        score = 2000;
        break;
    }

    for (int i = 0; i < cellsToRemove; i++) {
      final cell = cells[i];
      final row = cell ~/ 9;
      final col = cell % 9;
      board[row][col].value = 0;
      board[row][col].isOriginal = false;
    }
  }

  void _selectCell(int row, int col) {
    if (!board[row][col].isOriginal) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    }
  }

  void _placeNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (board[selectedRow!][selectedCol!].isOriginal) return;

    setState(() {
      if (board[selectedRow!][selectedCol!].value != 0 && 
          board[selectedRow!][selectedCol!].value != number) {
        _clearConflicts(selectedRow!, selectedCol!);
      }

      board[selectedRow!][selectedCol!].value = number;
      board[selectedRow!][selectedCol!].isCorrect = 
          number == solvedBoard[selectedRow!][selectedCol!].value;

      if (!board[selectedRow!][selectedCol!].isCorrect) {
        mistakes++;
        board[selectedRow!][selectedCol!].hasError = true;
        score = (score * 0.9).round();
        
        if (mistakes >= maxMistakes) {
          _showGameOverDialog();
        }
      } else {
        board[selectedRow!][selectedCol!].hasError = false;
        _checkWin();
      }
    });
  }

  void _clearConflicts(int row, int col) {
    final value = board[row][col].value;
    if (value == 0) return;

    for (int i = 0; i < 9; i++) {
      if (board[row][i].value == value && !board[row][i].isOriginal) {
        board[row][i].value = 0;
        board[row][i].isCorrect = false;
        board[row][i].hasError = false;
      }
      if (board[i][col].value == value && !board[i][col].isOriginal) {
        board[i][col].value = 0;
        board[i][col].isCorrect = false;
        board[i][col].hasError = false;
      }
    }

    final startRow = row - row % 3;
    final startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j].value == value && 
            !board[startRow + i][startCol + j].isOriginal) {
          board[startRow + i][startCol + j].value = 0;
          board[startRow + i][startCol + j].isCorrect = false;
          board[startRow + i][startCol + j].hasError = false;
        }
      }
    }
  }

  void _checkWin() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col].value == 0 || 
            board[row][col].value != solvedBoard[row][col].value) {
          return;
        }
      }
    }
    
    setState(() {
      isGameWon = true;
      stopwatch.stop();
      _timer.cancel();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _showWinDialog();
    });
  }

  void _getHint() {
    if (hintsUsed >= 3) return;
    
    final emptyCells = <Point<int>>[];
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col].value == 0 && !board[row][col].isOriginal) {
          emptyCells.add(Point(row, col));
        }
      }
    }
    
    if (emptyCells.isEmpty) return;
    
    emptyCells.shuffle();
    final cell = emptyCells.first;
    
    setState(() {
      board[cell.x][cell.y].value = solvedBoard[cell.x][cell.y].value;
      board[cell.x][cell.y].isCorrect = true;
      board[cell.x][cell.y].isHint = true;
      hintsUsed++;
      score = (score * 0.8).round();
      _checkWin();
    });
  }

  void _resetGame() {
    setState(() {
      isGameWon = false;
      mistakes = 0;
      hintsUsed = 0;
      selectedRow = null;
      selectedCol = null;
      stopwatch.reset();
      stopwatch.start();
      _initializeGame();
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              Icons.celebration,
              size: 60,
              color: Colors.amber.shade600,
            ),
            const SizedBox(height: 10),
            const Text(
              'Puzzle Solved!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow(Icons.timer, 'Time:', _formatTime(stopwatch.elapsed)),
            _buildStatRow(Icons.leaderboard, 'Score:', '$score points'),
            _buildStatRow(Icons.error_outline, 'Mistakes:', '$mistakes'),
            _buildStatRow(Icons.lightbulb, 'Hints Used:', '$hintsUsed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 60,
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 10),
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Too many mistakes!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You made $maxMistakes mistakes. Try again!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        title: const Text(
          'Sudoku Challenge',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _resetGame,
            tooltip: 'Restart Game',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Game Stats Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.timer, _formatTime(stopwatch.elapsed), Colors.blue),
                  _buildStatItem(Icons.score, '$score', Colors.amber),
                  _buildStatItem(Icons.error_outline, '$mistakes/$maxMistakes', 
                      mistakes >= maxMistakes ? Colors.red : Colors.green),
                  _buildStatItem(Icons.lightbulb, '$hintsUsed/3', 
                      hintsUsed >= 3 ? Colors.grey : Colors.purple),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Difficulty Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Difficulty:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<Difficulty>(
                    value: difficulty,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          difficulty = value;
                          _resetGame();
                        });
                      }
                    },
                    items: Difficulty.values.map((diff) {
                      return DropdownMenuItem(
                        value: diff,
                        child: Text(
                          diff.name.toUpperCase(),
                          style: TextStyle(
                            color: diff.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sudoku Board
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        final row = index ~/ 9;
                        final col = index % 9;
                        final cell = board[row][col];
                        
                        final isSelected = selectedRow == row && selectedCol == col;
                        final isSameRow = selectedRow == row;
                        final isSameCol = selectedCol == col;
                        final startRow = (row ~/ 3) * 3;
                        final startCol = (col ~/ 3) * 3;
                        final isSameBox = selectedRow != null && selectedCol != null &&
                            row >= startRow && row < startRow + 3 &&
                            col >= startCol && col < startCol + 3;

                        Color cellColor = Colors.white;
                        if (isSelected) {
                          cellColor = Colors.blue.shade50;
                        } else if (isSameRow || isSameCol || isSameBox) {
                          cellColor = Colors.grey.shade50;
                        }

                        if (cell.hasError) cellColor = Colors.red.shade50;
                        if (cell.isHint) cellColor = Colors.purple.shade50;

                        return GestureDetector(
                          onTap: () => _selectCell(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cellColor,
                              border: Border.all(
                                color: _getBorderColor(row, col),
                                width: _getBorderWidth(row, col),
                              ),
                            ),
                            child: Center(
                              child: cell.value == 0
                                  ? Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : Text(
                                      cell.value.toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: cell.isOriginal ? FontWeight.bold : FontWeight.w600,
                                        color: _getTextColor(cell),
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Number Pad
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final number = index + 1;
                  return GestureDetector(
                    onTap: () => _placeNumber(number),
                    child: Container(
                      decoration: BoxDecoration(
                        color: number == selectedNumber
                            ? Colors.blue.shade600
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          number.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: number == selectedNumber
                                ? Colors.white
                                : Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _getHint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text(
                      'Get Hint',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        if (selectedRow != null && selectedCol != null) {
                          board[selectedRow!][selectedCol!].value = 0;
                          board[selectedRow!][selectedCol!].isCorrect = false;
                          board[selectedRow!][selectedCol!].hasError = false;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.backspace),
                    label: const Text(
                      'Clear',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getTextColor(SudokuCell cell) {
    if (cell.hasError) return Colors.red;
    if (cell.isHint) return Colors.purple;
    if (cell.isCorrect) return Colors.green.shade700;
    if (cell.isOriginal) return Colors.black;
    return Colors.blue.shade800;
  }

  Color _getBorderColor(int row, int col) {
    if (row % 3 == 0 && col % 3 == 0) return Colors.black;
    if (row % 3 == 0) return Colors.black;
    if (col % 3 == 0) return Colors.black;
    return Colors.grey.shade300;
  }

  double _getBorderWidth(int row, int col) {
    if (row % 3 == 0 && col % 3 == 0) return 2.0;
    if (row % 3 == 0) return 1.5;
    if (col % 3 == 0) return 1.5;
    return 0.5;
  }
}
