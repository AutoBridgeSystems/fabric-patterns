# AutoBridge Fabric Patterns

A curated collection of [Fabric](https://github.com/danielmiessler/fabric) AI patterns, synchronized with the upstream community repository.

## What is Fabric?

Fabric is an open-source framework for augmenting humans using AI. Patterns are reusable prompt templates that solve specific tasks—summarization, analysis, code review, content extraction, and more.

## Repository Structure

```
fabric-patterns/
├── patterns/
│   ├── summarize/              # Upstream community patterns
│   ├── extract_wisdom/         # Upstream community patterns
│   ├── abs_*/                  # AutoBridge custom patterns (protected)
│   └── autobridge_*/           # AutoBridge custom patterns (protected)
├── scripts/
│   └── sync-upstream.sh        # Upstream synchronization script
├── .upstream-tracking          # Tracks last synced upstream commit
└── README.md
```

## Synchronization with Upstream

This repo syncs patterns from [danielmiessler/fabric](https://github.com/danielmiessler/fabric) while preserving our custom patterns.

### How It Works

1. **Upstream patterns** are pulled from `danielmiessler/fabric/data/patterns/`
2. **Custom patterns** (prefixed with `abs_` or `autobridge_`) are excluded from sync and never overwritten
3. The `.upstream-tracking` file records the last synced commit SHA

### Running a Sync

```bash
./scripts/sync-upstream.sh
```

This will:
- Sparse-clone the upstream repo (only patterns, ~1MB)
- Rsync patterns to `patterns/`, overwriting upstream ones
- Preserve all `abs_*` and `autobridge_*` patterns
- Update `.upstream-tracking` with the latest commit

After syncing, review and commit:
```bash
git status
git diff
git add patterns/ .upstream-tracking
git commit -m "sync: upstream patterns $(cat .upstream-tracking | head -c 7)"
```

### Conflict Strategy

| Pattern Type | On Sync |
|--------------|---------|
| Upstream (e.g., `summarize/`) | Overwritten with latest |
| Custom (`abs_*/`, `autobridge_*/`) | Preserved, never touched |

To modify an upstream pattern without losing changes on sync, copy it with your prefix:
```bash
cp -r patterns/summarize patterns/abs_summarize
# Edit patterns/abs_summarize/system.md
```

## Creating Custom Patterns

1. Create a directory with your prefix:
   ```bash
   mkdir patterns/abs_my_pattern
   ```

2. Add `system.md` (required):
   ```markdown
   # IDENTITY and PURPOSE
   You are an expert at [task].

   # STEPS
   1. First, analyze...
   2. Then, extract...

   # OUTPUT INSTRUCTIONS
   - Use Markdown
   - Be concise
   ```

3. Optionally add `user.md` for supplementary context.

## Usage with Fabric CLI

Point Fabric to this repository during setup:
```bash
fabric --setup
# When prompted for Git repository URL:
# https://github.com/AutoBridgeSystems/fabric-patterns.git
```

Or update patterns manually:
```bash
fabric --updatepatterns
```

Run a pattern:
```bash
echo "Your content" | fabric -p summarize
fabric -y "https://youtube.com/..." -p extract_wisdom
```

## Upstream Source

- **Repository:** https://github.com/danielmiessler/fabric
- **Patterns location:** `data/patterns/`
- **Current sync:** See `.upstream-tracking`
