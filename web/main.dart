import 'dart:html';

import 'package:dart2048/block.dart';
import 'package:dart2048/block_group.dart';

void main() {
  final grid = Block.gridElement()..id = 'grid';
  querySelector('#output').children.add(grid);
  BlockGroup.initialize().attach(grid);
}
