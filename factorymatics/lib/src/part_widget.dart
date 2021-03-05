import 'package:engine/engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'part_helpers.dart';

class PartWidget extends StatefulWidget {
  PartWidget({this.part, this.enabled, this.onTap});

  final Part part;
  final bool enabled;
  final void Function(Part part) onTap;

  @override
  _PartWidgetState createState() => _PartWidgetState();
}

class _PartWidgetState extends State<PartWidget> {
  Widget _triggersToIcons(List<Trigger> triggers) {
    var items = <Widget>[];
    items.add(Text('Triggers: '));
    for (var index = 0; index < triggers.length; ++index) {
      var trigger = triggers[index];
      switch (trigger.triggerType) {
        case TriggerType.store:
          items.add(Icon(partTypeToIcon(PartType.storage)));
          break;
        case TriggerType.acquire:
          items.add(
              Icon(partTypeToIcon(PartType.acquire), color: resourceToColor((trigger as AcquireTrigger).resourceType)));
          break;
        case TriggerType.construct:
          items.add(Icon(partTypeToIcon(PartType.construct),
              color: resourceToColor((trigger as ConstructTrigger).resourceType)));
          break;
        case TriggerType.convert:
          var t = trigger as ConvertTrigger;
          items.add(resourceToIcon(t.resourceType, resourceToColor(t.resourceType)));
          items.add(Icon(partTypeToIcon(PartType.converter)));
          //items.add(Icon(FontAwesome.question_circle));
          break;
        case TriggerType.purchased:
          items.add(Icon(Icons.monetization_on));
          break;
        case TriggerType.constructLevel:
          items.add(Icon(Icons.add_shopping_cart));
          break;
        case TriggerType.constructFromStore:
          items.add(Icon(Icons.add_shopping_cart));
          items.add(Icon(partTypeToIcon(PartType.storage)));
          break;
      }
      if (index < triggers.length - 1) {
        items.add(Icon(MaterialCommunityIcons.slash_forward));
      }
    }
    return Row(children: items);
  }

  List<Widget> _productsToList(Part part) {
    var list = <Widget>[];
    for (var product in part.products) {
      switch (product.productType) {
        case ProductType.convert:
          list.add(Icon(FontAwesome.question_circle));

          break;
        case ProductType.aquire:
          list.add(Icon(partTypeToIcon(PartType.acquire), color: Colors.black));
          break;
        case ProductType.doubleResource:
          break;
        case ProductType.freeConstruct:
          break;
        case ProductType.mysteryMeat:
          break;
        case ProductType.search:
          break;
        case ProductType.vp:
          break;
        default:
          throw InvalidOperationError('Unknown product type ${product.productType}');
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = 24.0;
    //Icon(_resourceToIcon(ResourceType.spade)).size;
    return SizedBox(
      width: 200,
      child: Card(
        color: resourceToColor(widget.part.resource),
        child: InkWell(
          onTap: () {
            if (widget.enabled) widget.onTap(widget.part);
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              color: widget.enabled ? Colors.white : Colors.grey[400],
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          //borderRadius: BorderRadius.all(Radius.circular(24.0)),
                        ),
                        child: Icon(
                          partTypeToIcon(widget.part.partType),
                          color: Colors.black,
                        ),
                      ),
                      Text('Cost: ${widget.part.cost}'),
                      resourceToIcon(widget.part.resource, resourceToColor(widget.part.resource)),
                      Text('VP: ${widget.part.vp}'),
                    ],
                  ),
                  _triggersToIcons(widget.part.triggers),
                  Text('Products: ${widget.part.products.length}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
