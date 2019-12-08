import 'dart:math';
import 'dart:async';
import 'dart:html';

import 'package:dart2048/block.dart';

class Animator {
  static const stage1Duration = 1.0;
  static const stage2Duration = 0.3;

  List<Move> _moves;
  List<Grow> _grows;

  Animator() {
    _moves = List();
    _grows = List();
  }

  Block grow(BlockCoord coord) {
    final level = Random().nextInt(10) == 0 ? 2 : 1;
    final block = Block(level, coord);
    _grows.add(Grow(block));
    return block;
  }

  Block move(Block block, BlockCoord dstCoord) {
    final nextBlock = Block(block.level, dstCoord);
    _moves.add(Move(block, nextBlock));
    return nextBlock;
  }

  apply({Function() beforeGrow}) {
    final stage2Delay = _moves.isEmpty ? 0 : Animator.stage1Duration;
    for (Move move in _moves) {
      move.block.coord = move.nextBlock.coord;
    }
    _moves.clear();
    final savedGrows = List.from(_grows);
    _grows.clear();
    Timer(Duration(seconds: stage2Delay), () {
      print('clean');
      for (Grow grow in savedGrows) {
        grow.block
          ..sizeTransDuration = 0
          ..size = 0;
      }
      window.requestAnimationFrame((n) {
        if (beforeGrow != null) {
          beforeGrow();
        }
        window.requestAnimationFrame((n) {
          print('grow');
          for (Grow grow in savedGrows) {
            grow.block
              ..sizeTransDuration = Animator.stage2Duration
              ..size = Block.normalSize;
          }
        });
      });
    });
  }
}

class Move {
  final Block block, nextBlock;
  Move(this.block, this.nextBlock);
}

class Grow {
  final Block block;
  Grow(this.block);
}
