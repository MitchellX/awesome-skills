#!/usr/bin/env bash
# Analyze a project directory and output metadata as structured text.
# Usage: analyze_project.sh <project_dir>
# Output: structured metadata for README generation

set -euo pipefail

DIR="${1:-.}"

if [ ! -d "$DIR" ]; then
  echo "ERROR: $DIR is not a directory" >&2
  exit 1
fi

echo "=== PROJECT ANALYSIS ==="
echo "Directory: $(realpath "$DIR")"
echo ""

# --- File tree (max depth 3, excluding common junk) ---
echo "=== FILE TREE ==="
find "$DIR" -maxdepth 3 \
  -not -path '*/.git/*' \
  -not -path '*/.git' \
  -not -path '*/node_modules/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/venv/*' \
  -not -path '*/.venv/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/.next/*' \
  -not -path '*/.tox/*' \
  -not -path '*/target/*' \
  -not -name '*.pyc' \
  -not -name '.DS_Store' \
  | sort
echo ""

# --- Git remote (for owner/repo inference) ---
echo "=== GIT REMOTE ==="
if [ -d "$DIR/.git" ] || git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$DIR" remote -v 2>/dev/null || echo "(no remotes)"
else
  echo "(not a git repo)"
fi
echo ""

# --- Key files detection ---
echo "=== KEY FILES ==="
for f in package.json setup.py pyproject.toml Cargo.toml go.mod Makefile CMakeLists.txt \
         SKILL.md CLAUDE.md plugin.json LICENSE README.md README_CN.md \
         Dockerfile docker-compose.yml .env.example requirements.txt \
         tsconfig.json .github/workflows; do
  target="$DIR/$f"
  if [ -e "$target" ]; then
    if [ -d "$target" ]; then
      echo "[DIR]  $f/"
      ls -1 "$target" 2>/dev/null | sed 's/^/       /'
    else
      size=$(wc -c < "$target" 2>/dev/null || echo "?")
      echo "[FILE] $f ($size bytes)"
    fi
  fi
done
echo ""

# --- Language stats (rough line count by extension) ---
echo "=== LANGUAGE STATS ==="
find "$DIR" -maxdepth 4 -type f \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/venv/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/target/*' \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15
echo ""

# --- Package metadata snippets ---
echo "=== PACKAGE METADATA ==="
if [ -f "$DIR/package.json" ]; then
  echo "--- package.json (first 30 lines) ---"
  head -30 "$DIR/package.json"
  echo ""
fi
if [ -f "$DIR/pyproject.toml" ]; then
  echo "--- pyproject.toml (first 40 lines) ---"
  head -40 "$DIR/pyproject.toml"
  echo ""
fi
if [ -f "$DIR/setup.py" ]; then
  echo "--- setup.py (first 30 lines) ---"
  head -30 "$DIR/setup.py"
  echo ""
fi
if [ -f "$DIR/Cargo.toml" ]; then
  echo "--- Cargo.toml (first 30 lines) ---"
  head -30 "$DIR/Cargo.toml"
  echo ""
fi
if [ -f "$DIR/go.mod" ]; then
  echo "--- go.mod ---"
  cat "$DIR/go.mod"
  echo ""
fi

# --- License detection ---
echo "=== LICENSE ==="
if [ -f "$DIR/LICENSE" ]; then
  head -5 "$DIR/LICENSE"
elif [ -f "$DIR/LICENSE.md" ]; then
  head -5 "$DIR/LICENSE.md"
else
  echo "(no LICENSE file)"
fi
echo ""

# --- Existing README preview ---
echo "=== EXISTING README ==="
if [ -f "$DIR/README.md" ]; then
  echo "--- README.md (first 50 lines) ---"
  head -50 "$DIR/README.md"
else
  echo "(no README.md)"
fi
echo ""
if [ -f "$DIR/README_CN.md" ]; then
  echo "--- README_CN.md (first 50 lines) ---"
  head -50 "$DIR/README_CN.md"
else
  echo "(no README_CN.md)"
fi

echo ""
echo "=== END ==="
