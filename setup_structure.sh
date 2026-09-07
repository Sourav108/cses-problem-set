#!/usr/bin/env bash
set -e

# Scaffolds and verifies all 18 folders of the CSES Problem Set (400 Problems)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -a FOLDERS=(
  "01-Introductory-Problems"
  "02-Sorting-and-Searching"
  "03-Dynamic-Programming"
  "04-Graph-Algorithms"
  "05-Range-Queries"
  "06-Tree-Algorithms"
  "07-Mathematics"
  "08-String-Algorithms"
  "09-Geometry"
  "10-Advanced-Techniques"
  "11-Sliding-Window-Problems"
  "12-Interactive-Problems"
  "13-Bitwise-Operations"
  "14-Construction-Problems"
  "15-Advanced-Graph-Problems"
  "16-Counting-Problems"
  "17-Additional-Problems-I"
  "18-Additional-Problems-II"
)

echo "🚀 Verifying and scaffolding CSES Problem Set (400 Problems across 18 Categories)..."

for folder in "${FOLDERS[@]}"; do
  mkdir -p "$ROOT_DIR/$folder"
  if [ ! -f "$ROOT_DIR/$folder/README.md" ]; then
    echo "Creating stub for $folder..."
    cat <<EOF > "$ROOT_DIR/$folder/README.md"
# $folder

Problem checklist and C++ solutions for $folder.
EOF
  fi
done

echo "✅ All 18 category folders verified in $ROOT_DIR."
