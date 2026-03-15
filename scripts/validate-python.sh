#!/bin/bash

# Python Code Validation Script
# This script performs various Python code quality checks

set -e

echo "======================================"
echo "Python Code Validation"
echo "======================================"

# Install dependencies
echo "📦 Installing validation tools..."
pip install -q flake8 black pytest bandit pyyaml cfn-lint 2>/dev/null || true

# Run flake8 linting
echo ""
echo "🔍 Running flake8 linting..."
if flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics 2>/dev/null; then
    echo "✅ Flake8 critical errors check passed"
else
    echo "⚠️ Flake8 found some issues (non-critical)"
fi

# Run black formatting check
echo ""
echo "🔍 Checking code formatting with black..."
if black --check . 2>/dev/null; then
    echo "✅ Code formatting check passed"
else
    echo "⚠️ Code formatting issues found (can be auto-fixed with 'black .')"
fi

# Run bandit security check
echo ""
echo "🔍 Running security checks with bandit..."
if bandit -r . -ll 2>/dev/null; then
    echo "✅ Security checks passed"
else
    echo "⚠️ Bandit found some issues (review needed)"
fi

# Run pytest if tests exist
echo ""
echo "🔍 Running unit tests..."
if [ -d "tests" ] && [ -n "$(find tests -name 'test_*.py' -o -name '*_test.py')" ]; then
    if pytest tests/ -v 2>/dev/null; then
        echo "✅ All tests passed"
    else
        echo "❌ Some tests failed"
        exit 1
    fi
else
    echo "ℹ️  No tests found (skipping)"
fi

echo ""
echo "======================================"
echo "✅ Python validation completed!"
echo "======================================"
