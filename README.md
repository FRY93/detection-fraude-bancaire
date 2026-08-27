# Détection des fraudes dans les transactions bancaires

Projet collaboratif — Diplôme *Data Analyst, Informatique et Statistique pour la décision*
Faculté d'Économie, Université de Montpellier (2025-2026)

**Auteur :** Kobenan Gboko
**Encadrant :** Thierry Blayac

## Contexte

Les fraudes par carte bancaire représentent des coûts considérables pour les banques et une perte de confiance pour les clients. Elles sont difficiles à détecter car elles sont rares (moins de 0,5 % des transactions) et parce que tout faux positif pénalise un client innocent.

Ce projet analyse des données transactionnelles anonymisées pour caractériser les fraudes et comparer l'aptitude de différentes méthodes à les identifier :
- **Python** pour l'analyse exploratoire et la modélisation prédictive (régression logistique, Random Forest)
- **SAS** pour l'analyse statistique et une régression logistique interprétable

## Question de recherche

Dans quelle mesure les données transactionnelles permettent-elles de détecter les fraudes, et quels facteurs y sont le plus fortement associés ?

## Données

Dataset public Kaggle *Credit Card Fraud Detection*, publié par des chercheurs de l'ULB (Université Libre de Bruxelles) en collaboration avec Worldline. Les variables `V1` à `V28` sont issues d'une ACP anonymisant les transactions.

| Variable | Description |
|---|---|
| `Time` | Temps écoulé depuis la première transaction |
| `Amount` | Montant de la transaction |
| `V1`–`V28` | Composantes anonymisées issues d'une ACP |
| `Class` | Cible : 1 = fraude, 0 = transaction normale |

Le jeu de données est fortement déséquilibré : **99,56 % de transactions normales contre 0,44 % de fraudes**.

## Méthodologie

- Suppression des observations incomplètes (peu de valeurs manquantes, variables déjà transformées)
- Python : pondération des classes (`class_weight="balanced"`), régression logistique et Random Forest, évaluation par rappel, précision et AUC-ROC
- SAS : `PROC FREQ`, `PROC MEANS`, `PROC TTEST`, régression logistique explicative avec rapports de cotes

## Résultats

| Modèle | Précision (fraude) | Rappel (fraude) | AUC-ROC |
|---|---|---|---|
| Régression logistique (Python) | 0,29 | 0,82 | 0,946 |
| Random Forest (Python) | 1,00 | 0,76 | 0,999 |
| Régression logistique (SAS) | 0,94 | 0,84 | — |

- Le **Random Forest** est le plus performant en détection brute (AUC proche de 1) mais reste peu interprétable.
- La **régression logistique SAS** offre le meilleur compromis précision/interprétabilité, avec des odds ratios directement mobilisables pour justifier une décision de blocage.
- Les variables `V14`, `V12`, `V3` et `V4` sont les plus discriminantes selon l'analyse d'importance du Random Forest.
- Les deux approches sont **complémentaires** : Python pour maximiser la détection, SAS pour expliquer et justifier.

Le rapport complet (contexte, méthodologie détaillée, discussion) est disponible dans [`report/Rapport_Projet.pdf`](report/Rapport_Projet.pdf).

## Structure du dépôt

```
.
├── notebooks/
│   └── analyse_fraude.ipynb    # Analyse exploratoire et modélisation Python
├── sas/
│   └── analyse_sas.sas         # Script SAS (import, stats descriptives, régression logistique)
├── report/
│   └── Rapport_Projet.pdf      # Rapport complet du projet
├── data/
│   └── creditcard.csv          # Dataset (source : Kaggle / ULB / Worldline)
└── README.md
```

## Reproduire l'analyse

```bash
git clone <url-du-repo>
cd <repo>
pip install -r requirements.txt
jupyter notebook notebooks/analyse_fraude.ipynb
```

Le script SAS (`sas/analyse_sas.sas`) nécessite un environnement SAS (ex. SAS OnDemand for Academics) et adapte le chemin `LIBNAME` / `PROC IMPORT` vers `data/creditcard.csv`.

## Limites et perspectives

- L'anonymisation des variables `V1`–`V28` empêche toute interprétation métier directe.
- L'ajout de données contextuelles (localisation, historique client) réduirait probablement les faux positifs.
- Pistes d'amélioration : gradient boosting, réseaux de neurones, déploiement en temps réel avec suivi de dérive des prédictions.

## Source des données

Dataset : [Credit Card Fraud Detection (Kaggle)](https://www.kaggle.com/mlg-ulb/creditcardfraud) — Machine Learning Group, Université Libre de Bruxelles, en collaboration avec Worldline.
