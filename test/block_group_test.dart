import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dart2048/block_group.dart';
import 'package:dart2048/block.dart';
import 'package:dart2048/animator.dart';

class FakeAnimator extends Fake implements Animator {
  @override
  Block move(Block block, BlockCoord coord) {
    return Block(block.level, coord);
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
    // expect(group.blocks.length, equals(1));
    final block = group.blocks[0];
    expect(BlockCoord.isEqual(block.coord, BlockCoord(size - 1, 0)), isTrue);
  });

  test('move it twice', () {
    var group = BlockGroup([Block(1, BlockCoord(0, 0))]);
    final animator = FakeAnimator();
    group = group.apply(Direction.right, animator);
    group = group.apply(Direction.down, animator);
    expect(group.blocks.length, equals(1));
    final block = group.blocks[0];
    expect(BlockCoord.isEqual(block.coord, BlockCoord(size - 1, size - 1)), isTrue);
  });
}
