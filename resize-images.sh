#!/usr/bin/env bash
# resize-images.sh
# Redimensionne et optimise les images du planning pour réduire la taille totale.
# Les images sont utilisées comme petites illustrations dans des tableaux,
# donc 600px de large est largement suffisant.
#
# Requiert: ImageMagick (convert/identify)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
MAX_WIDTH=600
QUALITY=100
DRY_RUN=false
OUTPUT_FORMAT="jpg"
IMG_DIR=""
MD_FILE="$SCRIPT_DIR/coree/planning.md"

show_help() {
    echo "Usage: $0 <IMG_DIR> [OPTIONS]"
    echo ""
    echo "Redimensionne et optimise les images pour le planning."
    echo ""
    echo "Arguments:"
    echo "  IMG_DIR        Répertoire des images (ex: coree/imgs)"
    echo ""
    echo "Options:"
    echo "  --width N      Largeur max en pixels (défaut: 600)"
    echo "  --quality N    Qualité JPEG 1-100 (défaut: 100)"
    echo "  --format FMT   Format de sortie: jpg ou png (défaut: jpg)"
    echo "  --md FILE      Fichier markdown à mettre à jour (défaut: coree/planning.md)"
    echo "  --dry-run      Afficher sans modifier"
    echo "  --help, -h     Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 coree/imgs"
    echo "  $0 coree/imgs --dry-run"
    echo "  $0 coree/imgs --width 800 --quality 60"
    echo "  $0 coree/imgs --format png"
}

# Show help if no arguments
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --width) MAX_WIDTH="$2"; shift 2 ;;
        --quality) QUALITY="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --format) OUTPUT_FORMAT="$2"; shift 2 ;;
        --md) MD_FILE="$2"; shift 2 ;;
        --help|-h) show_help; exit 0 ;;
        -*) echo "Option inconnue: $1"; exit 1 ;;
        *) IMG_DIR="$1"; shift ;;
    esac
done

if [[ -z "$IMG_DIR" ]]; then
    echo "❌ IMG_DIR requis. Voir: $0 --help"
    exit 1
fi

# Resolve relative path
if [[ "$IMG_DIR" != /* ]]; then
    IMG_DIR="$SCRIPT_DIR/$IMG_DIR"
fi
if [[ "$MD_FILE" != /* ]]; then
    MD_FILE="$SCRIPT_DIR/$MD_FILE"
fi

BACKUP_DIR="$IMG_DIR/originals"

if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick requis. Install: sudo apt-get install imagemagick"
    exit 1
fi

if [[ ! -d "$IMG_DIR" ]]; then
    echo "❌ Répertoire introuvable: $IMG_DIR"
    exit 1
fi

echo "📷 Resize images in: $IMG_DIR"
echo "   Max width: ${MAX_WIDTH}px | Quality: ${QUALITY} | Format: ${OUTPUT_FORMAT}"
echo ""

if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$BACKUP_DIR"
fi

total_before=0
total_after=0
count=0

shopt -s nullglob
for img in "$IMG_DIR"/*.png "$IMG_DIR"/*.jpg "$IMG_DIR"/*.jpeg "$IMG_DIR"/*.webp; do
    [[ -f "$img" ]] || continue

    filename=$(basename "$img")
    name="${filename%.*}"
    ext="${filename##*.}"
    size_before=$(stat -c%s "$img")
    total_before=$((total_before + size_before))
    size_before_h=$(numfmt --to=iec "$size_before")

    dimensions=$(identify -format "%wx%h" "$img" 2>/dev/null || echo "0x0")
    width=$(echo "$dimensions" | cut -dx -f1)

    if [[ "$OUTPUT_FORMAT" == "jpg" ]]; then
        new_filename="${name}.jpg"
    else
        new_filename="${name}.png"
    fi
    new_path="$IMG_DIR/$new_filename"

    if [[ "$width" -le "$MAX_WIDTH" && "$ext" == "$OUTPUT_FORMAT" ]]; then
        total_after=$((total_after + size_before))
        echo "  ⏭️  $filename (${width}px, ${size_before_h}) – skip"
        continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "  🔍 $filename (${dimensions}, ${size_before_h}) → ${new_filename} (max ${MAX_WIDTH}px)"
        count=$((count + 1))
        continue
    fi

    cp "$img" "$BACKUP_DIR/$filename"

    convert "$img" \
        -resize "${MAX_WIDTH}x>" \
        -quality "$QUALITY" \
        -strip \
        "$new_path"

    if [[ "$img" != "$new_path" && -f "$new_path" ]]; then
        rm -f "$img"
    fi

    size_after=$(stat -c%s "$new_path")
    total_after=$((total_after + size_after))
    size_after_h=$(numfmt --to=iec "$size_after")
    saved=$(( (size_before - size_after) * 100 / size_before ))

    echo "  ✅ $filename → $new_filename (${size_before_h} → ${size_after_h}, -${saved}%)"
    count=$((count + 1))

    # Update markdown references if extension changed
    if [[ "$ext" != "$OUTPUT_FORMAT" && -f "$MD_FILE" ]]; then
        sed -i "s|imgs/${filename}|imgs/${new_filename}|g" "$MD_FILE"
    fi
done

echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo "🔍 Dry run: $count images seraient redimensionnées"
    echo "   Total actuel: $(du -sh "$IMG_DIR" | cut -f1)"
else
    total_before_h=$(numfmt --to=iec "$total_before")
    total_after_h=$(numfmt --to=iec "$total_after")
    if [[ "$total_before" -gt 0 ]]; then
        total_saved=$(( (total_before - total_after) * 100 / total_before ))
        echo "✅ Done! $count images traitées"
        echo "   Avant: $total_before_h → Après: $total_after_h (-${total_saved}%)"
        echo "   Originaux sauvegardés dans: $BACKUP_DIR"
    fi
fi
