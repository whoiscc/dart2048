import 'dart:html';

extension _Vmin on num {
  String get vmin => toString() + 'vmin';
}

enum BlockStatus { past, current, next }

extension _ClassName on BlockStatus {
  String get className => 'block-status-${toString().split(".")[1]}';
}

class BlockCoord {
  final int x, y;

  const BlockCoord(this.x, this.y);

  num get left => Block.marginSize + (Block.size + Block.marginSize) * x;
  num get top => Block.marginSize + (Block.size + Block.marginSize) * y;

  static bool isEqual(BlockCoord c1, BlockCoord c2) =>
      c1.x == c2.x && c1.y == c2.y;
}

class Block {
  static const size = 16;
  static const marginSize = 4;

  final Element _element;
  final int _level;
  BlockStatus _status;

  Block(int level, BlockCoord coord, {BlockStatus status = BlockStatus.next})
      : _level = level,
        _element = DivElement()
          ..classes.add('block')
          ..classes.add('block-level-$level') {
    final size = _Vmin(Block.size).vmin;
    _element.style
      ..width = size
      ..height = size
      ..lineHeight = size;
    final halfSize = _Vmin(Block.size / 2).vmin;
    _element.style.fontSize = halfSize;
    this.coord = coord;
    this.status = status;
  }

  static Element gridElement() {
    final size = _Vmin(Block.size * 4 + Block.marginSize * 5).vmin;
    return DivElement()
      ..style.width = size
      ..style.height = size;
  }

  set coord(coord) {
    _element.style
      ..left = _Vmin(coord.left).vmin
      ..top = _Vmin(coord.top).vmin;
  }

  set status(status) {
    if (_status != null) {
      _element.classes.remove(_ClassName(_status).className);
    }
    _element.classes.add(_ClassName(status).className);
    _status = status;
  }

  static bool sameLevel(Block b1, Block b2) => b1._level == b2._level;

  attach(Element parent) {
    parent.children.add(_element);
  }

  remove() {
    _element.remove();
  }
}
