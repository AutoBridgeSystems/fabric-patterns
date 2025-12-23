#!/bin/bash
#
# Sync patterns from upstream danielmiessler/fabric repository
# This script pulls the latest patterns and lets Git handle conflicts
#

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_REPO="https://github.com/danielmiessler/fabric.git"
TRACKING_FILE="$REPO_ROOT/.upstream-tracking"
PATTERNS_DIR="$REPO_ROOT/data/patterns"

echo "=== Fabric Patterns Upstream Sync ==="
echo ""

# Get last synced commit
LAST_SYNC=$(cat "$TRACKING_FILE" 2>/dev/null || echo "none")
echo "Last synced commit: $LAST_SYNC"

# Create temp directory for sparse checkout
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Cloning upstream (sparse checkout, patterns only)..."
git clone --filter=blob:none --sparse "$UPSTREAM_REPO" "$TEMP_DIR" --quiet
cd "$TEMP_DIR"
git sparse-checkout set data/patterns

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
UPSTREAM_COUNT=$(find data/patterns -maxdepth 1 -type d | wc -l | tr -d ' ')
echo "Found $((UPSTREAM_COUNT - 1)) upstream patterns"

# Sync patterns
echo ""
echo "Syncing patterns to $PATTERNS_DIR..."
cd "$REPO_ROOT"

# Copy all upstream patterns (will overwrite upstream ones, preserve abs_* prefixed)
rsync -av --delete --exclude='abs_*' --exclude='autobridge_*' \
    "$TEMP_DIR/data/patterns/" "$PATTERNS_DIR/"

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
echo "  git add -A && git commit -m 'sync: upstream patterns $LATEST_SHORT'"
echo ""
