# PR Test Plan - CI test summary + Codecov

## Scope

Validate the PR workflow changes that add:

- Flutter test result summary (OK/RED)
- Line coverage extraction from `coverage/lcov.info`
- Sticky PR comment with test + coverage summary
- Coverage upload to Codecov using `CODECOV_TOKEN`

## Preconditions

- Repository secret `CODECOV_TOKEN` exists in GitHub Actions secrets.
- PR is opened against the default branch.
- Workflow `PR Web Preview` is enabled.

## Test Cases

### 1) Happy path: all tests pass

1. Push a commit with passing tests.
2. Wait for `PR Web Preview` workflow to finish.

Expected:

- Job succeeds.
- A PR comment exists (or is updated) with marker `<!-- test-coverage-summary-comment -->`.
- Comment shows:
  - `Status: OK`
  - non-zero `Total`
  - `Failed: 0`
  - coverage percentage with two decimals.
- Workflow summary (`GITHUB_STEP_SUMMARY`) contains the same test block.
- Codecov receives the uploaded report and updates the PR status/check.

### 2) Failure path: at least one test fails

1. Push a commit that intentionally breaks one unit test.
2. Wait for workflow execution.

Expected:

- Job fails on the test step.
- PR comment for test summary is not updated for this failed run (because subsequent steps do not execute).
- Existing sticky comment from previous successful run remains unchanged.

### 3) Sticky comment behavior

1. Push two consecutive passing commits.

Expected:

- Only one test summary comment exists.
- Latest run overwrites previous comment content (same marker).

### 4) Codecov token validation

1. Temporarily remove or invalidate `CODECOV_TOKEN`.
2. Push a passing commit.

Expected:

- Workflow continues (because `fail_ci_if_error: false`).
- Codecov step reports upload/auth problem in logs.
- Test summary comment is still posted.

## Evidence to attach in PR

- Screenshot of PR comment with `Status: OK` and coverage.
- Link/screenshot of Codecov PR check.
- Link to successful GitHub Actions run.

## Rollback

If regression is detected, revert `preview.yml` CI summary/Codecov blocks and keep baseline `flutter test` flow.
