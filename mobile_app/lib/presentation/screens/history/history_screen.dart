// lib/presentation/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_haven/core/theme/theme.provider.dart';
import 'package:smart_haven/core/utils/connectivity_handler.dart';
import 'package:smart_haven/presentation/navigation/app_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _historyItems = [];
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.record);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.history);
        break;
    }
  }

  Future<void> _loadHistoryData() async {
  setState(() => _isLoading = true);

  // Check connectivity first
  final connectivityResult = await ConnectivityHandler.checkConnectivity(context);
  if (!connectivityResult) {
    setState(() {
      _error = 'No internet connection';
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.signal_wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text('No internet connection'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return;
  }

  try {
    final items = await _apiService.getHistoryData();
    print(items);
    if (mounted) {
      setState(() {
        _historyItems = items;
        _isLoading = false;
        _error = null;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _error = 'Failed to load history data';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadHistoryData,
          ),
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(isDark),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(themeProvider),
                      const Spacer(), // Add this
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else if (_error != null)
                        _buildError()
                      else if (_historyItems.isEmpty)
                        _buildEmptyState()
                      else
                        _buildHistoryList(),
                      const Spacer(), // Add this
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildNavigationBar(),
        );
      },
    );
  }

  Widget _buildBackground(bool isDark) {
    final size = MediaQuery.of(context).size;
     final brightness = MediaQuery.platformBrightnessOf(context);
    final systemIsDark = brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        SizedBox.expand(
          child: Image.asset(
            systemIsDark
                ? 'lib/assets/images/bg_dark_mode.png'
                : 'lib/assets/images/bg_light_mode.png',
            fit: BoxFit.cover,
          ),
        ),
        // Top decoration
        Positioned(
          top: 0,
          right: 0,
          width: size.width * 0.3,
          child: Image.asset(
            'lib/assets/images/top_onboard.png',
            fit: BoxFit.contain,
          ),
        ),
        // Gradient overlay
        // Container(
        //   decoration: BoxDecoration(
        //     // gradient: LinearGradient(
        //     //   begin: Alignment.topCenter,
        //     //   end: Alignment.bottomCenter,
        //     //   colors: [
        //     //     Colors.transparent,
        //     //     isDark ? Colors.black54 : Colors.white70,
        //     //   ],
        //     // ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset(
                     ThemeProvider().isDarkMode
                        ? 'lib/assets/images/logo_dark.png'
                        : 'lib/assets/images/logo_light.png',
                      height: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SmartHaven',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              // Change this based on screen
              'History', // or 'Record' or 'History'
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'Find all your past suggestions here', // Change subtitle based on screen
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        // Top decoration - positioned behind the theme toggle
        // Positioned(
        //   top: -20, // Adjust based on your needs
        //   right: 0,
        //   width: size.width * 0.3,
        //   child: Image.asset(
        //     'lib/assets/images/top_onboard.png',
        //     fit: BoxFit.contain,
        //   ),
        // ),
        // Theme toggle - positioned on top
        // Positioned(
        //   top: size.height * 0.1, // Adjust based on your needs
        //   right: 16,
        //   child: IconButton(
        //     icon: Icon(
        //       themeProvider.isDarkMode
        //           ? Icons.wb_sunny
        //           : Icons.nightlight_round,
        //     ),
        //     onPressed: themeProvider.toggleTheme,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading history',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHistoryData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No History Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your activity history will appear here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _historyItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _historyItems[index];
        return _HistoryAccordion(
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          timestamp: DateTime.parse(item['timestamp'] ?? ''),
          isDark: ThemeProvider().isDarkMode,
        );
      },
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard, 'Dashboard'),
              _buildNavItem(1, Icons.mic, 'Record'),
              _buildNavItem(2, Icons.history, 'History'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryAccordion extends StatefulWidget {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isDark;

  const _HistoryAccordion({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isDark,
  });

  @override
  State<_HistoryAccordion> createState() => _HistoryAccordionState();
}

class _HistoryAccordionState extends State<_HistoryAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isDark ? Colors.white : Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: widget.isDark ? Colors.white : Colors.black,
                        ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${widget.timestamp.toString()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.isDark ? Colors.white70 : Colors.black54,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
