import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const OthelloApp());
}

class OthelloApp extends StatelessWidget {
  const OthelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Othello',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const OthelloGame(),
    );
  }
}

enum CellState { empty, black, white }

class OthelloGame extends StatefulWidget {
  const OthelloGame({super.key});

  @override
  State<OthelloGame> createState() => _OthelloGameState();
}

class _OthelloGameState extends State<OthelloGame> {
  List<List<CellState>> board = List.generate(6, (_) => List.filled(6, CellState.empty));
  CellState currentPlayer = CellState.black; // Player starts as black
  bool gameOver = false;
  String winnerMessage = '';

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    board[2][2] = CellState.white;
    board[3][3] = CellState.white;
    board[2][3] = CellState.black;
    board[3][2] = CellState.black;
  }

  void makeMove(int row, int col) {
    if (gameOver || currentPlayer != CellState.black) return;

    if (board[row][col] == CellState.empty && isValidMove(row, col, currentPlayer)) {
      setState(() {
        board[row][col] = currentPlayer;
        flipPieces(row, col, currentPlayer);
        currentPlayer = CellState.white; // Switch to computer
      });

      if (isBoardFull() || (!canMove(CellState.black) && !canMove(CellState.white))) {
        endGame();
      } else if (canMove(CellState.white)) {
        Future.delayed(Duration(milliseconds: 700), () {
          computerMove();
        });
      } else {
        setState(() {
          currentPlayer = CellState.black; // Switch back to player if computer can't move
        });
        if (!canMove(CellState.black)) {
          endGame();
        }
      }
    }
  }

  void computerMove() {
    if (gameOver) return;

    if (canMove(CellState.white)) {
      // Find all possible moves for the computer (white)
      List<List<int>> possibleMoves = [];
      for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 6; j++) {
          if (board[i][j] == CellState.empty && isValidMove(i, j, CellState.white)) {
            possibleMoves.add([i, j]);
          }
        }
      }

      if (possibleMoves.isNotEmpty) {
        // Randomly select a move from possible moves
        Random random = Random();
        int moveIndex = random.nextInt(possibleMoves.length);
        int row = possibleMoves[moveIndex][0];
        int col = possibleMoves[moveIndex][1];

        // Make the move and update the game state
        setState(() {
          board[row][col] = CellState.white;
          flipPieces(row, col, CellState.white);
          currentPlayer = CellState.black; // Switch back to the player
        });
      }
    }

    // Check if the game is over after the computer's move
    if (isBoardFull() || (!canMove(CellState.black) && !canMove(CellState.white))) {
      endGame();
    }
  }

  // The rest of the code (isValidMove, flipPieces, getOpponent, canMove, isBoardFull, endGame, resetGame, build) remains unchanged
  bool isValidMove(int row, int col, CellState player) {
    if (row < 0 || row >= 6 || col < 0 || col >= 6 || board[row][col] != CellState.empty) {
      return false;
    }

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        int r = row + dr;
        int c = col + dc;
        bool foundOpponent = false;

        while (r >= 0 && r < 6 && c >= 0 && c < 6 && board[r][c] != CellState.empty) {
          if (board[r][c] != getOpponent(player)) {
            break;
          }
          foundOpponent = true;
          r += dr;
          c += dc;
        }

        if (r >= 0 && r < 6 && c >= 0 && c < 6 && board[r][c] == player && foundOpponent) {
          return true;
        }
      }
    }

    return false;
  }

  void flipPieces(int row, int col, CellState player) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        int r = row + dr;
        int c = col + dc;
        bool foundOpponent = false;
        List<Point<int>> piecesToFlip = [];

        while (r >= 0 && r < 6 && c >= 0 && c < 6 && board[r][c] != CellState.empty) {
          if (board[r][c] != getOpponent(player)) {
            break;
          }
          foundOpponent = true;
          piecesToFlip.add(Point(r, c));
          r += dr;
          c += dc;
        }

        if (r >= 0 && r < 6 && c >= 0 && c < 6 && board[r][c] == player && foundOpponent) {
          for (var piece in piecesToFlip) {
            board[piece.x][piece.y] = player;
          }
        }
      }
    }
  }

  CellState getOpponent(CellState player) {
    return (player == CellState.black) ? CellState.white : CellState.black;
  }

  bool canMove(CellState player) {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        if (board[i][j] == CellState.empty && isValidMove(i, j, player)) {
          return true;
        }
      }
    }
    return false;
  }

  bool isBoardFull() {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        if (board[i][j] == CellState.empty) {
          return false;
        }
      }
    }
    return true;
  }

  void endGame() {
    int blackCount = 0;
    int whiteCount = 0;
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        if (board[i][j] == CellState.black) {
          blackCount++;
        } else if (board[i][j] == CellState.white) {
          whiteCount++;
        }
      }
    }

    setState(() {
      gameOver = true;
      if (blackCount > whiteCount) {
        winnerMessage = 'Chikawa wins! ($blackCount - $whiteCount)';
      } else if (whiteCount > blackCount) {
        winnerMessage = 'Shibafat wins! ($whiteCount - $blackCount)';
      } else {
        winnerMessage = 'It\'s a draw!';
      }
    });
  }

  void resetGame() {
    setState(() {
      board = List.generate(6, (_) => List.filled(6, CellState.empty));
      initializeBoard();
      currentPlayer = CellState.black;
      gameOver = false;
      winnerMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Othello'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: 36,
            itemBuilder: (context, index) {
              int row = index ~/ 6;
              int col = index % 6;
              return GestureDetector(
                onTap: () => makeMove(row, col),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.green[100],
                  ),
                  child: Center(
                    child: switch (board[row][col]) {
                      CellState.black => SizedBox(
                          width: 36,
                          height: 36,
                          child: Image.asset('assets/B_Piece.png'),
                        ),
                      CellState.white => SizedBox(
                          width: 36,
                          height: 36,
                          child: Image.asset('assets/W_Piece.png'),
                        ),
                      CellState.empty => null,
                    },
                  ),
                ),
              );
            },
          ),
          if (!gameOver)
            Text(
              'Current player: ${currentPlayer == CellState.black ? 'Chikawa' : 'Shibafat'}',
              style: const TextStyle(fontSize: 20),
            ),
          if (gameOver)
            Text(
              winnerMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
