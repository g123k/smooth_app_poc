part of 'product_page.dart';

class _ProductHeaderWrapperForSize extends StatefulWidget {
  const _ProductHeaderWrapperForSize(this.product);

  final Product product;

  @override
  State<_ProductHeaderWrapperForSize> createState() =>
      _ProductHeaderWrapperForSizeState();
}

class _ProductHeaderWrapperForSizeState
    extends State<_ProductHeaderWrapperForSize>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: _ProductHeader.tabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider<Product>.value(
      value: widget.product,
      child: ListenableProvider(
        create: (_) => _tabController,
        child: const _ProductHeader(),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({
    this.onElementTapped,
  });

  final VoidCallback? onElementTapped;

  static const List<Tab> tabs = [
    Tab(text: 'Pour moi'),
    Tab(text: 'Santé'),
    Tab(text: 'Environnement'),
    Tab(text: 'Photos'),
    Tab(text: 'Contribuer'),
    Tab(text: 'Infos'),
  ];

  @override
  Widget build(BuildContext context) {
    final TabController tabController = context.read<TabController>();
    return Material(
      type: MaterialType.card,
      child: Align(
        child: Column(
          children: [
            _ProductHeaderDetails(
              onNutriScoreClicked: () {
                tabController.animateTo(1);
                onElementTapped?.call();
              },
              onEcoScoreClicked: () {
                tabController.animateTo(2);
                onElementTapped?.call();
              },
            ),
            TabBar(
              controller: tabController,
              tabs: _ProductHeader.tabs,
              isScrollable: true,
              onTap: (_) => onElementTapped?.call(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeaderDetails extends StatelessWidget {
  const _ProductHeaderDetails({
    this.onNutriScoreClicked,
    this.onEcoScoreClicked,
  });

  final VoidCallback? onNutriScoreClicked;
  final VoidCallback? onEcoScoreClicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            top: 18.0,
            start: 20.0,
            end: 20.0,
            bottom: 10.0,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 75,
                    child: Semantics(
                      sortKey: const OrdinalSortKey(1.0),
                      child: const _ProductHeaderInfo(),
                    ),
                  ),
                  Expanded(
                    flex: 15,
                    child: Semantics(
                      sortKey: const OrdinalSortKey(2.0),
                      child: _ProductHeaderScores(
                        onNutriScoreClicked: onNutriScoreClicked,
                        onEcoScoreClicked: onEcoScoreClicked,
                      ),
                    ),
                  ),
                ],
              ),
              Semantics(
                sortKey: const OrdinalSortKey(3.0),
                explicitChildNodes: true,
                child: const _ProductHeaderPersonalScores(),
              ),
            ],
          ),
        ),
        Semantics(
          sortKey: const OrdinalSortKey(4.0),
          child: const _ProductHeaderButtonsBar(),
        ),
      ],
    );
  }
}

class _ProductHeaderInfo extends StatelessWidget {
  const _ProductHeaderInfo();

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          product.productName ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        Text(
          product.brands ?? '',
          style: const TextStyle(fontSize: 16.5),
        ),
        Text(
          product.quantity ?? '',
          style: const TextStyle(fontSize: 16.5),
        ),
      ],
    );
  }
}

class _ProductHeaderScores extends StatelessWidget {
  const _ProductHeaderScores({
    required this.onNutriScoreClicked,
    required this.onEcoScoreClicked,
  });

  final VoidCallback? onNutriScoreClicked;
  final VoidCallback? onEcoScoreClicked;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            InkWell(
              onTap: onNutriScoreClicked,
              child: SvgPicture.asset(
                'assets/images/nutriscore-a.svg',
                alignment: AlignmentDirectional.topCenter,
                width: constraints.maxWidth,
              ),
            ),
            const SizedBox(height: 10.0),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onEcoScoreClicked,
                child: Material(
                  type: MaterialType.transparency,
                  child: SvgPicture.asset(
                    'assets/images/ecoscore-a.svg',
                    alignment: AlignmentDirectional.topCenter,
                    width: constraints.maxWidth,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductHeaderPersonalScores extends StatelessWidget {
  const _ProductHeaderPersonalScores();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListItem.text(
          'Pas de moutarde',
          padding: const EdgeInsets.only(top: 10.0),
          leading: const ListItemLeadingScore.high(),
        ),
        ListItem.text(
          'Aliment ultra-transformé (NOVA 4)',
          padding: const EdgeInsets.only(top: 10.0),
          leading: const ListItemLeadingScore.low(),
        ),
      ],
    );
  }
}

class _ProductHeaderButtonsBar extends StatelessWidget {
  const _ProductHeaderButtonsBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: OutlinedButtonTheme(
        data: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            side: const BorderSide(color: AppColors.grey),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 19.0,
              vertical: 14.0,
            ),
          ),
        ),
        child: ListView(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20.0),
          scrollDirection: Axis.horizontal,
          children: [
            _ProductHeaderFilledButton(
              label: 'Comparer',
              icon: const icons.Compare(),
              onTap: () {},
            ),
            const SizedBox(width: 10.0),
            _ProductHeaderOutlinedButton(
              label: 'Ajouter à une liste',
              icon: const icons.AddToList(),
              onTap: () {},
            ),
            const SizedBox(width: 10.0),
            _ProductHeaderOutlinedButton(
              label: 'Modifier',
              icon: const icons.Edit(),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeaderFilledButton extends StatelessWidget {
  const _ProductHeaderFilledButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final icons.AppIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.orange,
        side: BorderSide.none,
      ),
      child: Row(
        children: [
          IconTheme(
            data: const IconThemeData(
              color: AppColors.white,
              size: 18.0,
            ),
            child: icon,
          ),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductHeaderOutlinedButton extends StatelessWidget {
  const _ProductHeaderOutlinedButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final icons.AppIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.orange,
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
          IconTheme(
            data: const IconThemeData(
              color: AppColors.orange,
              size: 18.0,
            ),
            child: icon,
          ),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
