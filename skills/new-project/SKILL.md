---
name: new-project
description: Create a new project folder, either minimal (safe name, .gitignore, README.md, initialized git) or scaffolded from a registered project template such as the layered Fastify/TypeScript service template. Use when the user wants to start, create, or scaffold a new project, repo, service, or API.
---

# New Project

## When To Use

Use this skill when the user wants to create a fresh project, empty repo, scratch project, experiment folder, or a new service from one of their templates.

Registered templates are listed in `references/templates.md`. If the user asks for a framework or stack that has no registered template, create a minimal project and say that no template exists for that stack. Do not improvise a framework scaffold unless the user explicitly asks for one.

## Inputs

1. **Template.** Ask which template to use unless the user already named one. Offer every template listed in `references/templates.md`, plus **None (minimal project)**. When the user's request clearly matches one template (for example "new Fastify service"), preselect it and confirm, instead of asking open-ended.
2. **Parent location.** Ask where the project folder should be created unless the user already provided it.
3. **Project name.** Ask whether the user wants to provide a name or skip naming. If they skip, generate a name in the format `adjective-noun-3digits`, using lowercase words separated by hyphens and three random digits. Example: `bright-harbor-042`.
4. **Template-specific inputs.** If a template was chosen, collect the extra inputs listed in that template's entry in `references/templates.md`. Ask them together in one question round, with sensible defaults filled in.

## Workflow

Always:

1. Resolve the parent location to an absolute path.
2. Determine the project folder name, and sanitize it for filesystem and git use:
   - Use lowercase letters, digits, and hyphens.
   - Replace whitespace and underscores with hyphens.
   - Remove characters that are not letters, digits, or hyphens.
   - Collapse repeated hyphens and trim leading or trailing hyphens.
3. If the target folder already exists and is not empty, stop and ask before writing into it.

### No template (minimal project)

4. Create the project folder inside the parent location.
5. Create a `.gitignore` file with broadly useful defaults for local noise, editor files, logs, dependencies, build output, and environment files.
6. Create a `README.md` file with the project name as the heading and a short placeholder description.
7. Initialize git in the project folder using the default branch name `main` when the installed git version supports it.
8. Leave the working tree uncommitted unless the user asks for an initial commit.

### From a template

4. Read the template's entry in `references/templates.md`.
5. Resolve the template source as that entry describes (a local checkout first, otherwise the git URL).
6. Run the template's scaffold script with the collected inputs. Scripts live in this skill's `scripts/` folder and create the folder, copy the template, rename the placeholders, and initialize git.
7. If the script reports a failed `npm run check` or any other error, show the relevant output, fix the cause if it is clearly a scaffolding problem, and rerun. Do not report success while checks fail.
8. Apply any follow-up steps the template entry lists, such as removing the example feature, only if the user asked for them.
9. Leave the working tree uncommitted unless the user asks for an initial commit.

## Default `.gitignore`

Use a compact, general-purpose `.gitignore` for minimal projects unless the user provides a language or framework:

```gitignore
.DS_Store
Thumbs.db

.env
.env.*
!.env.example

*.log

.vscode/
.idea/

node_modules/
vendor/

dist/
build/
coverage/

__pycache__/
*.py[cod]
```

Template projects bring their own `.gitignore`; do not overwrite it.

## Output

Tell the user:

- The final project path.
- Which template was used (or none), and where it was copied from.
- Whether git was initialized, and that nothing is committed yet.
- For template projects: the names that were substituted, and the result of `npm run check`.
- The next useful commands, usually `cd <project-path>`, plus any next steps from the template entry.
