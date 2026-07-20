import 'dart:ui';

import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../config/app_config.dart';
import '../models/auth_models.dart';
import '../models/achievements.dart';
import '../models/lesson_access_decision.dart';
import '../models/lesson_start_selection.dart';
import '../models/progress.dart';
import '../services/auth_service.dart';
import '../services/achievement_presentation_store.dart';
import '../services/service_factory.dart';
import '../theme/app_visuals.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/achievement_preview.dart';
import 'achievements_screen.dart';
import 'choose_topic_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

enum _HomeProgressState { loading, ready, unavailable }

enum _HomeAchievementsState { loading, ready, unavailable }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    AuthService? authService,
    AchievementPresentationStore? achievementPresentationStore,
  })  : _authService = authService,
        _achievementPresentationStore = achievementPresentationStore;

  static const String routeName = '/home';
  final AuthService? _authService;
  final AchievementPresentationStore? _achievementPresentationStore;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  late final AchievementPresentationStore _achievementPresentationStore;
  AuthUser? _currentUser;
  LessonAccessDecision? _lessonAccess;
  ProgressResponse? _progress;
  AchievementsResponse? _achievements;
  _HomeProgressState _progressState = _HomeProgressState.loading;
  _HomeAchievementsState _achievementsState = _HomeAchievementsState.loading;
  bool _isLoadingSummary = false;
  bool _isLoadingLessonSettings = false;
  bool _isOpeningSettings = false;
  bool _isOpeningAchievements = false;
  bool _isCheckingAchievementPresentations = false;
  bool _isShowingAchievementPresentation = false;
  final List<AchievementItem> _achievementPresentationQueue = [];
  String? _lessonStartError;

  @override
  void initState() {
    super.initState();
    _authService = widget._authService ?? createAuthService();
    _achievementPresentationStore = widget._achievementPresentationStore ??
        SecureAchievementPresentationStore();
    _loadHomeSummary();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (_achievementsState == _HomeAchievementsState.loading &&
        _achievements != null) {
      return;
    }
    if (mounted) {
      setState(() => _achievementsState = _HomeAchievementsState.loading);
    }
    final result = await _authService.fetchAchievements();
    if (!mounted) {
      return;
    }
    if (result.status == AchievementsStatus.authRequired) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (_) => false);
      return;
    }
    setState(() {
      _achievements = result.achievements;
      _achievementsState = result.isSuccess
          ? _HomeAchievementsState.ready
          : _HomeAchievementsState.unavailable;
    });
    _queueNewAchievementPresentations();
  }

  Future<void> _queueNewAchievementPresentations() async {
    final userId = _currentUser?.userId;
    final achievements = _achievements;
    if (_isCheckingAchievementPresentations ||
        userId == null ||
        achievements == null) {
      return;
    }
    _isCheckingAchievementPresentations = true;
    try {
      final presented =
          await _achievementPresentationStore.readPresentedIds(userId);
      if (!mounted) return;
      final queuedIds =
          _achievementPresentationQueue.map((item) => item.id).toSet();
      _achievementPresentationQueue.addAll(achievements.achievements.where(
          (item) =>
              item.unlocked &&
              !presented.contains(item.id) &&
              !queuedIds.contains(item.id)));
      _showNextAchievementPresentation();
    } catch (_) {
      // A storage failure must not interrupt Home.
    } finally {
      _isCheckingAchievementPresentations = false;
    }
  }

  Future<void> _showNextAchievementPresentation() async {
    if (!mounted ||
        _isShowingAchievementPresentation ||
        _achievementPresentationQueue.isEmpty) {
      return;
    }
    final achievement = _achievementPresentationQueue.first;
    final userId = _currentUser?.userId;
    if (userId == null) return;
    _isShowingAchievementPresentation = true;
    final dismissal = await showQueuedAchievementPreview(context, achievement);
    if (dismissal == AchievementPreviewDismissal.closeAll) {
      final queuedItems =
          List<AchievementItem>.from(_achievementPresentationQueue);
      _achievementPresentationQueue.clear();
      try {
        for (final queued in queuedItems) {
          await _achievementPresentationStore.markPresented(userId, queued.id);
        }
      } catch (_) {
        // It is safe to show items again later if local persistence fails.
      }
    } else {
      _achievementPresentationQueue.removeAt(0);
      try {
        await _achievementPresentationStore.markPresented(
            userId, achievement.id);
      } catch (_) {
        // It is safe to show the item again later if local persistence fails.
      }
    }
    _isShowingAchievementPresentation = false;
    if (mounted) _showNextAchievementPresentation();
  }

  Future<void> _openAchievements() async {
    if (_isOpeningAchievements) return;
    _isOpeningAchievements = true;
    try {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AchievementsScreen(authService: _authService)));
    } finally {
      if (mounted) _isOpeningAchievements = false;
    }
  }

  Future<void> _loadHomeSummary() async {
    if (_isLoadingSummary) return;
    _isLoadingSummary = true;
    if (mounted) setState(() => _progressState = _HomeProgressState.loading);

    AuthUser? user;
    LessonAccessDecision? lessonAccess;
    var shouldSignInAgain = false;

    try {
      user = await _authService.loadCurrentUser();
    } on ApiException catch (error) {
      shouldSignInAgain = error.message == 'Please sign in again.';
    } catch (_) {}

    if (!shouldSignInAgain) {
      try {
        lessonAccess = await _authService.fetchLessonAccessDecision();
      } on ApiException catch (error) {
        shouldSignInAgain = error.message == 'Please sign in again.';
      } catch (_) {}
    }

    ProgressResult? progressResult;
    if (!shouldSignInAgain) {
      progressResult = await _authService.fetchProgress();
      shouldSignInAgain = progressResult.status == ProgressStatus.authRequired;
    }

    if (!mounted) return;
    _isLoadingSummary = false;
    if (shouldSignInAgain) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (_) => false);
      return;
    }

    setState(() {
      _currentUser = user;
      _lessonAccess = lessonAccess;
      _progress = progressResult?.progress;
      _progressState = progressResult?.isSuccess == true
          ? _HomeProgressState.ready
          : _HomeProgressState.unavailable;
    });
    _queueNewAchievementPresentations();
  }

  Future<void> _startLesson() async {
    if (_isLoadingLessonSettings) return;
    setState(() {
      _isLoadingLessonSettings = true;
      _lessonStartError = null;
    });

    try {
      final settings = await _authService.fetchUserSettings();
      if (!mounted) return;
      final selectedLevel = lessonLevelFor(settings.currentLevel);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChooseTopicScreen(
            selectedLevel: selectedLevel,
            authService: _authService,
          ),
        ),
      );
      if (mounted) {
        _loadHomeSummary();
        _loadAchievements();
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.message == 'Please sign in again.') {
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.routeName, (_) => false);
        return;
      }
      setState(() => _lessonStartError =
          'Unable to load your learning settings right now. Please try again.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _lessonStartError =
          'Unable to load your learning settings right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoadingLessonSettings = false);
    }
  }

  Future<void> _openSettings() async {
    if (_isOpeningSettings) return;
    _isOpeningSettings = true;
    try {
      await Navigator.pushNamed(context, SettingsScreen.routeName);
      if (mounted) _loadHomeSummary();
    } finally {
      if (mounted) _isOpeningSettings = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AppVisuals.screenBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _StreakBadge(
                    state: _progressState,
                    currentDays: _progress?.streaks.currentDays,
                  ),
                ),
                const SizedBox(height: 10),
                const _HomeTitle(),
                const SizedBox(height: 16),
                _HomeActionButton(
                  onPressed: _isLoadingLessonSettings ? null : _startLesson,
                  icon: Icons.school,
                  label: _isLoadingLessonSettings
                      ? 'Loading settings...'
                      : 'Start lesson',
                ),
                if (_lessonStartError != null) ...[
                  const SizedBox(height: 8),
                  Text(_lessonStartError!),
                ],
                const SizedBox(height: 16),
                _AccountSummary(
                    user: _currentUser, lessonAccess: _lessonAccess),
                const SizedBox(height: 12),
                _HomeAchievements(
                  state: _achievementsState,
                  achievements: _achievements,
                  onOpen: _isOpeningAchievements ? null : _openAchievements,
                  onRetry: _loadAchievements,
                ),
                const SizedBox(height: 12),
                _WeeklyActivity(state: _progressState, progress: _progress),
                const SizedBox(height: 16),
                _HomeActionButton(
                  key: const Key('home-open-settings'),
                  onPressed: _isOpeningSettings ? null : _openSettings,
                  icon: Icons.settings,
                  label: 'Open Settings',
                ),
              ],
            ),
          ),
        ),
      );
}

