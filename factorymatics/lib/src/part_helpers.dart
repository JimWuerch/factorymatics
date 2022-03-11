import 'package:community_material_icon/community_material_icon.dart';
import 'package:engine/engine.dart';
import 'package:flutter/material.dart';

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
      return CommunityMaterialIcons.crane;
    default:
      return CommunityMaterialIcons.help;
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
      return CommunityMaterialIcons.feature_search;
    case ActionType.convert:
      return Icons.arrow_forward_ios;
    case ActionType.mysteryMeat:
      return CommunityMaterialIcons.cloud_question;
    default:
      throw ArgumentError('invalid action ${actionType.toString()}');
  }
}

IconData partIcon() {
  return CommunityMaterialIcons.hammer_wrench;
}

IconData resourceToIconData(ResourceType resourceType, {bool outline = false}) {
  switch (resourceType) {
    case ResourceType.none:
      return Icons.cancel;
    case ResourceType.heart:
      return CommunityMaterialIcons.cards_heart;
    case ResourceType.spade:
      return CommunityMaterialIcons.cards_spade;
    case ResourceType.diamond:
      return CommunityMaterialIcons.cards_diamond;
    case ResourceType.club:
      return CommunityMaterialIcons.cards_club;
    case ResourceType.any:
      //return CommunityMaterialIcons.all_inclusive;
      return CommunityMaterialIcons.help_circle;
    default:
      return CommunityMaterialIcons.help;
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
      return Colors.black;
    case ResourceType.diamond:
      return Colors.yellow;
    case ResourceType.club:
      return Colors.blue[800];
    case ResourceType.any:
      return Colors.purple;
    //return Colors.black;
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
    return CommunityMaterialIcons.cog;
  } else if (productType == ProductType.convert) {
    return CommunityMaterialIcons.help_circle;
  } else {
    return CommunityMaterialIcons.help;
  }
}

String productTooltipString(Product product) {
  switch (product.productType) {
    case ProductType.aquire:
      return "Acquire a resource";
    case ProductType.convert:
      return "Convert a resource to a different type";
    case ProductType.doubleResource:
      return "Double a resource";
    case ProductType.freeConstructL1:
      return "Construct a level 1 part for free";
    case ProductType.mysteryMeat:
      return "Acquire a random resource from the well";
    case ProductType.search:
      return "Perform the search action";
    case ProductType.store:
      return "Move a part into storage";
    case ProductType.vp:
      {
        var p = product as VpProduct;
        if (p.vp == 1) {
          return "Gain a victory point";
        }
        return 'Gain ${p.vp} vicory points';
      }
    default:
      return "Unknown product";
  }
}
