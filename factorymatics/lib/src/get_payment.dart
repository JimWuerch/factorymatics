import 'package:engine/engine.dart';
import 'package:flutter/material.dart';

import 'icons.dart';
import 'part_helpers.dart';

class GetPaymentWidget extends StatefulWidget {
  GetPaymentWidget(this.paths, {Key key, this.onTap}) : super(key: key);

  final List<SpendHistory> paths;
  final void Function(int index) onTap;

  @override
  State<GetPaymentWidget> createState() => _GetPaymentWidgetState();
}

class _GetPaymentWidgetState extends State<GetPaymentWidget> {
  List<Widget> _makeChoices(BuildContext context, List<SpendHistory> paths) {
    var list = <Widget>[];
    for (var path in paths) {
      var items = <Widget>[];
      var first = true;
      for (var used in path.history) {
        if (used.product.productType == ProductType.spend) {
          if (!first) {
            items.add(Icon(iconPlusThick));
          } else {
            first = false;
          }
          items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
        }
      }
      for (var used in path.history) {
        if (used.product.productType == ProductType.convert) {
          if (!first) {
            items.add(Icon(iconPlusThick));
          } else {
            first = false;
          }
          items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
          items.add(Icon(partTypeToIcon(PartType.converter)));
          items.add(resourceToIcon(
              (used.product as ConvertProduct).dest, resourceToColor((used.product as ConvertProduct).dest)));
        } else if (used.product.productType == ProductType.doubleResource) {
          if (!first) {
            items.add(Icon(iconPlusThick));
          } else {
            first = false;
          }
          items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
          items.add(Icon(partTypeToIcon(PartType.converter)));
          items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
          items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
        }
      }
      list.add(Row(children: items));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var choices = _makeChoices(context, widget.paths);
    return Column(
      children: List.generate(
        widget.paths.length,
        (index) => SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, index);
          },
          child: choices[index],
        ),
      ),
    );
  }
}