class _HomeAchievements extends StatelessWidget {
  const _HomeAchievements(
      {required this.state,
      required this.achievements,
      required this.onOpen,
      required this.onRetry});
  final _HomeAchievementsState state;
  final AchievementsResponse? achievements;
  final VoidCallback? onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state == _HomeAchievementsState.loading) {
      return const _FrostedHomeCard(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Achievements'),
              SizedBox(height: 10),
              _AchievementsPlaceholder(),
            ],
          ),
        ),
      );
    }
    if (state == _HomeAchievementsState.unavailable || achievements == null) {
      return _FrostedHomeCard(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Expanded(
                    child: Text('Achievements are temporarily unavailable')),
                TextButton(onPressed: onRetry, child: const Text('Retry'))
              ])));
    }
    final items = achievements!.homeItems;
    return _FrostedHomeCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                'Achievements',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
                key: const Key('home-achievements-view-all'),
                onPressed: onOpen,
                child: const Text('View all'))
          ]),
          if (items.isEmpty)
            const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Your achievements will appear here.')),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              for (final item in items)
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                            key: Key('home-achievement-${item.id}'),
                            onTap: item.unlocked
                                ? () => showAchievementPreview(context, item)
                                : null,
                            borderRadius: BorderRadius.circular(14),
                            child: AchievementBadge(
                                achievement: item, compact: true))))
            ]),
          ],
        ]),
      ),
    );
  }
}

