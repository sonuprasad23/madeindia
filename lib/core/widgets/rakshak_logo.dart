import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../branding/brand_config.dart';

enum RakshakLogoVariant { icon, mark, compact, mono }

/// Renders the Rakshak brand mark, automatically picking the light/dark
/// variant from the current theme brightness.
///
/// Swap [BrandConfig]'s asset paths to re-brand without touching call sites.
class RakshakLogo extends StatelessWidget {
  const RakshakLogo({
    super.key,
    this.size = 40,
    this.variant = RakshakLogoVariant.mark,
    this.withWordmark = false,
  });

  final double size;
  final RakshakLogoVariant variant;
  final bool withWordmark;

  String _assetFor(Brightness brightness) {
    switch (variant) {
      case RakshakLogoVariant.icon:
        return BrandConfig.appIcon;
      case RakshakLogoVariant.compact:
        return BrandConfig.logoCompact;
      case RakshakLogoVariant.mono:
        return BrandConfig.logoMonochrome;
      case RakshakLogoVariant.mark:
        return brightness == Brightness.dark
            ? BrandConfig.logoAssetDark
            : BrandConfig.logoAssetLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final mark = SvgPicture.asset(
      _assetFor(brightness),
      width: size,
      height: size,
    );

    if (!withWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        Text(
          BrandConfig.appName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
