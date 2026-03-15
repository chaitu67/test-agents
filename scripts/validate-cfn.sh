#!/bin/bash

# CloudFormation Validation Script
# This script validates the CloudFormation template before deployment

set -e

TEMPLATE_FILE="${1:-.github/workflows/../../../cloudformation/template.yaml}"
REGION="${2:-us-east-1}"

echo "======================================"
echo "CloudFormation Template Validation"
echo "======================================"
echo "Template: $TEMPLATE_FILE"
echo "Region: $REGION"
echo ""

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Error: Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Install cfn-lint if not already installed
if ! command -v cfn-lint &> /dev/null; then
    echo "📦 Installing cfn-lint..."
    pip install cfn-lint > /dev/null 2>&1
fi

# Run cfn-lint validation
echo "🔍 Running cfn-lint validation..."
if cfn-lint "$TEMPLATE_FILE" -i W; then
    echo "✅ cfn-lint validation passed!"
else
    echo "❌ cfn-lint validation failed!"
    exit 1
fi

# Validate JSON syntax
echo ""
echo "🔍 Validating YAML syntax..."
if python3 -c "import yaml; yaml.safe_load(open('$TEMPLATE_FILE'))" 2>/dev/null; then
    echo "✅ YAML syntax is valid!"
else
    echo "❌ YAML syntax validation failed!"
    exit 1
fi

# Check for required sections
echo ""
echo "🔍 Checking required CloudFormation sections..."
if grep -q "AWSTemplateFormatVersion" "$TEMPLATE_FILE"; then
    echo "✅ AWSTemplateFormatVersion found"
else
    echo "❌ AWSTemplateFormatVersion not found"
    exit 1
fi

if grep -q "Resources:" "$TEMPLATE_FILE"; then
    echo "✅ Resources section found"
else
    echo "❌ Resources section not found"
    exit 1
fi

# Count resources
RESOURCE_COUNT=$(grep -c "Type: AWS::" "$TEMPLATE_FILE")
echo "📊 Found $RESOURCE_COUNT AWS resources"

echo ""
echo "======================================"
echo "✅ All validations passed!"
echo "======================================"
exit 0
