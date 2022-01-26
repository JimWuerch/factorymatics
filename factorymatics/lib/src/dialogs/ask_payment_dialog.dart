import 'package:engine/engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../part_helpers.dart';

List<Widget> _makeChoices(BuildContext context, List<SpendHistory> paths) {
  var list = <Widget>[];
  var index = 0;
  for (var path in paths) {
    var cost = path.getCost().toList();
    var items = <Widget>[];
    var first = true;
    for (var used in path.history) {
      if (used.product.productType == ProductType.spend) {
        if (!first) {
          items.add(Text(' , '));
        } else {
          first = false;
        }
        items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
      }
    }
    //items.add(Icon(MaterialCommunityIcons.arrow_right_thick));
    for (var used in path.history) {
      if (used.product.productType == ProductType.convert) {
        if (!first) {
          items.add(Text(' , '));
        } else {
          first = false;
        }
        items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
        items.add(Icon(partTypeToIcon(PartType.converter)));
        items.add(resourceToIcon((used.product as ConvertProduct).dest, resourceToColor((used.product as ConvertProduct).dest)));
      } else if (used.product.productType == ProductType.doubleResource) {
        if (!first) {
          items.add(Text(' , '));
        } else {
          first = false;
        }
        items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
        items.add(Icon(partTypeToIcon(PartType.converter)));
        items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
        items.add(resourceToIcon(used.product.sourceResource, resourceToColor(used.product.sourceResource)));
      }
    }
    list.add(SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context, index++);
      },
      child: Row(children: items),
    ));
  }
  return list;
}

Future<int> showAskPaymentDialog(BuildContext context, List<SpendHistory> paths) async {
  return await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Choose payment'),
          children: _makeChoices(context, paths),
        );
      });
}
