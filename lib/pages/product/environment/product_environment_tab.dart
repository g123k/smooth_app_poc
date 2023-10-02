import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/widgets/page_view.dart';

class ProductEnvironmentTab extends StatefulWidget {
  const ProductEnvironmentTab({super.key});

  @override
  State<ProductEnvironmentTab> createState() => _ProductEnvironmentTabState();
}

class _ProductEnvironmentTabState extends State<ProductEnvironmentTab>
    with AutomaticKeepAliveClientMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final double width = MediaQuery.sizeOf(context).width;

    if (!_isExpanded) {
      return SizedBox(
        height: PageViewData.of(context).minHeight,
        child: Column(
          children: [
            SizedBox(
              width: width,
              height: 394,
              child: Image.asset(
                'assets/images/product_env_min.webp',
                width: width,
                height: 394,
                fit: BoxFit.fitWidth,
                alignment: AlignmentDirectional.topCenter,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              child: Image.asset(
                'assets/images/product_env_min_footer.webp',
                width: width,
                fit: BoxFit.fitWidth,
                alignment: AlignmentDirectional.topCenter,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        setState(() => _isExpanded = !_isExpanded);
      },
      child: SizedBox(
        width: width,
        height: (width / 428) * 1449,
        child: Image.asset(
          'assets/images/product_envx_max.webp',
          // 428 x 1300
          width: width,
          height: (width / 428) * 1449,
          fit: BoxFit.fitWidth,
          alignment: AlignmentDirectional.topCenter,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
