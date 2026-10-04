class AccessibilityPreferences {
  const AccessibilityPreferences({
    this.textScale = 1,
    this.highContrast = false,
    this.reduceMotion = false,
  });
  final double textScale;
  final bool highContrast, reduceMotion;
}
