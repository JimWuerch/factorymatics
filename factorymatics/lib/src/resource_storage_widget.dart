import 'package:engine/engine.dart';
import 'package:factorymatics/src/part_helpers.dart';
import 'package:flutter/material.dart';

class ResourceStorageWidget extends StatelessWidget {
  final Map<ResourceType, int> resources;

  const ResourceStorageWidget({Key key, this.resources}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              resourceToIcon(ResourceType.heart, resourceToColor(ResourceType.heart)),
              Text(' : ${resources[ResourceType.heart]} '),
            ],
          ),
          Row(
            children: [
              resourceToIcon(ResourceType.diamond, resourceToColor(ResourceType.diamond)),
              Text(' : ${resources[ResourceType.diamond]} '),
            ],
          ),
          Row(
            children: [
              resourceToIcon(ResourceType.spade, resourceToColor(ResourceType.spade)),
              Text(' : ${resources[ResourceType.spade]} '),
            ],
          ),
          Row(
            children: [
              resourceToIcon(ResourceType.club, resourceToColor(ResourceType.club)),
              Text(' : ${resources[ResourceType.club]} '),
            ],
          ),
        ],
      ),
    );
  }
}
