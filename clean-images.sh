#!/usr/bin/env bash
# clean-images.sh
# Supprime les images du répertoire imgs/ qui ne sont plus référencées dans le markdown.
#
# Requiert: rien (bash pur)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
MD_FILE=""
IMG_DIR=""
DRY_RUN=false

show_help() {
    echo "Usage: $0 --md <FILE> --dir <IMG_DIR> [OPTIONS]"
    echo ""
    echo "Supprime les images non référencées dans le markdown."
    echo ""
    echo "Options:"
    echo "  --md FILE      Fichier markdown à scanner (requis)"
    echo "  --dir DIR      Répertoire des images (requis)"
    echo "  --dry-run      Afficher sans supprimer"
    echo "  --help, -h     Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 --md coree/planning.md --dir coree/imgs"
    echo "  $0 --md coree/planning.md --dir coree/imgs --dry-run"
}

if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --md) MD_FILE="$2"; shift 2 ;;
        --dir) IMG_DIR="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --help|-h) show_help; exit 0 ;;
        *) echo "Option inconnue: $1"; show_help; exit 1 ;;
    esac
done

if [[ -z "$MD_FILE" || -z "$IMG_DIR" ]]; then
    echo "❌ --md et --dir sont requis. Voir: $0 --help"
    exit 1
fi

if [[ "$MD_FILE" != /* ]]; then
    MD_FILE="$SCRIPT_DIR/$MD_FILE"
fi
if [[ "$IMG_DIR" != /* ]]; then
    IMG_DIR="$SCRIPT_DIR/$IMG_DIR"
fi

if [[ ! -f "$MD_FILE" ]]; then
    echo "❌ Fichier introuvable: $MD_FILE"
    exit 1
fi
if [[ ! -d "$IMG_DIR" ]]; then
    echo "❌ Répertoire introuvable: $IMG_DIR"
    exit 1
fi

echo "🧹 Scan: $MD_FILE"
echo "   Images dir: $IMG_DIR"
echo ""

count=0
freed=0

shopt -s nullglob
for img in "$IMG_DIR"/*.png "$IMG_DIR"/*.jpg "$IMG_DIR"/*.jpeg "$IMG_DIR"/*.webp "$IMG_DIR"/*.gif; do
    [[ -f "$img" ]] || continue
    filename=$(basename "$img")

    if ! grep -qF "$filename" "$MD_FILE"; then
        size=$(stat -c%s "$img")
        size_h=$(numfmt --to=iec "$size")

        if [[ "$DRY_RUN" == true ]]; then
            echo "  🗑️  $filename ($size_h) – non référencée"
        else
            rm -f "$img"
            echo "  🗑️  Supprimée: $filename ($size_h)"
        fi

        freed=$((freed + size))
        count=$((count + 1))
    fi
done

echo ""
freed_h=$(numfmt --to=iec "$freed")
if [[ "$DRY_RUN" == true ]]; then
    echo "🔍 Dry run: $count image(s) seraient supprimées (${freed_h} libérés)"
else
    if [[ "$count" -gt 0 ]]; then
        echo "✅ Done! $count image(s) supprimée(s) – ${freed_h} libérés"
    else
        echo "✅ Aucune image orpheline trouvée."
    fi
fi
