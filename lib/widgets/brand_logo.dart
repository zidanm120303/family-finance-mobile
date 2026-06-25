import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 190, this.center = true});

  final double width;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      'assets/svg/logo_famfinance.svg',
      width: width,
      fit: BoxFit.contain,
    );
    if (!center) return logo;
    return Center(child: logo);
  }
}
