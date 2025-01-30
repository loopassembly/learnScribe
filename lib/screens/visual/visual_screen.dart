import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './aichat.dart';

/// Definition of AppThemes with predefined themes.
class AppThemes {
  static final Map<String, ColorScheme> themes = {
    'light': ColorScheme.light(
      primary: Colors.indigo,
      onPrimary: Colors.white,
      secondary: Colors.indigoAccent,
      surface: Colors.white,
      surfaceVariant: Colors.grey[100]!,
      onSurface: Colors.black87,
    ),
    'dark': ColorScheme.dark(
      primary: Colors.tealAccent,
      onPrimary: Colors.black87,
      secondary: Colors.tealAccent,
      surface: const Color(0xFF121212),
      surfaceVariant: Colors.grey[900]!,
      onSurface: Colors.white,
    ),
  };
}

/// Definition of AccessibleTextStyles for dynamic text styling.
class AccessibleTextStyles {
  /// Returns a title large TextStyle considering accessibility settings.
  static TextStyle titleLarge(
      BuildContext context, bool largeText, bool dyslexicFont) {
    double fontSize = largeText ? 28 : 24;
    String fontFamily = dyslexicFont
        ? 'OpenDyslexic'
        : GoogleFonts.poppins().fontFamily ?? 'Poppins';

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      fontFamily: fontFamily,
      letterSpacing: 0.5,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Returns a body TextStyle considering accessibility settings.
  static TextStyle bodyText(
      BuildContext context, bool largeText, bool dyslexicFont) {
    double fontSize = largeText ? 18 : 16;
    String fontFamily = dyslexicFont
        ? 'OpenDyslexic'
        : GoogleFonts.poppins().fontFamily ?? 'Poppins';

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamily,
      letterSpacing: 0.25,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}

/// Custom Theme Extension to add additional theming options.
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color cardColor;
  final Color buttonColor;
  final Color shadowColor;

  CustomThemeExtension({
    required this.cardColor,
    required this.buttonColor,
    required this.shadowColor,
  });

  @override
  CustomThemeExtension copyWith({
    Color? cardColor,
    Color? buttonColor,
    Color? shadowColor,
  }) {
    return CustomThemeExtension(
      cardColor: cardColor ?? this.cardColor,
      buttonColor: buttonColor ?? this.buttonColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  CustomThemeExtension lerp(
      ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

/// Model class for Language.
class Language {
  final String code;
  final String name;
  final String label;

  Language({required this.code, required this.name, required this.label});
}

/// Main Visual Support Screen Widget.
class VisualSupportScreen extends StatefulWidget {
  const VisualSupportScreen({Key? key}) : super(key: key);

  @override
  State<VisualSupportScreen> createState() => _VisualSupportScreenState();
}

class _VisualSupportScreenState extends State<VisualSupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String selectedLanguage = 'en-IN';
  bool isRecording = false;
  String currentTheme = 'light';
  final double cardBorderRadius = 16.0;

  // Accessibility settings
  bool largeText = false;
  bool highContrast = false;
  bool dyslexicFont = false;
  String? colorFilterType;

  final List<Language> languages = [
    Language(code: 'en-IN', name: 'English', label: 'English'),
    Language(code: 'hi-IN', name: 'हिंदी', label: 'Hindi'),
    Language(code: 'bn-IN', name: 'বাংলা', label: 'Bengali'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppThemes.themes[currentTheme]!;

    return Theme(
      data: ThemeData.from(
        colorScheme: colorScheme,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ).copyWith(
        extensions: [
          CustomThemeExtension(
            cardColor: colorScheme.surfaceVariant,
            buttonColor: colorScheme.primary,
            shadowColor: colorScheme.shadow,
          ),
        ],
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardBorderRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      child: ColorFiltered(
        colorFilter: _getColorFilter(),
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildTextPreferences(context),
                          const SizedBox(height: 20),
                          _buildColorTheme(context),
                          const SizedBox(height: 20),
                          _buildVoiceToTextSection(),
                          const SizedBox(height: 32),
                          _buildContinueButton(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            'Visual Support',
            style: AccessibleTextStyles.titleLarge(
                context, largeText, dyslexicFont),
          ),
        ],
      ),
    );
  }

  Widget _buildTextPreferences(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields, size: 28),
              const SizedBox(width: 12),
              Text(
                'Text Preferences',
                style: AccessibleTextStyles.titleLarge(
                    context, largeText, dyslexicFont),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPreferencesGrid(),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeExtension>()?.cardColor,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                    .extension<CustomThemeExtension>()
                    ?.shadowColor
                    .withAlpha(30) ??
                Colors.transparent,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPreferencesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildPreferenceToggle(
            'Large Text Mode', largeText, (v) => setState(() => largeText = v)),
        _buildPreferenceToggle('High Contrast', highContrast,
            (v) => setState(() => highContrast = v)),
        _buildPreferenceToggle('Dyslexic Font', dyslexicFont,
            (v) => setState(() => dyslexicFont = v)),
        _buildColorFilterDropdown(),
      ],
    );
  }

  Widget _buildPreferenceToggle(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: AccessibleTextStyles.bodyText(
                  context, largeText, dyslexicFont),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildColorFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: colorFilterType ?? 'None',
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(value: 'None', child: Text('Color Filters')),
            DropdownMenuItem(value: 'Protanopia', child: Text('Protanopia')),
            DropdownMenuItem(
                value: 'Deuteranopia', child: Text('Deuteranopia')),
          ],
          onChanged: (value) =>
              setState(() => colorFilterType = value == 'None' ? null : value),
        ),
      ),
    );
  }

  ColorFilter _getColorFilter() {
    if (colorFilterType == null) {
      return const ColorFilter.mode(Colors.transparent, BlendMode.srcOver);
    }

    if (colorFilterType == 'Protanopia') {
      return const ColorFilter.matrix([
        0.567,
        0.433,
        0,
        0,
        0,
        0.558,
        0.442,
        0,
        0,
        0,
        0,
        0.242,
        0.758,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]);
    }

    return const ColorFilter.matrix([
      0.625,
      0.375,
      0,
      0,
      0,
      0.7,
      0.3,
      0,
      0,
      0,
      0,
      0.3,
      0.7,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  Widget _buildColorTheme(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined, size: 28),
              const SizedBox(width: 12),
              Text(
                'Color Theme',
                style: AccessibleTextStyles.titleLarge(
                    context, largeText, dyslexicFont),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: AppThemes.themes.keys
                .map((theme) => _buildThemeButton(theme))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(String themeName) {
    final isSelected = currentTheme == themeName;
    final colorScheme = AppThemes.themes[themeName]!;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => currentTheme = themeName),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            themeName.toUpperCase(),
            style:
                AccessibleTextStyles.bodyText(context, largeText, dyslexicFont)
                    .copyWith(color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceToTextSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voice to Text',
            style: AccessibleTextStyles.titleLarge(
                context, largeText, dyslexicFont),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Choose your language:',
                      style: AccessibleTextStyles.bodyText(
                          context, largeText, dyslexicFont),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageDropdown(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Voice transcription will appear here...',
                  style: AccessibleTextStyles.bodyText(
                          context, largeText, dyslexicFont)
                      .copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCircularButton(
                      icon: isRecording ? Icons.stop : Icons.mic,
                      color: isRecording
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        setState(() => isRecording = !isRecording);
                        if (isRecording) {
                          _animationController.repeat(reverse: true);
                        } else {
                          _animationController.stop();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildCircularButton(
                      icon: Icons.refresh,
                      color: Theme.of(context).colorScheme.surface,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildCircularButton(
                      icon: Icons.copy,
                      color: Theme.of(context).colorScheme.surface,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguage,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: languages.map((lang) {
            return DropdownMenuItem(
              value: lang.code,
              child: Text(
                '${lang.name} (${lang.label})',
                style: AccessibleTextStyles.bodyText(
                    context, largeText, dyslexicFont),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedLanguage = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final isDark = color == Theme.of(context).colorScheme.surface;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Icon(
                icon,
                size: 20 + (_animationController.value * 4),
                color: isDark
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AiTutorPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          minimumSize: const Size(200, 50),
          elevation: 4,
          shadowColor: Theme.of(context).colorScheme.primary.withAlpha(100),
        ),
        child: Text(
          'Continue to VisualAI',
          style: AccessibleTextStyles.bodyText(context, largeText, dyslexicFont)
              .copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
