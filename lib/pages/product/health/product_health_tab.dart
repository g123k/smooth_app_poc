import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smoothapp_poc/utils/widgets/page_view.dart';

class ProductHealthTab extends StatefulWidget {
  const ProductHealthTab({super.key});

  @override
  State<ProductHealthTab> createState() => _ProductHealthTabState();
}

class _ProductHealthTabState extends State<ProductHealthTab>
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
              height: 474,
              child: Image.asset(
                'assets/images/product_nutrition_min.webp',
                width: width,
                height: 474,
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
                'assets/images/product_nutrition_min_footer.webp',
                width: width,
                height: 75,
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
        height: _isExpanded ? ((width / 428) * 1300) : 474,
        child: Image.asset(
          'assets/images/product_nutrition_${!_isExpanded ? 'min' : 'max'}.webp',
          // 428 x 1300
          width: width,
          height: _isExpanded ? ((width / 428) * 1300) : 474,
          fit: BoxFit.fitWidth,
          alignment: AlignmentDirectional.topCenter,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
