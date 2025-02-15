#!/bin/bash

# Define the regex pattern to match file paths with line and column numbers
REGEX="[a-zA-Z0-9_\-~\/]+(?:\.[a-zA-Z0-9_\-~]+)+\:\d+(?:\:\d+)?"

# Define test cases (expected valid paths)
test_cases=(
  "foo.js:13"
  "foo.js:13:7"
  "foo.test.js:13:7"
  "foo/bar.js:34:3"
  "foo/bar.test.js:99"
  "src/utils/helper.ts:12"
  "src/.dotfile:23:3"
  "baz/qux.spec.jsx:23:7"
  "nested/path.to.file.py:56:18"
  "good/path.file.ext:123:45"
  "good/path-file.ext:123:45"
  "some/file.name.with.many.dots.cpp:200:10"
  "src/components/shared/test-sadf.test.js:56:3"
)

# Define invalid test cases (should NOT match)
invalid_cases=(
  "foo.js"  # No line number
  "not/a/path.txt"  # No line number
  "missing/line/number.js"  # No line number
  "invalid/path:34a"  # Invalid line number
  "invalid/path:34a:12"  # Invalid line number
  "random_text_without_path"  # No file path format
)

echo "Testing valid file paths..."
echo "=========================="

for test_case in "${test_cases[@]}"; do
  result=$(echo "$test_case" | rg -oi "$REGEX")

  if [[ -z "$result" ]]; then
    echo "❌ FAIL: Regex did not match expected pattern: '$test_case'"
  elif [[ "$result" != "$test_case" ]]; then
    echo "❌ FAIL: Extracted string '$result' does not match original '$test_case'"
  else
    echo "✅ PASS: Matched '$test_case'"
  fi
done

echo ""
echo "Testing invalid cases (should NOT match)..."
echo "==========================================="

for test_case in "${invalid_cases[@]}"; do
  result=$(echo "$test_case" | rg -oi "$REGEX")

  if [[ -n "$result" ]]; then
    echo "❌ FAIL: Regex incorrectly matched invalid input: '$test_case'"
  else
    echo "✅ PASS: Correctly ignored '$test_case'"
  fi
done
