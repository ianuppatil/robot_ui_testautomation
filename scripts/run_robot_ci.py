from __future__ import annotations

import os
import shutil
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import TypedDict


class RobotResults(TypedDict):
    passed: int
    failed: int
    skipped: int
    total: int
    challenge_detected: bool
    all_skipped_due_to_challenge: bool


def build_robot_command(output_dir: Path, suite_path: str) -> list[str]:
    command = [
        sys.executable,
        "-m",
        "robot",
        "--outputdir",
        str(output_dir),
        "--xunit",
        str(output_dir / "xunit.xml"),
        "--variable",
        f"HEADLESS:{os.getenv('HEADLESS', 'true')}",
        "--variable",
        f"SKIP_ON_AMAZON_CHALLENGE:{os.getenv('SKIP_ON_AMAZON_CHALLENGE', 'true')}",
        "--variable",
        f"BROWSER:{os.getenv('BROWSER', 'chrome')}",
    ]

    chrome_binary = os.getenv("CHROME_BINARY", "").strip()
    if chrome_binary:
        command.extend(["--variable", f"CHROME_BINARY:{chrome_binary}"])

    driver_path = os.getenv("DRIVER_PATH", "").strip()
    if driver_path:
        command.extend(["--variable", f"DRIVER_PATH:{driver_path}"])

    command.append(suite_path)
    return command


def parse_robot_results(output_xml: Path) -> RobotResults:
    tree = ET.parse(output_xml)
    root = tree.getroot()

    total_stat = root.find("./statistics/total/stat")
    if total_stat is None:
        raise RuntimeError(f"Could not find total statistics in {output_xml}")

    passed = int(total_stat.attrib.get("pass", "0"))
    failed = int(total_stat.attrib.get("fail", "0"))
    skipped = int(total_stat.attrib.get("skip", "0"))
    total = passed + failed + skipped

    texts: list[str] = []
    for msg in root.findall(".//msg"):
        text = (msg.text or "").strip()
        if text:
            texts.append(text)

    combined_text = "\n".join(texts)
    challenge_detected = "Amazon challenge/captcha detected" in combined_text
    all_skipped_due_to_challenge = total > 0 and skipped == total and failed == 0 and challenge_detected

    return {
        "passed": passed,
        "failed": failed,
        "skipped": skipped,
        "total": total,
        "challenge_detected": challenge_detected,
        "all_skipped_due_to_challenge": all_skipped_due_to_challenge,
    }


def write_summary(message: str) -> None:
    summary_path = os.getenv("GITHUB_STEP_SUMMARY", "").strip()
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as summary_file:
            summary_file.write(message + "\n")


def main() -> int:
    project_root = Path(__file__).resolve().parents[1]
    output_dir = project_root / os.getenv("ROBOT_OUTPUTDIR", "reports")
    suite_path = os.getenv("ROBOT_SUITE", "tests/amazon_smoke_tests.robot")
    max_attempts = int(os.getenv("ROBOT_MAX_ATTEMPTS", "2"))
    retry_delay_seconds = int(os.getenv("ROBOT_RETRY_DELAY_SECONDS", "20"))

    for attempt in range(1, max_attempts + 1):
        if output_dir.exists():
            shutil.rmtree(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

        command = build_robot_command(output_dir, suite_path)
        print(f"Running Robot attempt {attempt}/{max_attempts}: {' '.join(command)}", flush=True)
        completed = subprocess.run(command, cwd=project_root)

        output_xml = output_dir / "output.xml"
        if not output_xml.exists():
            print("Robot did not produce output.xml", file=sys.stderr, flush=True)
            return completed.returncode or 1

        results = parse_robot_results(output_xml)
        passed = int(results["passed"])
        failed = int(results["failed"])
        skipped = int(results["skipped"])
        total = int(results["total"])
        all_skipped_due_to_challenge = bool(results["all_skipped_due_to_challenge"])

        print(
            f"Robot results: total={total}, passed={passed}, failed={failed}, skipped={skipped}, "
            f"all_skipped_due_to_challenge={all_skipped_due_to_challenge}",
            flush=True,
        )

        if failed > 0:
            write_summary(
                "## Robot UI Tests\n"
                f"- Result: **FAILED**\n"
                f"- Passed: {passed}\n"
                f"- Failed: {failed}\n"
                f"- Skipped: {skipped}\n"
                f"- Attempt: {attempt}/{max_attempts}"
            )
            return 1

        if passed > 0:
            write_summary(
                "## Robot UI Tests\n"
                f"- Result: **PASSED**\n"
                f"- Passed: {passed}\n"
                f"- Failed: {failed}\n"
                f"- Skipped: {skipped}\n"
                f"- Attempt: {attempt}/{max_attempts}"
            )
            return 0

        if all_skipped_due_to_challenge and attempt < max_attempts:
            print(
                f"Amazon challenge detected on all tests. Waiting {retry_delay_seconds}s before retry...",
                flush=True,
            )
            time.sleep(retry_delay_seconds)
            continue

        if all_skipped_due_to_challenge:
            warning = (
                "Amazon challenge/captcha blocked the GitHub-hosted runner IP. "
                "All tests were skipped intentionally for CI stability. "
                "Use a self-hosted runner for reliable Amazon UI execution."
            )
            print(f"::warning::{warning}", flush=True)
            write_summary(
                "## Robot UI Tests\n"
                "- Result: **SKIPPED**\n"
                f"- Passed: {passed}\n"
                f"- Failed: {failed}\n"
                f"- Skipped: {skipped}\n"
                f"- Attempts: {attempt}/{max_attempts}\n"
                "- Reason: Amazon challenge/captcha page blocked the hosted runner IP.\n"
                "- Recommendation: Run full Amazon UI tests on a `self-hosted` runner."
            )
            return 0

        write_summary(
            "## Robot UI Tests\n"
            "- Result: **UNEXPECTED SKIP STATE**\n"
            f"- Passed: {passed}\n"
            f"- Failed: {failed}\n"
            f"- Skipped: {skipped}\n"
            f"- Attempt: {attempt}/{max_attempts}"
        )
        print(
            "Robot finished without failures but did not pass any tests, and the skip reason was not the Amazon challenge page.",
            file=sys.stderr,
            flush=True,
        )
        return completed.returncode or 1

    return 1


if __name__ == "__main__":
    raise SystemExit(main())

