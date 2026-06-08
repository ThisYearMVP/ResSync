# Rapport d'Erreurs Potentielles et Améliorations - RSSync

Après une relecture complète du code, voici les points d'attention, erreurs potentielles et axes d'amélioration identifiés, sans aucune modification apportée au code source.

## 🔐 Sécurité

1.  **Clés API en clair** :
    *   Dans `API.py` : Les clés `SNCF_API_KEY` et `SUPABASE_KEY` (qui semble être une `service_role` key à haut privilège) sont codées en dur.
    *   Dans `SupabaseService.swift` : La `supabaseKey` est présente en clair dans le code.
    *   *Risque* : Fuite de credentials si le code est poussé sur un dépôt public. Utiliser des variables d'environnement ou un fichier `.plist` ignoré par Git.

2.  **Privilèges Supabase** : Le script Python utilise une clé de service. Il faut s'assurer que les politiques RLS (Row Level Security) sur Supabase sont correctement configurées pour que les utilisateurs mobiles ne puissent pas modifier les horaires TGV ou les profils des autres.

## 🐞 Erreurs de Logique & Bugs Potentiels

1.  **Incohérence des Identifiants (ID)** :
    *   Le modèle `User` utilise `UUID?`.
    *   Le modèle `Trip` utilise `String` (généré par `UUID().uuidString`).
    *   Le modèle `Match` utilise `UUID?`.
    *   *Risque* : Des erreurs de cast ou de comparaison lors des jointures manuelles ou des requêtes Supabase si les types ne sont pas alignés dans la base de données.

2.  **Matching JSONB Fragile** :
    *   Dans `TripMatchingService.swift`, la requête utilise `currentTrip->>origin`. 
    *   *Risque* : Si la structure de l'objet `Trip` change dans le code Swift sans mise à jour de la base de données, les recherches de voyageurs échoueront silencieusement (retourneront 0 résultat).

3.  **Gestion des Mocks dans le Feed** :
    *   `FeedViewModel` charge les mocks si la base est vide ou en cas d'erreur.
    *   *Risque* : En production, un utilisateur pourrait voir des profils de démonstration (Léa, Marc, etc.) au lieu d'un message "Aucun voyageur trouvé", ce qui est trompeur.

4.  **Date Parsing** :
    *   Plusieurs endroits (`TripDTO`, `TgvSchedule`) effectuent un parsing manuel des dates ISO8601 avec et sans millisecondes.
    *   *Risque* : Fragilité si l'API SNCF ou Supabase change son format de date par défaut. Utiliser un `JSONDecoder` configuré globalement serait plus robuste.

## 🏗 Architecture & UI/UX

1.  **Profil Incomplet** :
    *   `ProfileSetupView.swift` : La section "Centres d'intérêt" ne contient qu'un `Text`. Il n'y a aucun champ (`TextField` ou boutons) pour saisir ou sélectionner réellement les intérêts.
    *   *Conséquence* : L'utilisateur ne peut pas remplir ses intérêts, ce qui bloquera `isProfileComplete` dans `SupabaseService`.

2.  **Stubs de Messagerie** :
    *   `MatchesListView` et `ChatView` utilisent des données statiques ("Thomas", "Salut ! Tu vas à Lyon aussi ?").
    *   *Conséquence* : La fonctionnalité de messagerie n'est pas opérationnelle bien que présente dans l'UI.

3.  **Gestion des Erreurs Silencieuses** :
    *   Beaucoup de blocs `catch` se contentent d'un `print` (ex: `ProfileViewModel.saveProfile`).
    *   *Conséquence* : Si la sauvegarde échoue (pas de réseau, session expirée), l'utilisateur pense que c'est enregistré alors que non.

4.  **Performance du Script Python** :
    *   `API.py` utilise `time.sleep(0.1)` entre chaque gare. Pour 60+ gares sur 15 jours, cela peut être long et risquer des timeouts ou des bans si l'API SNCF devient plus restrictive.
    *   La suppression de l'ancien cache est commentée (`# supabase.table("tgv_schedules").delete()...`), ce qui peut entraîner une accumulation massive de données obsolètes.

## 💅 Style & Conventions

1.  **Doublon de Services** : `TgvService` et `TripMatchingService` recréent leur propre instance de `client` au lieu d'utiliser `SupabaseService.shared.client` systématiquement (bien que `TgvService` le fasse, c'est irrégulier).
2.  **Z-Index dans App** : L'utilisation de `zIndex` dans `RSSyncApp` pour le fond d'écran pourrait compliquer la gestion des interactions tactiles sur certaines couches si des vues complexes sont ajoutées ultérieurement.
