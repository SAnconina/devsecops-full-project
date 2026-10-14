#!/usr/bin/env bash
set -euo pipefail

CLUSTER="devsecops"
IMAGE="devsecops-api:local"

echo "==> Vérification du cluster Kind"

if kind get clusters | grep -qx "$CLUSTER"; then
    echo "Cluster existant détecté."
    if ! kubectl --context "kind-$CLUSTER" cluster-info >/dev/null 2>&1; then
        echo "ERREUR : cluster existant mais inaccessible."
        echo "Vérifie Docker avant de continuer."
        exit 1
    fi
else
    echo "Création du cluster Kind..."
    kind create cluster --name "$CLUSTER"
fi

echo "==> Construction de l'image FastAPI"
docker build --no-cache --pull -t "$IMAGE" .

echo "==> Chargement de l'image dans Kind"
kind load docker-image "$IMAGE" --name "$CLUSTER"

echo "==> Déploiement Kubernetes"
kubectl --context "kind-$CLUSTER" apply \
    -f kubernetes/deployment.yaml \
    -f kubernetes/service.yaml

echo "==> Vérification des pods"
kubectl --context "kind-$CLUSTER" rollout status \
    deployment/devsecops-api --timeout=120s

echo "==> Environnement prêt !"
kubectl --context "kind-$CLUSTER" get pods
