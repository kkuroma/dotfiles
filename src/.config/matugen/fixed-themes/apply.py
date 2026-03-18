#!/usr/bin/env python3
"""Apply a fixed theme by copying pre-rendered files to matugen output paths."""
import sys, os, subprocess, shutil, tomllib
from pathlib import Path

MATUGEN_DIR = Path.home() / ".config" / "matugen"
FIXED_DIR = MATUGEN_DIR / "fixed-themes"
CONFIG = MATUGEN_DIR / "config.toml"

def apply_theme(name: str):
    theme_dir = FIXED_DIR / name
    if not theme_dir.is_dir():
        avail = [d.name for d in FIXED_DIR.iterdir() if d.is_dir()]
        print(f"Unknown theme: {name}")
        print(f"Available: {', '.join(sorted(avail))}")
        sys.exit(1)

    with open(CONFIG, "rb") as f:
        config = tomllib.load(f)

    print(f"Applying theme: {name}")
    hooks = []
    for tpl_name, tpl in config.get("templates", {}).items():
        input_path = Path(tpl["input_path"]).expanduser()
        output_path = Path(tpl["output_path"]).expanduser()
        theme_file = theme_dir / input_path.name
        if not theme_file.exists():
            print(f"  skip {tpl_name} (no {input_path.name} in theme)")
            continue
        output_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(theme_file, output_path)
        print(f"  {tpl_name} -> {output_path}")
        if hook := tpl.get("post_hook"):
            hooks.append((tpl_name, hook))

    for tpl_name, hook in hooks:
        print(f"  hook: {tpl_name}")
        subprocess.run(hook, shell=True, check=False)

    print("Done.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <theme>")
        sys.exit(1)
    apply_theme(sys.argv[1])
