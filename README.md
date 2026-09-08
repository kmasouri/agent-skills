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

For Codex, copy or symlink skills into:

```bash
~/.codex/skills
```

For Claude Code, copy or symlink skills into:

```bash
~/.claude/skills
```

Project-scoped skills can also live in repo-local agent skill directories when supported by the agent.

## Skills

- `skills/starter-project`: create a minimal project folder with `.gitignore`, `README.md`, and initialized git.
