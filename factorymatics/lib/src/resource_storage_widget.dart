import 'package:engine/engine.dart';
import 'package:factorymatics/src/part_helpers.dart';
import 'package:flutter/material.dart';

class ResourceStorageWidget extends StatelessWidget {
  final Map<ResourceType, int/*!*/>/*!*/ resources;

  const ResourceStorageWidget({Key key, this.resources}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.black,
      ),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text('${resources[ResourceType.heart]}'),
                resourceToIcon(ResourceType.heart, resourceToColor(ResourceType.heart)),
              ],
            ),
            Row(
              children: [
                Text('  ${resources[ResourceType.diamond]}'),
                resourceToIcon(ResourceType.diamond, resourceToColor(ResourceType.diamond)),
              ],
            ),
            Row(
              children: [
                Text('  ${resources[ResourceType.spade]}'),
                resourceToIcon(ResourceType.spade, resourceToColor(ResourceType.spade)),
              ],
            ),
            Row(
              children: [
                Text('  ${resources[ResourceType.club]}'),
                resourceToIcon(ResourceType.club, resourceToColor(ResourceType.club)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
