#!/usr/bin/env python3
"""First-pass compliance evidence scanner for local Markdown rules."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable


IGNORE_DIRS = {
    ".git",
    ".idea",
    ".vscode",
    ".venv",
    "__pycache__",
    "node_modules",
    "target",
}

TEXT_EXTENSIONS = {
    "",
    ".css",
    ".csv",
    ".env",
    ".gitignore",
    ".groovy",
    ".har",
    ".html",
    ".java",
    ".js",
    ".json",
    ".jsp",
    ".md",
    ".properties",
    ".py",
    ".scala",
    ".sh",
    ".side",
    ".toml",
    ".ts",
    ".txt",
    ".xml",
    ".yaml",
    ".yml",
}

STOPWORDS = {
    "about",
    "against",
    "another",
    "before",
    "between",
    "current",
    "document",
    "during",
    "evidence",
    "explain",
    "include",
    "instead",
    "local",
    "project",
    "provide",
    "required",
    "should",
    "source",
    "through",
    "unless",
    "using",
    "where",
    "which",
    "while",
}


@dataclass
class Rule:
    number: int
    line: int
    text: str


@dataclass
class Finding:
    status: str
    rule_number: int
    line: int
    rule: str
    evidence_terms: list[str]
    found_terms: list[str]
    missing_terms: list[str]
    note: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate a target path against Markdown compliance rules."
    )
    parser.add_argument("--target", default=".", help="Project, folder, or file to scan.")
    parser.add_argument(
        "--rules",
        default=".agents/rules/compliance.md",
        help="Markdown compliance rules file.",
    )
    parser.add_argument(
        "--format",
        choices=("text", "json"),
        default="text",
        help="Output format.",
    )
    parser.add_argument(
        "--fail-on",
        choices=("fail", "warn", "manual"),
        default="fail",
        help="Lowest status that should produce exit code 1.",
    )
    return parser.parse_args()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def parse_rules(rules_path: Path) -> list[Rule]:
    rules: list[Rule] = []
    bullet_pattern = re.compile(r"^\s*(?:[-*+]|\d+[.)])\s+(?P<text>.+?)\s*$")
    for line_no, line in enumerate(read_text(rules_path).splitlines(), start=1):
        match = bullet_pattern.match(line)
        if not match:
            continue
        text = re.sub(r"\s+", " ", match.group("text")).strip()
        if text:
            rules.append(Rule(number=len(rules) + 1, line=line_no, text=text))
    return rules


def is_text_file(path: Path) -> bool:
    if path.name in {"Dockerfile", "Jenkinsfile", "Makefile"}:
        return True
    return path.suffix.lower() in TEXT_EXTENSIONS


def iter_target_files(target: Path) -> Iterable[Path]:
    if target.is_file():
        if is_text_file(target):
            yield target
        return

    for root, dirs, files in os.walk(target):
        dirs[:] = [directory for directory in dirs if directory not in IGNORE_DIRS]
        for filename in files:
            path = Path(root) / filename
            if is_text_file(path):
                yield path


def build_corpus(files: list[Path], root: Path) -> str:
    chunks: list[str] = []
    for path in files:
        try:
            rel = path.relative_to(root)
        except ValueError:
            rel = path
        chunks.append(str(rel).lower())
        try:
            chunks.append(read_text(path).lower())
        except OSError:
            continue
    return "\n".join(chunks)


def extract_terms(rule_text: str) -> list[str]:
    terms: list[str] = []
    terms.extend(re.findall(r"`([^`]+)`", rule_text))
    terms.extend(re.findall(r"https?://[^\s,)]+", rule_text))
    terms.extend(re.findall(r"\b[\w.-]+/[\w./:-]+", rule_text))
    terms.extend(re.findall(r"\b[\w-]+\.(?:md|jsp|war|har|side|pdf|xml|yml|yaml|json|sh|py)\b", rule_text, re.I))
    terms.extend(re.findall(r"\b\d{2,5}\b", rule_text))

    if not terms:
        words = re.findall(r"\b[a-zA-Z][a-zA-Z0-9_-]{3,}\b", rule_text)
        terms.extend(word for word in words if word.lower() not in STOPWORDS)

    normalized: list[str] = []
    seen: set[str] = set()
    for term in terms:
        cleaned = term.strip("`'\".,;:()[]{}").lower()
        if len(cleaned) < 3 or cleaned in seen:
            continue
        seen.add(cleaned)
        normalized.append(cleaned)
    return normalized[:8]


def classify_rule(rule: Rule, corpus: str) -> Finding:
    terms = extract_terms(rule.text)
    found = [term for term in terms if term in corpus]
    missing = [term for term in terms if term not in corpus]
    lowered = rule.text.lower()

    if not terms:
        status = "manual"
        note = "No concrete evidence tokens were extracted from this rule."
    elif any(marker in lowered for marker in ("do not", "must not", "never ")):
        status = "manual"
        note = "Negative rule requires manual review for prohibited behavior."
    elif missing and found:
        status = "warn"
        note = "Some expected evidence tokens were not found."
    elif missing:
        status = "warn"
        note = "No direct evidence found for this rule."
    else:
        status = "pass"
        note = "All extracted evidence tokens were found."

    return Finding(
        status=status,
        rule_number=rule.number,
        line=rule.line,
        rule=rule.text,
        evidence_terms=terms,
        found_terms=found,
        missing_terms=missing,
        note=note,
    )


def render_text(payload: dict) -> str:
    lines = [
        "Compliance validation",
        f"Rules: {payload['rules_path']}",
        f"Target: {payload['target_path']}",
        f"Rules parsed: {payload['rules_count']}",
        f"Files scanned: {payload['files_scanned']}",
        "Status counts: "
        + ", ".join(f"{key}={value}" for key, value in payload["status_counts"].items()),
        "",
    ]
    for item in payload["findings"]:
        if item["status"] == "pass":
            continue
        lines.extend(
            [
                f"[{item['status'].upper()}] rule {item['rule_number']} line {item['line']}: {item['rule']}",
                f"  note: {item['note']}",
                f"  found: {', '.join(item['found_terms']) or '-'}",
                f"  missing: {', '.join(item['missing_terms']) or '-'}",
                "",
            ]
        )
    if not any(item["status"] != "pass" for item in payload["findings"]):
        lines.append("No warnings or manual-review items found by the heuristic scanner.")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    args = parse_args()
    root = Path.cwd()
    rules_path = (root / args.rules).resolve()
    target_path = (root / args.target).resolve()

    if not rules_path.exists():
        fallback = root / ".agents/rules/contribution.md"
        message = {
            "error": "rules file not found",
            "rules_path": str(rules_path),
            "hint": "Create .agents/rules/compliance.md or pass --rules explicitly.",
            "fallback_exists": fallback.exists(),
            "fallback_path": str(fallback),
        }
        if args.format == "json":
            print(json.dumps(message, indent=2, sort_keys=True))
        else:
            print(f"ERROR: rules file not found: {rules_path}", file=sys.stderr)
            print("Create .agents/rules/compliance.md or pass --rules explicitly.", file=sys.stderr)
            if fallback.exists():
                print(f"Available alternate rule file: {fallback}", file=sys.stderr)
        return 2

    if not target_path.exists():
        print(f"ERROR: target path not found: {target_path}", file=sys.stderr)
        return 2

    rules = parse_rules(rules_path)
    files = list(iter_target_files(target_path))
    corpus = build_corpus(files, target_path if target_path.is_dir() else target_path.parent)
    findings = [classify_rule(rule, corpus) for rule in rules]
    status_counts = {"pass": 0, "warn": 0, "manual": 0, "fail": 0}
    for finding in findings:
        status_counts[finding.status] += 1

    payload = {
        "rules_path": str(rules_path),
        "target_path": str(target_path),
        "rules_count": len(rules),
        "files_scanned": len(files),
        "status_counts": status_counts,
        "findings": [asdict(finding) for finding in findings],
    }

    if args.format == "json":
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(render_text(payload), end="")

    fail_order = {"fail": 0, "warn": 1, "manual": 2}
    threshold = args.fail_on
    if threshold == "fail":
        return 1 if status_counts["fail"] else 0
    if threshold == "warn":
        return 1 if status_counts["fail"] or status_counts["warn"] else 0
    if threshold == "manual":
        return 1 if status_counts["fail"] or status_counts["warn"] or status_counts["manual"] else 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
