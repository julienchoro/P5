# Backend de test pour l'application Aura

## Installation

Le back-end (de test) est développé en Swift via le framework service-side ![Vapor](https://vapor.codes)

Il vous faudra donc suivre ![les étapes d'installation de Vapor](https://docs.vapor.codes/install/macos/) afin de pouvoir executer le backend


## Lancez le backend

Pour cela, il suffit d'ouvrir le projet avec Xcode utilisant la commande `open Package.swift`. Cela va automatiquement ouvrir une nouvelle fenetre de Xcode pour le backend et préparer le projet au lancement

Une fois Xcode ouvert, cliquez sur le bouton Run comme pour une application iOS (ou via le raccourci Cmd+R) et votre serveur sera lancé en local.

La console dans Xcode devrait faire apparaitre le message suivant : 

```
[ NOTICE ] Server starting on http://127.0.0.1:8080
```


## API Detail

### `GET /`

Description: Il s'agit d'une route pour verifier si l'API est lancé. DOit retourner "It works" si le serveur est correctement lancé

### `POST /auth`

Description: Permet de s'authentifier dans l'API et de généré un token qui devra être utilisé dans les API /account

Body Content Type: `application/json`
Body Format : 
  - `username`: `String` (`email`)
  - `password`: `String`
  
Exemple: 
```
{
    "username": "test@aura.app",
    "password": "test123"
}
```

Body Response: 
  - `token`: `String` (`UUID`)
  
Exemple: 
```
{
    "token": "93D2C537-FA4A-448C-90A9-6058CF26DB29"
}
```

> ⚠️ Un seul compte est configuré dans l'API, il s'agit du compte `test@aura.app` avec le mot de passe `test123`

### `GET /account`

Description: Permet de récuperer le detail du compte courant

Header:
  - `token`: `String` (`UUID`)
  
> Le token a fournit en header ici est le token obtenu dans l'appel a la route `POST /auth`

Body Response:
  - `currentBalance`: `Decimal`
  - `transactions`: `ListOf<Transaction>`
    - `value`: `Decimal`
    - `label`: `String`

### `POST /account/transfer`

Description: Permet de demander le transfer d'argent a une personne via son numero de téléphone (Français uniquement) ou son adresse e-mail'

Body Content Type: `application/json`
Body Format : 
  - `recipient`: `String` (`email` ou `phone`)
  - `amount`: `Decimal`
  
Exemple: 
```
{
    "recipient": "+33 6 01 02 03 04",
    "amount": 12.4
}
```

> La response est vide mais avec le code HTTP 200 si le transfert a été accepté.
