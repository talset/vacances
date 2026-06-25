#!/usr/bin/env bash
# update-images.sh
# Détecte les URLs d'images (pastefile ou autres) dans un fichier markdown,
# les télécharge dans un répertoire imgs/, et remplace l'URL par un lien markdown local.
#
# Requiert: curl

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
MD_FILE=""
IMG_DIR=""

show_help() {
    echo "Usage: $0 --md <FILE> --dir <IMG_DIR>"
    echo ""
    echo "Télécharge les images référencées par URL dans un markdown et les remplace par des chemins locaux."
    echo ""
    echo "Options:"
    echo "  --md FILE      Fichier markdown à scanner (requis)"
    echo "  --dir DIR      Répertoire de destination des images (requis)"
    echo "  --help, -h     Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 --md coree/planning.md --dir coree/imgs"
    echo ""
    echo "Workflow:"
    echo "  1. Éditer le markdown et coller une URL d'image :"
    echo "     https://pastefile.owl.cycloid.io/8ba2d470b3e4c53c7f2e2a2542974347.png"
    echo "  2. Lancer ce script"
    echo "  3. L'URL est remplacée par : ![alt](imgs/filename.png)"
    echo ""
    echo "Formats supportés: .png, .jpg, .jpeg, .webp, .gif"
}

# Show help if no arguments
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --md) MD_FILE="$2"; shift 2 ;;
        --dir) IMG_DIR="$2"; shift 2 ;;
        --help|-h) show_help; exit 0 ;;
        *) echo "Option inconnue: $1"; show_help; exit 1 ;;
    esac
done

if [[ -z "$MD_FILE" || -z "$IMG_DIR" ]]; then
    echo "❌ --md et --dir sont requis. Voir: $0 --help"
    exit 1
fi

# Resolve relative paths
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

mkdir -p "$IMG_DIR"

# Compute relative path from MD_FILE to IMG_DIR for markdown references
MD_DIR=$(dirname "$MD_FILE")
IMG_REL=$(realpath --relative-to="$MD_DIR" "$IMG_DIR")

# Pattern: URLs ending with image extensions
URL_PATTERN='https?://[^ )\"]+\.(png|jpg|jpeg|webp|gif)'

echo "📷 Scanning: $MD_FILE"
echo "   Images dir: $IMG_DIR"
echo "   Relative path in md: $IMG_REL/"
echo ""

if ! grep -qE "$URL_PATTERN" "$MD_FILE"; then
    echo "  Aucune URL d'image trouvée."
    exit 0
fi

grep -oEn "$URL_PATTERN" "$MD_FILE" | while IFS=: read -r line_num url; do
    filename=$(basename "$url")

    if [[ -f "$IMG_DIR/$filename" ]]; then
        echo "  ⏭️  Already exists: $filename"
    else
        echo "  ⬇️  Downloading: $url"
        if curl -sL -o "$IMG_DIR/$filename" "$url"; then
            echo "     ✅ Saved: $IMG_REL/$filename"
        else
            echo "     ❌ Failed to download: $url"
            continue
        fi
    fi

    # Check if already formatted as markdown image
    line_content=$(sed -n "${line_num}p" "$MD_FILE")
    if echo "$line_content" | grep -q "!\[.*\]($url)"; then
        echo "     ⏭️  Already markdown image syntax"
    elif echo "$line_content" | grep -q "!\[.*\]($IMG_REL/$filename)"; then
        echo "     ⏭️  Already using local path"
    else
        alt_text=$(echo "$filename" | sed 's/\.[^.]*$//' | sed 's/[-_]/ /g')
        sed -i "${line_num}s|$url|![$alt_text]($IMG_REL/$filename)|g" "$MD_FILE"
        echo "     ✏️  Replaced with: ![$alt_text]($IMG_REL/$filename)"
    fi
done

echo ""
echo "✅ Done!"
