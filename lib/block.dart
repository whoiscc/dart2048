import 'dart:html';

import 'package:dart2048/block_group.dart';
import 'package:dart2048/animator.dart';

extension _Vmin on num {
  String get vmin => toString() + 'vmin';
}

enum BlockStatus { past, current, next }

extension _ClassName on BlockStatus {
  String get className => 'block-status-${toString().split(".")[1]}';
}

class BlockCoord {
  final int row, col;

  const BlockCoord(this.row, this.col);

  num get left =>
      Block.marginSize + (Block.normalSize + Block.marginSize) * col;
  num get top => Block.marginSize + (Block.normalSize + Block.marginSize) * row;

  static bool isEqual(BlockCoord c1, BlockCoord c2) =>
      c1.row == c2.row && c1.col == c2.col;
}

class Block {
  static const normalSize = 16;
  static const marginSize = 4;
  static const stage1Trans =
      'left ${Animator.stage1Duration}s, top ${Animator.stage1Duration}s';

  final Element _element;
  final int _level;
  BlockStatus _status;
  BlockCoord _coord;

  Block(int level, BlockCoord coord,
      {BlockStatus status = BlockStatus.next, num size = Block.normalSize})
      : _level = level,
        _element = DivElement()
          ..classes.add('block')
          ..classes.add('block-level-$level')
          ..style.transition = Block.stage1Trans {
    this.coord = coord;
    this.status = status;
    this.size = size;
  }

  int get level => _level;

  static Element gridElement() {
    final size = _Vmin(Block.marginSize +
            (Block.normalSize + Block.marginSize) * BlockGroup.gridSize)
        .vmin;
    return DivElement()
      ..style.width = size
      ..style.height = size;
  }

  set coord(coord) {
    _coord = coord;
    _element.style
      ..left = _Vmin(coord.left).vmin
      ..top = _Vmin(coord.top).vmin;
  }

  get coord => _coord;

  set size(num size) {
    final vminSize = _Vmin(size).vmin;
    _element.style
      ..width = vminSize
      ..height = vminSize
      ..lineHeight = vminSize
      ..fontSize = _Vmin(size / 2).vmin
      ..margin = _Vmin((Block.normalSize - size) / 2).vmin;
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

  hide() {
    _element.style.display = 'none';
  }

  set sizeTransDuration(num duration) {
    final stage2Trans =
        'width ${duration}s, height ${duration}s, line-height ${duration}s, font-size ${duration}s, margin ${duration}s';
    _element.style.transition = '${Block.stage1Trans}, ${stage2Trans}';
  }
}
