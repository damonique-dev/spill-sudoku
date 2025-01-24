import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_model.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spill Sudoku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SudokuModel>(context, listen: false).resetGame();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildBoard(),
            ),
          ),
          _buildNumberPad(),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Consumer<SudokuModel>(
      builder: (context, sudokuModel, child) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            childAspectRatio: 1.0,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final number = sudokuModel.board[row][col];
            final isFixed = sudokuModel.isFixed[row][col];
            final isInvalid = sudokuModel.isInvalid[row][col];

            return InkWell(
              onTap: () {
                _showNumberInputDialog(context, row, col);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: (col + 1) % 3 == 0 ? 2.0 : 1.0,
                      color: Colors.black,
                    ),
                    bottom: BorderSide(
                      width: (row + 1) % 3 == 0 ? 2.0 : 1.0,
                      color: Colors.black,
                    ),
                    left: BorderSide(
                      width: col % 3 == 0 ? 2.0 : 0.0,
                      color: Colors.black,
                    ),
                    top: BorderSide(
                      width: row % 3 == 0 ? 2.0 : 0.0,
                      color: Colors.black,
                    ),
                  ),
                  color: isInvalid
                      ? Colors.red.withOpacity(0.2)
                      : isFixed
                          ? Colors.grey.withOpacity(0.2)
                          : Colors.white,
                ),
                child: Center(
                  child: Text(
                    number == 0 ? '' : number.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: isFixed ? FontWeight.bold : FontWeight.normal,
                      color: isInvalid ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: List.generate(
          9,
          (index) => ElevatedButton(
            child: Text(
              (index + 1).toString(),
              style: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              // The number selected will be handled in the cell selection
              _showCellSelectionDialog(context, index + 1);
            },
          ),
        ),
      ),
    );
  }

  void _showCellSelectionDialog(BuildContext context, int number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select cell for number $number'),
          content: Consumer<SudokuModel>(
            builder: (context, sudokuModel, child) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 81,
                  itemBuilder: (context, index) {
                    final row = index ~/ 9;
                    final col = index % 9;
                    final currentNumber = sudokuModel.board[row][col];
                    final isFixed = sudokuModel.isFixed[row][col];

                    return InkWell(
                      onTap: isFixed
                          ? null
                          : () {
                              sudokuModel.updateNumber(row, col, number);
                              Navigator.of(context).pop();
                              if (sudokuModel.isComplete) {
                                _showCompletionDialog(context);
                              }
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: isFixed ? Colors.grey.withOpacity(0.2) : null,
                        ),
                        child: Center(
                          child: Text(
                            currentNumber == 0 ? '' : currentNumber.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isFixed ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNumberInputDialog(BuildContext context, int row, int col) {
    final sudokuModel = Provider.of<SudokuModel>(context, listen: false);
    if (sudokuModel.isFixed[row][col]) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter number'),
          content: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (int i = 1; i <= 9; i++)
                ElevatedButton(
                  child: Text(i.toString()),
                  onPressed: () {
                    sudokuModel.updateNumber(row, col, i);
                    Navigator.of(context).pop();
                    if (sudokuModel.isComplete) {
                      _showCompletionDialog(context);
                    }
                  },
                ),
              ElevatedButton(
                child: const Text('Clear'),
                onPressed: () {
                  sudokuModel.updateNumber(row, col, 0);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have successfully completed the puzzle!'),
          actions: [
            TextButton(
              child: const Text('New Game'),
              onPressed: () {
                Provider.of<SudokuModel>(context, listen: false).resetGame();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}