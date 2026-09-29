# Project Templates

Each entry describes one template that `new-project` can scaffold. To register a new template, add an entry with the same fields, and add a scaffold script under `scripts/` if the template needs renaming.

---

## fastify-service

A layered Fastify/TypeScript API service with:

- routes, handlers, services and repositories layers
- Zod request validation and types
- Postgres
- Swagger UI
- Jest tests
- a Dockerfile
- Terraform for AWS ECS Fargate
- GitHub Actions for CI, Release Please releases, and deploys

It includes an example `items` feature that shows every layer.

**Offer it when** the user wants a new backend service, REST API, or Fastify/Node/TypeScript service.

### Source

Use the first source that exists:

1. Local checkout: `~/Documents/github.com/kmasouri/fastify-service-template`
2. Git URL: `https://github.com/kmasouri/fastify-service-template.git`

When the source is a git checkout with commits, the script copies only committed files. Uncommitted template edits are not carried over, so mention that if `git -C <source> status --short` shows changes.

### Inputs

| Input       | Flag            | Default                                    | Notes                                                                               |
| ----------- | --------------- | ------------------------------------------ | ----------------------------------------------------------------------------------- |
| Name        | `--name`        | the project folder name                    | kebab-case; becomes the npm package name and the Release Please package name         |
| Title       | `--title`       | the name in Title Case (`orders-api` → `Orders Api`) | Shown in the README heading and the Swagger title. Suggest fixing acronyms, e.g. `Orders API`. |
| AWS prefix  | `--aws-prefix`  | the name                                   | 16 characters or fewer; prefixes every AWS resource name. Suggest a short one, e.g. `orders`. |
| GitHub repo | `--github-repo` | `kmasouri/<name>`                          | `owner/repo` allowed to assume the deploy role through OIDC                         |
| Install     | `--no-install`  | install and run checks                     | Pass `--no-install` only if the user asks, or there is no network access.           |

The Postgres schema name is always derived from the name in snake_case (`orders-api` → `orders_api`).

### Command

```bash
<skill-dir>/scripts/scaffold-fastify-service.sh \
  --source <template-source> \
  --dest <parent>/<name> \
  --name <name> \
  --title "<Title>" \
  --aws-prefix <prefix> \
  --github-repo <owner/repo>
```

### Optional follow-up: remove the example feature

Only do this if the user asks for it. Recommend keeping `items` until the first real feature exists, because the docs use it as the reference implementation.

1. Delete these:
   - `src/routes/items/`
   - `src/handlers/items/`
   - `src/services/items/`
   - `src/data/items/`
   - `src/observability/loggers/items/`
   - `src/plugins/item.ts`
   - `db/schema/001_items.sql`
2. Remove the `items` re-exports from:
   - `src/routes/index.ts`
   - `src/handlers/index.ts`
   - `src/data/index.ts`
   - `src/observability/loggers/index.ts`
3. In `src/app.ts`, remove the `itemPlugin` import and registration, and the `itemsRouter` registration.
4. Remove `Item` from `src/shared/types.ts`, leaving the file with a comment placeholder.
5. In `src/app.test.ts`, remove the OpenAPI `/items` test and the `/items` validation cases.
6. Remove the `/items` endpoints from the README API list and the `psql ... 001_items.sql` line.
7. Check `docs/architecture.md` and `docs/adding-a-feature.md`, and update any wording that points to `items` as a file that exists.
8. Empty barrel files can break the build (`export {}` is fine). Run `npm run check` and fix anything it reports.

### Next steps to tell the user

- `cd <path> && cp .env.example .env`, set the database settings, then `npm run dev`.
- Apply `db/schema/*.sql` to the database in filename order.
- Read `AGENTS.md` and `docs/adding-a-feature.md` before adding endpoints.
- To deploy: create the GitHub repo, apply `infrastructure/` with Terraform, then set up the GitHub `sandbox` environment. Its secrets and variables are listed in the service README.
