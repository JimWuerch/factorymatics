import 'package:engine/engine.dart';
import 'package:flutter/material.dart';

//import 'game_page_model.dart';
import 'icons.dart';
import 'part_helpers.dart';

class PartWidget extends StatefulWidget {
  PartWidget({this.part, this.enabled, this.onTap, this.onProductTap, this.isResourcePickerEnabled});

  final Part part;
  final bool enabled;
  final void Function(Part part) onTap;
  final void Function(Product product) onProductTap;
  final bool isResourcePickerEnabled;

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

  List<Widget> _productionLine() {
    if (widget.part is MultipleConverterPart) {
      var part = widget.part as MultipleConverterPart;
      return <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _triggersToIcons(part.converters[0]),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text('|', style: TextStyle(color: _fixColor(resourceToColor(part.resource), Colors.black))),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: _triggersToIcons(part.converters[1]),
        ),
      ];
    } else {
      var items = _triggersToIcons(widget.part);
      items.addAll(_productsToIcons(widget.part.products));
      return items;
    }
  }

  List<Widget> _triggersToIcons(Part part) {
    var items = <Widget>[];
    // items.add(Text(
    //   'Triggers: ',
    //   style: const TextStyle(fontWeight: FontWeight.bold),
    // ));
    if (part is EnhancementPart) {
      if (part.resourceStorage > 0) {
        items.add(Icon(partTypeToIcon(PartType.acquire),
            color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
        items.add(Text(':${part.resourceStorage} ',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: _fixColor(resourceToColor(widget.part.resource), Colors.black))));
      }
      if (part.partStorage > 0) {
        items.add(Icon(partTypeToIcon(PartType.storage),
            color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
        items.add(Text(':${part.partStorage} ',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: _fixColor(resourceToColor(widget.part.resource), Colors.black))));
      }
      if (part.search > 0) {
        items.add(Icon(actionToIcon(ActionType.search),
            color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
        items.add(Text(':${part.search}',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: _fixColor(resourceToColor(widget.part.resource), Colors.black))));
      }
      return items;
      // return Row(
      //   children: items,
      //   mainAxisAlignment: MainAxisAlignment.center,
      // );
    }
    for (var index = 0; index < part.triggers.length; ++index) {
      var trigger = part.triggers[index];
      switch (trigger.triggerType) {
        case TriggerType.store:
          items.add(Icon(partTypeToIcon(PartType.storage),
              color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
          break;
        case TriggerType.acquire:
          items.add(Icon(partTypeToIcon(PartType.acquire),
              color: _fixColor(
                  resourceToColor(widget.part.resource), resourceToColor((trigger as AcquireTrigger).resourceType))));
          items.add(resourceToIcon(
              (trigger as AcquireTrigger).resourceType,
              _fixColor(
                  resourceToColor(widget.part.resource), resourceToColor((trigger as AcquireTrigger).resourceType))));
          break;
        case TriggerType.construct:
          items.add(Icon(partTypeToIcon(PartType.construct),
              color: resourceToColor((trigger as ConstructTrigger).resourceType)));
          items.add(resourceToIcon(
              (trigger as ConstructTrigger).resourceType,
              _fixColor(
                  resourceToColor(widget.part.resource), resourceToColor((trigger as ConstructTrigger).resourceType))));
          break;
        case TriggerType.convert:
          var t = trigger as ConvertTrigger;
          items.add(resourceToIcon(
              t.resourceType, _fixColor(resourceToColor(widget.part.resource), resourceToColor(t.resourceType))));
          items.add(Icon(partTypeToIcon(PartType.converter),
              color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
          if (part.products[0].productType == ProductType.convert) {
            items.add(Icon(productTypeToIcon(ProductType.convert),
                color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
            //items.add(Icon(FontAwesome.question_circle));
          } else if (part.products[0].productType == ProductType.doubleResource) {
            items.add(resourceToIcon(
                (part.products[0] as DoubleResourceProduct).sourceResource,
                _fixColor(resourceToColor(widget.part.resource),
                    resourceToColor((part.products[0] as DoubleResourceProduct).sourceResource))));
            items.add(resourceToIcon(
                (part.products[0] as DoubleResourceProduct).sourceResource,
                _fixColor(resourceToColor(widget.part.resource),
                    resourceToColor((part.products[0] as DoubleResourceProduct).sourceResource))));
          }
          break;
        case TriggerType.purchased:
          items.add(Icon(Icons.monetization_on, color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
          break;
        case TriggerType.constructLevel:
          items.add(
              Icon(Icons.add_shopping_cart, color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
          break;
        case TriggerType.constructFromStore:
          items.add(Icon(partTypeToIcon(PartType.construct),
              color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
          items.add(Icon(partTypeToIcon(PartType.storage),
              color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
          break;
      }
      if (index < part.triggers.length - 1) {
        items.add(Icon(iconSlashForward, color: _fixColor(resourceToColor(widget.part.resource), Colors.black)));
      }
    }
    return items;
    // return Row(
    //   children: items,
    //   mainAxisAlignment: MainAxisAlignment.center,
    // );
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
      return Text('+${product.vp} VP', style: const TextStyle(fontWeight: FontWeight.bold));
    } else {
      return Icon(productToIcon(product));
    }
  }

  List<Widget> _productsToIcons(List<Product> products) {
    var items = <Widget>[];
    for (var product in products) {
      if (product is DoubleResourceProduct || product is ConvertProduct) continue;
      items.add(Tooltip(
        message: productTooltipString(product.productType),
        child: ElevatedButton(
          child: _productWidget(product),
          onPressed: !widget.isResourcePickerEnabled &&
                  widget.part.ready.value &&
                  !product.activated.value &&
                  (widget.onProductTap != null)
              ? () async => await widget.onProductTap(product)
              : null,
        ),
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    //var iconSize = 24.0;
    //Icon(_resourceToIcon(ResourceType.spade)).size;
    return SizedBox(
      width: 200,
      child: Card(
        shape: widget.enabled
            ? RoundedRectangleBorder(
                side: BorderSide(color: Colors.orange, width: 4),
                borderRadius: BorderRadius.all(
                  Radius.circular(4.0),
                ),
              )
            : null,
        color: resourceToColor(widget.part.resource),
        child: DefaultTextStyle(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _fixColor(resourceToColor(widget.part.resource), Colors.black),
            fontSize: 24,
          ),
          child: InkWell(
            onTap: () {
              if (widget.enabled) widget.onTap(widget.part);
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                //color: widget.enabled ? Colors.white : Colors.grey[400],
                //color: widget.enabled ? Colors.white : resourceToColor(widget.part.resource),
                color: resourceToColor(widget.part.resource),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // Container(
                        //   width: iconSize,
                        //   height: iconSize,
                        //   decoration: BoxDecoration(
                        //     //color: Colors.grey[300],
                        //     color: widget.enabled ? Colors.white : resourceToColor(widget.part.resource),
                        //     //borderRadius: BorderRadius.all(Radius.circular(24.0)),
                        //   ),
                        //   child: Icon(
                        //     partTypeToIcon(widget.part.partType),
                        //     color: Colors.black,
                        //   ),
                        // ),
                        Row(
                          children: [
                            Text('${widget.part.id}'),
                            Icon(
                              partTypeToIcon(widget.part.partType),
                              color: _fixColor(resourceToColor(widget.part.resource), Colors.black),
                            ),
                          ],
                        ),
                        if (widget.part.cost > 0)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('${widget.part.cost}'),
                              resourceToIcon(
                                widget.part.resource,
                                _fixColor(resourceToColor(widget.part.resource), Colors.black),
                              ),
                            ],
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${widget.part.vp}'),
                            Icon(
                              productTypeToIcon(ProductType.vp),
                              color: _fixColor(resourceToColor(widget.part.resource), Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: _productionLine(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
