---
name: basic-code-review
description: Review code changes for correctness, regressions, security risks, and missing tests.
---

# Basic Code Review

## When To Use

Use this skill when the user asks for a code review, PR review, diff review, or risk-focused review of code changes.

Do not use this skill for broad refactoring, implementation work, or style-only feedback unless the user asks for that explicitly.

## Workflow

1. Identify the changed files, touched behavior, and user-visible impact.
2. Prioritize findings that could cause bugs, regressions, data loss, security issues, performance problems, or broken workflows.
3. Check whether tests cover the changed behavior and important edge cases.
4. Ignore purely subjective style issues unless they hide a real maintainability or correctness problem.
5. If there are no actionable issues, say so clearly and mention any remaining test gaps or residual risks.

## Output

Lead with findings ordered by severity.

For each finding, include:

- A short title.
- The affected file and line when available.
- Why it matters.
- The smallest practical fix or verification step.

After findings, include open questions or assumptions only when they affect confidence.
