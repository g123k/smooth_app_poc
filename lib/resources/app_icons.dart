import 'package:flutter/material.dart';
import 'package:smoothapp_poc/utils/ui_utils.dart';

part 'app_icons_font.dart';

class AddToList extends IconType {
  const AddToList({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.add_to_list);
}

class ArrowHorizontal extends IconType {
  const ArrowHorizontal({
    this.direction = HorizontalDirection.end,
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.arrow_down);

  final HorizontalDirection direction;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: switch (direction) {
        HorizontalDirection.start => 0,
        HorizontalDirection.end => 2,
      },
      child: super.build(context),
    );
  }
}

class ArrowVertical extends IconType {
  const ArrowVertical({
    this.direction = VerticalDirection.down,
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.arrow_right);

  final VerticalDirection direction;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: switch (direction) {
        VerticalDirection.up => 1,
        VerticalDirection.down => 3,
      },
      child: super.build(context),
    );
  }
}

class Check extends IconType {
  const Check({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.check);
}

class ChevronVertical extends IconType {
  const ChevronVertical({
    super.color,
    super.size,
    super.shadow,
    this.direction = VerticalDirection.up,
    super.key,
  }) : super(_IconsFont.warning);

  final VerticalDirection direction;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: switch (direction) {
        VerticalDirection.up => 0,
        VerticalDirection.down => 2,
      },
      child: super.build(context),
    );
  }
}

class CircledArrow extends IconType {
  const CircledArrow({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.arrow_circled);
}

class Close extends IconType {
  const Close({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.close);
}

class Barcode extends IconType {
  const Barcode({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.barcode);
}

class Camera extends IconType {
  const Camera.filled({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.camera_filled);

  const Camera.outlined({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.camera_outlined);
}

class Categories extends IconType {
  const Categories({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.categories);
}

class Compare extends IconType {
  const Compare({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.compare);
}

class Countries extends IconType {
  const Countries({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.countries);
}

class Cupcake extends IconType {
  const Cupcake({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.cupcake);
}

class Edit extends IconType {
  const Edit({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.edit);
}

class Environment extends IconType {
  const Environment({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.environment);
}

class Expand extends IconType {
  const Expand({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.expand);
}

class CameraFlash extends IconType {
  const CameraFlash({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.flash_on);
}

class Fruit extends IconType {
  const Fruit({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.fruit);
}

class Info extends IconType {
  const Info({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.info);
}

class Ingredients extends IconType {
  const Ingredients({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.ingredients);
}

class Labels extends IconType {
  const Labels({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.labels);
}

class Lifebuoy extends IconType {
  const Lifebuoy({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.lifebuoy);
}

class Outdated extends IconType {
  const Outdated({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.outdated);
}

class NutritionFacts extends IconType {
  const NutritionFacts({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.nutrition_facts);
}

class Packaging extends IconType {
  const Packaging({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.packaging);
}

class Question extends IconType {
  const Question({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.question);

  const Question.circled({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.question_circled);
}

class Settings extends IconType {
  const Settings({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.settings);
}

class Stores extends IconType {
  const Stores({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.stores);
}

class ToggleCamera extends IconType {
  const ToggleCamera({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.toggle_camera);
}

class Warning extends IconType {
  const Warning({
    super.color,
    super.size,
    super.shadow,
    super.key,
  }) : super(_IconsFont.warning);
}

abstract class IconType extends StatelessWidget {
  const IconType(
    this.icon, {
    this.color,
    this.shadow,
    this.size,
    super.key,
  }) : assert(size == null || size >= 0);

  final IconData icon;
  final Color? color;
  final double? size;
  final Shadow? shadow;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (size == 0.0) {
      return const SizedBox.shrink();
    }

    final IconThemeData iconThemeData = IconTheme.of(context);
    Color? color = switch (this.color) {
      Color _ => this.color,
      _ => iconThemeData.color ?? Theme.of(context).iconTheme.color,
    };

    return Icon(
      icon,
      color: color,
      size: size,
      shadows: shadow != null ? <Shadow>[shadow!] : null,
    );
  }
}
