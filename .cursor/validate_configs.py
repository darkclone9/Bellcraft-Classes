#!/usr/bin/env python3
"""Validate every YAML config in the Bellcraft-Classes repo.

This is the closest thing this repo has to a unit test: the deliverable is
plugin configuration, and a malformed YAML file makes the corresponding
Paper/Spigot plugin fail to load (see CoreTools/README.md and NOTES.md for
real incidents where a broken skill tree stopped MMOCore from starting).

Files are parsed with a strict YAML parser. MythicMobs mob/skill files embed
Minecraft color codes such as "&5" and "&aDamage" inside unquoted scalars,
which a strict YAML parser misreads as anchors/aliases even though MythicMobs'
own lenient loader accepts them. Those specific ampersand cases are reported as
warnings, not hard failures. Anything else that fails to parse is a real error.
"""
from __future__ import annotations

import os
import sys

try:
    import yaml
except ImportError:
    sys.stderr.write(
        "PyYAML is not installed. Install it with: pip install pyyaml\n"
    )
    sys.exit(2)

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP_DIRS = {".git", "server", "userdata", "node_modules", ".cursor"}
YAML_EXTS = (".yml", ".yaml")


def parse_ok(text: str) -> bool:
    try:
        list(yaml.safe_load_all(text))
        return True
    except yaml.YAMLError:
        return False


def is_ampersand_color_code_issue(text: str, err: yaml.YAMLError) -> bool:
    """Return True if the only reason parsing fails is an unquoted '&' token
    (a Minecraft color code) being misread as a YAML anchor/alias."""
    msg = str(err).lower()
    if "anchor" not in msg and "alias" not in msg:
        return False
    # Neutralize color-code ampersands, then see if it parses cleanly.
    neutralized = text.replace("&", "A")
    return parse_ok(neutralized)


def main() -> int:
    errors: list[tuple[str, str]] = []
    warnings: list[tuple[str, str]] = []
    total = 0

    for dirpath, dirnames, filenames in os.walk(REPO_ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in sorted(filenames):
            if not name.endswith(YAML_EXTS):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, REPO_ROOT)
            total += 1
            try:
                with open(path, "r", encoding="utf-8") as fh:
                    text = fh.read()
                list(yaml.safe_load_all(text))
            except yaml.YAMLError as exc:
                first_line = str(exc).splitlines()[0][:200]
                if is_ampersand_color_code_issue(text, exc):
                    warnings.append((rel, first_line))
                else:
                    errors.append((rel, first_line))
            except OSError as exc:
                errors.append((rel, str(exc)[:200]))

    print(f"Scanned {total} YAML config files.")
    if warnings:
        print(f"\n{len(warnings)} file(s) with MythicMobs color-code ampersands "
              f"(valid for MythicMobs, flagged only by strict YAML):")
        for rel, msg in warnings:
            print(f"  WARN  {rel}: {msg}")

    if errors:
        print(f"\n{len(errors)} file(s) FAILED to parse:")
        for rel, msg in errors:
            print(f"  FAIL  {rel}: {msg}")
        print("\nResult: FAILED")
        return 1

    print(f"\nResult: OK ({total} files parsed, {len(warnings)} color-code warnings)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
