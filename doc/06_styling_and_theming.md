# 06 - Styling and Theming

Interdit formellement l'utilisation de couleurs et d'espacements "en dur" (hardcodés) directement dans le code des UI. L'application supporte par nature et par défaut un thème sombre propre et lisible. 

## Thème Global (`AppTheme`)
Toutes les règles globales sont définies dans `lib/src/shared/theme/app_theme.dart`.
- Couleurs de fond (background): `#121212`
- Couleurs de surface (cartes/modales): `#1E1E1E`
- Boutons primaires se basant sur la couleur d'accentuation standard de l'application (Teal).

## Accès Sécurisé & Responsive
Utilisez l'extension `BuildContext` de `theme_ext.dart` pour éviter la verbosité à chaque application de classe :

```dart
// Récupérer le style de texte correctement (Roboto pour les Titres, Lato pour le corps) :
final titleStyle = context.textTheme.headlineLarge;

// Obtenir une constante de padding responsive (16px standards) :
final myGridPadding = context.responsivePadding;

// Couleur provenant de votre palette :
final color = context.colorScheme.primary;
```

Toute ressource supplémentaire (`GroupTheme`) utilisée par une fonctionnalité spécifique pour afficher ses données dynamiques réside indépendamment dans `src/shared/theme/`.
