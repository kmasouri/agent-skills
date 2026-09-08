---
name: starter-project
description: Create a minimal new project folder with a safe name, .gitignore, README.md, and initialized git repository.
---

# Starter Project

## When To Use

Use this skill when the user wants to create a fresh starter project, empty repo, scratch project, experiment folder, or minimal initialized project directory.

Do not use this skill for framework scaffolding unless the user explicitly asks for a specific framework or toolchain.

## Inputs

Ask the user for the parent location where the project folder should be created unless they already provided it.

Ask whether they want to provide a project name or skip naming. If they skip, generate a name in this format:

```text
adjective-noun-3digits
```

Use lowercase words separated by hyphens, and generate the three digits randomly. Example: `bright-harbor-042`.

## Workflow

1. Resolve the parent location to an absolute path.
2. Determine the project folder name.
3. Sanitize the folder name for filesystem and git use:
   - Use lowercase letters, digits, and hyphens.
   - Replace whitespace and underscores with hyphens.
   - Remove characters that are not letters, digits, or hyphens.
   - Collapse repeated hyphens and trim leading or trailing hyphens.
4. Create the project folder inside the parent location.
5. If the target folder already exists and is not empty, stop and ask before writing into it.
6. Create a `.gitignore` file with broadly useful defaults for local noise, editor files, logs, dependencies, build output, and environment files.
7. Create a `README.md` file with the project name as the heading and a short placeholder description.
8. Initialize git in the project folder using the default branch name `main` when the installed git version supports it.
9. Leave the working tree uncommitted unless the user asks for an initial commit.

## Default `.gitignore`

Use a compact, general-purpose `.gitignore` unless the user provides a language or framework:

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

## Output

Tell the user:

- The final project path.
- Whether git was initialized.
- What files were created.
- The next useful command, usually `cd <project-path>`.
