# flower-garden

Application Flutter (package `flower_garden`) de rappel d'arrosage. Interface en français.

## Vue d'ensemble

App de rappel d'arrosage pour les plantes, avec notification sur le téléphone.

- L'utilisateur ajoute ses plantes.
- Fréquence d'arrosage : idéalement récupérée automatiquement via une API de base de données de plantes (à évaluer : simplicité d'intégration), sinon saisie à la main.
- L'utilisateur note la date du dernier arrosage de chaque plante.
- Le jour où la plante doit être arrosée à nouveau (dernier arrosage + fréquence), une notification de rappel est envoyée.
- Les rappels sont automatiques : une fois les plantes configurées, l'utilisateur n'a plus rien à faire (notifications planifiées, reprogrammées à chaque arrosage noté).

### État d'avancement

- Fait : ajout / modification / suppression (glisser vers la gauche) des plantes, saisie manuelle de la fréquence, bouton « Arrosée aujourd'hui », historique des arrosages, sauvegarde locale, liste avec J-x, page perso, calendrier.
- À faire : notifications planifiées (ex. `flutter_local_notifications` + `timezone`, config Android à prévoir), API de plantes.

### UI

- **Liste des plantes** : chaque plante affiche ses infos et le nombre de jours restants avant le prochain arrosage (J-x, `J+x` si en retard), triée par prochain arrosage. Le bouton goutte (« Arrosée aujourd'hui ») se vide au fil des jours (pleine = vient d'être arrosée, vide = à arroser). Toucher une plante ouvre sa page perso.
- **Page perso** : infos, prochain arrosage, historique des arrosages (lignes supprimables, sauf la dernière restante) ; bouton crayon → formulaire d'édition.
- **Calendrier** : vue mensuelle avec une pastille de couleur par plante sur les jours où il faut arroser (max 4 par case), glisser gauche/droite pour changer de mois ; toucher un jour liste les plantes à arroser, toucher une plante ouvre sa page perso.

## Logique d'arrosage (`Plant`)

- Dates stockées sans heure ; écarts calculés en UTC (`daysBetween`) pour ignorer les changements d'heure.
- `wateringHistory` : dates d'arrosage triées (plus récente en premier), jamais vide ; `lastWatered` = la plus récente. Le formulaire d'édition remplace la plus récente. JSON : l'ancien champ `lastWatered` est encore lu.
- Prochain arrosage = `lastWatered + wateringIntervalDays`.
- Calendrier : jours `nextWatering + k × intervalle` (k ≥ 0), en supposant les arrosages faits à l'heure.

## Stack technique

- Flutter (Dart SDK ^3.11.5, Material 3), locale `fr` via `flutter_localizations` (dates, calendrier, sélecteur de date)
- Packages : `shared_preferences` (liste des plantes en JSON sous la clé `plants`)
- Plateformes : Android, iOS, Web, Windows, Linux, macOS

## Architecture des fichiers

```
lib/
├── main.dart                      # Point d'entrée, MaterialApp (thème vert, locale fr)
├── data/
│   └── plant_repository.dart      # Charge/sauve les plantes (SharedPreferences)
├── models/
│   └── plant.dart                 # Modèle Plant, couleurs par défaut plantColors, daysBetween
├── screens/
│   ├── main_shell.dart            # Racine : NavigationBar + IndexedStack, détient la liste des plantes
│   ├── plants/
│   │   ├── plant_list_page.dart   # Liste, ajout (FAB), suppression par glissement
│   │   ├── plant_detail_page.dart # Page perso (infos + historique), garde une copie locale et appelle onSave
│   │   └── plant_form_page.dart   # Formulaire ajout/modif (couleur : aperçu + roue en dialogue + aléatoire), renvoie la Plant via Navigator.pop
│   └── calendar/
│       └── calendar_page.dart     # Calendrier mensuel avec pastilles, swipe pour changer de mois
└── widgets/
    ├── color_wheel.dart           # Roue chromatique HSV (teinte = angle, saturation = rayon), sans package
    ├── plant_tile.dart            # Ligne de la liste avec badge J-x et bouton arroser
    ├── watering_badge.dart        # Badge J-x / Aujourd'hui / J+x
    └── watering_drop.dart         # Goutte bleu pluie (rainBlue) remplie selon Plant.waterLevel
```

Organiser les écrans par module dans `screens/<module>/`.

## Conventions de code

- Dart idiomatique, classes immutables avec constructeurs `const`
- `StatelessWidget` quand possible, `StatefulWidget` sinon
- Pas de state management externe (`setState` uniquement) ; données partagées remontées dans un widget parent et passées en paramètres + callbacks
- Commentaires en français si nécessaire

## Commandes utiles

- Lancer : `flutter run` (ou `flutter run -d windows` / `-d chrome`, plus rapide qu'un émulateur Android)
- Formater : `dart format lib`
- Analyser : `flutter analyze`
- Tests : `flutter test`
- Build Android : `flutter build apk`

## Règles

- Après chaque modification, lancer `dart format lib` puis `flutter analyze` et corriger les erreurs.
- Ne pas lancer l'app : l'utilisateur la lance depuis VS Code.
- Mettre à jour ce fichier quand l'architecture ou les conventions évoluent.
