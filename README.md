# MongoDB Docker

Image Docker MongoDB 7.0 préconfigurée avec une base `blog_db` et un schéma de validation strict.

## Image Docker Hub

tomballauriynov/tomballauri_mongodb:1.0.0

## Contenu

- **Base de données** : `blog_db`
- **Collection** : `posts` avec validation de schéma (champs requis : `titre`, `auteur`, `vues`)
- **Données initiales** : 5 articles insérés au démarrage

## Prérequis

- Docker

## Démarrage rapide

cp .env.example .env
# Renseigner les valeurs dans .env, puis :
docker run -d --name mongo_container -p 27017:27017 \
  --env-file .env \
  tomballauriynov/tomballauri_mongodb:1.0.0


## Variables d'environnement

| Variable | Description |
| --- | --- |
| `MONGO_INITDB_ROOT_USERNAME` | Nom d'utilisateur admin |
| `MONGO_INITDB_ROOT_PASSWORD` | Mot de passe admin |
| `MONGO_INITDB_DATABASE` | Base de données initiale |

Copier `.env.example` vers `.env` et renseigner les valeurs.

## Connexion via mongosh

docker exec -it mongo_container mongosh \
  -u <MONGO_INITDB_ROOT_USERNAME> -p <MONGO_INITDB_ROOT_PASSWORD> \
  --authenticationDatabase admin

## Validation du schéma

La collection `posts` impose un schéma strict. Une insertion invalide (champ manquant ou mauvais type) retourne une erreur :

db.getSiblingDB('blog_db').posts.insertOne({ titre: "Test", auteur: "Alice" })

## Health check

Un script est fourni pour vérifier que le conteneur est opérationnel :

bash check-status.sh

Il vérifie :
1. Que le processus `mongod` ne tourne pas en root
2. Que la base `blog_db` est accessible
3. Que la collection `posts` contient des données

## Build local

docker build -t tomballauriynov/tomballauri_mongodb:1.0.0 .
