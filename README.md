# AutoBridge Fabric Patterns

A curated collection of [Fabric](https://github.com/danielmiessler/fabric) AI patterns and strategies, synchronized with the upstream community repository. Includes official Claude Code Skills integration.

## What is Fabric?

Fabric is an open-source framework for augmenting humans using AI. Patterns are reusable prompt templates that solve specific tasks—summarization, analysis, code review, content extraction, and more. Strategies are prompt engineering techniques (Chain of Thought, Tree of Thought, etc.) that enhance AI reasoning.

## Repository Structure

```
fabric-patterns/
├── .claude/
│   └── skills/
│       └── fabric-patterns/
│           └── SKILL.md        # Claude Code Skills integration
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

## Claude Code Skills Integration (Recommended)

This repository includes an official [Claude Code Skills](https://code.claude.com/docs/en/skills) integration. Skills are model-invoked—Claude automatically activates them based on your request.

### How It Works

```
You: "Summarize this research paper"
        │
        ▼
┌─────────────────────────────────────┐
│ Claude reads skill descriptions     │
│ → Matches "fabric-patterns" skill   │
│ → Loads SKILL.md                    │
│ → Reads data/patterns/summarize_paper/system.md
│ → Applies pattern methodology       │
└─────────────────────────────────────┘
        │
        ▼
Structured summary using Fabric's format
```

### Installation

**Option 1: Project-level (share with team via git)**
```bash
# Clone this repo into your project
git clone https://github.com/AutoBridgeSystems/fabric-patterns.git

# The .claude/skills/ directory is automatically discovered by Claude Code
```

**Option 2: Personal (available across all projects)**
```bash
# Clone to your personal skills directory
git clone https://github.com/AutoBridgeSystems/fabric-patterns.git ~/.claude/skills/fabric-patterns
```

**Option 3: Symlink (recommended for development)**
```bash
# Clone once, symlink to skills
git clone https://github.com/AutoBridgeSystems/fabric-patterns.git ~/fabric-patterns
ln -s ~/fabric-patterns/.claude/skills/fabric-patterns ~/.claude/skills/fabric-patterns
```

**After installation, restart Claude Code** for skills to be discovered. Verify with:
```
What skills are available?
```

### Usage

Once installed, Claude automatically uses Fabric patterns when relevant. Just ask naturally:

```bash
# Claude will use extract_wisdom pattern
"Extract the key insights from this document"

# Claude will use summarize pattern
"Give me a summary of this paper"

# Claude will use review_code pattern
"Review this code for issues"

# Claude will use create_prd pattern
"Create a PRD for this feature"
```

### Available Patterns

| Category | Patterns | Use When |
|----------|----------|----------|
| **Summarize** | `summarize`, `summarize_paper`, `summarize_meeting`, `summarize_git_diff` | Condensing content |
| **Analyze** | `analyze_claims`, `analyze_prose`, `analyze_logs`, `review_code` | Evaluating content |
| **Extract** | `extract_wisdom`, `extract_ideas`, `extract_recommendations` | Pulling insights |
| **Create** | `create_prd`, `create_user_story`, `write_pull-request` | Generating documents |
| **Improve** | `improve_writing`, `improve_prompt`, `improve_academic_writing` | Enhancing content |

Full list: `ls data/patterns/` (232 patterns)

### Architecture: Progressive Disclosure

Following [Anthropic's best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), this skill uses **progressive disclosure**:

1. **SKILL.md** (~80 lines) - Small routing document loaded when skill activates
2. **Pattern files** - Read on-demand only when needed
3. **Zero context cost** - Unused patterns don't consume tokens

This allows 232+ patterns without context bloat.

---

## Fabric CLI Usage (Alternative)

You can also use these patterns with the standalone Fabric CLI tool.

### Setup

Point Fabric to this repository during setup:
```bash
fabric --setup
# When prompted for Git repository URL (patterns):
# https://github.com/AutoBridgeSystems/fabric-patterns.git
# When prompted for Git repository URL (strategies):
# https://github.com/AutoBridgeSystems/fabric-patterns.git
```

### Usage

```bash
# Summarize content
echo "Your content" | fabric -p summarize

# Extract wisdom from YouTube
fabric -y "https://youtube.com/..." -p extract_wisdom

# Chain patterns
cat document.txt | fabric -p extract_ideas | fabric -p summarize
```

---

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

---

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

4. Update the SKILL.md if you want Claude Code to know about the new pattern.

---

## Upstream Source

- **Repository:** https://github.com/danielmiessler/fabric
- **Patterns location:** `data/patterns/`
- **Strategies location:** `data/strategies/`
- **Current sync:** See `.upstream-tracking`

## References

- [Fabric GitHub](https://github.com/danielmiessler/fabric)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
