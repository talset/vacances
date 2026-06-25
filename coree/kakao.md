# Navigation en Corée avec k-skill

5 skills installés pour couvrir tous les modes de transport du voyage.

---

## Skills installés

| Skill | Mode | Credentials |
|-------|------|-------------|
| `kakao-map` | Voiture + recherche de lieux | Aucune |
| `korean-transit-route` | Bus + Métro local | Clé Odsay |
| `ktx-booking` | KTX (trains grandes lignes) | ⚠️ Compte Korail requis — inutilisable pour étrangers |
| `express-bus-booking` | Bus express interurbain | Aucune |
| `flight-ticket-search` | Vols domestiques | Aucune |

---

## Configuration des credentials

### Odsay (bus + métro)

1. Créer un compte sur https://lab.odsay.com
2. Créer une application → récupérer la clé API
3. **Enregistrer l'IP de la machine dans la whitelist** (obligatoire — sinon erreur 401)
4. Limite : 1 000 appels/jour en tier gratuit

```bash
mkdir -p ~/.config/k-skill
echo 'ODSAY_API_KEY=ta_clé_ici' >> ~/.config/k-skill/secrets.env
```

### Korail (KTX) — ⚠️ skill inutilisable pour étrangers

Le skill `ktx-booking` utilise letskorail.com, qui **bloque l'inscription des étrangers** (vérification obligatoire par numéro de téléphone coréen). Le skill est installé mais non fonctionnel sans compte coréen.

#### Alternatives pour réserver le KTX en tant qu'étranger

| Option | Compte | Paiement | Frais | Notes |
|--------|--------|----------|-------|-------|
| **korail.com/global/eng** | Non requis | CB internationale | Aucun | Site officiel Korail pour étrangers, réservation invité, passeport suffit |
| **Klook / 12Go Asia** | Non requis | CB internationale | ~1 000–5 000 ₩/billet | Plus simple, gère le 3D Secure |
| **Guichet en gare** | Non requis | CB ou espèces + passeport | Aucun | Idéal pour billets de dernière minute |

> 💡 **Recommandé : korail.com/global/eng** — prix face value, pas de compte, accepte Visa/Mastercard internationales. Utiliser Chrome sur desktop. Le nom doit correspondre exactement à la carte bancaire.

---

## Ce qui est couvert

| Trajet | Skill | Données retournées |
|--------|-------|--------------------|
| Voiture | `kakao-map` | Distance, durée, péage, tarif taxi |
| Métro / bus local | `korean-transit-route` | Numéro de ligne/bus, stations, correspondances, durée, tarif |
| Bus express (ex: Seoul→Sokcho) | `express-bus-booking` | Horaires, tarif, places dispo, terminal, classe (premium/standard) |
| KTX (ex: Seoul→Busan) | `korean-transit-route` (temps) + korail.com/global/eng (réservation) | Durée estimée via ODsay, réservation manuelle sur le site officiel |
| Vols (ex: Busan→Jeju) | `flight-ticket-search` | Compagnie, horaire, durée, prix, lien réservation |

---

## Ce qui n'est pas couvert

- **SRT** — skill `srt-booking` disponible dans k-skill si besoin (nécessite compte SRT séparé)
- **Ferries** (Busan → Jeju en bateau) — pas de skill disponible
- Vélo / trottinette
- Temps réel arrivées métro — voir Apify south-korea-rail-transit-scraper

---

## Exemples d'usage

```
"Itinéraire en voiture de 강남역 à 홍대입구역"
"Comment aller en métro de Myeongdong à Gyeongbokgung ?"
"Bus express Seoul → Sokcho demain matin, quels horaires et tarifs ?"
"KTX Seoul → Busan le 28 septembre, trains disponibles ?"
"Vol Busan → Jeju le 8 octobre, quel prix ?"
```
