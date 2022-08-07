import 'package:engine/engine.dart';
import 'package:factorymatics/src/display_sizes.dart';
import 'package:flutter/material.dart';

import 'part_widget.dart';

class PartTestWidget extends StatelessWidget {
  PartTestWidget({Key? key, this.parts}) : super(key: key);

  final List<Part>? parts;
  final DisplaySizes displaySizes = DisplaySizes();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Part List'),
      ),
      body: Center(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: parts!.length,
          itemBuilder: ((context, index) {
            return Wrap(
              children: [
                PartWidget(
                  part: parts![index],
                  enabled: false,
                  onTap: null,
                  onProductTap: null,
                  isResourcePickerEnabled: false,
                  displaySizes: displaySizes,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
