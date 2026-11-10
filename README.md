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

## Install

This repo is a plugin marketplace for both Claude Code and Codex. All skills ship together as the `agent-skills` plugin.

### Claude Code

```text
/plugin marketplace add kmasouri/agent-skills
/plugin install agent-skills@kmasouri-agent-skills
```

On Claude Code 2.1.275 or later, you can do both in one step:

```text
/plugin install agent-skills --marketplace kmasouri/agent-skills
```

Installed skills are namespaced by the plugin, for example `/agent-skills:new-project`.

### Codex

```bash
codex plugin marketplace add kmasouri/agent-skills
codex plugin add agent-skills@kmasouri-agent-skills
```

To pick up new changes, run `codex plugin marketplace upgrade`.

### Adding a Skill

- Claude Code: add the skill folder to the plugin's `skills` list in `.claude-plugin/marketplace.json`.
- Codex: `.codex-plugin/plugin.json` loads everything under `skills/`, so no change is needed there. Bump its `version` when you release changes.

## Skills

- `skills/ai-delivery-impact`: measure and explain AI-assisted delivery from attributable code, pull requests, deployments, and published documentation.
- `skills/codex-insights`: analyze accessible Codex task history for work patterns, outcomes, friction, and actionable improvements.
- `skills/create-ticket`: draft engineering Jira tickets and create them in the Compass Project after explicit confirmation.
- `skills/new-project`: create a minimal project folder with `.gitignore`, `README.md`, and initialized git, or scaffold one from a registered template (see `skills/new-project/references/templates.md`), such as the `fastify-service` template.
