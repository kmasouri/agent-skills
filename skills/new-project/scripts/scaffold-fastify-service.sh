#!/usr/bin/env bash
# Scaffold a new service from the fastify-service-template.
#
# Usage:
#   scaffold-fastify-service.sh --source <dir|git-url> --dest <new-project-dir> --name <kebab-name> \
#     [--aws-prefix <prefix>] [--title <Title>] [--github-repo <owner/repo>] [--no-install]
#
# Copies the template (committed files only when the source is a git checkout with commits),
# replaces the template's placeholder names, strips template-only README content, initializes git,
# and runs npm install + npm run check unless --no-install is given. The working tree is left
# uncommitted.

set -euo pipefail

usage() {
  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-1}"
}

die() {
  echo "error: $*" >&2
  exit 1
}

SOURCE=""
DEST=""
NAME=""
AWS_PREFIX=""
TITLE=""
GITHUB_REPO=""
INSTALL=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SOURCE="${2:-}"; shift 2 ;;
    --dest) DEST="${2:-}"; shift 2 ;;
    --name) NAME="${2:-}"; shift 2 ;;
    --aws-prefix) AWS_PREFIX="${2:-}"; shift 2 ;;
    --title) TITLE="${2:-}"; shift 2 ;;
    --github-repo) GITHUB_REPO="${2:-}"; shift 2 ;;
    --no-install) INSTALL=0; shift ;;
    -h | --help) usage 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[[ -n "$SOURCE" && -n "$DEST" && -n "$NAME" ]] || usage

[[ "$NAME" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]] ||
  die "--name must be lowercase kebab-case starting with a letter (got '$NAME')"

# AWS resource names such as "<prefix>-<environment>-alb" are limited to 32 characters.
AWS_PREFIX="${AWS_PREFIX:-$NAME}"
[[ "$AWS_PREFIX" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]] ||
  die "--aws-prefix must be lowercase kebab-case (got '$AWS_PREFIX')"
