import 'package:engine/engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'game_page_model.dart';
import 'part_helpers.dart';

class PartWidget extends StatefulWidget {
  PartWidget({this.part, this.enabled, this.onTap, this.onProductTap, this.model});

  final Part part;
  final bool enabled;
  final void Function(Part part) onTap;
  final void Function(Product product) onProductTap;
  final GamePageModel model;

  @override
  _PartWidgetState createState() => _PartWidgetState();
}

class _PartWidgetState extends State<PartWidget> {
  // if the resource is spade, then we need to fix anything that is black
  Color _fixColor(Color bg, Color fg) {
    if (bg == fg) {
      return Colors.white;
    } else {
      return fg;
    }
  }

  Widget _triggersToIcons(Part part) {
    var items = <Widget>[];
    items.add(Text(
      'Triggers: ',
      style: const TextStyle(fontWeight: FontWeight.bold),
    ));
    if (part is EnhancementPart) {
      if (part.resourceStorage > 0) {
        items.add(Icon(partTypeToIcon(PartType.acquire)));
        items.add(Text(':${part.resourceStorage} ', style: const TextStyle(fontWeight: FontWeight.bold)));
      }
      if (part.partStorage > 0) {
        items.add(Icon(partTypeToIcon(PartType.storage)));
        items.add(Text(':${part.partStorage} ', style: const TextStyle(fontWeight: FontWeight.bold)));
      }
      if (part.search > 0) {
        items.add(Icon(actionToIcon(ActionType.search)));
        items.add(Text(':${part.search}', style: const TextStyle(fontWeight: FontWeight.bold)));
      }
      return Row(children: items);
    }
    for (var index = 0; index < part.triggers.length; ++index) {
      var trigger = part.triggers[index];
      switch (trigger.triggerType) {
        case TriggerType.store:
          items.add(Icon(partTypeToIcon(PartType.storage)));
          break;
        case TriggerType.acquire:
          items.add(Icon(partTypeToIcon(PartType.acquire), color: resourceToColor((trigger as AcquireTrigger).resourceType)));
          break;
        case TriggerType.construct:
          items.add(Icon(partTypeToIcon(PartType.construct), color: resourceToColor((trigger as ConstructTrigger).resourceType)));
          break;
        case TriggerType.convert:
          var t = trigger as ConvertTrigger;
          items.add(resourceToIcon(t.resourceType, resourceToColor(t.resourceType)));
          items.add(Icon(partTypeToIcon(PartType.converter)));
          if (part.products[0].productType == ProductType.convert) {
            items.add(Icon(productTypeToIcon(ProductType.convert)));
            //items.add(Icon(FontAwesome.question_circle));
          } else if (part.products[0].productType == ProductType.doubleResource) {
            items.add(resourceToIcon((part.products[0] as DoubleResourceProduct).sourceResource, resourceToColor((part.products[0] as DoubleResourceProduct).sourceResource)));
            items.add(resourceToIcon((part.products[0] as DoubleResourceProduct).sourceResource, resourceToColor((part.products[0] as DoubleResourceProduct).sourceResource)));
          }
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
      if (index < part.triggers.length - 1) {
        items.add(Icon(MaterialCommunityIcons.slash_forward));
      }
    }
    return Row(children: items);
  }

  Widget _productWidget(Product product) {
    if (product is DoubleResourceProduct) {
      return Row(
        children: [
          resourceToIcon(product.sourceResource, resourceToColor(product.sourceResource)),
          resourceToIcon(product.sourceResource, resourceToColor(product.sourceResource)),
        ],
      );
    } else if (product is VpProduct) {
      return Text('+1 VP', style: const TextStyle(fontWeight: FontWeight.bold));
    } else {
      return Icon(productToIcon(product));
    }
  }

  Widget _productsToIcons(List<Product> products) {
    var items = <Widget>[];
    for (var product in products) {
      if (product is DoubleResourceProduct || product is ConvertProduct) continue;
      items.add(Tooltip(
        message: productTooltipString(product.productType),
        child: ElevatedButton(
          child: _productWidget(product),
          onPressed: !widget.model.isResourcePickerEnabled && widget.part.ready.value && !product.activated.value && (widget.onProductTap != null)
              ? () async => await widget.onProductTap(product)
              : null,
        ),
      ));
    }
    return Row(children: items);
  }

  // List<Widget> _productsToList(Part part) {
  //   var list = <Widget>[];
  //   for (var product in part.products) {
  //     switch (product.productType) {
  //       case ProductType.convert:
  //         list.add(Icon(FontAwesome.question_circle));

  //         break;
  //       case ProductType.aquire:
  //         list.add(Icon(partTypeToIcon(PartType.acquire), color: Colors.black));
  //         break;
  //       case ProductType.doubleResource:
  //         break;
  //       case ProductType.freeConstruct:
  //         break;
  //       case ProductType.mysteryMeat:
  //         break;
  //       case ProductType.search:
  //         break;
  //       case ProductType.vp:
  //         break;
  //       default:
  //         throw InvalidOperationError('Unknown product type ${product.productType}');
  //     }
  //   }
  //   return list;
  // }

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
              //color: widget.enabled ? Colors.white : Colors.grey[400],
              color: widget.enabled ? Colors.white : resourceToColor(widget.part.resource),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          //color: Colors.grey[300],
                          color: widget.enabled ? Colors.white : resourceToColor(widget.part.resource),
                          //borderRadius: BorderRadius.all(Radius.circular(24.0)),
                        ),
                        child: Icon(
                          partTypeToIcon(widget.part.partType),
                          color: Colors.black,
                        ),
                      ),
                      Text('Cost: ${widget.part.cost}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      resourceToIcon(widget.part.resource, resourceToColor(widget.part.resource)),
                      Text('VP: ${widget.part.vp}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  _triggersToIcons(widget.part),
                  //Text('Products: ${widget.part.products.length}'),
                  _productsToIcons(widget.part.products),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
