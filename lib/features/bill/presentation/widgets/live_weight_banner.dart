import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bill_bloc.dart';
import '../bloc/bill_state.dart';
import 'weight_display.dart';

/// Banner state consumed by [WeightDisplay].
///
/// Selected as one value so the banner only rebuilds when a field it actually
/// renders changes, instead of on every live scale reading.
typedef _WeightBannerState = ({
  double netWeightKg,
  double grossWeight,
  double tareWeight,
  String weightUnit,
  double? liveScaleWeightKg,
  String? activeMode,
  bool isStable,
  bool isMotion,
  bool isOverload,
});

/// The live scale readout, isolated in its own subscription.
///
/// The weigh indicator streams weight continuously, so this widget keeps that
/// traffic off the form, the recent billings panel, and the action bar, which
/// are driven by the page-level BlocConsumer.
class LiveWeightBanner extends StatelessWidget {
  final VoidCallback? onNavigateToReports;
  final VoidCallback? onNavigateToMaterials;

  const LiveWeightBanner({
    super.key,
    this.onNavigateToReports,
    this.onNavigateToMaterials,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BillBloc, BillState, _WeightBannerState>(
      selector: (state) => (
        netWeightKg: state.netWeightKg,
        grossWeight: state.grossWeightKg,
        tareWeight: state.tareWeightKg,
        weightUnit: state.weightUnit,
        liveScaleWeightKg: state.liveScaleWeightKg,
        activeMode: state.selectedWeightType.toUpperCase(),
        isStable: state.isScaleStable,
        isMotion: state.isScaleMotion,
        isOverload: state.isScaleOverload,
      ),
      builder: (context, banner) => WeightDisplay(
        netWeightKg: banner.netWeightKg,
        grossWeight: banner.grossWeight,
        tareWeight: banner.tareWeight,
        weightUnit: banner.weightUnit,
        liveScaleWeightKg: banner.liveScaleWeightKg,
        activeMode: banner.activeMode,
        isStable: banner.isStable,
        isMotion: banner.isMotion,
        isOverload: banner.isOverload,
        onNavigateToReports: onNavigateToReports,
        onNavigateToMaterials: onNavigateToMaterials,
      ),
    );
  }
}
