import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MineSweeper(),
    );
  }
}

class MineSweeper extends StatefulWidget {
  @override
  _MineSweeperState createState() => _MineSweeperState();
}

class _MineSweeperState extends State<MineSweeper> {
  int rows = 8;
  int columns = 8;
  int totalMines = 10;
  late List<List<bool>> isMine;
  late List<List<bool>> isRevealed;
  late List<List<bool>> isFlagged;
  late List<List<int>> adjacentMines;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    isMine = List.generate(rows, (i) => List<bool>.filled(columns, false));
    isRevealed = List.generate(rows, (i) => List<bool>.filled(columns, false));
    isFlagged = List.generate(rows, (i) => List<bool>.filled(columns, false));
    adjacentMines = List.generate(rows, (i) => List<int>.filled(columns, 0));

    placeMines();
    calculateAdjacentMines();
  }
//123456
  void placeMines() {
    Random random = Random();
    int count = 0;

    while (count < totalMines) {
      int row = random.nextInt(rows);
      int col = random.nextInt(columns);

      if (!isMine[row][col]) {
        isMine[row][col] = true;
        count++;
      }
    }
  }

  void calculateAdjacentMines() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (!isMine[i][j]) {
          for (int m = -1; m <= 1; m++) {
            for (int n = -1; n <= 1; n++) {
              int row = i + m;
              int col = j + n;

              if (row >= 0 && row < rows && col >= 0 && col < columns && isMine[row][col]) {
                adjacentMines[i][j]++;
              }
            }
          }
        }
      }
    }
  }

  void revealCell(int row, int col) {
    if (row >= 0 && row < rows && col >= 0 && col < columns && !isRevealed[row][col] && !isFlagged[row][col]) {
      setState(() {
        isRevealed[row][col] = true;
      });

      if (isMine[row][col]) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Game Over'),
              content: Text('Oops, you stepped on a mine! Game Over.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    initializeGame();
                  },
                  child: Text('Try Again'),
                ),
              ],
            );
          },
        );
      } else if (adjacentMines[row][col] == 0) {
        for (int m = -1; m <= 1; m++) {
          for (int n = -1; n <= 1; n++) {
            revealCell(row + m, col + n);
          }
        }
      }

      if (checkVictory()) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Victory!'),
              content: Text('Congratulations, you found all the mines!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    initializeGame();
                  },
                  child: Text('Play Again'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  bool checkVictory() {
    int flaggedMines = 0;

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (isMine[i][j] && isFlagged[i][j]) {
          flaggedMines++;
        }
      }
    }

    return flaggedMines == totalMines;
  }

  void toggleFlag(int row, int col) {
    if (row >= 0 && row < rows && col >= 0 && col < columns && !isRevealed[row][col]) {
      setState(() {
        isFlagged[row][col] = !isFlagged[row][col];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MineSweeper'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ columns;
          int col = index % columns;

          return GestureDetector(
            onTap: () => revealCell(row, col),
            onSecondaryTap: () => toggleFlag(row, col),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                color: isRevealed[row][col] ? Colors.grey : Colors.blue,
              ),
              child: Center(
                child: isRevealed[row][col]
                    ? isMine[row][col]
                    ? Icon(Icons.brightness_5)
                    : adjacentMines[row][col] > 0 ? Text(adjacentMines[row][col].toString()) : Text('')
                    : isFlagged[row][col] ? Icon(Icons.flag) : Text(''),
              ),
            ),
          );
        },
        itemCount: rows * columns,
      ),
    );
  }
}
