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
    for (int i = 0; i < initialSize; i++) {
      coordList.add(BlockGroup.findAvailable(coordList));
    }
    return BlockGroup(
        List.from(coordList.map((coord) => animator.grow(coord))));
  }

  static BlockCoord findAvailable(List<BlockCoord> existCoords) {
    assert(existCoords.length < BlockGroup.gridSize * BlockGroup.gridSize);
    Random rand = Random();
    while (true) {
      final nextCoord =
          BlockCoord(rand.nextInt(gridSize), rand.nextInt(gridSize));
      if (!existCoords.any((coord) => BlockCoord.isEqual(coord, nextCoord))) {
        return nextCoord;
      }
    }
  }

  BlockGroup apply(Direction direction, Animator animator) {
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

    List<Block> blockList = [];
    if (direction == Direction.left || direction == Direction.right) {
      for (int row = 0; row < BlockGroup.gridSize; row += 1) {
        blockList.addAll(
            _applyRow(grid[row], near, step, far, RowAnimator(animator, row)));
      }
    } else {
      for (int col = 0; col < BlockGroup.gridSize; col += 1) {
        final column = List.generate(BlockGroup.gridSize, (i) => grid[i][col]);
        blockList.addAll(
            _applyRow(column, near, step, far, ColumnAnimator(animator, col)));
      }
    }

    blockList = blockList.where((block) => block != null).toList();
    if (!animator.isEmpty) {
      // there must be some empty position after an non-trivial action
      final BlockCoord coord = BlockGroup.findAvailable(
          blockList.map<BlockCoord>((block) => block.coord).toList());
      blockList.add(animator.grow(coord));
    }
    return BlockGroup(blockList);
  }

  List<Block> _applyRow(
      List<Block> row, int near, int step, int far, VecAnimator animator) {
    List<Block> nextRow = List.filled(BlockGroup.gridSize, null);
    List<bool> mergedBlock = List.filled(BlockGroup.gridSize, false);
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
          nextRow[dest] == null && dest != near;
          dest -= step) {}
      if (nextRow[dest] == null) {
        // empty row case
        assert(dest == near);
        nextRow[near] = animator.move(block, near);
      } else if (Block.sameLevel(nextRow[dest], block) && !mergedBlock[dest]) {
        // mergable case
        // notice the discarded immediate moving block
        // it exists for animation, but it should not be part of
        // next block group
        nextRow[dest] =
            animator.merge(animator.move(block, dest), nextRow[dest]);
        mergedBlock[dest] = true;
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
