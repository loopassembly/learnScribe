import 'package:flutter/material.dart';

class VoiceToTextSection extends StatelessWidget {
  final bool isRecording;
  final String selectedLanguage;
  final List<Language> languages;
  final AnimationController animationController;
  final ValueChanged<bool> onRecordingToggle;
  final ValueChanged<String> onLanguageChanged;
  final bool largeText;
  final bool dyslexicFont;

  const VoiceToTextSection({
    super.key,
    required this.isRecording,
    required this.selectedLanguage,
    required this.languages,
    required this.animationController,
    required this.onRecordingToggle,
    required this.onLanguageChanged,
    required this.largeText,
    required this.dyslexicFont,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voice to Text',
            style: AccessibleTextStyles.titleLarge(context, largeText, dyslexicFont),
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
                      style: AccessibleTextStyles.bodyText(context, largeText, dyslexicFont),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LanguageDropdown(
                        selectedLanguage: selectedLanguage,
                        languages: languages,
                        onChanged: onLanguageChanged,
                        largeText: largeText,
                        dyslexicFont: dyslexicFont,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Voice transcription will appear here...',
                  style: AccessibleTextStyles.bodyText(context, largeText, dyslexicFont)
                      .copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha(153)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircularButton(
                      icon: isRecording ? Icons.stop : Icons.mic,
                      color: isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                      onPressed: () => onRecordingToggle(!isRecording),
                      animationController: animationController,
                      largeText: largeText,
                      dyslexicFont: dyslexicFont,
                    ),
                    const SizedBox(width: 8),
                    CircularButton(
                      icon: Icons.refresh,
                      color: Theme.of(context).colorScheme.surface,
                      onPressed: () {},
                      animationController: animationController,
                      largeText: largeText,
                      dyslexicFont: dyslexicFont,
                    ),
                    const SizedBox(width: 8),
                    CircularButton(
                      icon: Icons.copy,
                      color: Theme.of(context).colorScheme.surface,
                      onPressed: () {},
                      animationController: animationController,
                      largeText: largeText,
                      dyslexicFont: dyslexicFont,
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

  Widget _buildCard({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeExtension>()?.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).extension<CustomThemeExtension>()?.shadowColor.withAlpha(30) ?? Colors.transparent,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class LanguageDropdown extends StatelessWidget {
  final String selectedLanguage;
  final List<Language> languages;
  final ValueChanged<String> onChanged;
  final bool largeText;
  final bool dyslexicFont;

  const LanguageDropdown({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onChanged,
    required this.largeText,
    required this.dyslexicFont,
  });

  @override
  Widget build(BuildContext context) {
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
                style: AccessibleTextStyles.bodyText(context, largeText, dyslexicFont),
              ),
            );
          }).toList(),
          onChanged: (value) => value != null ? onChanged(value) : null,
        ),
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final AnimationController animationController;
  final bool largeText;
  final bool dyslexicFont;

  const CircularButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.animationController,
    required this.largeText,
    required this.dyslexicFont,
  });

  @override
  Widget build(BuildContext context) {
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
            animation: animationController,
            builder: (context, child) {
              return Icon(
                icon,
                size: 20 + (animationController.value * 4),
                color: isDark ? Theme.of(context).colorScheme.onSurface : Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }
}