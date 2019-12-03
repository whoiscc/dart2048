import 'dart:html';
import 'dart:async';

void main() {
  final grid = DivElement()..id = 'grid';
  querySelector('#output').children.add(grid);
  final block = Block(1, BlockCoord(0, 0))..attach(grid);
  Timer.periodic(Duration(seconds: 1), (timer) {
    block.coord = BlockCoord(timer.tick % 4, (timer.tick % 16) ~/ 4);
  });
}

extension VminNum on num {
  String get vmin => toString() + 'vmin';
}

class BlockCoord {
  final int x, y;

  const BlockCoord(this.x, this.y);

  num get left => Block.MARGIN_SIZE + (Block.SIZE + 2 * Block.MARGIN_SIZE) * x;
  num get top => Block.MARGIN_SIZE + (Block.SIZE + 2 * Block.MARGIN_SIZE) * y;
}

class Block {
  static const SIZE = 16;
  static const MARGIN_SIZE = 2;

  final Element _element;

  Block(
    int level,
    BlockCoord coord,
  ) : _element = DivElement()
          ..classes.add('block')
          ..classes.add('block-level-$level') {
    this.coord = coord;
  }

  set coord(coord) {
    _element.style
      ..left = VminNum(coord.left).vmin
      ..top = VminNum(coord.top).vmin;
  }

  attach(Element parent) {
    parent.children.add(_element);
  }

  remove() {
    _element.remove();
  }
}
