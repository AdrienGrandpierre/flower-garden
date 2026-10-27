# flower-garden

Application Flutter (package `flower_garden`), en cours de démarrage : coquille vide pour l'instant.

## Vue d'ensemble (à implémenter)

App de rappel d'arrosage pour les plantes, avec notification sur le téléphone.

- L'utilisateur ajoute ses plantes.
- Fréquence d'arrosage : idéalement récupérée automatiquement via une API de base de données de plantes (à évaluer : simplicité d'intégration), sinon saisie à la main.
- L'utilisateur note la date du dernier arrosage de chaque plante.
- Le jour où la plante doit être arrosée à nouveau (dernier arrosage + fréquence), une notification de rappel est envoyée.
- Les rappels sont automatiques : une fois les plantes configurées, l'utilisateur n'a plus rien à faire (notifications planifiées, reprogrammées à chaque arrosage noté).

### UI prévue

- **Liste des plantes** : chaque plante affiche ses infos et le nombre de jours restants avant le prochain arrosage (J-x).
- **Calendrier** : vue mensuelle avec une pastille de couleur par plante sur les jours où il faut arroser.

## Stack technique

- Flutter (Dart SDK ^3.11.5, Material 3)
- Plateformes : Android, iOS, Web, Windows, Linux, macOS
- Aucun package externe pour l'instant

## Architecture des fichiers

```
lib/
└── main.dart   # Point d'entrée
```

Organiser les écrans par module dans `screens/<module>/`, avec `models/`, `data/` et `widgets/` à côté dès que nécessaire.

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
