import "dart:html";
import "dart:math";

import "package:dart2048/block.dart";
import "package:dart2048/animator.dart";

enum Direction { up, down, left, right }

class BlockGroup {
  static const gridSize = 4;

  final List<Block> blocks;

  const BlockGroup(this.blocks);

  attach(Element parent) {
    blocks.forEach((block) {
      block.attach(parent);
    });
  }

  remove() {
    blocks.forEach((block) {
      block.remove();
    });
  }

  set status(status) {
    blocks.forEach((block) {
      block.status = status;
    });
  }

  static const initialSize = 2;

  factory BlockGroup.initialize(Animator animator,
      {status = BlockStatus.current}) {
    List<BlockCoord> coordList = List();
    Random rand = Random();
    for (int i = 0; i < initialSize; i++) {
      while (true) {
        final nextCoord =
            BlockCoord(rand.nextInt(gridSize), rand.nextInt(gridSize));
        if (!coordList.any((coord) => BlockCoord.isEqual(coord, nextCoord))) {
          coordList.add(nextCoord);
          break;
        }
      }
    }
    return BlockGroup(
        List.from(coordList.map((coord) => animator.grow(coord))));
  }

  BlockGroup apply(Direction direction, animator) {
    List<List<Block>> grid = List.generate(
        BlockGroup.gridSize, (i) => List.filled(BlockGroup.gridSize, null));
    blocks.forEach((block) {
      assert(grid[block.coord.row][block.coord.col] == null);
      grid[block.coord.row][block.coord.col] = block;
    });
    final bool littleEndian =
        direction == Direction.left || direction == Direction.up;
    final int near = littleEndian ? 0 : BlockGroup.gridSize - 1,
        far = BlockGroup.gridSize - near - 1,
        step = littleEndian ? 1 : -1;
    List<List<Block>> nextGrid = List.filled(BlockGroup.gridSize, null);
    if (direction == Direction.left || direction == Direction.right) {
      for (int row = 0; row < BlockGroup.gridSize; row += 1) {
        nextGrid[row] =
            _applyRow(grid[row], near, step, far, RowAnimator(animator, row));
      }
    } else {
      nextGrid = nextGrid
          .map<List<Block>>((n) => List.filled(BlockGroup.gridSize, null))
          .toList();
      for (int col = 0; col < BlockGroup.gridSize; col += 1) {
        final column = List.generate(BlockGroup.gridSize, (i) => grid[i][col]);
        _applyRow(column, near, step, far, ColumnAnimator(animator, col))
            .asMap()
            .forEach((i, block) {
          nextGrid[i][col] = block;
        });
      }
    }
    // TODO: check difference & grow
    return BlockGroup(nextGrid
        .expand((blocks) => blocks)
        .where((block) => block != null)
        .toList());
  }

  List<Block> _applyRow(
      List<Block> row, int near, int step, int far, VecAnimator animator) {
    List<Block> nextRow = List.filled(BlockGroup.gridSize, null);
    if (row[near] != null) {
      // the nearest block cannot move
      // but it may be merged later
      nextRow[near] = row[near];
    }
    for (int index = near + step; index != far + step; index += step) {
      if (row[index] == null) {
        continue;
      }
      final block = row[index];
      int dest;
      for (dest = index - step;
          nextRow[dest] == null || Block.sameLevel(nextRow[dest], block);
          dest -= step) {
        if (dest == near) {
          // row is empty from index to near
          break;
        }
      }
      if (nextRow[dest] == null) {
        // empty row case
        assert(dest == near);
        nextRow[near] = animator.move(block, near);
      } else if (Block.sameLevel(nextRow[dest], block)) {
        // mergable case
        nextRow[dest] = animator.merge(block, nextRow[dest]);
      } else if (dest + step != index) {
        // if dest + step == index, then block is stuck and nothing happened
        nextRow[dest + step] = animator.move(block, dest + step);
      }
    }
    return nextRow;
  }
}

abstract class VecAnimator {
  final Animator animator;

  const VecAnimator(this.animator);

  Block move(Block block, int dest);
  Block merge(Block block1, Block block2) {
    return animator.merge(block1, block2);
  }
}

class RowAnimator extends VecAnimator {
  final int index;

  const RowAnimator(Animator animator, this.index) : super(animator);

  Block move(Block block, int dest) =>
      animator.move(block, BlockCoord(index, dest));
}

class ColumnAnimator extends VecAnimator {
  final int index;

  const ColumnAnimator(Animator animator, this.index) : super(animator);

  Block move(Block block, int dest) =>
      animator.move(block, BlockCoord(dest, index));
}
