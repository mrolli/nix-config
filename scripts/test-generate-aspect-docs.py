#!/usr/bin/env python3
"""Focused tests for generate-aspect-docs.py."""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("generate-aspect-docs.py")
SPEC = importlib.util.spec_from_file_location("generate_aspect_docs", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)

REPO_URL = "https://github.com/example/repo"


class GeneratorTests(unittest.TestCase):
    def test_updates_only_managed_block(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "modules").mkdir()
            (root / "docs").mkdir()
            (root / "modules" / "example.nix").write_text(
                "{ ... }:\n"
                "# @doc id=example target=docs/example.md\n"
                "# ## Generated\n"
                "#\n"
                "# Updated text.\n"
                "# @enddoc\n"
            )
            target = root / "docs" / "example.md"
            target.write_text(
                "# Curated title\n\n"
                "<!-- BEGIN GENERATED: example -->\n"
                "old text\n"
                "<!-- END GENERATED: example -->\n\n"
                "Curated footer.\n"
            )

            documents = MODULE.parse_sources(root)
            self.assertTrue(MODULE.update_target(documents[0], root, REPO_URL))
            result = target.read_text()
            self.assertIn("# Curated title", result)
            self.assertIn("## Generated", result)
            self.assertIn("Curated footer.", result)
            self.assertNotIn("old text", result)
            self.assertIn(
                "[Source: `modules/example.nix`]"
                "(https://github.com/example/repo/blob/HEAD/modules/example.nix)",
                result,
            )

    def test_missing_block_is_appended(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "modules").mkdir()
            (root / "docs").mkdir()
            (root / "modules" / "example.nix").write_text(
                "# @doc id=example target=docs/example.md\n"
                "# Content.\n"
                "# @enddoc\n"
            )
            target = root / "docs" / "example.md"
            target.write_text("# Existing\n")
            document = MODULE.parse_sources(root)[0]

            self.assertTrue(MODULE.update_target(document, root, REPO_URL))
            self.assertIn("BEGIN GENERATED: example", target.read_text())

    def test_repo_url_is_read_from_zensical_toml(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "zensical.toml").write_text(
                '[project]\nrepo_url = "https://github.com/example/repo/"\n'
            )
            self.assertEqual(MODULE.load_repo_url(root), REPO_URL)

    def test_missing_repo_url_fails(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with self.assertRaisesRegex(ValueError, "repo_url is not set in zensical.toml"):
                MODULE.load_repo_url(root)
            (root / "zensical.toml").write_text('[project]\nsite_name = "x"\n')
            with self.assertRaisesRegex(ValueError, "repo_url is not set in zensical.toml"):
                MODULE.load_repo_url(root)

    def test_stale_block_is_removed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            docs = root / "docs"
            docs.mkdir()
            target = docs / "example.md"
            target.write_text(
                "# Existing\n\n"
                "<!-- BEGIN GENERATED: removed -->\n"
                "obsolete\n"
                "<!-- END GENERATED: removed -->\n\n"
                "Footer\n"
            )

            self.assertEqual(MODULE.cleanup_stale_blocks(root, set(), False), 1)
            result = target.read_text()
            self.assertNotIn("removed", result)
            self.assertIn("# Existing", result)
            self.assertIn("Footer", result)


if __name__ == "__main__":
    unittest.main()
