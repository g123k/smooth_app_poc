import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smoothapp_poc/resources/app_colors.dart';
import 'package:smoothapp_poc/resources/app_icons.dart' as icons;

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    required this.text,
    required this.onClose,
    this.dismissible = false,
    this.actionText,
    this.actionCallback,
    super.key,
  });

  final String text;
  final VoidCallback? onClose;
  final bool dismissible;
  final String? actionText;
  final VoidCallback? actionCallback;

  @override
  Widget build(BuildContext context) {
    final Widget child = Semantics(
      hint: text,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.blackPrimary,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: double.infinity,
                width: 38.0,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadiusDirectional.horizontal(
                    start: Radius.circular(5.0),
                  ),
                  color: AppColors.greyDark,
                  border: Border.all(
                    color: AppColors.blackPrimary,
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 10.0,
                  vertical: 16.0,
                ),
                alignment: AlignmentDirectional.topCenter,
                child: const icons.Info(
                  color: AppColors.white,
                  size: 18.0,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              text,
                              style: const TextStyle(
                                color: AppColors.blackSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Retirer ce message d\'aide',
                          enableFeedback: true,
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: onClose,
                              child: Container(
                                width: 28.0,
                                height: 28.0,
                                decoration: const BoxDecoration(
                                  color: AppColors.greyDark,
                                  borderRadius: BorderRadiusDirectional.only(
                                    topEnd: Radius.circular(5.0),
                                    bottomStart: Radius.circular(5.0),
                                  ),
                                ),
                                child: const Center(
                                  child: icons.Close(
                                    size: 12.0,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    if (actionText != null && actionCallback != null) ...[
                      const Divider(
                        color: AppColors.blackPrimary,
                      ),
                      InkWell(
                        onTap: actionCallback,
                        child: Ink(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          child: Row(
                            children: [
                              Text(
                                actionText!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6.0),
                              const icons.Chevron.right(
                                size: 10.0,
                              ),
                            ],
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (dismissible) {
      return FadeDismissible(
        dismissibleKey: const Key('info_widget'),
        onDismissed: () => onClose?.call(),
        child: child,
      );
    } else {
      return child;
    }
  }
}

class ListItemDivider extends StatelessWidget {
  const ListItemDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1.0,
      color: AppColors.greyLight2,
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SvgPicture.asset('assets/images/placeholder.svg'),
    );
  }
}

class FadeDismissible extends StatefulWidget {
  const FadeDismissible({
    required this.dismissibleKey,
    required this.child,
    this.onDismissed,
    super.key,
  });

  final Key dismissibleKey;
  final Widget child;
  final VoidCallback? onDismissed;

  @override
  State<FadeDismissible> createState() => _FadeDismissibleState();
}

class _FadeDismissibleState extends State<FadeDismissible> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: widget.dismissibleKey,
      child: Opacity(
        opacity: 1 - _progress,
        child: widget.child,
      ),
      onUpdate: (DismissUpdateDetails details) {
        setState(() => _progress = details.progress);
      },
    );
  }
}
