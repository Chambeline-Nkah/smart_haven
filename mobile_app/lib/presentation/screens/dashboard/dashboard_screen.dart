// lib/presentation/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smart_haven/core/theme/theme.provider.dart';
import 'package:smart_haven/extensions/string_extension.dart';
import 'package:smart_haven/presentation/screens/dashboard/widgets/audio_stream_widget.dart';
import 'package:smart_haven/presentation/screens/dashboard/widgets/gauge_widget.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../navigation/app_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  String _poultryState = 'Loading...';
  double _temperature = 0;
  double _humidity = 0;
  bool _isLoading = true;
  String _error = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _apiService.ensureAuthenticated();
    try {
      setState(() => _isLoading = true);

      // Fetch poultry state
      Map<String, dynamic> stateData;
      Map<String, dynamic> sensorData;

      try {
        stateData = await _apiService.getPoultryState();
      } catch (e) {
        stateData = {'state': 'Unknown'};
      }

      try {
        sensorData = await _apiService.getSensorData();
      } catch (e) {
        // Provide a fallback structure matching the expected nesting
        sensorData = {
          'data': {'temperature': 0, 'humidity': 0}
        };
      }

      setState(() {
        // Extract poultry state:
        final poultryValue = stateData['state'];
        if (poultryValue is Map<String, dynamic>) {
          _poultryState =
              (poultryValue['state']?.toString() ?? 'Unknown').capitalize;
        } else {
          _poultryState = (poultryValue?.toString() ?? 'Unknown').capitalize;
        }

        // Extract sensor data (from the nested "data" field):
        final sensorDetails = sensorData['data'];
        if (sensorDetails is Map<String, dynamic>) {
          _temperature = sensorDetails['temperature']?.toDouble() ?? 0;
          _humidity = sensorDetails['humidity']?.toDouble() ?? 0;
        } else {
          _temperature = 0;
          _humidity = 0;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'distress':
        return AppTheme.primaryColor;
      case 'sick':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background first in stack
              _buildBackground(themeProvider.isDarkMode),

              // Main content
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SafeArea(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(themeProvider),
                                const SizedBox(height: 24),
                                _buildPoultryState(),
                                const SizedBox(height: 24),
                                _buildSensorData(),
                                const SizedBox(height: 24),
                                _buildLiveFeed(),
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

  // Replace _buildBackground in all screens (Dashboard, Record, History)
  Widget _buildBackground(bool isDark) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final systemIsDark = brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        SizedBox.expand(
          // Ensure background fills entire space
          child: Image.asset(
            systemIsDark
                ? 'lib/assets/images/bg_dark_mode.png'
                : 'lib/assets/images/bg_light_mode.png',
            fit: BoxFit.cover,
          ),
        ),
        // Color overlay
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
              'Dashboard', // or 'Record' or 'History'
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'Monitor your poultry', // Change subtitle based on screen
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w100,
                    // color: themeProvider.isDarkMode
                    //     ? Colors.white70
                    //     : Colors.black54,
                  ),
            ),
          ],
        ),
        // Top decoration - positioned behind the theme toggle
        Positioned(
          top: -20, // Adjust based on your needs
          right: 0,
          width: size.width * 0.3,
          child: Image.asset(
            'lib/assets/images/top_onboard.png',
            fit: BoxFit.contain,
          ),
        ),
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

  Widget _buildPoultryState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Poultry State',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (_poultryState == 'Loading...' || _poultryState == 'Unknown')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'No poultry state available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          )
        else
          Text(
            _poultryState,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: _getStateColor(_poultryState),
                  fontWeight: FontWeight.bold,
                ),
          ),
      ],
    );
  }

  Widget _buildSensorData() {
    final bool noSensorData = _temperature == 0 && _humidity == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sensor Data',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        if (noSensorData)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.sensors_off, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'No sensor data available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Refresh Data'),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: SensorGauge(
                  title: 'Temperature',
                  value: _temperature,
                  unit: '°C',
                  icon: Icons.thermostat,
                  type: SensorType.temperature,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SensorGauge(
                  title: 'Humidity',
                  value: _humidity,
                  unit: '%',
                  icon: Icons.water_drop,
                  type: SensorType.humidity,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLiveFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Feed',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        StreamBuilder<bool>(
          stream: _apiService.getAudioStreamStatus(),
          builder: (context, snapshot) {
            if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.mic_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Audio stream unavailable',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Add method to restart audio stream
                      },
                      child: const Text('Reconnect'),
                    ),
                  ],
                ),
              );
            }
            return const LiveFeedSpectrogram();
          },
        ),
      ],
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
