import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/research_controller.dart';
import 'dashboard_screen.dart';
import 'search_screen.dart';
import 'trend_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _selectedIndex = 0;

  final _searchScrollController = ScrollController();
  final _trendsScrollController = ScrollController();
  final _dashboardScrollController = ScrollController();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      SearchScreen(scrollController: _searchScrollController),
      TrendAnalysisScreen(scrollController: _trendsScrollController),
      DashboardScreen(scrollController: _dashboardScrollController),
    ];
  }

  @override
  void dispose() {
    _searchScrollController.dispose();
    _trendsScrollController.dispose();
    _dashboardScrollController.dispose();
    super.dispose();
  }

  void _scrollToTop(int index) {
    ScrollController? controller;
    if (index == 0) controller = _searchScrollController;
    if (index == 1) controller = _trendsScrollController;
    if (index == 2) controller = _dashboardScrollController;

    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResearchController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.query_stats_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Journal Trend Analyzer',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (controller.hasAnalysis)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: controller.isLoading ? null : controller.refresh,
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: NavigationBar(
              height: 65,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: _selectedIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
              onDestinationSelected: (index) {
                if (index == _selectedIndex) {
                  _scrollToTop(index);
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.stacked_line_chart_outlined),
                  selectedIcon: Icon(Icons.stacked_line_chart),
                  label: 'Trends',
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
