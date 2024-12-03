import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../mdc_lk_components.dart';

class NewMessageIndicator extends StatelessWidget {
  const NewMessageIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomContext>(builder: (context, roomCtx, child) {
      return roomCtx.showNewMessageIndicator
          ? Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Container(),
              ),
            )
          : Container();
    });
  }
}
