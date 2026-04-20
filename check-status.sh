#!/bin/bash

CONTAINER="mongo_container"

if [ -f "$(dirname "$0")/.env" ]; then
  source "$(dirname "$0")/.env"
fi

MONGO_USER="${MONGO_INITDB_ROOT_USERNAME}"
MONGO_PWD="${MONGO_INITDB_ROOT_PASSWORD}"

if [ -z "$MONGO_USER" ] || [ -z "$MONGO_PWD" ]; then
  echo "[ERREUR] Variables MONGO_INITDB_ROOT_USERNAME et MONGO_INITDB_ROOT_PASSWORD manquantes."
  echo "         Copier .env.example vers .env et renseigner les valeurs."
  exit 1
fi

ERRORS=()

echo "=== Health Check : $CONTAINER ==="
echo ""

# 1. Vérifier que le conteneur tourne
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "[ERREUR] Le conteneur '$CONTAINER' n'est pas en cours d'exécution."
  exit 1
fi

# 2. Vérifier que l'utilisateur n'est pas root
echo "[1/3] Vérification de l'utilisateur du service mongod..."
MONGOD_USER=$(docker exec "$CONTAINER" sh -c "ps aux | grep '[m]ongod' | awk '{print \$1}' | head -1" 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$MONGOD_USER" ]; then
  ERRORS+=("Impossible de déterminer l'utilisateur du processus mongod.")
elif [ "$MONGOD_USER" = "root" ]; then
  ERRORS+=("Le service mongod tourne en tant que root (utilisateur: $MONGOD_USER).")
else
  echo "      OK — mongod tourne en tant que : $MONGOD_USER (non-root)"
fi

# 3. Vérifier que blog_db est accessible
echo "[2/3] Vérification de la base blog_db..."
DB_CHECK=$(docker exec "$CONTAINER" mongosh \
  -u "$MONGO_USER" -p "$MONGO_PWD" \
  --authenticationDatabase admin \
  --quiet \
  --eval "db.getSiblingDB('blog_db').getName()" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$DB_CHECK" ]; then
  ERRORS+=("Impossible de se connecter à blog_db via mongosh.")
else
  echo "      OK — base accessible : $DB_CHECK"
fi

# 4. Vérifier que les données sont présentes dans posts
echo "[3/3] Vérification des données dans blog_db.posts..."
DOC_COUNT=$(docker exec "$CONTAINER" mongosh \
  -u "$MONGO_USER" -p "$MONGO_PWD" \
  --authenticationDatabase admin \
  --quiet \
  --eval "db.getSiblingDB('blog_db').posts.countDocuments()" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$DOC_COUNT" ]; then
  ERRORS+=("Impossible de compter les documents dans blog_db.posts.")
elif [ "$DOC_COUNT" -lt 1 ]; then
  ERRORS+=("La collection posts est vide (0 documents trouvés).")
else
  echo "      OK — $DOC_COUNT document(s) trouvé(s) dans posts"
fi

# Résultat final
echo ""
if [ ${#ERRORS[@]} -eq 0 ]; then
  echo "=============================="
  echo " SUCCÈS — Tous les checks OK "
  echo "=============================="
else
  echo "=============================="
  echo " ÉCHEC — Erreur(s) détectée(s)"
  echo "=============================="
  for ERR in "${ERRORS[@]}"; do
    echo "  - $ERR"
  done
  exit 1
fi
