import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show ImageFilter;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../widgets/floating_nav_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../theme/app_theme.dart';
import '../models/profile.dart';
import '../widgets/partner_preferences_sheet.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/profile_details_sheet.dart';
import 'my_profile_screen.dart';
import 'chat_screen.dart';
import 'notifications_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/storage_helper.dart';
import '../widgets/profile_completion_ring.dart';
import '../widgets/global_completion_overlay.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  // Controllers
  final ScrollController _dailyPicksController = ScrollController();
  final ScrollController _searchResultsController = ScrollController();
  final TextEditingController _excludeNukhController = TextEditingController();
  final TextEditingController _homeSearchController = TextEditingController();
  final TextEditingController _customCityController = TextEditingController();

  // Search filter states
  RangeValues _ageRange = const RangeValues(22, 35);
  RangeValues _heightRange = const RangeValues(5.0, 6.2);
  final List<String> _selectedCities = [];
  String? _selectedProfession;
  String? _selectedIncome;
  String? _selectedMaritalStatus;
  final List<String> _selectedEducation = [];
  String? _manglikStatus;
  bool _showSearchResults = false;

  // Home search filter states
  double _homeMaxAge = 50.0;
  String? _homeSelectedState;

  Map<String, dynamic> _getResponsiveLayout() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    int crossAxisCount = 1;
    double maxContainerWidth = 600;
    if (screenWidth >= 1100) {
      crossAxisCount = 3;
      maxContainerWidth = 1000;
    } else if (screenWidth >= 700) {
      crossAxisCount = 2;
      maxContainerWidth = 850;
    }
    return {
      'crossAxisCount': crossAxisCount,
      'maxContainerWidth': maxContainerWidth,
    };
  }

  // Filter options
  final List<String> _cities = ["All", "Mumbai", "Pune", "Bangalore", "Ahmedabad", "Jaipur", "Delhi NCR", "Other"];
  final List<String> _professions = ["All", "Corporate Job", "Business", "Professional", "Not Working"];
  final List<String> _incomes = ["All", "Under 5 Lakh", "5-10 Lakhs", "10-20 Lakhs", "20+ Lakhs"];
  final List<String> _maritalStatuses = ["All", "Never Married", "Divorced", "Widowed", "Awaiting Divorce"];
  final List<String> _educations = ["All", "Bachelors", "Masters", "Doctorate", "Diploma", "High School"];
  final List<String> _manglikOptions = ["All", "Yes", "No", "Anshik (Partial)"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dailyPicksController.addListener(_onDailyPicksScroll);
    _searchResultsController.addListener(_onSearchResultsScroll);
    _homeSearchController.addListener(_triggerHomeFilterChange);

    // Initial load of daily picks and incoming requests
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      if (provider.dailyPicks.isEmpty) {
        provider.fetchDailyPicks(refresh: true, filters: _getHomeFilters());
      }
      provider.fetchIncomingInterests();
      provider.fetchConversations();
      // Check for app updates (fetches config then shows dialog if needed)
      provider.fetchAppConfig().then((_) {
        if (mounted) _checkForUpdate(provider);
      });

      _checkAndShowPartnerPreferences();
    });
  }

  Future<void> _checkAndShowPartnerPreferences() async {
    final hasSeen = await AppStorage.get('has_seen_partner_prefs');
    if (hasSeen != 'true') {
      await AppStorage.save('has_seen_partner_prefs', 'true');
      if (mounted) {
        _showPartnerPreferencesSheet();
      }
    }
  }

  void _showPartnerPreferencesSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PartnerPreferencesSheet(),
    );
    
    if (result == true) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      provider.fetchDailyPicks(refresh: true, filters: _getHomeFilters());
    }
  }

  void _checkForUpdate(AuthProvider provider) {
    if (!provider.updateAvailable) return;

    final isForced = provider.forceUpdateRequired;
    showDialog(
      context: context,
      barrierDismissible: !isForced,
      barrierColor: Colors.black.withValues(alpha: isForced ? 0.92 : 0.6),
      builder: (ctx) => PopScope(
        canPop: !isForced, // block back gesture/button if forced update
        child: AlertDialog(
          backgroundColor: AppTheme.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          icon: Icon(
            isForced ? Icons.system_update_alt_rounded : Icons.update_rounded,
            color: AppTheme.accentGold,
            size: 48,
          ),
          title: Text(
            isForced ? 'Update Required' : 'Update Available',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.textCarbon,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.updateMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Latest Version: ${provider.latestVersion}',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            if (!isForced)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Later',
                  style: GoogleFonts.montserrat(color: AppTheme.textMuted),
                ),
              ),
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.tryParse(provider.updateDownloadUrl);
                if (url != null && await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: Text(
                'Update Now',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      provider.fetchDailyPicks(refresh: true, filters: _getHomeFilters());
      provider.fetchIncomingInterests();
      provider.fetchMyProfile();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dailyPicksController.dispose();
    _searchResultsController.dispose();
    _excludeNukhController.dispose();
    _homeSearchController.dispose();
    _customCityController.dispose();
    super.dispose();
  }

  Map<String, String> _getHomeFilters() {
    final Map<String, String> filters = {};
    if (_homeSearchController.text.trim().isNotEmpty) {
      filters['search'] = _homeSearchController.text.trim();
    }
    if (_homeMaxAge < 50.0) {
      filters['max_age'] = _homeMaxAge.round().toString();
    }
    if (_homeSelectedState != null && _homeSelectedState!.isNotEmpty) {
      filters['city'] = _homeSelectedState!;
    }
    return filters;
  }

  void _triggerHomeFilterChange() {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    provider.fetchDailyPicks(refresh: true, filters: _getHomeFilters());
  }

  void _onDailyPicksScroll() {
    if (!_dailyPicksController.hasClients) return;
    if (_dailyPicksController.position.pixels >= _dailyPicksController.position.maxScrollExtent - 200) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      if (!provider.isLoadingDailyPicks && provider.hasMoreDailyPicks) {
        provider.fetchDailyPicks(
          offset: provider.dailyPicks.length,
          filters: _getHomeFilters(),
        );
      }
    }
  }

  void _onSearchResultsScroll() {
    if (!_searchResultsController.hasClients) return;
    if (_searchResultsController.position.pixels >= _searchResultsController.position.maxScrollExtent - 200) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      if (!provider.isLoadingSearch && provider.hasMoreSearch) {
        provider.searchProfiles(
          filters: _getActiveFilters(),
          offset: provider.searchResults.length,
        );
      }
    }
  }

  void _triggerSearch() {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    provider.searchProfiles(filters: _getActiveFilters(), refresh: true);
    setState(() {
      _showSearchResults = true;
    });
  }

  Map<String, String> _getActiveFilters() {
    final Map<String, String> filters = {
      'min_age': _ageRange.start.round().toString(),
      'max_age': _ageRange.end.round().toString(),
      'min_height': _heightRange.start.toStringAsFixed(1),
      'max_height': _heightRange.end.toStringAsFixed(1),
    };

    if (_selectedCities.isNotEmpty && !_selectedCities.contains("All")) {
      if (_selectedCities.contains("Other") && _customCityController.text.trim().isNotEmpty) {
        filters['city'] = _customCityController.text.trim();
      } else {
        final firstValidCity = _selectedCities.firstWhere((c) => c != "Other", orElse: () => _selectedCities.first);
        if (firstValidCity != "Other") {
          filters['city'] = firstValidCity;
        }
      }
    }

    if (_selectedProfession != null && _selectedProfession != "All") {
      filters['profession'] = _selectedProfession!;
    }

    if (_selectedIncome != null && _selectedIncome != "All") {
      filters['incomeBracket'] = _selectedIncome!;
    }

    if (_selectedMaritalStatus != null && _selectedMaritalStatus != "All") {
      filters['maritalStatus'] = _selectedMaritalStatus!;
    }

    if (_selectedEducation.isNotEmpty && !_selectedEducation.contains("All")) {
      filters['education'] = _selectedEducation.join(',');
    }

    if (_manglikStatus != null && _manglikStatus != "All") {
      filters['manglikStatus'] = _manglikStatus!;
    }

    if (_excludeNukhController.text.trim().isNotEmpty) {
      filters['exclude_nukh'] = _excludeNukhController.text.trim();
    }

    return filters;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;
        final bodyContent = IndexedStack(
          index: _currentIndex,
          children: [
            _buildDailyPicksTab(),
            _buildSearchTab(),
            _buildActivityTab(),
            _buildChatsTab(),
            const MyProfileScreen(),
          ],
        );

        if (isDesktop) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundLight,
            body: SafeArea(
              child: Row(
                children: [
                  _buildNavigationRail(),
                  const VerticalDivider(thickness: 1, width: 1, color: AppTheme.glassBorderColor),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: bodyContent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          body: Stack(
            children: [
              SafeArea(child: bodyContent),
              const GlobalCompletionOverlay(),
              FloatingNavBar(
                currentIndex: _currentIndex,
                onTap: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (index == 4) {
                    Provider.of<AuthProvider>(context, listen: false).fetchMyProfile();
                  } else if (index == 2) {
                    Provider.of<AuthProvider>(context, listen: false).fetchActivityData();
                  } else if (index == 3) {
                    Provider.of<AuthProvider>(context, listen: false).fetchConversations();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Premium Desktop/Tablet Vertical Navigation Rail
  Widget _buildNavigationRail() {
    final lang = Provider.of<LanguageProvider>(context);
    return NavigationRail(
      backgroundColor: AppTheme.cardWhite,
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _currentIndex = index;
        });
        if (index == 4) {
          Provider.of<AuthProvider>(context, listen: false).fetchMyProfile();
        } else if (index == 2) {
          Provider.of<AuthProvider>(context, listen: false).fetchActivityData();
        } else if (index == 3) {
          Provider.of<AuthProvider>(context, listen: false).fetchConversations();
        }
      },
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: GoogleFonts.cinzel(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelTextStyle: GoogleFonts.cinzel(color: AppTheme.textMuted, fontSize: 11),
      selectedIconTheme: const IconThemeData(color: AppTheme.accentGold, size: 28),
      unselectedIconTheme: const IconThemeData(color: AppTheme.textMuted, size: 24),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.auto_awesome_outlined),
          selectedIcon: const Icon(Icons.auto_awesome),
          label: Text(lang.translate('daily_picks')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.search_rounded),
          selectedIcon: const Icon(Icons.search_rounded),
          label: Text(lang.translate('search')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.timeline_outlined),
          selectedIcon: const Icon(Icons.timeline),
          label: Text(lang.translate('shortlisted')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.forum_outlined),
          selectedIcon: const Icon(Icons.forum),
          label: Text(lang.translate('chat')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: Text(lang.translate('my_profile')),
        ),
      ],
    );
  }

  // Premium Custom Bottom Navigation Bar

  // --- TAB 1: DAILY PICKS ---
  Widget _buildDailyPicksTab() {
    final provider = Provider.of<AuthProvider>(context);

    return Column(
      children: [
        _buildPremiumHeader(),
        _buildPremiumFiltersRow(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.fetchDailyPicks(refresh: true, filters: _getHomeFilters()),
            color: AppTheme.accentGold,
            backgroundColor: AppTheme.cardWhite,
            child: provider.dailyPicks.isEmpty && provider.isLoadingDailyPicks
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                : provider.dailyPicks.isEmpty
                    ? _buildEmptyState("No recommendations for today yet.", onRetry: () {
                        provider.fetchDailyPicks(refresh: true);
                      })
                    : Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _getResponsiveLayout()['maxContainerWidth'],
                          ),
                          child: CustomScrollView(
                            controller: _dailyPicksController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              if (provider.dailyPicks.any((p) => p.isFallback))
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGold.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: AppTheme.accentGold, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Showing profiles outside your strict preferences as we found fewer matches.',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                color: AppTheme.textCarbon,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                sliver: SliverMasonryGrid.count(
                                  crossAxisCount: _getResponsiveLayout()['crossAxisCount'],
                                  mainAxisSpacing: 24.0,
                                  crossAxisSpacing: 24.0,
                                  childCount: provider.dailyPicks.length,
                                  itemBuilder: (context, index) {
                                    final profile = provider.dailyPicks[index];
                                    return ProfileBentoCard(profile: profile);
                                  },
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: provider.isLoadingDailyPicks
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 24.0),
                                        child: Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
                                      )
                                    : const SizedBox(height: 80),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumHeader() {
    final provider = Provider.of<AuthProvider>(context);
    final profile = provider.myProfile;
    final photoUrl = profile != null && profile['photos'] != null && (profile['photos'] as List).isNotEmpty 
        ? (profile['photos'] as List).first 
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        border: Border(bottom: BorderSide(color: AppTheme.glassBorderColor, width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo as Drawer trigger
            GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer(); // assuming drawer exists
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset('assets/logo.png', height: 44, width: 44, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PB Matches',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textCarbon,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showPartnerPreferencesSheet,
                    child: Row(
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            'as per partner preferences ',
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 12, color: AppTheme.accentGold),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded, color: AppTheme.textCarbon, size: 28),
                  if (provider.hasUnreadNotifications)
                    Positioned(
                      top: 2,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        child: const SizedBox(width: 6, height: 6), // Simple red dot
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppTheme.textCarbon, size: 28),
              onPressed: () {
                setState(() => _currentIndex = 1);
              },
            ),
            const SizedBox(width: 70), // Reserve space for the GlobalCompletionOverlay
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFiltersRow() {
    return Container(
      width: double.infinity,
      color: AppTheme.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showFiltersBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.glassBorderColor, width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune_rounded, size: 16, color: AppTheme.textCarbon),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textCarbon),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textCarbon),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Maximum Age: ${_homeMaxAge.round()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Slider(
                    value: _homeMaxAge,
                    min: 18.0,
                    max: 50.0,
                    activeColor: AppTheme.accentGold,
                    inactiveColor: AppTheme.glassBorderColor,
                    onChanged: (val) {
                      setModalState(() {
                        _homeMaxAge = val;
                      });
                      setState(() {
                        _homeMaxAge = val;
                      });
                    },
                    onChangeEnd: (_) => _triggerHomeFilterChange(),
                  ),
                  const SizedBox(height: 16),
                  const Text('City', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _homeSelectedState,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    hint: const Text('All Locations'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Locations'),
                      ),
                      ..._cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        _homeSelectedState = val;
                      });
                      setState(() {
                        _homeSelectedState = val;
                      });
                      _triggerHomeFilterChange();
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 2: SEARCH ENGINE ---
  Widget _buildFilterSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSearchTab() {
    final provider = Provider.of<AuthProvider>(context);

    if (_showSearchResults) {
      return Column(
        children: [
          _buildHeader(
            title: "SEARCH RESULTS",
            subtitle: "FOUND ${provider.searchCount} ELITE PROFILES",
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textCarbon, size: 18),
              onPressed: () {
                setState(() {
                  _showSearchResults = false;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.searchProfiles(filters: _getActiveFilters(), refresh: true),
              color: AppTheme.accentGold,
              backgroundColor: AppTheme.cardWhite,
              child: provider.searchResults.isEmpty && provider.isLoadingSearch
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                  : provider.searchResults.isEmpty
                      ? _buildEmptyState("No profiles match these filters.", onRetry: () {
                          setState(() {
                            _showSearchResults = false;
                          });
                        }, buttonText: "Modify Filters")
                      : Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: _getResponsiveLayout()['maxContainerWidth'],
                            ),
                            child: CustomScrollView(
                              controller: _searchResultsController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                  sliver: SliverPadding(
                                    padding: EdgeInsets.zero,
                                    sliver: SliverMasonryGrid.count(
                                      crossAxisCount: _getResponsiveLayout()['crossAxisCount'],
                                      mainAxisSpacing: 24.0,
                                      crossAxisSpacing: 24.0,
                                      childCount: provider.searchResults.length,
                                      itemBuilder: (context, index) {
                                        final profile = provider.searchResults[index];
                                        return ProfileBentoCard(profile: profile);
                                      },
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: provider.isLoadingSearch
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 24.0),
                                          child: Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
                                        )
                                      : const SizedBox(height: 80),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildHeader(title: "SEARCH ENGINE", subtitle: "DEFINE YOUR IDEAL MATCH"),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _getResponsiveLayout()['maxContainerWidth']),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Age Slider
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Age Range", "${_ageRange.start.round()} - ${_ageRange.end.round()} Years"),
                          RangeSlider(
                            values: _ageRange,
                            min: 18,
                            max: 60,
                            divisions: 42,
                            activeColor: AppTheme.accentGold,
                            inactiveColor: AppTheme.glassBorderColor,
                            labels: RangeLabels(
                              '${_ageRange.start.round()} yrs',
                              '${_ageRange.end.round()} yrs',
                            ),
                            onChanged: (values) {
                              setState(() {
                                _ageRange = values;
                              });
                            },
                            onChangeEnd: (values) {
                              // Search trigger removed to wait for CTA button press
                            },
                          ),
                        ],
                      ),
                    ),

                    // Height Slider
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Height Range", "${_heightRange.start.toStringAsFixed(1)}' - ${_heightRange.end.toStringAsFixed(1)}' Feet"),
                          RangeSlider(
                            values: _heightRange,
                            min: 4.5,
                            max: 6.5,
                            divisions: 20,
                            activeColor: AppTheme.accentGold,
                            inactiveColor: AppTheme.glassBorderColor,
                            labels: RangeLabels(
                              "${_heightRange.start.toStringAsFixed(1)}'",
                              "${_heightRange.end.toStringAsFixed(1)}'",
                            ),
                            onChanged: (values) {
                              setState(() {
                                _heightRange = values;
                              });
                            },
                            onChangeEnd: (values) {
                              // Search trigger removed to wait for CTA button press
                            },
                          ),
                        ],
                      ),
                    ),

                    // Cities Bubbles
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Preferred Location", "${_selectedCities.length} Selected"),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _cities.map((city) {
                              final bool isSelected = _selectedCities.contains(city);
                              return FilterChip(
                                label: Text(city),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      if (city == "All") {
                                        _selectedCities.clear();
                                        _selectedCities.add("All");
                                      } else {
                                        _selectedCities.remove("All");
                                        _selectedCities.add(city);
                                      }
                                    } else {
                                      _selectedCities.remove(city);
                                    }
                                  });
                                },
                                selectedColor: AppTheme.accentGold.withValues(alpha: 0.15),
                                checkmarkColor: AppTheme.accentGold,
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.accentGold : AppTheme.textCarbon,
                                ),
                                backgroundColor: AppTheme.cardWhite,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.accentGold : AppTheme.glassBorderColor,
                                  width: 0.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              );
                            }).toList(),
                          ),
                          if (_selectedCities.contains("Other")) ...[
                            const SizedBox(height: 16.0),
                            TextField(
                              controller: _customCityController,
                              onChanged: (val) {
                                // Search trigger removed to wait for CTA button press
                              },
                              decoration: InputDecoration(
                                labelText: "Specify Other Location",
                                labelStyle: GoogleFonts.montserrat(color: AppTheme.accentGold, fontSize: 13, fontWeight: FontWeight.w500),
                                hintText: "e.g., London, New York, Kolkata",
                                hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13),
                                filled: true,
                                fillColor: AppTheme.backgroundLight,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: const BorderSide(color: AppTheme.accentGold, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
                                ),
                              ),
                              style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Profession Pills
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Profession Sector", _selectedProfession ?? "Any"),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _professions.map((prof) {
                              final bool isSelected = _selectedProfession == prof;
                              return ChoiceChip(
                                label: Text(prof),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedProfession = selected ? prof : null;
                                  });
                                },
                                selectedColor: AppTheme.accentGold.withValues(alpha: 0.15),
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.accentGold : AppTheme.textCarbon,
                                ),
                                backgroundColor: AppTheme.cardWhite,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.accentGold : AppTheme.glassBorderColor,
                                  width: 0.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Income Pills
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Income Bracket", _selectedIncome ?? "Any"),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _incomes.map((inc) {
                              final bool isSelected = _selectedIncome == inc;
                              return ChoiceChip(
                                label: Text(inc),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedIncome = selected ? inc : null;
                                  });
                                },
                                selectedColor: AppTheme.accentGold.withValues(alpha: 0.15),
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.accentGold : AppTheme.textCarbon,
                                ),
                                backgroundColor: AppTheme.cardWhite,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.accentGold : AppTheme.glassBorderColor,
                                  width: 0.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Exclude Clan
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Exclude Clan / Nukh", "Prevents incest match rules"),
                          TextField(
                            controller: _excludeNukhController,
                            onChanged: (val) {
                              // Search trigger removed to wait for CTA button press
                            },
                            decoration: InputDecoration(
                              hintText: "Enter surname/nukh to exclude",
                              hintStyle: GoogleFonts.montserrat(color: AppTheme.textMuted, fontSize: 13),
                              filled: true,
                              fillColor: AppTheme.backgroundLight,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: AppTheme.accentGold, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
                              ),
                            ),
                            style: GoogleFonts.montserrat(color: AppTheme.textCarbon, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    // Marital Status Pills
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Marital Status", _selectedMaritalStatus ?? "Any"),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _maritalStatuses.map((status) {
                              final bool isSelected = _selectedMaritalStatus == status;
                              return ChoiceChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedMaritalStatus = selected ? status : null;
                                  });
                                },
                                selectedColor: AppTheme.accentGold.withValues(alpha: 0.15),
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.accentGold : AppTheme.textCarbon,
                                ),
                                backgroundColor: AppTheme.cardWhite,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.accentGold : AppTheme.glassBorderColor,
                                  width: 0.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Education Level Pills
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Education Level", "${_selectedEducation.length} Selected"),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _educations.map((edu) {
                              final bool isSelected = _selectedEducation.contains(edu);
                              return FilterChip(
                                label: Text(edu),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      if (edu == "All") {
                                        _selectedEducation.clear();
                                        _selectedEducation.add("All");
                                      } else {
                                        _selectedEducation.remove("All");
                                        _selectedEducation.add(edu);
                                      }
                                    } else {
                                      _selectedEducation.remove(edu);
                                    }
                                  });
                                },
                                selectedColor: AppTheme.accentGold.withValues(alpha: 0.15),
                                checkmarkColor: AppTheme.accentGold,
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.accentGold : AppTheme.textCarbon,
                                ),
                                backgroundColor: AppTheme.cardWhite,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.accentGold : AppTheme.glassBorderColor,
                                  width: 0.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Manglik Status Pills
                    _buildFilterSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Manglik Status", _manglikStatus ?? "Any"),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _manglikOptions.map((status) {
                              final bool isSelected = _manglikStatus == status;
                              return ChoiceChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _manglikStatus = selected ? status : null;
                                  });
                                },
                                selectedColor: AppTheme.accentGold.withValues(alpha: 0.15),
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.accentGold : AppTheme.textCarbon,
                                ),
                                backgroundColor: AppTheme.cardWhite,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.accentGold : AppTheme.glassBorderColor,
                                  width: 0.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // Search CTA
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppTheme.premiumGoldGradient,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGold.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _triggerSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: Text(
                          'SEARCH CURATED POOL',
                          style: GoogleFonts.cinzel(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 3: SHORTLIST ---
  Widget _buildActivityTab() {
    final provider = Provider.of<AuthProvider>(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Activity Header with user avatar and notification bell
          Container(
            color: AppTheme.cardWhite,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              children: [
                // User Avatar
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.premiumGoldGradient,
                  ),
                  child: Center(
                    child: Text(
                      (provider.myProfile != null && provider.myProfile!['firstName'] != null && provider.myProfile!['firstName'].toString().isNotEmpty)
                          ? provider.myProfile!['firstName'].toString()[0].toUpperCase()
                          : 'P',
                      style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Activity',
                  style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textCarbon),
                ),
                const Spacer(),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppTheme.textCarbon),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                      },
                    ),
                    if (provider.hasUnreadNotifications)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Stats Cards Row
          Container(
            color: AppTheme.cardWhite,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildActivityStatCard(
                  count: provider.profileVisitsList.length > 0 ? provider.profileVisitsList.length.toString() : provider.profileVisits.toString(),
                  label: 'Profile\nVisits',
                  color: Colors.green,
                  onTap: () => _showProfileListDialog(context, 'Profile Visits', provider.profileVisitsList),
                ),
                const SizedBox(width: 10),
                _buildActivityStatCard(
                  count: provider.shortlistedProfiles.length.toString(),
                  label: 'Shortlisted\nProfiles',
                  color: Colors.red,
                  onTap: () => _showProfileListDialog(context, 'Shortlisted Profiles', provider.shortlistedProfiles),
                ),
                const SizedBox(width: 10),
                _buildActivityStatCard(
                  count: provider.contactViewsList.length > 0 ? provider.contactViewsList.length.toString() : provider.contactViews.toString(),
                  label: 'Contact\nViews',
                  color: Colors.blue,
                  onTap: () => _showProfileListDialog(context, 'Contact Views', provider.contactViewsList),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.glassBorderColor),
          // Interests Header
          Container(
            color: AppTheme.cardWhite,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Requests',
                  style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textCarbon),
                ),
                TextButton(
                  onPressed: () {
                    provider.fetchIncomingInterests();
                  },
                  child: Text('View all', style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),
          // Tab bar for Received / Accepted / Sent
          Container(
            color: AppTheme.cardWhite,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              indicatorColor: AppTheme.accentGold,
              indicatorWeight: 2,
              labelColor: AppTheme.textCarbon,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Received'),
                Tab(text: 'Accepted'),
                Tab(text: 'Sent'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              children: [
                // Received Tab
                RefreshIndicator(
                  onRefresh: () => provider.fetchIncomingInterests(),
                  color: AppTheme.accentGold,
                  backgroundColor: AppTheme.cardWhite,
                  child: provider.incomingInterests.isEmpty && provider.isLoadingIncoming
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                      : provider.incomingInterests.isEmpty
                          ? _buildActivityEmptyState()
                          : Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: _getResponsiveLayout()['maxContainerWidth'],
                                ),
                                child: PageView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: provider.incomingInterests.length + (false ? 1 : 0),
                              onPageChanged: (index) {
                                if (index == provider.incomingInterests.length - 1) {
                                  // Trigger load more here if needed
                                }
                              },
                              itemBuilder: (context, index) {
                                if (index == provider.incomingInterests.length) {
                                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
                                }
                                final profile = provider.incomingInterests[index];
                                return ProfileBentoCard(profile: profile);
                              },
                            ),
                              ),
                            ),
                ),
                // Accepted Tab
                provider.acceptedInterests.isEmpty
                    ? _buildActivityEmptyState()
                    : Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _getResponsiveLayout()['maxContainerWidth'],
                          ),
                          child: PageView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: provider.acceptedInterests.length + (false ? 1 : 0),
                              onPageChanged: (index) {
                                if (index == provider.acceptedInterests.length - 1) {
                                  // Trigger load more here if needed
                                }
                              },
                              itemBuilder: (context, index) {
                                if (index == provider.acceptedInterests.length) {
                                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
                                }
                                final profile = provider.acceptedInterests[index];
                                return ProfileBentoCard(profile: profile);
                              },
                            ),
                        ),
                      ),
                // Sent Tab
                provider.sentInterests.isEmpty
                    ? _buildActivityEmptyState()
                    : Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _getResponsiveLayout()['maxContainerWidth'],
                          ),
                          child: PageView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: provider.sentInterests.length + (false ? 1 : 0),
                              onPageChanged: (index) {
                                if (index == provider.sentInterests.length - 1) {
                                  // Trigger load more here if needed
                                }
                              },
                              itemBuilder: (context, index) {
                                if (index == provider.sentInterests.length) {
                                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
                                }
                                final profile = provider.sentInterests[index];
                                return ProfileBentoCard(profile: profile);
                              },
                            ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileListDialog(BuildContext context, String title, List<Profile> profiles) {
    if (profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No $title yet.')));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                return ProfileBentoCard(profile: profiles[index]);
              },
            ),
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            Positioned(
              top: 48,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStatCard({required String count, required String label, required Color color, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.glassBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AppTheme.textCarbon,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildActivityEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGold.withValues(alpha: 0.06),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 60, color: AppTheme.accentGold.withValues(alpha: 0.4)),
                  Positioned(
                    bottom: 25,
                    right: 25,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Receive requests with Spotlight!',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textCarbon,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Remain on top of the list and increase your chances of receiving more requests',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(
                'Tell me more',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // --- TAB 4: CHATS ---
  Widget _buildChatsTab() {
    final provider = Provider.of<AuthProvider>(context);

    return Column(
      children: [
        _buildHeader(title: "CHATS", subtitle: "YOUR ACTIVE CONVERSATIONS"),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.fetchConversations(),
            color: AppTheme.accentGold,
            backgroundColor: AppTheme.cardWhite,
            child: provider.conversations.isEmpty && provider.isLoadingConversations
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                : provider.conversations.isEmpty
                    ? _buildEmptyState(
                        "No active chats yet.\nConnect with matching profiles or send a message to start chatting.",
                        icon: Icons.forum_outlined,
                        onRetry: () => provider.fetchConversations(),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _getResponsiveLayout()['maxContainerWidth'],
                          ),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            itemCount: provider.conversations.length,
                            itemBuilder: (context, index) {
                              final chatProfile = provider.conversations[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                color: AppTheme.cardWhite,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: const BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
                                ),
                                elevation: 0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppTheme.accentGold.withValues(alpha: 0.1),
                                    child: Text(
                                      chatProfile.initials,
                                      style: GoogleFonts.cinzel(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    chatProfile.name,
                                    style: GoogleFonts.cinzel(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textCarbon,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "${chatProfile.age} Yrs • ${chatProfile.profession} • ${chatProfile.location.split(',')[0]}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.accentGold,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(profile: chatProfile),
                                      ),
                                    ).then((_) {
                                      provider.fetchConversations();
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  // --- REUSABLE UTILITIES ---
  Widget _buildHeader({required String title, required String subtitle, Widget? leading}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.glassBorderColor, width: 0.5),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: 8.0),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cinzel(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textCarbon,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentGold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Consumer<LanguageProvider>(
                builder: (context, langProvider, _) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.glassBorderColor, width: 0.5),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (langProvider.currentLanguage == 'en') {
                          langProvider.setLanguage('hi');
                        } else {
                          langProvider.setLanguage('en');
                        }
                      },
                      child: Text(
                        langProvider.currentLanguage == 'en' ? 'हिन्दी' : 'EN',
                        style: GoogleFonts.cinzel(
                          color: AppTheme.accentGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textCarbon,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, {IconData icon = Icons.info_outline_rounded, VoidCallback? onRetry, String buttonText = "Retry"}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textMuted.withValues(alpha: 0.5), size: 48),
            const SizedBox(height: 16.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: AppTheme.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20.0),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentGold, width: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.montserrat(
                    color: AppTheme.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _completionTip(Map<String, dynamic>? profile, String key, String label, IconData icon, int weight) {
    bool filled = false;
    if (profile != null) {
      final val = profile[key];
      if (key == 'uploadedPhotos') {
        filled = val is List && val.isNotEmpty && val[0] != null && val[0].toString().isNotEmpty;
      } else {
        filled = val != null && val.toString().trim().isNotEmpty;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            filled ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: filled ? Colors.green : Colors.grey.shade400,
            size: 18,
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 16, color: filled ? AppTheme.textMuted : AppTheme.textCarbon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: filled ? AppTheme.textMuted : AppTheme.textCarbon,
                fontWeight: filled ? FontWeight.normal : FontWeight.w600,
                decoration: filled ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            "+$weight%",
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: filled ? Colors.transparent : Colors.green,
            ),
          )
        ],
      ),
    );
  }
}

// Curated Bento Profile Card
class ProfileBentoCard extends StatefulWidget {
  final Profile profile;

  const ProfileBentoCard({super.key, required this.profile});

  @override
  State<ProfileBentoCard> createState() => _ProfileBentoCardState();
}

class _ProfileBentoCardState extends State<ProfileBentoCard> {
  int _currentPhotoIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showBlockDialog(BuildContext context, Profile profile) {
    String selectedReason = 'Not Interested';
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Block ${profile.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to block ${profile.name}? They will no longer be able to see you or contact you.', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 16),
                  const Text('Reason:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    items: ['Not Interested', 'Harassment', 'Spam', 'Fake Profile', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedReason = val!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Details (Optional):'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Provide more info...'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final provider = Provider.of<AuthProvider>(context, listen: false);
                  final success = await provider.blockUser(profile.phone, selectedReason, detailsController.text);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${profile.name} blocked.')));
                    provider.fetchDailyPicks(refresh: true); // Refresh feed
                  }
                },
                child: const Text('Block', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showReportDialog(BuildContext context, Profile profile) {
    String selectedReason = 'Inappropriate Content';
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Report ${profile.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reason:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    items: ['Inappropriate Content', 'Fake Profile', 'Spam', 'Harassment', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedReason = val!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Details (Optional):'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Provide more info...'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final provider = Provider.of<AuthProvider>(context, listen: false);
                  final success = await provider.reportUser(profile.phone, selectedReason, detailsController.text);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${profile.name} reported. Thank you.')));
                  }
                },
                child: const Text('Report', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);
    final profile = widget.profile;
    final bool isShortlisted = provider.shortlistedIds.contains(profile.id);

    // Calculate a height that perfectly fits the screen without scrolling
    // Account for header (~80), filters (~60), bottom nav (~80) = ~220px total vertical space used
    final double cardHeight = MediaQuery.of(context).size.height - 220;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: cardHeight > 400 ? cardHeight : 400,
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Stack(
            children: [
              // Photo PageView
              PageView.builder(
                controller: _pageController,
                itemCount: profile.photos.isEmpty ? 1 : profile.photos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPhotoIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final bool hasPhotos = profile.photos.isNotEmpty;
                  final String photo = hasPhotos ? profile.photos[index] : '';
                  final bool hasImage = hasPhotos && (photo.startsWith('http') || photo.startsWith('data:image/'));

                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          profile.gradientColors[0].withValues(alpha: 0.8),
                          profile.gradientColors[profile.gradientColors.length > 1 ? 1 : 0].withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: hasImage
                        ? (photo.startsWith('data:image/')
                            ? (() {
                                try {
                                  final String base64Data = photo.split(',')[1];
                                  final Uint8List imageBytes = base64Decode(base64Data);
                                  return Image.memory(imageBytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
                                } catch (_) {
                                  return const Icon(Icons.broken_image, color: Colors.white);
                                }
                              })()
                            : Image.network(photo, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, color: Colors.white)))
                        : Center(
                            child: Container(
                              height: 72,
                              width: 72,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                profile.initials,
                                style: GoogleFonts.cinzel(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textCarbon,
                                ),
                              ),
                            ),
                          ),
                  );
                },
              ),

              // Image count badge (Top Right)
              if (profile.photos.isNotEmpty)
                Positioned(
                  top: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.photos.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Report button (Top Left)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.flag_rounded, color: Colors.white70),
                  onPressed: () => _showReportDialog(context, profile),
                ),
              ),

              // Bottom Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7), Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Info
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Active Today',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                if (profile.isSeriousSeeker) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.white, size: 10),
                                        const SizedBox(width: 2),
                                        Text(
                                          'SERIOUS SEEKER',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.name}, ${profile.age}',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.height} • ${profile.location.split(',')[0]} • ${profile.caste}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${profile.profession} • No Income',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      
                      // Managed By strip
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        color: Colors.white.withValues(alpha: 0.15),
                        child: const Text(
                          'Profile managed by Self',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),

                      // Action Bar (Black background)
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Builder(
                              builder: (context) {
                                final status = profile.interestStatus;
                                IconData reqIcon = Icons.favorite_border_rounded;
                                Color reqColor = Colors.redAccent;
                                String reqLabel = 'Request';
                                VoidCallback reqTap = () async {
                                  final success = await provider.sendInterest(profile.phone, profile.id);
                                  if (success && context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppTheme.cardWhite,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 64),
                                            const SizedBox(height: 16),
                                            Text('Request Sent!', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Text('Your interest has been sent to ${profile.name}.', textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: AppTheme.textCarbon)),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text('OK', style: GoogleFonts.montserrat(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                };

                                if (status == 'pending') {
                                  reqIcon = Icons.close_rounded;
                                  reqColor = Colors.grey;
                                  reqLabel = 'Cancel';
                                  reqTap = () async {
                                    final success = await provider.cancelInterest(profile.phone, profile.id);
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request cancelled.')));
                                    }
                                  };
                                } else if (status == 'accepted') {
                                  reqIcon = Icons.check_circle_rounded;
                                  reqColor = Colors.green;
                                  reqLabel = 'Connected';
                                  reqTap = () {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are already connected with ${profile.name}.')));
                                  };
                                } else if (status == 'incoming') {
                                  reqIcon = Icons.favorite_rounded;
                                  reqColor = AppTheme.accentGold;
                                  reqLabel = 'Accept';
                                  reqTap = () async {
                                    final success = await provider.acceptInterest(profile.phone, profile.id);
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request from ${profile.name} accepted!')));
                                    }
                                  };
                                }

                                return _buildActionButton(
                                  icon: reqIcon,
                                  label: reqLabel,
                                  color: reqColor,
                                  onTap: reqTap,
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: isShortlisted ? Icons.star_rounded : Icons.star_border_rounded,
                              label: 'Shortlist',
                              color: isShortlisted ? AppTheme.accentGold : Colors.white,
                              onTap: () {
                                provider.toggleShortlist(profile);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(isShortlisted ? 'Removed from Shortlist' : 'Added to Shortlist')),
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.close_rounded,
                              label: profile.interestStatus == 'incoming' ? 'Decline' : 'Ignore',
                              color: Colors.white,
                              onTap: () async {
                                if (profile.interestStatus == 'incoming') {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request declined.')));
                                  await provider.rejectInterest(profile.phone, profile.id);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile hidden.')));
                                  provider.removeProfileLocally(profile.id);
                                  await provider.blockUser(profile.phone, 'Ignored', 'Hidden from dashboard');
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: 'Chat',
                              color: Colors.white,
                              onTap: () {
                                if (profile.interestStatus == 'accepted') {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(profile: profile)));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat requires an accepted request.')));
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.family_restroom_rounded,
                              label: 'Family',
                              color: Colors.white,
                              onTap: () => _shareToFamily(context, profile),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Full tap area to show details (except buttons)
              Positioned.fill(
                bottom: 120, // keep buttons clickable
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ProfileDetailsSheet(profile: profile),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _completionTip(Map<String, dynamic>? profile, String key, String label, IconData icon, int weight) {
    bool filled = false;
    if (profile != null) {
      final val = profile[key];
      if (key == 'uploadedPhotos') {
        filled = val is List && val.isNotEmpty && val[0] != null && val[0].toString().isNotEmpty;
      } else {
        filled = val != null && val.toString().trim().isNotEmpty;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            filled ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: filled ? Colors.green : Colors.grey.shade400,
            size: 18,
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 16, color: filled ? AppTheme.textMuted : AppTheme.textCarbon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: filled ? AppTheme.textMuted : AppTheme.textCarbon,
                fontWeight: filled ? FontWeight.normal : FontWeight.w600,
                decoration: filled ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            '+$weight%',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: filled ? Colors.green : AppTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }

  void _shareToFamily(BuildContext context, Profile profile) {
    final shareUrl = 'https://play.google.com/store/apps/details?id=com.piyush.assudani';
    final message = '''
🔱 *Jai Jhulelal!*

📋 *Profile Details — Perfect Bandhan*
━━━━━━━━━━━━━━━━
👤 *Name:* ${profile.name}
🎂 *Age:* ${profile.age} years
🏢 *Profession:* ${profile.profession}
🎓 *Education:* ${profile.education}
📍 *Location:* ${profile.location}
🧬 *Nukh:* ${profile.nukh.isNotEmpty ? profile.nukh : profile.caste}
━━━━━━━━━━━━━━━━

📲 *Download Perfect Bandhan app to view full profile, photos & connect:*
$shareUrl

_Shared via Perfect Bandhan — Sindhi Matrimony App_ 🤝
''';

    final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  }
}
