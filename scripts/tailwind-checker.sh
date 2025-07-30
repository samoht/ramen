#!/usr/bin/env bash

# Script to check for proper Tailwind CSS usage and find unused classes
# 
# This script ensures all Tailwind classes use the centralized Tw module
# for optimal tree-shaking and consistent styling patterns.
# 
# Usage: ./scripts/tailwind-checker.sh [--unused]
#        ./scripts/tailwind-checker.sh          # Check for improper usage
#        ./scripts/tailwind-checker.sh --unused # Show unused Tw classes
# 
# Add to your regular development workflow to maintain clean Tailwind usage.

# Color codes
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
BOLD='\033[1m'
RESET='\033[0m'

# Check if we should show unused classes
show_unused=false
if [[ "$1" == "--unused" ]]; then
    show_unused=true
fi

if [[ "$show_unused" == "true" ]]; then
    # ==================== UNUSED CLASSES MODE ====================
    echo -e "${BOLD}🔍 Finding Unused Tw Classes${RESET}"
    echo "Analyzing which Tw module classes are never used in the codebase..."
    echo

    # Get all defined classes from tw.mli
    all_classes=$(grep "^val" lib/brui/tw.mli | sed 's/val \([^ ]*\).*/\1/' | sort)
    
    # Get all used classes from ML files (excluding tw.ml itself)
    used_classes=$(grep -r "Tw\." lib --include="*.ml" --exclude="tw.ml" | sed 's/.*Tw\.\([a-zA-Z0-9_]*\).*/\1/' | sort -u)
    
    # Find unused classes
    unused_classes=$(comm -23 <(echo "$all_classes") <(echo "$used_classes"))
    unused_count=$(echo "$unused_classes" | wc -l)
    
    echo -e "Found ${YELLOW}$unused_count${RESET} unused classes"
    echo
    
    # Group unused classes by category
    echo -e "${BLUE}=== UNUSED COLOR VARIANTS ===${RESET}"
    echo "$unused_classes" | grep -E "^(bg_|text_|border_)" | sort
    
    echo
    echo -e "${BLUE}=== UNUSED SPACING CLASSES ===${RESET}"
    echo "$unused_classes" | grep -E "^(p_|px_|py_|pt_|pb_|pl_|pr_|m_|mx_|my_|mt_|mb_|ml_|mr_|space_|gap_)" | sort
    
    echo
    echo -e "${BLUE}=== UNUSED SIZE CLASSES ===${RESET}"
    echo "$unused_classes" | grep -E "^(w_|h_|min_w_|max_w_|min_h_|max_h_)" | sort
    
    echo
    echo -e "${BLUE}=== UNUSED TYPOGRAPHY CLASSES ===${RESET}"
    echo "$unused_classes" | grep -E "^(text_|font_|leading_|tracking_)" | grep -v -E "^(text_[a-z]+_[0-9]+)" | sort
    
    echo
    echo -e "${BLUE}=== OTHER UNUSED CLASSES ===${RESET}"
    echo "$unused_classes" | grep -v -E "^(bg_|text_|border_|p_|px_|py_|pt_|pb_|pl_|pr_|m_|mx_|my_|mt_|mb_|ml_|mr_|space_|gap_|w_|h_|min_w_|max_w_|min_h_|max_h_|font_|leading_|tracking_)" | sort
    
    echo
    echo -e "${YELLOW}=== COLOR USAGE STATISTICS ===${RESET}"
    # Check which color shades are actually used for each color
    for color in gray red green blue yellow indigo purple orange; do
      echo -e "${BLUE}${color} color usage:${RESET}"
      total_uses=0
      for shade in 50 100 200 300 400 500 600 700 800 900; do
        count=$(grep -r "Tw\.\(text_\|bg_\|border_\)${color}_${shade}" lib --include="*.ml" --exclude="tw.ml" 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
          echo "  ${color}_${shade}: $count uses"
          total_uses=$((total_uses + count))
        fi
      done
      if [ $total_uses -eq 0 ]; then
        echo "  ${RED}No uses found - entire color family can be removed${RESET}"
      else
        echo "  ${GREEN}Total: $total_uses uses${RESET}"
      fi
      echo
    done
    
    echo -e "${YELLOW}=== RECOMMENDATIONS ===${RESET}"
    echo "1. Remove unused color shades to simplify the palette"
    echo "2. Keep only commonly used spacing increments (2, 4, 6, 8)"
    echo "3. Remove custom value classes in favor of standard sizes"
    echo "4. Consider removing entire color families if barely used (e.g., purple, orange)"
    echo
    echo "These unused classes can be safely removed from tw.ml and tw.mli"
    
else
    # ==================== USAGE CHECKER MODE ====================
    echo -e "${BOLD}🔍 Tailwind CSS Usage Checker${RESET}"
    echo "Ensuring all Tailwind classes use the centralized Tw module"
    echo

    total_issues=0
    # Use temporary file for tracking issues per file to avoid subshell issues
    issue_tracking_file=$(mktemp)
    trap 'rm -f "$issue_tracking_file"' EXIT

    check_pattern() {
        local name="$1"
        local pattern="$2"
        local cmd="$3"
        local exclude_examples="${4:-true}"
        
        echo -e "${BLUE}→ Checking: $name${RESET}"
        
        # Build exclude pattern
        local exclude_pattern="tw\\.ml"
        if [[ "$exclude_examples" == "true" ]]; then
            exclude_pattern="${exclude_pattern}\\|examples/"
        fi
        
        # Run the search command and count results
        local results
        if [[ -n "$cmd" ]]; then
            results=$(eval "$cmd" 2>/dev/null | grep -v "$exclude_pattern" || true)
        else
            results=$(find lib -name '*.ml' -o -name '*.mli' | grep -v "$exclude_pattern" | xargs grep -n "$pattern" 2>/dev/null || true)
        fi
        
        local count=0
        if [[ -n "$results" ]]; then
            count=$(echo "$results" | wc -l)
            total_issues=$((total_issues + count))
            
            echo -e "  ${RED}❌ Found ${count} issues${RESET}"
            echo "$results" | head -10 | while IFS= read -r line; do
                echo "    $line"
                # Track issues per file
                local filename
                filename=$(echo "$line" | cut -d: -f1)
                echo "$filename" >> "$issue_tracking_file"
            done
            
            if [[ $count -gt 10 ]]; then
                echo "    ... and $((count - 10)) more"
            fi
            echo
        else
            echo -e "  ${GREEN}✅ No issues found${RESET}"
            echo
        fi
    }

    # Main patterns to check

    # 1. At.class' with Tailwind classes (should use Tw.class')
    check_pattern "At.class' with Tailwind classes (should use Tw.class')" "" \
        "find lib -name '*.ml' -o -name '*.mli' | xargs grep -n 'At\\.class.*\"[^\"]*\\(bg-\\|text-\\|p[xy]*-\\|m[xy]*-\\|flex\\|grid\\|border\\|rounded\\|shadow\\|hover:\\|focus:\\|w-\\|h-\\|gap-\\|space-\\|opacity-\\)\'"

    # 2. ~cls parameter with Tailwind classes (most common issue)
    check_pattern "~cls parameter with Tailwind classes" "" \
        "find lib -name '*.ml' -o -name '*.mli' | xargs grep -n '~cls:\"[^\"]*\\(bg-\\|text-\\|p[xy]*-\\|m[xy]*-\\|flex\\|grid\\|border\\|rounded\\|shadow\\|hover:\\|focus:\\|w-\\|h-\\|gap-\\|space-\\|opacity-\\|min-\\|max-\\|fixed\\|absolute\\|relative\\|sticky\\|transform\\|transition\\|duration\\|divide\\|col-span\\)\'"

    # 3. string_attr "class" with raw Tailwind strings
    check_pattern "string_attr with raw Tailwind strings" "" \
        "find lib -name '*.ml' -o -name '*.mli' | xargs python3 scripts/tailwind-linter.py"

    # 4. Raw Tailwind strings in concatenation or variables (excluding data attributes and SVG attributes)
    check_pattern "Raw Tailwind strings assigned to variables" "" \
        "find lib -name '*.ml' | xargs grep -n 'let.*=.*\"[^\"]*\\(bg-\\|text-\\|p[xy]*-\\|m[xy]*-\\|w-\\|h-\\|flex\\|grid\\|border\\|rounded\\|opacity-\\)\' | grep -v 'data-' | grep -v 'clip-rule' | grep -v 'fill-rule'"

    # 5. Status/color patterns that return raw strings
    check_pattern "Functions returning raw Tailwind strings" "" \
        "find lib -name '*.ml' | xargs grep -B1 -A1 '->.*\"[^\"]*\\(bg-\\|text-\\|border-\\|opacity-\\)\' | grep -v '^--$'"

    # 6. Height parameter with raw Tailwind (common in chart components)
    check_pattern "~height parameter with raw Tailwind" "" \
        "find lib -name '*.ml' | xargs grep -n '~height:\"[hw]-'"

    # 7. Custom Tailwind values that need special handling
    check_pattern "Custom Tailwind values (min-w-[*], min-h-[*], etc.)" "" \
        "find lib -name '*.ml' | xargs grep -n '\"[^\"]*\\(min-[wh]-\\[\\|max-[wh]-\\[\\|-translate-\\|-mt-\\|-top-\\|-left-\\)\'"

    echo -e "${BOLD}📊 SUMMARY REPORT${RESET}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ $total_issues -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}🎉 EXCELLENT! All Tailwind usage follows best practices.${RESET}"
        echo -e "${GREEN}All CSS classes properly use the centralized Tw module.${RESET}"
        echo -e "${GREEN}Tree-shaking will work optimally! 📦✨${RESET}"
    else
        echo -e "${RED}${BOLD}❌ FOUND $total_issues TAILWIND USAGE ISSUES${RESET}"
        echo
        echo -e "${YELLOW}Files with most issues:${RESET}"
        
        # Sort and display files by issue count
        if [[ -f "$issue_tracking_file" ]]; then
            sort "$issue_tracking_file" | uniq -c | sort -rn | head -10 | while IFS=' ' read -r count file; do
                echo -e "  ${RED}●${RESET} $file: ${YELLOW}$count${RESET} issues"
            done
        fi
        
        echo
        echo -e "${YELLOW}🔧 HOW TO FIX:${RESET}"
        echo "  1. Replace At.class' containing Tailwind classes with Tw.class'"
        echo "  2. Convert ~cls:\"tailwind classes\" to proper Tw module usage"
        echo "  3. Use Tw module constants instead of raw CSS strings"
        echo "  4. Add missing classes to lib/brui/tw.ml and tw.mli"
        echo "  5. For dynamic classes, use list concatenation"
        echo
        echo -e "${BLUE}💡 CORRECT USAGE EXAMPLES:${RESET}"
        echo '  ✅ Tw.class'\'' [ Tw.bg_white; Tw.p_4 ]'
        echo '  ✅ Tw.class'\'' (base_classes @ if condition then [Tw.text_red_500] else [])'
        echo '  ✅ At.class'\'' "custom-component-style"  (* OK for non-Tailwind CSS *)'
        echo '  ❌ At.class'\'' "bg-white p-4"'
        echo '  ❌ Tw.class'\'' ~cls:"gap-4" []'
        echo '  ❌ let color = "bg-red-500" in ...'
        echo
        echo -e "${YELLOW}📝 EXCEPTIONS:${RESET}"
        echo "  • Custom CSS classes (non-Tailwind) are OK with At.class'"
        echo "  • Data attributes (e.g., data-show-suggestions) are not CSS classes"
    fi

    echo
    echo -e "${BLUE}🔍 COMMON MISSING CLASSES:${RESET}"
    echo "Classes frequently found that may need adding to tw.ml:"

    # Extract and count unique Tailwind classes
    {
        # From At.class' usage
        find lib -name '*.ml' | grep -v 'tw\\.ml\\|examples/' | xargs grep -o 'At\\.class'\''[^'\']'*'\''' 2>/dev/null | \
            sed 's/At\\.class'\''//g' | sed 's/'\''//g' | tr ' ' '\n'
        
        # From ~cls usage
        find lib -name '*.ml' | grep -v 'tw\\.ml\\|examples/' | xargs grep -o '~cls:\"[^\"]*\"' 2>/dev/null | \
            sed 's/~cls://g' | sed 's/\"//g' | tr ' ' '\n'
    } | grep -E '^(bg-|text-|p[xy]*-|m[xy]*-|w-|h-|gap-|space-|border|rounded|shadow|hover:|focus:|min-|max-|fixed|absolute|relative|sticky|transform|transition|duration|divide|col-span|grid-cols|flex|block|hidden|inline|opacity-)' | \
        sort | uniq -c | sort -rn | head -20 | while IFS=' ' read -r count class; do
        echo "  $class ($count occurrences)"
    done

    echo
    echo -e "${BLUE}🔄 Next steps:${RESET}"
    echo "  1. Run: dune build && dune test"
    echo "  2. Add missing classes to tw.ml/tw.mli"
    echo "  3. Convert files with issues"
    echo "  4. Re-run this script to verify"
    echo "  5. Run with --unused flag to find unused Tw classes"
    echo
    echo -e "${GREEN}💡 Add to git hooks:${RESET}"
    echo "  echo './scripts/tailwind-checker.sh' >> .git/hooks/pre-commit"
fi