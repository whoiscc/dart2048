import 'dart:math';
import 'dart:async';
import 'dart:html';

import 'package:dart2048/block.dart';

class Animator {
  static const stage1Duration = 1.0;
  static const stage2Duration = 0.3;

  List<Move> _moves;
  List<Grow> _grows;
  List<Merge> _merges;

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

  Block merge(Block merged1, Block merged2) {
    assert(BlockCoord.isEqual(merged1.coord, merged2.coord) &&
        Block.sameLevel(merged1, merged2));
    final nextBlock = Block(merged1.level + 1, merged1.coord);
    _merges.add(Merge(merged1, merged2, nextBlock));
    return nextBlock;
  }

  apply(Function() after, {Function() beforeGrow}) {
    final stage2Delay = _moves.isEmpty ? 0 : Animator.stage1Duration;
    for (Move move in _moves) {
      move.block.coord = move.nextBlock.coord;
    }
    _moves.clear();
    final savedGrows = List.from(_grows);
    _grows.clear();
    Timer(Duration(milliseconds: (stage2Delay * 1000).floor()), () {
      print('clean');
      for (Grow grow in savedGrows) {
        grow.block
          ..sizeTransDuration = 0
          ..size = 0;
      }
      // this will waste a frame if beforeGrow is null, which is the most
      // common case, so it may be fixed later
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
          // TODO: merge animation
          Timer(Duration(milliseconds: (stage2Duration * 1000).floor()), after);
        });
      });
    });
  }

  // assert(_merges.isEmpty) when this.isEmpty
  bool get isEmpty => _moves.isEmpty && _grows.isEmpty;
}

class Move {
  final Block block, nextBlock;
  const Move(this.block, this.nextBlock);
}

class Grow {
  final Block block;
  const Grow(this.block);
}

class Merge {
  final Block merged1, merged2, nextBlock;
  const Merge(this.merged1, this.merged2, this.nextBlock);
}
