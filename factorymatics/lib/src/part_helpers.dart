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
    case ActionType.convert:
      return Icons.arrow_forward_ios;
    case ActionType.mysteryMeat:
      return MaterialCommunityIcons.cloud_question;
    default:
      throw ArgumentError('invalid action ${actionType.toString()}');
  }
}

IconData resourceToIconData(ResourceType resourceType) {
  switch (resourceType) {
    case ResourceType.none:
      return Icons.cancel;
    case ResourceType.heart:
      return MaterialCommunityIcons.cards_heart;
    case ResourceType.spade:
      return MaterialCommunityIcons.cards_spade;
    case ResourceType.diamond:
      return MaterialCommunityIcons.cards_diamond;
    case ResourceType.club:
      return MaterialCommunityIcons.cards_club;
    case ResourceType.any:
      //return MaterialCommunityIcons.all_inclusive;
      return FontAwesome.question_circle;
    default:
      return Fontisto.question;
  }
}

Icon resourceToIcon(ResourceType resourceType, Color color) {
  return Icon(resourceToIconData(resourceType), color: color);
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
      //return Colors.pink[300];
      return Colors.black;
    default:
      return Colors.lightGreen[600];
  }
}

IconData productToIcon(Product product) {
  return productTypeToIcon(product.productType);
  // if (product is MysteryMeatProduct) {
  //   return actionToIcon(ActionType.mysteryMeat);
  // } else if (product is AcquireProduct) {
  //   return actionToIcon(ActionType.acquire);
  // } else if (product is VpProduct) {
  //   return FontAwesome.gear;
  // } else if (product is ConvertProduct) {
  //   return FontAwesome.question_circle;
  // } else {
  //   return Fontisto.question;
  // }
}

IconData productTypeToIcon(ProductType productType) {
  if (productType == ProductType.mysteryMeat) {
    return actionToIcon(ActionType.mysteryMeat);
  } else if (productType == ProductType.aquire) {
    return actionToIcon(ActionType.acquire);
  } else if (productType == ProductType.vp) {
    return FontAwesome.gear;
  } else if (productType == ProductType.convert) {
    return FontAwesome.question_circle;
  } else {
    return Fontisto.question;
  }
}

String productTooltipString(ProductType productType) {
  switch (productType) {
    case ProductType.aquire:
      return "Acquire a resource";
    case ProductType.convert:
      return "Convert a resource to a different type";
    case ProductType.doubleResource:
      return "Double a resource";
    case ProductType.freeConstruct:
      return "Construct a level 1 part for free";
    case ProductType.mysteryMeat:
      return "Acquire a random resource from the well";
    case ProductType.search:
      return "Perform the search action";
    case ProductType.store:
      return "Move a part into storage";
    case ProductType.vp:
      return "Gain a victory point";
    default:
      return "Unknown product";
  }
}
