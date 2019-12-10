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
    grid.onClick.listen((event) {
      final oldGroup = group;
      group = group.apply(Direction.right, animator);
      animator.apply(() {
        print('finish');
      }, beforeGrow: () {
        print('replace');
        oldGroup.remove();
        group.attach(grid);
      });
    });
  }, beforeGrow: () {
    print('attach');
    group.attach(grid);
  });
}
