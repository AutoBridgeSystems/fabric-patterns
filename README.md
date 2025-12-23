# AutoBridge Fabric Patterns

A curated collection of [Fabric](https://github.com/danielmiessler/fabric) AI patterns and strategies, synchronized with the upstream community repository.

## What is Fabric?

Fabric is an open-source framework for augmenting humans using AI. Patterns are reusable prompt templates that solve specific tasks—summarization, analysis, code review, content extraction, and more. Strategies are prompt engineering techniques (Chain of Thought, Tree of Thought, etc.) that enhance AI reasoning.

## Repository Structure

```
fabric-patterns/
├── data/
│   ├── patterns/
│   │   ├── summarize/          # Upstream community patterns
│   │   ├── extract_wisdom/     # Upstream community patterns
│   │   ├── abs_*/              # AutoBridge custom patterns (protected)
│   │   └── autobridge_*/       # AutoBridge custom patterns (protected)
│   └── strategies/
│       ├── cot.json            # Chain of Thought
│       ├── tot.json            # Tree of Thought
│       └── ...                 # Other prompt strategies
├── scripts/
│   └── sync-upstream.sh        # Upstream synchronization script
├── .upstream-tracking          # Tracks last synced upstream commit
└── README.md
```

## Synchronization with Upstream

This repo syncs patterns and strategies from [danielmiessler/fabric](https://github.com/danielmiessler/fabric) while preserving custom content.

### How It Works

1. **Upstream content** is pulled from `danielmiessler/fabric/data/patterns/` and `data/strategies/`
2. **Custom content** (prefixed with `abs_` or `autobridge_`) is excluded from sync and never overwritten
3. The `.upstream-tracking` file records the last synced commit SHA

### Running a Sync

```bash
./scripts/sync-upstream.sh
```

This will:
- Sparse-clone the upstream repo (only patterns + strategies)
- Rsync content to `data/`, overwriting upstream files
- Preserve all `abs_*` and `autobridge_*` custom content
- Update `.upstream-tracking` with the latest commit

After syncing, review and commit:
```bash
git status
git diff
git add data/ .upstream-tracking
git commit -m "sync: upstream $(cat .upstream-tracking | head -c 7)"
```

### Conflict Strategy

| Content Type | On Sync |
|--------------|---------|
| Upstream (e.g., `summarize/`, `cot.json`) | Overwritten with latest |
| Custom (`abs_*/`, `autobridge_*/`) | Preserved, never touched |

To modify an upstream pattern without losing changes on sync, copy it with your prefix:
```bash
cp -r data/patterns/summarize data/patterns/abs_summarize
# Edit data/patterns/abs_summarize/system.md
```

## Creating Custom Patterns

1. Create a directory with your prefix:
   ```bash
   mkdir data/patterns/abs_my_pattern
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
# When prompted for Git repository URL (patterns):
# https://github.com/AutoBridgeSystems/fabric-patterns.git
# When prompted for Git repository URL (strategies):
# https://github.com/AutoBridgeSystems/fabric-patterns.git
```

Or update content manually:
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
- **Strategies location:** `data/strategies/`
- **Current sync:** See `.upstream-tracking`
