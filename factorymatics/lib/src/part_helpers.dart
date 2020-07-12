import 'package:engine/engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

IconData partTypeToIcon(PartType partType) {
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

IconData actionToIcon(ActionType actionType) {
  switch (actionType) {
    case ActionType.store:
      return partTypeToIcon(PartType.storage);
    case ActionType.acquire:
      return partTypeToIcon(PartType.acquire);
    case ActionType.construct:
      return partTypeToIcon(PartType.construct);
    case ActionType.search:
      return MaterialCommunityIcons.feature_search;
    default:
      throw ArgumentError('invalid action ${actionType.toString()}');
  }
}

Icon resourceToIcon(ResourceType resourceType, Color color) {
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

Color resourceToColor(ResourceType resourceType) {
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
