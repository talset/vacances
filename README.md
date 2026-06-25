# 🇰🇷 Corée du Sud – Voyage

Documents de planification pour un voyage en Corée du Sud (18 jours, fin septembre / début octobre).

## Structure

```
tmp/
├── README.md              ← ce fichier
├── update-images.sh       ← script pour télécharger/intégrer des images
├── resize-images.sh       ← script pour redimensionner/optimiser les images
├── coree-du-sud-voyage.md ← notes de recherche (lieux, préférences)
└── coree/
    ├── planning.md        ← planning jour par jour (document principal)
    ├── imgs/              ← images illustrant les lieux
    │   ├── image1.png
    │   ├── image2.png
    │   └── ...
    ├── plan.md            ← plan source original (notes brutes)
    ├── plan.pdf           ← plan source PDF
    └── plan.docx          ← plan source DOCX
```

## 📷 Ajouter des images au planning

### Usage

Le script `update-images.sh` détecte les URLs d'images dans le planning, les télécharge dans `coree/imgs/` et remplace l'URL par la syntaxe markdown locale.

```bash
./update-images.sh                                          # défaut
./update-images.sh --md coree/planning.md --dir coree/imgs  # explicite
```

### Comment ça marche

1. Éditer `coree/planning.md`
2. Coller une URL d'image sur une ligne (pastefile, imgur, etc.) :
   ```
   https://pastefile.owl.cycloid.io/8ba2d470b3e4c53c7f2e2a2542974347.png
   ```
3. Lancer le script :
   ```bash
   ./update-images.sh
   ./update-images.sh --md coree/planning.md --dir coree/imgs   # explicite
   ```
4. Le script va :
   - Détecter l'URL (supporte `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif`)
   - Télécharger l'image dans le répertoire spécifié
   - Remplacer l'URL dans le markdown par : `![alt text](imgs/filename.png)`

### Formats supportés

- `https://pastefile.owl.cycloid.io/xxx.png`
- `https://example.com/path/to/image.jpg`
- Toute URL se terminant par `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif`

---

## Génération des documents avec Pandoc

### Prérequis

```bash
# Installation pandoc (si pas déjà installé)
sudo apt-get install pandoc

# Pour la génération PDF (nécessite un moteur LaTeX)
sudo apt-get install texlive-xetex texlive-fonts-recommended texlive-fonts-extra
```

### Générer le planning en PDF

```bash
pandoc coree/planning.md -o coree/planning.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=2cm \
  -V fontsize=11pt \
  -V mainfont="DejaVu Sans" \
  --toc \
  --toc-depth=2 \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue
```

### Générer le planning en DOCX

```bash
pandoc coree/planning.md -o coree/planning.docx \
  --toc \
  --toc-depth=2
```

### Générer le planning en HTML (avec style)

```bash
pandoc coree/planning.md -o coree/planning.html \
  --standalone \
  --toc \
  --toc-depth=2 \
  --metadata title="Planning Corée du Sud – 18 jours" \
  --css=https://cdn.jsdelivr.net/npm/water.css@2/out/water.min.css
```

### Générer tous les formats en une commande

```bash
cd coree && \
pandoc planning.md -o planning.pdf --pdf-engine=xelatex -V geometry:margin=2cm -V fontsize=11pt -V mainfont="DejaVu Sans" --toc --toc-depth=2 -V colorlinks=true && \
pandoc planning.md -o planning.docx --toc --toc-depth=2 && \
pandoc planning.md -o planning.html --standalone --toc --toc-depth=2 --metadata title="Planning Corée du Sud" && \
echo "✅ Tous les documents générés"
```

### Notes

- Le PDF nécessite `xelatex` pour le support Unicode (caractères coréens, emojis)
- Si `DejaVu Sans` n'est pas disponible, remplacer par `Noto Sans` ou retirer l'option `mainfont`
- Pour un PDF sans emojis (plus compatible), ajouter `--strip-comments` ou retirer les emojis du markdown
- Les images locales (`imgs/`) sont incluses automatiquement dans les exports PDF/DOCX/HTML

---

## 📐 Redimensionner / optimiser les images

Les images extraites du docx font ~150Mo au total (certaines 5-6Mo).
Comme elles sont utilisées en petit format dans des tableaux, **600px de large suffit**.
Le script `resize-images.sh` les convertit en JPEG optimisé (~95% de réduction).

### Usage

```bash
# Dry run (voir ce qui serait fait sans modifier)
./resize-images.sh --dry-run

# Redimensionner (défaut: max 600px largeur, qualité 100, conversion JPEG)
./resize-images.sh
./resize-images.sh coree/imgs            # spécifier le répertoire

# Options personnalisées
./resize-images.sh --width 800           # largeur max 800px
./resize-images.sh --quality 80          # qualité JPEG réduite
./resize-images.sh --format png          # garder en PNG
./resize-images.sh --md other/file.md    # autre fichier markdown à mettre à jour
```

### Ce que fait le script

1. Redimensionne les images plus larges que `--width` (défaut 600px)
2. Convertit en JPEG pour une meilleure compression (photos)
3. Supprime les métadonnées EXIF (`-strip`)
4. Sauvegarde les originaux dans `imgs/originals/` (git-ignoré)
5. Met à jour les chemins dans le markdown si l'extension change

### Prérequis

```bash
sudo apt-get install imagemagick

```


### Example update images

```bash
./update-images.sh --md coree/planning.md --dir coree/imgs
./resize-images.sh coree/imgs
./clean-images.sh --md coree/planning.md --dir coree/imgs
```
