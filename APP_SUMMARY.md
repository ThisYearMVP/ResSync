# Résumé de l'Application : RSSync (R-S)

**RSSync** est une application mobile (iOS) conçue pour connecter les voyageurs, principalement sur le réseau TGV, afin de partager des activités durant leurs trajets (travailler, discuter, jouer, etc.).

## 🚀 Fonctionnalités Principales

### 1. Authentification & Profil
- Inscription et connexion via **Supabase Auth**.
- Création de profil détaillé : nom, âge, nationalité, bio, et centres d'intérêt.
- Gestion de l'identité visuelle avec des photos de profil.

### 2. Recherche de Voyages
- Recherche de trajets TGV réels grâce à une base de données synchronisée avec l'API SNCF.
- Sélection de l'origine, de la destination, de la date et de l'heure précise.
- Choix de l'activité souhaitée pour le voyage (Travail, Discussion, Repos, Jeu).

### 3. Matching & Réseau Social
- **Feed de voyageurs** : Interface de type "Swipe" (Tinder-like) pour découvrir les autres passagers sur le même trajet.
- Filtrage par trajet et par activité.
- Système de "Like" et de "Skip" pour initier des connexions.

### 4. Messagerie (En cours)
- Liste des correspondances (Matchs).
- Interface de chat pour discuter avec les futurs voisins de voyage.

## 🛠 Architecture Technique

- **Frontend** : Swift (SwiftUI) avec l'architecture `Observation` (iOS 17+).
- **Backend** : [Supabase](https://supabase.com/) pour la base de données (PostgreSQL), l'authentification et le stockage.
- **Synchronisation de données** : Script Python (`API.py`) qui récupère les horaires SNCF (Navitia API) et les injecte dans Supabase pour servir de cache local.
- **Design** : Thème personnalisé avec des effets visuels (vitres d'avion, animations de transition).

## 📂 Structure du Projet

- `App/` : Point d'entrée et configuration globale de l'UI.
- `Models/` : Définitions des objets (User, Trip, Match, Message).
- `ViewModels/` : Logique métier et gestion d'état des vues.
- `Views/` : Interfaces utilisateur découpées par modules (Auth, Home, Messaging, Profile).
- `Services/` : Clients pour les API externes et Supabase.
- `API.py` : Script utilitaire pour la mise à jour des données de transport.
