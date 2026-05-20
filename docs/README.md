# Robot UI Test Automation Docs

This folder contains the project documentation for the Amazon.de UI automation suite.

## Documentation Index

- `docs/README.md` (this file): quick navigation and setup summary
- `docs/Test_Flows_and_Test_Cases.docs`: detailed test flows, test cases, expected outcomes, and page-object mapping

## Quick Summary

- Framework: Robot Framework + SeleniumLibrary
- Target site: `https://www.amazon.de/`
- Browser: Chrome (headed or headless)
- Execution modes:
  - local headed
  - local headless
  - GitLab/GitHub CI headless pipeline

## GitHub Actions Behavior for Amazon.de

- The workflow uses `scripts/run_robot_ci.py` to run Robot tests in CI.
- If Amazon serves a challenge/captcha page to a GitHub-hosted runner IP, the script retries once.
- If all tests are still blocked after the retry, the workflow completes successfully and records the run as skipped with a warning/summary instead of failing due to an external anti-bot block.
- For reliable full Amazon UI execution in CI, prefer a `self-hosted` runner.

## Quick Run Commands

Install dependencies:

```powershell
python -m pip install -r requirements.txt
```

Run all tests (headed):

```powershell
robot -T tests\amazon_smoke_tests.robot
```

Run all tests (headless):

```powershell
robot -T --variable HEADLESS:true --variable BROWSER:chrome tests\amazon_smoke_tests.robot
```

Run in CI style (explicit browser binaries):

```powershell
python -m robot --outputdir reports --variable HEADLESS:true --variable BROWSER:chrome --variable CHROME_BINARY:"C:\\Path\\To\\chrome.exe" --variable DRIVER_PATH:"C:\\Path\\To\\chromedriver.exe" tests\amazon_smoke_tests.robot
```

## Audience Notes

- If you are a developer/test engineer, start with `docs/Test_Flows_and_Test_Cases.docs` section **Technical Mapping**.
- If you are a reviewer/business stakeholder, start with `docs/Test_Flows_and_Test_Cases.docs` section **Business View of Test Flows**.

