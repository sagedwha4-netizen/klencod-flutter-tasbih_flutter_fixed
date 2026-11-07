import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TasbihApp());
}

class TasbihApp extends StatefulWidget {
  const TasbihApp({super.key});

  @override
  State<TasbihApp> createState() => _TasbihAppState();
}

class _TasbihAppState extends State<TasbihApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _themeMode = (prefs.getBool('dark_mode') ?? false)
          ? ThemeMode.dark
          : ThemeMode.light;
      _ready = true;
    });
  }

  Future<void> _toggleTheme() async {
    final next = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setState(() => _themeMode = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', next == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF168C83);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مسبحتي',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7F6),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101A1A),
      ),
      home: _ready
          ? TasbihPage(
              isDark: _themeMode == ThemeMode.dark,
              onThemeToggle: _toggleTheme,
            )
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class TasbihPage extends StatefulWidget {
  const TasbihPage({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  final bool isDark;
  final Future<void> Function() onThemeToggle;

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  static const Color teal = Color(0xFF168C83);
  int count = 0;
  int target = 33;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      count = prefs.getInt('tasbih_count') ?? 0;
      target = prefs.getInt('tasbih_target') ?? 33;
      ready = true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', count);
    await prefs.setInt('tasbih_target', target);
  }

  Future<void> _increment() async {
    setState(() => count++);
    await HapticFeedback.lightImpact();
    await _save();
    if (count > 0 && count % target == 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أحسنت! أكملت $target تسبيحة 🌿'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _decrement() async {
    if (count == 0) return;
    setState(() => count--);
    await HapticFeedback.selectionClick();
    await _save();
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تصفير العداد؟'),
        content: const Text('هل تريد إعادة العداد إلى الصفر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => count = 0);
      await _save();
    }
  }

  Future<void> _chooseTarget() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر هدف التسبيح',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final value in [33, 99, 100])
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text('$value تسبيحة'),
                  trailing: target == value
                      ? const Icon(Icons.check_circle, color: teal)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, value),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() => target = selected);
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('مسبحتي', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              tooltip: widget.isDark ? 'الوضع النهاري' : 'الوضع الليلي',
              onPressed: widget.onThemeToggle,
              icon: Icon(widget.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: !ready
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'اذكر الله واطمئن قلبك',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    _counterCard(),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            icon: Icons.flag_rounded,
                            title: 'الهدف',
                            value: '$target',
                            onTap: _chooseTarget,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.autorenew_rounded,
                            title: 'المتبقي',
                            value: '${count >= target ? 0 : target - count}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 64,
                      child: FilledButton.icon(
                        onPressed: _increment,
                        icon: const Icon(Icons.touch_app_rounded, size: 26),
                        label: const Text(
                          'تسبيح',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _decrement,
                            icon: const Icon(Icons.remove_rounded),
                            label: const Text('تراجع'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('تصفير'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_rounded, color: teal),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر',
                                style: TextStyle(
                                  height: 1.7,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'يُحفظ العدد والوضع الليلي تلقائيًا على جهازك.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _counterCard() {
    final progress = (count % target) / target;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF168C83), Color(0xFF105E65)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: teal.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('عدد التسبيحات', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 205,
                height: 205,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 9,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('تسبيحة', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('الهدف $target تسبيحة', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 2),
              Icon(icon, color: teal, size: 25),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
              if (onTap != null)
                const Text('اضغط للتغيير', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}