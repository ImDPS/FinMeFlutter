class AppCategory {
  final String id;
  final String label;
  final String emoji;

  const AppCategory({required this.id, required this.label, required this.emoji});
}

const List<AppCategory> kDefaultCategories = [
  AppCategory(id: 'food',          label: 'Food & Dining',    emoji: '🍽️'),
  AppCategory(id: 'transport',     label: 'Transport',        emoji: '🚗'),
  AppCategory(id: 'utilities',     label: 'Utilities',        emoji: '💡'),
  AppCategory(id: 'shopping',      label: 'Shopping',         emoji: '🛍️'),
  AppCategory(id: 'entertainment', label: 'Entertainment',    emoji: '🎬'),
  AppCategory(id: 'health',        label: 'Health & Medical', emoji: '🏥'),
  AppCategory(id: 'education',     label: 'Education',        emoji: '📚'),
  AppCategory(id: 'travel',        label: 'Travel',           emoji: '✈️'),
  AppCategory(id: 'personal',      label: 'Personal Care',    emoji: '💆'),
  AppCategory(id: 'other',         label: 'Other',            emoji: '📦'),
  AppCategory(id: 'uncategorized', label: 'Uncategorized',    emoji: '❓'),
];
