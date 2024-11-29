
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../mdc_lk_components.dart';

class IsLocalIndicator extends StatelessWidget {
  const IsLocalIndicator({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, bool isLocal) builder;

  @override
  Widget build(BuildContext context) {
    var participantContext = Provider.of<ParticipantContext>(context);
    // var trackCtx = Provider.of<TrackReferenceContext?>(context);

    /// Show speaking indicator only if the participant is not sharing screen
    // var showSpeakingIndicator = !(trackCtx?.isScreenShare ?? true);
    Debug.log('===>     IsLocalIndicator for ${participantContext.name}');
    return Selector<ParticipantContext, bool>(
      selector: (context, isLocal) => participantContext.isLocal,
      builder: (context, isLocal, child) =>
          builder(context, isLocal ? isLocal : false),
    );
  }
}
