# Agent Skills

Portable skills for AI coding agents such as Codex and Claude.

## Structure

Each skill is a folder with a required `SKILL.md` file:

```text
skills/
  my-skill/
    SKILL.md
    references/
    scripts/
    assets/
```

Keep the portable core simple:

- Use `name` and `description` in YAML frontmatter.
- Write the description as a clear trigger for when the skill should apply.
- Put long docs, schemas, examples, or checklists in `references/`.
- Put deterministic repeatable work in `scripts/`.
- Put reusable templates or media in `assets/`.
- Avoid agent-specific metadata in the portable skill unless an adapter needs it.

## Install Locally

On Linux or macOS, run:

```bash
./scripts/install.sh
```

The installer uses only built-in shell commands. By default, it symlinks all skills into both Codex and Claude Code skill directories so updates to this repo are picked up automatically.

Install only one skill:

```bash
./scripts/install.sh new-project
```

Install to one agent:

```bash
./scripts/install.sh --target codex
./scripts/install.sh --target claude
```

Replace an existing installed skill:

```bash
./scripts/install.sh --force
```

Copy instead of symlinking:

```bash
./scripts/install.sh --copy --force
```

For Codex, skills install into:

```bash
~/.codex/skills
```

For Claude Code, skills install into:

```bash
~/.claude/skills
```

Project-scoped skills can also live in repo-local agent skill directories when supported by the agent.

## Skills

- `skills/new-project`: create a minimal project folder with `.gitignore`, `README.md`, and initialized git.
