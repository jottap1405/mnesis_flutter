#!/bin/bash

# Fix Flutter analyze issues for Mnesis project

echo "=== Fixing Flutter Analyze Issues ==="

# 1. Fix navigation_helper_test.dart - Critical errors
echo "Fixing navigation_helper_test.dart..."

# Fix line 46 - Change null to Future.value(null)
sed -i '' 's/when(() => mockRouter.pushReplacement(any())).thenReturn(null);/when(() => mockRouter.pushReplacement(any())).thenReturn(Future.value(null));/' test/core/router/navigation_helper_test.dart

# Fix the indentation and structure of Type Safety group (lines 581-640)
# Remove the extra closing brace and fix indentation
perl -i -pe 's/^  \}\);$/  });/ if $. == 579' test/core/router/navigation_helper_test.dart
perl -i -pe 's/^    group\('\''Type Safety'\''/    group('\''Type Safety'\''/' test/core/router/navigation_helper_test.dart
perl -i -pe 's/^  \}\);$// if $. == 640' test/core/router/navigation_helper_test.dart

# 2. Fix unnecessary_cast warning
echo "Fixing unnecessary cast in app_router_simple_test.dart..."
sed -i '' 's/as GoRouter//' test/core/router/app_router_simple_test.dart

# 3. Fix avoid_returning_null_for_void warnings
echo "Fixing null returns for void functions..."
sed -i '' 's/return null;$/return;/' test/core/database/database_helper_test.dart
sed -i '' 's/return null;$/return;/' test/core/router/router_observer_test.dart

# 4. Fix deprecated onPopPage usage - Replace with onDidRemovePage
echo "Fixing deprecated onPopPage usage..."
find test -name "*.dart" -exec sed -i '' 's/onPopPage:/onDidRemovePage:/' {} \;

# 5. Fix deprecated withOpacity
echo "Fixing deprecated withOpacity..."
sed -i '' 's/\.withOpacity(0\.5)/.withValues(alpha: 127)/' test/core/design_system/theme/theme_validation_test.dart

# 6. Fix dangling library doc comments
echo "Fixing dangling library doc comments..."

# Add library directive after doc comments
files=(
  "lib/core/design_system/mnesis_theme.dart"
  "test/core/design_system/design_system_showcase_test.dart"
  "test/core/router/routes/all_routes_test.dart"
  "test/core/router/transitions/fade_transition_page_test.dart"
  "test/core/router/transitions/transition_config_test.dart"
  "test/main_test.dart"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    # Check if file has /// comment at line 1 but no library directive
    if head -n1 "$file" | grep -q "^///" && ! head -n10 "$file" | grep -q "^library"; then
      # Insert library directive after the doc comment block
      awk '/^\/\/\// {print; found=1; next} found && !/^\/\/\// {print "library;\n"; found=0} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi
  fi
done

# 7. Fix unnecessary imports
echo "Fixing unnecessary imports..."
sed -i '' '/import.*theme_validation.dart/d' test/core/design_system/theme/mnesis_theme_test.dart
sed -i '' '/import.*theme_validation.dart/d' test/core/design_system/theme/theme_validation_test.dart

# 8. Fix undefined ProviderLogger in main_test.dart
echo "Fixing undefined ProviderLogger..."
# Replace ProviderLogger with proper mock
sed -i '' 's/ProviderLogger()/MockProviderObserver()/' test/main_test.dart

# Add MockProviderObserver class if not exists
if ! grep -q "class MockProviderObserver" test/main_test.dart; then
  cat >> test/main_test.dart << 'EOF'

/// Mock provider observer for testing
class MockProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {}

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {}

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {}
}
EOF
fi

echo "=== Running Flutter Analyze to verify fixes ==="
flutter analyze

echo "=== Fix script completed ==="