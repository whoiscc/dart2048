import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dart2048/block_group.dart';
import 'package:dart2048/block.dart';
import 'package:dart2048/animator.dart';

class FakeAnimator extends Fake implements Animator {
  bool isEmpty = true;

  @override
  Block move(Block block, BlockCoord coord) {
    assert(block.coord.row == coord.row || block.coord.col == coord.col);
    isEmpty = false;
    return Block(block.level, coord);
  }

  @override
  Block merge(Block merged1, Block merged2) {
    assert(BlockCoord.isEqual(merged1.coord, merged2.coord) &&
        Block.sameLevel(merged1, merged2));
    isEmpty = false;
    return Block(merged1.level + 1, merged1.coord);
  }

  @override
  Block grow(BlockCoord coord) {
    isEmpty = false;
    // too complicated...
    return Animator().grow(coord);
  }
}

const size = BlockGroup.gridSize;

void main() {
  test('system is fine', () {
    final n = 42;
    expect(n, equals(42));
  });

  test('create a block group', () {
    final group = BlockGroup([Block(1, BlockCoord(0, 0))]);
    expect(group.blocks.length, equals(1));
  });

  test('move a block', () {
    var group = BlockGroup([Block(1, BlockCoord(0, 0))]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 1))),
        isTrue);
  });

  test('move it twice', () {
    var group = BlockGroup([Block(1, BlockCoord(0, 0))]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    group = group.apply(Direction.down, animator);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(size - 1, size - 1))),
        isTrue);
  });

  test('move two blocks', () {
    var group = BlockGroup([
      Block(1, BlockCoord(0, 0)),
      Block(1, BlockCoord(1, 0)),
    ]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 1))),
        isTrue);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(1, size - 1))),
        isTrue);
  });

  test('move two blocks on a row', () {
    var group = BlockGroup([
      Block(1, BlockCoord(0, 0)),
      Block(2, BlockCoord(0, 1)),
    ]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 2)) &&
            block.level == 1),
        isTrue);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 1)) &&
            block.level == 2),
        isTrue);
  });

  test('merge two blocks', () {
    var group = BlockGroup([
      Block(1, BlockCoord(0, 0)),
      Block(1, BlockCoord(0, 1)),
    ]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 1)) &&
            block.level == 2),
        isTrue);
  });

  test('merge and move', () {
    var group = BlockGroup([
      Block(1, BlockCoord(0, 0)),
      Block(1, BlockCoord(0, 1)),
      Block(2, BlockCoord(0, 2)),
    ]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 1)) &&
            block.level == 2),
        isTrue);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 2)) &&
            block.level == 2),
        isTrue);
  });

  test('move and merge', () {
    var group = BlockGroup([
      Block(2, BlockCoord(0, 0)),
      Block(1, BlockCoord(0, 1)),
      Block(1, BlockCoord(0, 2)),
    ]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 1)) &&
            block.level == 2),
        isTrue);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, size - 2)) &&
            block.level == 2),
        isTrue);
  });

  test('grow block', () {
    var group = BlockGroup([Block(1, BlockCoord(0, 0))]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    expect(
        group.blocks.any((block) =>
            !BlockCoord.isEqual(block.coord, BlockCoord(0, size - 1))),
        isTrue);
  });

  test('not grow when unchanged', () {
    var group = BlockGroup([Block(1, BlockCoord(0, 0))]);
    final animator = FakeAnimator();
    group = group.apply(Direction.left, animator);
    expect(
        group.blocks
            .any((block) => !BlockCoord.isEqual(block.coord, BlockCoord(0, 0))),
        isFalse);
  });

  test('stuck block survives', () {
    var group = BlockGroup([
      Block(1, BlockCoord(0, 0)),
      Block(2, BlockCoord(0, 1)),
    ]);
    final animator = FakeAnimator();
    group = group.apply(Direction.left, animator);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, 0)) &&
            block.level == 1),
        isTrue);
    expect(
        group.blocks.any((block) =>
            BlockCoord.isEqual(block.coord, BlockCoord(0, 1)) &&
            block.level == 2),
        isTrue);
  });
}
