# Tests pour l'application Aura

Ce dossier contient les tests unitaires simplifiés pour l'application Aura.

## Architecture des tests

L'architecture des tests a été conçue pour permettre des tests unitaires isolés et efficaces avec une approche minimaliste.

### Tests unitaires

Les tests unitaires utilisent des mocks simples pour isoler les composants testés de leurs dépendances. Pour le service réseau, nous utilisons:

- `NetworkServiceProtocol`: Un protocole qui définit l'interface du service réseau
- `SimpleMockNetworkService`: Une implémentation simplifiée du protocole pour les tests unitaires

Cette approche permet de tester le comportement des composants qui dépendent du service réseau sans effectuer de véritables requêtes HTTP, avec un minimum de complexité.

## Structure des fichiers

- `SimpleNetworkServiceTests.swift`: Tests unitaires simplifiés pour le service réseau
- `Mock/SimpleMockNetworkService.swift`: Implémentation simplifiée du service réseau pour les tests
- `Mock/TestModels.swift`: Modèles de données pour les tests

## Exécution des tests

Pour exécuter les tests, ouvrez le projet dans Xcode et utilisez le raccourci Cmd+U ou sélectionnez Product > Test dans le menu.

## Couverture des Tests

Les tests couvrent les aspects suivants du `NetworkService` :

### Gestion des Tokens d'Authentification
- Définition et récupération du token

### Requêtes Réseau
- Requêtes GET réussies
- Requêtes POST réussies

### Gestion des Erreurs
- URL invalide
- Erreur de décodage
- Erreur d'authentification (401)
- Erreur de requête (400)
- Erreur serveur (500)

## Notes sur l'Implémentation

Les tests utilisent `SimpleMockNetworkService` pour simuler le comportement du service réseau sans avoir besoin d'un serveur réel ou de requêtes HTTP. Cette implémentation est volontairement minimaliste pour faciliter la compréhension et la maintenance. 