# 🚀 Guide de déploiement — DevSecOps Platform

**FastAPI • Docker • Kubernetes • Terraform • Helm • Prometheus • Grafana**

## 1. Présentation

Ce document décrit les étapes d'installation, de déploiement et de vérification de la plateforme DevSecOps.

L'environnement repose sur GitHub Codespaces, Docker, Kubernetes avec Kind, Terraform et Helm.

## 2. Prérequis

Les outils suivants sont nécessaires :

| Outil | Utilisation |
|---|---|
| Git | Gestion du code source |
| Python 3 | Exécution de l'API et des tests |
| Docker | Construction des images |
| kubectl | Gestion du cluster Kubernetes |
| Kind | Création d'un cluster Kubernetes local |
| Terraform | Infrastructure as Code |
| Helm | Installation de la stack de monitoring |

Vérifier les outils :

```bash
python --version
docker --version
kubectl version --client
kind version
terraform version
helm version
```

## 3. Récupération du projet

Cloner le dépôt GitHub :

```bash
git clone https://github.com/SAnconina/devsecops-full-project.git
cd devsecops-full-project
```

## 4. Installation et tests de l'application

Créer un environnement virtuel :

```bash
python -m venv .venv
source .venv/bin/activate
```

Installer les dépendances :

```bash
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

Lancer les tests :

```bash
pytest -v
```

Démarrer l'application :

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Vérifier l'API :

```bash
curl http://localhost:8000/health
```

Réponse attendue :

```json
{
  "status": "healthy"
}
```

La documentation Swagger est accessible à l'adresse :

`http://localhost:8000/docs`

## 5. Construction Docker

Construire l'image de l'application :

```bash
docker build --no-cache --pull -t devsecops-api:local .
```

Vérifier sa présence :

```bash
docker images devsecops-api
```

Démarrer un conteneur pour tester l'API :

```bash
docker run --rm -p 8000:8000 devsecops-api:local
```

Depuis un second terminal :

```bash
curl http://localhost:8000/health
```

## 6. Déploiement Kubernetes avec Kind

### 6.1 Créer le cluster

```bash
kind create cluster --name devsecops
```

Vérifier le cluster :

```bash
kubectl cluster-info --context kind-devsecops
```

### 6.2 Charger l'image Docker

```bash
kind load docker-image devsecops-api:local --name devsecops
```

### 6.3 Déployer l'application

Depuis la racine du projet :

```bash
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

### 6.4 Vérifier le déploiement

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

Vérifier que le Deployment est disponible :

```bash
kubectl rollout status deployment/devsecops-api
```

### 6.5 Accéder à l'API

```bash
kubectl port-forward service/devsecops-api 8000:8000
```

Depuis un second terminal :

```bash
curl http://localhost:8000/health
```

**Remarque :** le nom du Deployment ou du Service doit correspondre à celui défini dans les manifestes Kubernetes.

## 7. Déploiement automatisé

Le dépôt contient un script Bash pour automatiser le déploiement local.

Depuis la racine du projet :

```bash
bash scripts/start-local.sh
```

Le script prend en charge :

1. La vérification ou la création du cluster Kind.
2. La construction de l'image Docker.
3. Le chargement de l'image dans Kind.
4. L'application des manifestes Kubernetes.
5. La vérification du déploiement.

## 8. Infrastructure as Code avec Terraform

Le dossier `terraform/` contient les fichiers suivants :

```text
terraform/
├── main.tf
├── variables.tf
└── outputs.tf
```

Terraform utilise le provider Kubernetes pour gérer un namespace.

Se placer dans le dossier Terraform :

```bash
cd terraform
```

Initialiser Terraform :

```bash
terraform init
```

Vérifier la configuration :

```bash
terraform validate
```

Afficher les modifications :

```bash
terraform plan
```

Appliquer la configuration :

```bash
terraform apply
```

Vérifier le namespace :

```bash
kubectl get namespaces
```

Revenir à la racine du projet :

```bash
cd ..
```

**Important :** Terraform doit utiliser un contexte Kubernetes valide. Le contexte par défaut du projet est `kind-devsecops`.

## 9. Monitoring avec Helm

Le monitoring repose sur la stack `kube-prometheus-stack`.

Elle comprend notamment :

- Prometheus pour les métriques.
- Grafana pour les tableaux de bord.
- Alertmanager pour les alertes.
- Prometheus Operator pour l'administration des ressources Prometheus.

### 9.1 Ajouter le dépôt Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 9.2 Créer le namespace

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
```

### 9.3 Installer la stack

Depuis la racine du projet :

```bash
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values kubernetes/monitoring-values.yaml
```

### 9.4 Vérifier les composants

```bash
helm list -n monitoring
kubectl get pods -n monitoring
kubectl get services -n monitoring
```

## 10. Accès à Grafana

Identifier le Service Grafana :

```bash
kubectl get services -n monitoring
```

Si le Service s'appelle `monitoring-grafana`, démarrer le port-forward :

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Ouvrir ensuite :

`http://localhost:3000`

Les identifiants de connexion dépendent de la configuration Helm et des secrets Kubernetes utilisés lors de l'installation.

## 11. Accès à Prometheus

Identifier le Service Prometheus :

```bash
kubectl get services -n monitoring
```

Avec le nom de Service standard de cette installation :

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
```

Ouvrir ensuite :

`http://localhost:9090`

## 12. Tests et vérifications

Les vérifications du projet couvrent plusieurs niveaux :

| Niveau | Vérification |
|---|---|
| Application | Réponse HTTP de `/health` |
| Tests | Exécution de Pytest |
| Docker | Construction et démarrage du conteneur |
| Kubernetes | Disponibilité du Deployment et des pods |
| Terraform | Validation et application de la configuration |
| Helm | Installation de la release |
| Prometheus | Accès à l'interface et aux métriques |
| Grafana | Accès aux tableaux de bord |
| Sécurité | Analyses automatisées de la CI |

## 13. Dépannage

### Docker ne démarre pas

Vérifier son état :

```bash
docker info
```

### Le cluster Kind est indisponible

Lister les clusters :

```bash
kind get clusters
```

Vérifier les contextes Kubernetes :

```bash
kubectl config get-contexts
```

### Un pod ne démarre pas

Afficher son état :

```bash
kubectl get pods
```

Afficher les événements :

```bash
kubectl describe pods
```

### Le monitoring ne répond pas

Vérifier les pods et services :

```bash
kubectl get pods,services -n monitoring
```

**Note sur Codespaces :** l'environnement Docker ou le cluster Kind peut être affecté par l'arrêt ou la recréation du Codespace. Le script de déploiement local facilite la reconstruction de l'environnement.

## 14. Documentation complémentaire

- [Architecture](architecture.md)
- [Sécurité](security.md)
- [README principal](../README.md)

---

**DevSecOps Platform — Guide de déploiement**

*Documentation des procédures d'installation, de déploiement et de vérification de la plateforme.*