class _AchievementsPlaceholder extends StatelessWidget {
  const _AchievementsPlaceholder();
  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
          3,
          (_) => const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                height: 82,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E7EF),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.06,
          letterSpacing: -0.35,
        );
    return Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          AppConfig.logoAsset,
          key: const Key('app-logo'),
          semanticLabel: AppConfig.logoSemanticLabel,
          width: 64,
          height: 64,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Semantics(
          label: AppConfig.appName,
          header: true,
          child: ExcludeSemantics(
            child: Text.rich(
              TextSpan(style: titleStyle, children: [
                TextSpan(
                  text: 'Language',
                  style: _wordmarkGradient(
                      const Color(0xFF39B9F2), const Color(0xFF173F9D)),
                ),
                TextSpan(
                  text: ' Voice',
                  style: _wordmarkGradient(
                      const Color(0xFFFFB12B), const Color(0xFFD7382B)),
                ),
                TextSpan(
                  text: ' Tutor',
                  style: _wordmarkGradient(
                      const Color(0xFF96E942), const Color(0xFF218D24)),
                ),
              ]),
              key: const Key('home-branded-title'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    ]);
  }

  TextStyle _wordmarkGradient(Color top, Color bottom) => TextStyle(
        foreground: Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, bottom],
          ).createShader(const Rect.fromLTWH(0, 0, 1, 42)),
      );
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x5539679A),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppVisuals.actionButtonGradient,
                border: Border.all(color: const Color(0x99E8F8FF)),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(1.12, -0.45),
                            radius: 1.12,
                            colors: [
                              Color(0xE6FFFFFF),
                              Color(0x66DFF7FF),
                              Color(0x0039B9F2),
                            ],
                            stops: [0, 0.3, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(38),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: onPressed,
                    icon: Icon(icon, size: 19),
                    label: Text(label),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _FrostedHomeCard extends StatelessWidget {
  const _FrostedHomeCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Card(
            margin: EdgeInsets.zero,
            color: AppVisuals.translucentCard,
            elevation: 1,
            child: child,
          ),
        ),
      );
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.state, required this.currentDays});
  final _HomeProgressState state;
  final int? currentDays;

  @override
  Widget build(BuildContext context) {
    final isReady = state == _HomeProgressState.ready && currentDays != null;
    final label = isReady
        ? '$currentDays day learning streak'
        : state == _HomeProgressState.loading
            ? 'Learning streak loading'
            : 'Learning streak unavailable';
    final text = isReady
        ? '$currentDays 🍪'
        : state == _HomeProgressState.loading
            ? '…'
            : '—';
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          key: const Key('home-streak-badge'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: state == _HomeProgressState.unavailable
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : const Color(0xFFFFE0B2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(text, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.user, required this.lessonAccess});
  final AuthUser? user;
  final LessonAccessDecision? lessonAccess;

  String get _name {
    final value = user?.displayName?.trim() ?? '';
    return value.isEmpty ? 'Learner' : value;
  }

  String get _plan {
    if (lessonAccess?.premiumActive ?? false) return 'Premium plan';
    if (lessonAccess?.trialActive ?? false) return 'Premium trial';
    return 'Free plan';
  }

  String? get _freeLessonsLabel {
    if (lessonAccess?.premiumActive ?? false) return null;
    if (lessonAccess?.trialActive ?? false) return null;
    final remaining = lessonAccess?.freeLessonRemainingToday;
    if (remaining == null) return null;
    final lesson = remaining == 1 ? 'lesson' : 'lessons';
    return '$remaining free $lesson available today';
  }

  @override
  Widget build(BuildContext context) => _FrostedHomeCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Signed in as $_name',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              _plan,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppVisuals.learningGreen,
                  ),
            ),
            if (_freeLessonsLabel != null) ...[
              const SizedBox(height: 3),
              Text(_freeLessonsLabel!),
            ],
          ]),
        ),
      );
}

