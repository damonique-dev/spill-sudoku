import 'package:flutter/foundation.dart';
import 'dart:math';

class SudokuModel extends ChangeNotifier {
  late List<List<int>> _board;
  late List<List<bool>> _isFixed;
  late List<List<bool>> _isInvalid;
  bool _isComplete = false;

  SudokuModel() {
    _initializeGame();
  }

  List<List<int>> get board => _board;
  List<List<bool>> get isFixed => _isFixed;
  List<List<bool>> get isInvalid => _isInvalid;
  bool get isComplete => _isComplete;

  void _initializeGame() {
    _board = List.generate(9, (i) => List.filled(9, 0));
    _isFixed = List.generate(9, (i) => List.filled(9, false));
    _isInvalid = List.generate(9, (i) => List.filled(9, false));
    _generatePuzzle();
  }

  void _generatePuzzle() {
    // Start with an empty board and fill diagonal boxes
    _fillDiagonalBoxes();
    // Solve the rest of the board
    _solveSudoku(0, 0);
    // Remove numbers to create puzzle
    _createPuzzle();
    notifyListeners();
  }

  void _fillDiagonalBoxes() {
    for (int box = 0; box < 9; box += 3) {
      _fillBox(box, box);
    }
  }

  void _fillBox(int row, int col) {
    var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    numbers.shuffle();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        _board[row + i][col + j] = numbers[i * 3 + j];
      }
    }
  }

  bool _solveSudoku(int row, int col) {
    if (row == 9) {
      row = 0;
      if (++col == 9) return true;
    }

    if (_board[row][col] != 0) return _solveSudoku(row + 1, col);

    for (int num = 1; num <= 9; num++) {
      if (_isSafe(row, col, num)) {
        _board[row][col] = num;
        if (_solveSudoku(row + 1, col)) return true;
        _board[row][col] = 0;
      }
    }
    return false;
  }

  bool _isSafe(int row, int col, int num) {
    // Check row
    for (int x = 0; x < 9; x++) {
      if (_board[row][x] == num) return false;
    }

    // Check column
    for (int x = 0; x < 9; x++) {
      if (_board[x][col] == num) return false;
    }

    // Check 3x3 box
    int startRow = row - row % 3, startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i + startRow][j + startCol] == num) return false;
      }
    }

    return true;
  }

  void _createPuzzle() {
    const minClues = 25; // Minimum number of clues for a unique solution
    var random = Random();
    var cellsToRemove = 81 - minClues;

    while (cellsToRemove > 0) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);

      if (_board[row][col] != 0) {
        int temp = _board[row][col];
        _board[row][col] = 0;
        cellsToRemove--;
        _isFixed[row][col] = false;
      }
    }

    // Mark remaining numbers as fixed
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_board[i][j] != 0) {
          _isFixed[i][j] = true;
        }
      }
    }
  }

  void updateNumber(int row, int col, int number) {
    if (!_isFixed[row][col]) {
      _board[row][col] = number;
      _checkValidity();
      _checkCompletion();
      notifyListeners();
    }
  }

  void _checkValidity() {
    _isInvalid = List.generate(9, (i) => List.filled(9, false));
    
    // Check rows and columns
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_board[i][j] != 0) {
          _checkCell(i, j);
        }
      }
    }
  }

  void _checkCell(int row, int col) {
    int number = _board[row][col];
    
    // Check row
    for (int j = 0; j < 9; j++) {
      if (j != col && _board[row][j] == number) {
        _isInvalid[row][col] = true;
        _isInvalid[row][j] = true;
      }
    }

    // Check column
    for (int i = 0; i < 9; i++) {
      if (i != row && _board[i][col] == number) {
        _isInvalid[row][col] = true;
        _isInvalid[i][col] = true;
      }
    }

    // Check 3x3 box
    int boxRow = row - row % 3;
    int boxCol = col - col % 3;
    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        if (i != row && j != col && _board[i][j] == number) {
          _isInvalid[row][col] = true;
          _isInvalid[i][j] = true;
        }
      }
    }
  }

  void _checkCompletion() {
    // Check if board is filled and valid
    bool isFilled = true;
    bool isValid = true;

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_board[i][j] == 0) {
          isFilled = false;
        }
        if (_isInvalid[i][j]) {
          isValid = false;
        }
      }
    }

    _isComplete = isFilled && isValid;
  }

  void resetGame() {
    _initializeGame();
  }
}