[[ ${#AWS_PREFIX} -le 16 ]] ||
  die "--aws-prefix must be 16 characters or fewer for AWS name limits (got ${#AWS_PREFIX}); pass a shorter --aws-prefix"

SNAKE_NAME="${NAME//-/_}"
if [[ -z "$TITLE" ]]; then
  TITLE="$(echo "$NAME" | tr '-' ' ' | awk '{ for (i = 1; i <= NF; i++) $i = toupper(substr($i, 1, 1)) substr($i, 2) } 1')"
fi
GITHUB_REPO="${GITHUB_REPO:-kmasouri/$NAME}"

if [[ -e "$DEST" ]] && [[ -n "$(ls -A "$DEST" 2>/dev/null)" ]]; then
  die "destination '$DEST' already exists and is not empty"
fi

command -v perl >/dev/null || die "perl is required"
command -v git >/dev/null || die "git is required"

mkdir -p "$DEST"
DEST="$(cd "$DEST" && pwd)"

# --- Copy the template -----------------------------------------------------------------------

WORK_DIR=""
cleanup() {
  [[ -n "$WORK_DIR" ]] && rm -rf "$WORK_DIR"
}
trap cleanup EXIT

if [[ -d "$SOURCE" ]]; then
  SOURCE_DIR="$(cd "$SOURCE" && pwd)"
else
  WORK_DIR="$(mktemp -d)"
  git clone --quiet --depth 1 "$SOURCE" "$WORK_DIR/template" || die "could not clone '$SOURCE'"
  SOURCE_DIR="$WORK_DIR/template"
fi

[[ -f "$SOURCE_DIR/package.json" && -f "$SOURCE_DIR/AGENTS.md" ]] ||
  die "'$SOURCE' does not look like the fastify-service-template"

if git -C "$SOURCE_DIR" rev-parse --verify --quiet HEAD >/dev/null; then
  COPY_MODE="committed files at $(git -C "$SOURCE_DIR" rev-parse --short HEAD)"
  git -C "$SOURCE_DIR" archive --format=tar HEAD | tar -x -C "$DEST"
else
  COPY_MODE="working tree (no commits in source)"
  tar -C "$SOURCE_DIR" \
    --exclude=./.git --exclude=./node_modules --exclude=./dist --exclude=./coverage \
    --exclude=./.env --exclude='./infrastructure/.terraform' --exclude='*.tfstate*' \
    --exclude='./infrastructure/terraform.tfvars' \
    -cf - . | tar -x -C "$DEST"
fi

# --- Replace placeholder names ---------------------------------------------------------------

export NAME SNAKE_NAME TITLE AWS_PREFIX GITHUB_REPO

# Walk text files in Perl rather than grep/xargs so flags behave the same on Linux and macOS.
# Order matters: the owner/repo string contains the kebab name, so it is replaced first.
perl -MFile::Find -e '
  my @replacements = (
    [qr{kmasouri/fastify-service-template}, $ENV{GITHUB_REPO}],
    [qr{Fastify/TypeScript service template}, "Fastify/TypeScript service"],
    [qr{fastify-service-template}, $ENV{NAME}],
    [qr{fastify_service_template}, $ENV{SNAKE_NAME}],
    [qr{Fastify Service Template}, $ENV{TITLE}],
    [qr{fastify-svc}, $ENV{AWS_PREFIX}],
  );
  find({
    no_chdir => 1,
    preprocess => sub { grep { $_ ne ".git" && $_ ne "node_modules" } @_ },
    wanted => sub {
      my $path = $File::Find::name;
      return unless -f $path && -T $path;
      open(my $in, "<:raw", $path) or die "read $path: $!";
      my $content = do { local $/; <$in> };
      close($in);
      my $original = $content;
      $content =~ s/$_->[0]/$_->[1]/g for @replacements;
      return if $content eq $original;
      open(my $out, ">:raw", $path) or die "write $path: $!";
      print {$out} $content;
      close($out);
    },
  }, $ARGV[0]);
' "$DEST"

# Drop README sections that only make sense in the template itself.
perl -0pi -e 's{\n?<!-- template-only:start -->.*?<!-- template-only:end -->\n?}{\n}gs' "$DEST/README.md"

LEFTOVERS="$(grep -rnI -e 'fastify-service-template' -e 'fastify_service_template' \
  -e 'Fastify Service Template' -e 'fastify-svc' -e 'template-only' \
  --exclude-dir=.git --exclude-dir=node_modules "$DEST" || true)"
[[ -z "$LEFTOVERS" ]] || die "placeholder names remain after replacement:
$LEFTOVERS"

# --- Initialize ------------------------------------------------------------------------------

git -C "$DEST" init --quiet -b main 2>/dev/null || {
  git -C "$DEST" init --quiet
  git -C "$DEST" symbolic-ref HEAD refs/heads/main
}

CHECK_RESULT="skipped (--no-install)"
if [[ "$INSTALL" -eq 1 ]]; then
  command -v npm >/dev/null || die "npm is required unless --no-install is given"
  (cd "$DEST" && npm install --no-audit --no-fund --loglevel=error)
  if (cd "$DEST" && npm run check); then
    CHECK_RESULT="passed"
  else
    CHECK_RESULT="FAILED"
  fi
fi

cat <<EOF

Scaffolded $NAME
  path:            $DEST
  copied from:     $SOURCE ($COPY_MODE)
  package name:    $NAME
  title:           $TITLE
  postgres schema: $SNAKE_NAME
  aws prefix:      $AWS_PREFIX
  github repo:     $GITHUB_REPO (infrastructure/terraform.tfvars.example)
  git:             initialized on main, nothing committed
  npm run check:   $CHECK_RESULT
EOF

[[ "$CHECK_RESULT" != "FAILED" ]]
