import 'package:engine/engine.dart';
import 'package:flutter/material.dart';

import 'part_widget.dart';

class PartTestWidget extends StatelessWidget {
  const PartTestWidget({Key key, this.parts}) : super(key: key);

  final List<Part> parts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: parts.length,
      itemBuilder: ((context, index) {
        return Wrap(
          children: [
            PartWidget(
              part: parts[index],
              enabled: false,
              onTap: null,
              onProductTap: null,
              isResourcePickerEnabled: false,
            ),
          ],
        );
      }),
    );
  }
}