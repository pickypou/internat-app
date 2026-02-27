# 07 - Security

La sécurité est principalement gérée via les politiques RLS (Row Level Security) directement chez **Supabase**.

## Base de données
- Aucun accès en écriture direct depuis l'application sans jeton JWT Supabase valide (à l'exception potentielle du processus d'inscription ou d'API publiques configurées intentionnellement).
- Les tables métiers (comme `groups`) sont sécurisées par Supabase par définition par rôle. Les repositories dans Flutter manipulent la clef de service anonyme (`anonKey`). 

## Logique Métier UI 
L'application respecte les limitations en restreignant l'émergence des erreurs pour l'utilisateur. Toute exception, particulièrement la fuite des failles Supabase, est interceptée dans `Repository` et convertie manuellement en une `ServerFailure("Message propre")` pour affichage sur l'UI, évitant la fuite de logs bruts sensibles.