class _WeeklyActivity extends StatelessWidget {
  const _WeeklyActivity({required this.state, required this.progress});
  final _HomeProgressState state;
  final ProgressResponse? progress;

  @override
  Widget build(BuildContext context) {
    if (state == _HomeProgressState.loading) {
      return const _ActivityPlaceholder();
    }
    if (state == _HomeProgressState.unavailable || progress == null) {
      return const _ActivityUnavailable();
    }
    final allItems = progress!.dailyActivity;
    final items =
        allItems.sublist(allItems.length > 7 ? allItems.length - 7 : 0);
    return _FrostedHomeCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your week', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          _ActivityBars(items: items),
          const SizedBox(height: 12),
          Text(
              '${progress!.completedLessons.last7Days} lessons in the last 7 days'),
          if (progress!.completedLessons.last7Days == 0) ...[
            const SizedBox(height: 4),
            const Text('Start your streak today'),
          ],
        ]),
      ),
    );
  }
}

class _ActivityPlaceholder extends StatelessWidget {
  const _ActivityPlaceholder();
  @override
  Widget build(BuildContext context) => _FrostedHomeCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your week', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              key: const Key('home-activity-loading'),
              height: 54,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ]),
        ),
      );
}

class _ActivityUnavailable extends StatelessWidget {
  const _ActivityUnavailable();
  @override
  Widget build(BuildContext context) => _FrostedHomeCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your week', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text('Activity is unavailable right now.'),
          ]),
        ),
      );
}

class _ActivityBars extends StatefulWidget {
  const _ActivityBars({required this.items});
  final List<ProgressDailyActivityItem> items;

  @override
  State<_ActivityBars> createState() => _ActivityBarsState();
}

class _ActivityBarsState extends State<_ActivityBars> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    var maximum = 1;
    for (final item in widget.items) {
      if (item.completedLessons > maximum) {
        maximum = item.completedLessons;
      }
    }
    final selectedItem =
        _selectedIndex == null ? null : widget.items[_selectedIndex!];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var index = 0; index < widget.items.length; index++)
              Expanded(
                child: _ActivityBar(
                  item: widget.items[index],
                  maximum: maximum,
                  isLatest: index == widget.items.length - 1,
                  isSelected: index == _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = index),
                ),
              ),
          ],
        ),
        if (selectedItem != null) ...[
          const SizedBox(height: 8),
          Text(
            '${_weekday(selectedItem.activityDate)}: '
            '${selectedItem.completedLessons} '
            '${selectedItem.completedLessons == 1 ? 'lesson' : 'lessons'} completed',
            key: const Key('home-activity-detail'),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ],
    );
  }

  String _weekday(DateTime date) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({
    required this.item,
    required this.maximum,
    required this.isLatest,
    required this.isSelected,
    required this.onTap,
  });
  final ProgressDailyActivityItem item;
  final int maximum;
  final bool isLatest;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = item.activityDate.toIso8601String().substring(0, 10);
    final height = item.completedLessons == 0
        ? 8.0
        : 12 + (40 * item.completedLessons / maximum);
    return Semantics(
      label: '$date: ${item.completedLessons} completed lessons',
      button: true,
      selected: isSelected,
      container: true,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                height: 52,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    key: Key('home-activity-$date'),
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: item.completedLessons > 0
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppVisuals.activityEmeraldLight,
                                AppVisuals.activityEmeraldDark,
                              ],
                            )
                          : null,
                      color: item.completedLessons == 0
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : isLatest
                              ? Border.all(
                                  color: AppVisuals.learningGreen,
                                  width: 1.5,
                                )
                              : null,
                    ),
                    child: item.completedLessons > 0
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 3,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xBBFFFFFF),
                                    Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(_weekday(item.activityDate),
                  style: Theme.of(context).textTheme.labelSmall),
            ]),
          ),
        ),
      ),
    );
  }

  String _weekday(DateTime date) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
}
