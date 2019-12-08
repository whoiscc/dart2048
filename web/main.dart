import 'dart:html';

import 'package:dart2048/block.dart';
import 'package:dart2048/block_group.dart';
import 'package:dart2048/animator.dart';

void main() {
  final grid = Block.gridElement()..id = 'grid';
  querySelector('#output').children.add(grid);
  final animator = Animator();
  var group = BlockGroup.initialize(animator);
  animator.apply(() {
    group = group.apply(Direction.right, animator);
  }, beforeGrow: () {
    print('attach');
    group.attach(grid);
  });
}
