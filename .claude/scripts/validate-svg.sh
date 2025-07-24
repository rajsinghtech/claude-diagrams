#!/bin/bash
# SVG validation script for claude-diagrams project
# Validates all SVG files against project standards

set -e

echo "🎨 Validating SVG files in claude-diagrams project..."

# Initialize counters
total_svgs=0
errors=0
warnings=0

# Function to validate a single SVG
validate_svg() {
    local svg_file="$1"
    local file_errors=0
    local file_warnings=0
    
    echo ""
    echo "Checking: $svg_file"
    
    # 1. XML syntax validation using xmllint
    if command -v xmllint > /dev/null 2>&1; then
        if ! xmllint --noout "$svg_file" 2>&1; then
            echo "  ❌ XML syntax error detected"
            file_errors=$((file_errors + 1))
        fi
    else
        echo "  ⚠️  xmllint not found, skipping XML syntax validation"
    fi
    
    # 2. Check for viewBox attribute
    if ! grep -q 'viewBox=' "$svg_file"; then
        echo "  ❌ Missing viewBox attribute (required for responsive scaling)"
        file_errors=$((file_errors + 1))
    fi
    
    # 3. Check for Inter font family
    if ! grep -q 'font-family="Inter' "$svg_file"; then
        echo "  ⚠️  Missing Inter font family (should use: font-family=\"Inter, Arial, sans-serif\")"
        file_warnings=$((file_warnings + 1))
    fi
    
    # 4. Check file naming convention
    basename=$(basename "$svg_file")
    if [[ ! "$basename" =~ ^[a-z0-9-]+\.svg$ ]]; then
        echo "  ⚠️  File name should be kebab-case: $basename"
        file_warnings=$((file_warnings + 1))
    fi
    
    # 5. Check for Tailscale-specific requirements
    if [[ "$svg_file" =~ tailscale|tailnet|acl|exit-node|subnet ]]; then
        echo "  📋 Tailscale diagram detected, applying additional checks..."
        
        # Check for proper IP format
        if grep -q '100\.' "$svg_file"; then
            if ! grep -E '100\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$svg_file" > /dev/null; then
                echo "  ⚠️  Invalid Tailscale IP format detected"
                file_warnings=$((file_warnings + 1))
            fi
        fi
        
        # Check for non-standard colors
        if grep -E 'fill="#|stroke="#' "$svg_file" | grep -vE '#000000|#FFFFFF|#F5F5F5|#E3F2FD|#2196F3|#4CAF50|#FF9800|#F44336|#607D8B|#374151|#64748B|#9CA3AF|#6B7280|#E5E7EB|#FFC107' > /dev/null; then
            echo "  ⚠️  Non-standard colors in Tailscale diagram"
            file_warnings=$((file_warnings + 1))
        fi
    fi
    
    # 6. Check for corresponding index.md
    dir_path=$(dirname "$svg_file")
    if [ ! -f "$dir_path/index.md" ]; then
        echo "  ❌ Missing index.md in diagram directory"
        file_errors=$((file_errors + 1))
    fi
    
    # Update global counters
    errors=$((errors + file_errors))
    warnings=$((warnings + file_warnings))
    
    if [ $file_errors -eq 0 ] && [ $file_warnings -eq 0 ]; then
        echo "  ✅ All checks passed"
    fi
}

# Find and validate all SVG files
while IFS= read -r -d '' svg_file; do
    validate_svg "$svg_file"
    total_svgs=$((total_svgs + 1))
done < <(find content/diagrams -name "*.svg" -type f -print0)

# Summary
echo ""
echo "════════════════════════════════════════"
echo "📊 Validation Summary:"
echo "  Total SVGs checked: $total_svgs"
echo "  Errors found: $errors"
echo "  Warnings found: $warnings"

if [ $errors -gt 0 ]; then
    echo ""
    echo "❌ Validation failed with $errors error(s)"
    exit 1
elif [ $warnings -gt 0 ]; then
    echo ""
    echo "⚠️  Validation passed with $warnings warning(s)"
    exit 0
else
    echo ""
    echo "✅ All SVG files passed validation!"
    exit 0
fi