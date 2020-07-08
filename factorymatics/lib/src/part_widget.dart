import 'package:engine/engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class PartWidget extends StatefulWidget {
  PartWidget(this.part);

  final Part part;

  @override
  _PartWidgetState createState() => _PartWidgetState();
}

class _PartWidgetState extends State<PartWidget> {
  IconData _partTypeToIcon(PartType partType) {
    switch (partType) {
      case PartType.storage:
        return Icons.save;
      case PartType.enhancement:
        return Icons.add_circle;
      case PartType.converter:
        return Icons.arrow_forward_ios;
      case PartType.acquire:
        return Icons.arrow_drop_down_circle;
      case PartType.construct:
        return MaterialCommunityIcons.crane;
      default:
        return Fontisto.question;
    }
  }

  Icon _resourceToIcon(ResourceType resourceType, Color color) {
    switch (resourceType) {
      case ResourceType.none:
        return Icon(Icons.cancel, color: color);
      case ResourceType.heart:
        return Icon(MaterialCommunityIcons.cards_heart, color: color);
      case ResourceType.spade:
        return Icon(MaterialCommunityIcons.cards_spade, color: color);
      case ResourceType.diamond:
        return Icon(MaterialCommunityIcons.cards_diamond, color: color);
      case ResourceType.club:
        return Icon(MaterialCommunityIcons.cards_club, color: color);
      case ResourceType.any:
        return Icon(MaterialCommunityIcons.all_inclusive, color: color);
      default:
        return Icon(Fontisto.question, color: color);
    }
  }

  Color _resourceToColor(ResourceType resourceType) {
    switch (resourceType) {
      case ResourceType.none:
        return Colors.grey[300];
      case ResourceType.heart:
        return Colors.red[700];
      case ResourceType.spade:
        return Colors.black87;
      case ResourceType.diamond:
        return Colors.yellow;
      case ResourceType.club:
        return Colors.blue[800];
      case ResourceType.any:
        return Colors.pink[300];
      default:
        return Colors.lightGreen[600];
    }
  }

  Widget _triggersToIcons(List<Trigger> triggers) {
    var items = <Widget>[];
    items.add(Text('Triggers: '));
    for (var index = 0; index < triggers.length; ++index) {
      var trigger = triggers[index];
      switch (trigger.triggerType) {
        case TriggerType.store:
          items.add(Icon(_partTypeToIcon(PartType.storage)));
          break;
        case TriggerType.acquire:
          items.add(Icon(_partTypeToIcon(PartType.acquire),
              color: _resourceToColor((trigger as AcquireTrigger).resourceType)));
          break;
        case TriggerType.construct:
          items.add(Icon(_partTypeToIcon(PartType.construct),
              color: _resourceToColor((trigger as ConstructTrigger).resourceType)));
          break;
        case TriggerType.convert:
          var t = trigger as ConvertTrigger;
          items.add(_resourceToIcon(t.resourceType, _resourceToColor(t.resourceType)));
          items.add(Icon(_partTypeToIcon(PartType.converter)));
          break;
        case TriggerType.purchased:
          items.add(Icon(Icons.monetization_on));
          break;
        case TriggerType.constructLevel:
          items.add(Icon(Icons.add_shopping_cart));
          break;
      }
      if (index < triggers.length - 1) {
        items.add(Icon(MaterialCommunityIcons.slash_forward));
      }
    }
    return Row(children: items);
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = 24.0;
    //Icon(_resourceToIcon(ResourceType.spade)).size;
    return SizedBox(
      width: 200,
      child: Card(
        color: _resourceToColor(widget.part.resource),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            color: Colors.white,
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
                        _partTypeToIcon(widget.part.partType),
                        color: Colors.black,
                      ),
                    ),
                    Text('Cost: ${widget.part.cost}'),
                    _resourceToIcon(widget.part.resource, _resourceToColor(widget.part.resource)),
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
    );
  }
}
