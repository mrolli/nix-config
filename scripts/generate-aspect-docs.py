#!/usr/bin/env python3
"""Synchronize marked Nix documentation blocks into tracked Markdown files."""

from __future__ import annotations

import argparse
import re
import shlex
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

SOURCE_START = re.compile(r"^\s*#\s*@doc(?:\s+(.*))?$")
SOURCE_END = re.compile(r"^\s*#\s*@enddoc\s*$")
GENERATED_BLOCK = re.compile(
    r"^<!-- BEGIN GENERATED: (?P<id>[A-Za-z0-9_-]+) -->\n"
    r".*?"
    r"^<!-- END GENERATED: (?P=id) -->\n?"
    r"(?:\n<!-- GENERATED SOURCE: (?P=id) -->\n.*?"
    r"^<!-- END GENERATED SOURCE: (?P=id) -->\n?)?",
    re.MULTILINE | re.DOTALL,
)


@dataclass(frozen=True)
class Document:
    identifier: str
    target: Path
    source: Path
    content: str


def parse_sources(root: Path) -> list[Document]:
    documents: list[Document] = []
    seen: set[tuple[Path, str]] = set()

    for source in sorted((root / "modules").rglob("*.nix")):
        lines = source.read_text().splitlines()
        index = 0
        while index < len(lines):
            match = SOURCE_START.match(lines[index])
            if not match:
                index += 1
                continue

            metadata = dict(
                item.split("=", 1)
                for item in shlex.split(match.group(1) or "")
                if "=" in item
            )
            identifier = metadata.get("id")
            target_name = metadata.get("target")
            if not identifier or not target_name:
                raise ValueError(f"{source}:{index + 1}: @doc needs id= and target=")

            end = index + 1
            while end < len(lines) and not SOURCE_END.match(lines[end]):
                end += 1
            if end == len(lines):
                raise ValueError(f"{source}:{index + 1}: missing @enddoc")

            content_lines = []
            for line in lines[index + 1 : end]:
                content_lines.append(re.sub(r"^\s*# ?", "", line))
            content = "\n".join(content_lines).strip()
            target = (root / target_name).resolve()
            key = (target, identifier)
            if key in seen:
                raise ValueError(f"duplicate generated destination: {target_name} ({identifier})")
            seen.add(key)
            documents.append(
                Document(
                    identifier=identifier,
                    target=target,
                    source=source.resolve(),
                    content=content,
                )
            )
            index = end + 1

    return documents


def load_repo_url(root: Path) -> str:
    config = root / "zensical.toml"
    try:
        with config.open("rb") as handle:
            project = tomllib.load(handle).get("project", {})
    except FileNotFoundError:
        project = {}
    repo_url = project.get("repo_url")
    if not isinstance(repo_url, str) or not repo_url.strip():
        raise ValueError("repo_url is not set in zensical.toml")
    return repo_url.strip().rstrip("/")


def rendered(document: Document, root: Path, repo_url: str) -> str:
    source = document.source.relative_to(root)
    # GitHub resolves HEAD to the repository's default branch.
    source_link = f"{repo_url}/blob/HEAD/{source.as_posix()}"
    notice = f"<!-- Generated from {source}; edit the marked Nix block instead. -->"
    return (
        f"<!-- BEGIN GENERATED: {document.identifier} -->\n"
        f"{notice}\n{document.content}\n"
        f"<!-- END GENERATED: {document.identifier} -->\n\n"
        f"<!-- GENERATED SOURCE: {document.identifier} -->\n"
        f"[Source: `{source}`]({source_link})\n"
        f"<!-- END GENERATED SOURCE: {document.identifier} -->"
    )


def update_target(document: Document, root: Path, repo_url: str) -> bool:
    if not document.target.exists():
        raise FileNotFoundError(f"generated target does not exist: {document.target.relative_to(root)}")

    original = document.target.read_text()
    block = rendered(document, root, repo_url)
    pattern = re.compile(
        rf"<!-- BEGIN GENERATED: {re.escape(document.identifier)} -->\n.*?"
        rf"<!-- END GENERATED: {re.escape(document.identifier)} -->\n?"
        rf"(?:\n<!-- GENERATED SOURCE: {re.escape(document.identifier)} -->\n.*?"
        rf"<!-- END GENERATED SOURCE: {re.escape(document.identifier)} -->)?",
        re.DOTALL,
    )
    matches = list(pattern.finditer(original))
    if len(matches) > 1:
        raise ValueError(
            f"{document.target.relative_to(root)} contains multiple generated blocks "
            f"for {document.identifier!r}"
        )
    updated, replacements = pattern.subn(block, original, count=1)
    if replacements == 0:
        updated = original.rstrip() + "\n\n" + block + "\n"

    if updated != original:
        document.target.write_text(updated)
        return True
    return False


def cleanup_stale_blocks(root: Path, active_ids: set[str], check: bool) -> int:
    changed = 0
    for target in sorted((root / "docs").rglob("*.md")):
        original = target.read_text()
        stale = [match.group("id") for match in GENERATED_BLOCK.finditer(original)
                 if match.group("id") not in active_ids]
        if not stale:
            continue
        if check:
            identifiers = ", ".join(sorted(set(stale)))
            raise ValueError(
                f"{target.relative_to(root)} contains stale generated block(s): {identifiers}"
            )
        updated = GENERATED_BLOCK.sub(
            lambda match: "" if match.group("id") not in active_ids else match.group(0),
            original,
        )
        target.write_text(updated)
        changed += len(stale)
    return changed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--check", action="store_true", help="fail when generated blocks are stale")
    args = parser.parse_args()
    root = args.root.resolve()

    try:
        documents = parse_sources(root)
        repo_url = load_repo_url(root) if documents else ""
        active_ids = {document.identifier for document in documents}
        changed = 0
        changed += cleanup_stale_blocks(root, active_ids, args.check)
        for document in documents:
            if args.check:
                original = document.target.read_text()
                block = rendered(document, root, repo_url)
                pattern = re.compile(
                    rf"<!-- BEGIN GENERATED: {re.escape(document.identifier)} -->\n.*?"
                    rf"<!-- END GENERATED: {re.escape(document.identifier)} -->\n?"
                    rf"(?:\n<!-- GENERATED SOURCE: {re.escape(document.identifier)} -->\n.*?"
                    rf"<!-- END GENERATED SOURCE: {re.escape(document.identifier)} -->)?",
                    re.DOTALL,
                )
                if len(list(pattern.finditer(original))) != 1:
                    raise ValueError(
                        f"{document.target.relative_to(root)} must contain exactly one "
                        f"generated block for {document.identifier!r}"
                    )
                updated = pattern.sub(block, original, count=1)
                if updated != original:
                    raise ValueError(
                        f"stale generated block: {document.target.relative_to(root)} ({document.identifier})"
                    )
            else:
                changed += update_target(document, root, repo_url)
    except (OSError, ValueError) as error:
        print(f"generate-aspect-docs: error: {error}", file=sys.stderr)
        return 1

    if not args.check:
        print(f"Updated {changed} generated block(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
