import "dart:html";
import "dart:math";

import "package:dart2048/block.dart";

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

  factory BlockGroup.initialize({status = BlockStatus.current}) {
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
    return BlockGroup(List.from(coordList.map((coord) =>
        Block(rand.nextInt(10) == 0 ? 2 : 1, coord, status: status))));
  }

  BlockGroup apply(Direction direction, animator) {
    //
  }
}
