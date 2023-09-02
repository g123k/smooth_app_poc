import 'package:flutter/material.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;
import 'package:smoothapp_poc/utils/barcode_utils.dart';
import 'package:smoothapp_poc/utils/text_utils.dart';

class SearchQueryItem extends StatelessWidget {
  const SearchQueryItem.search({
    required this.value,
    required this.onTap,
    super.key,
  })  : search = null,
        type = _SearchQueryType.internalSearch;

  const SearchQueryItem.history({
    required this.search,
    required this.value,
    required this.onTap,
    super.key,
  }) : type = _SearchQueryType.history;

  const SearchQueryItem.suggestions({
    required this.value,
    required this.onTap,
    super.key,
  })  : search = null,
        type = _SearchQueryType.suggestion;

  const SearchQueryItem.advancedSearch({
    required this.value,
    required this.onTap,
    super.key,
  })  : search = null,
        type = _SearchQueryType.advancedSearch;

  final String? search;
  final String value;
  final VoidCallback onTap;

  // ignore: library_private_types_in_public_api
  final _SearchQueryType type;

  @override
  Widget build(BuildContext context) {
    final bool isBarcode = BarcodeUtils.isABarcode(value);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 20.0,
          end: 17.0,
          top: 15.0,
          bottom: 15.0,
        ),
        child: IconTheme(
          data: const IconThemeData(
            color: AppColors.blackPrimary,
          ),
          child: Row(
            children: [
              IconTheme(
                data: const IconThemeData(size: 20.0),
                child: _getLeadingIcon(isBarcode),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                    text: TextSpan(
                      children: _getLabel(isBarcode),
                      style: DefaultTextStyle.of(context).style,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconTheme(
                data: const IconThemeData(size: 12.0),
                child: _getSuffixIcon(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLeadingIcon(bool isBarcode) {
    return switch (type) {
      _SearchQueryType.internalSearch when isBarcode => const icons.Barcode(),
      _SearchQueryType.internalSearch => const icons.Search(),
      _SearchQueryType.history => const icons.History(),
      _SearchQueryType.suggestion => const icons.Suggestion(),
      _SearchQueryType.advancedSearch => const icons.Search.advanced(),
    };
  }

  List<InlineSpan> _getLabel(bool isBarcode) {
    return switch (type) {
      _SearchQueryType.internalSearch ||
      _SearchQueryType.suggestion =>
        <InlineSpan>[
          const TextSpan(text: 'Rechercher "'),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: '"'),
        ],
      _SearchQueryType.history => <InlineSpan>[
          const TextSpan(text: 'Rechercher "'),
          ..._getParts(),
          const TextSpan(text: '"'),
        ],
      _SearchQueryType.advancedSearch => <InlineSpan>[
          const TextSpan(text: 'Faire une recherche avancée "'),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: '"'),
        ],
    };
  }

  Widget _getSuffixIcon() {
    return switch (type) {
      _SearchQueryType.internalSearch ||
      _SearchQueryType.history ||
      _SearchQueryType.suggestion =>
        const icons.Arrow.right(),
      _SearchQueryType.advancedSearch => const icons.ExternalLink(),
    };
  }

  Iterable<InlineSpan> _getParts() {
    const TextStyle defaultTextStyle = TextStyle();

    return TextHighlighter.getParts(
            text: value,
            filter: search ?? '',
            defaultStyle: defaultTextStyle,
            highlightedStyle: const TextStyle(fontWeight: FontWeight.bold))
        .map(
      ((String, TextStyle?) part) {
        return TextSpan(
          text: part.$1,
          style: defaultTextStyle.merge(part.$2),
        );
      },
    );
  }
}

enum _SearchQueryType {
  internalSearch,
  history,
  advancedSearch,
  suggestion,
}
