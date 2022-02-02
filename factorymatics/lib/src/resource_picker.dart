import 'package:engine/engine.dart';
import 'package:factorymatics/src/part_helpers.dart';
import 'package:flutter/material.dart';

class ResourcePicker extends StatelessWidget {
  final List<ResourceType> resources;
  final Future<void> Function(int index) onTap;
  final bool enabled;

  const ResourcePicker({Key key, this.resources, this.onTap, this.enabled}) : super(key: key);

  List<Widget> _makeTargets() {
    var ret = <Widget>[];
    ret.add(Icon(partTypeToIcon(PartType.acquire)));
    ret.add(Text('  '));
    for (var i = 0; i < resources.length; ++i) {
      ret.add(IconButton(
        icon: Icon(resourceToIconData(resources[i]), color: resourceToColor(resources[i])),
        onPressed: enabled && (onTap != null) ? () async => await onTap(i) : null,
      ));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: enabled ? Colors.lightBlueAccent : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _makeTargets(),
      ),
    );
  }
}
