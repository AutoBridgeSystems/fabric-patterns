#!/bin/bash
#
# Sync patterns and strategies from upstream danielmiessler/fabric repository
# This script pulls the latest content and lets Git handle conflicts
#

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_REPO="https://github.com/danielmiessler/fabric.git"
TRACKING_FILE="$REPO_ROOT/.upstream-tracking"
PATTERNS_DIR="$REPO_ROOT/data/patterns"
STRATEGIES_DIR="$REPO_ROOT/data/strategies"

echo "=== Fabric Upstream Sync ==="
echo ""

# Get last synced commit
LAST_SYNC=$(cat "$TRACKING_FILE" 2>/dev/null || echo "none")
echo "Last synced commit: $LAST_SYNC"

# Create temp directory for sparse checkout
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Cloning upstream (sparse checkout, patterns + strategies)..."
git clone --filter=blob:none --sparse "$UPSTREAM_REPO" "$TEMP_DIR" --quiet
cd "$TEMP_DIR"
git sparse-checkout set data/patterns data/strategies

LATEST_COMMIT=$(git rev-parse HEAD)
LATEST_SHORT=$(git rev-parse --short HEAD)
LATEST_DATE=$(git log -1 --format=%ci)

echo "Latest upstream commit: $LATEST_SHORT ($LATEST_DATE)"

if [ "$LAST_SYNC" = "$LATEST_COMMIT" ]; then
    echo ""
    echo "Already up to date with upstream."
    exit 0
fi

# Count patterns
PATTERNS_COUNT=$(find data/patterns -maxdepth 1 -type d | wc -l | tr -d ' ')
echo "Found $((PATTERNS_COUNT - 1)) upstream patterns"

# Count strategies
STRATEGIES_COUNT=$(find data/strategies -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "Found $STRATEGIES_COUNT upstream strategies"

cd "$REPO_ROOT"

# Ensure directories exist
mkdir -p "$PATTERNS_DIR" "$STRATEGIES_DIR"

# Sync patterns (preserve abs_* and autobridge_* prefixed)
echo ""
echo "Syncing patterns to $PATTERNS_DIR..."
rsync -av --delete --exclude='abs_*' --exclude='autobridge_*' \
    "$TEMP_DIR/data/patterns/" "$PATTERNS_DIR/"

# Sync strategies (preserve abs_* and autobridge_* prefixed)
echo ""
echo "Syncing strategies to $STRATEGIES_DIR..."
rsync -av --delete --exclude='abs_*' --exclude='autobridge_*' \
    "$TEMP_DIR/data/strategies/" "$STRATEGIES_DIR/"

# Update tracking file
echo "$LATEST_COMMIT" > "$TRACKING_FILE"

echo ""
echo "=== Sync Complete ==="
echo ""
echo "Review changes:"
echo "  git status"
echo "  git diff"
echo ""
echo "If satisfied, commit:"
echo "  git add data/ .upstream-tracking && git commit -m 'sync: upstream $LATEST_SHORT'"
echo ""
