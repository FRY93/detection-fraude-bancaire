
/* Création  d'une bibliothèque*/

LIBNAME PRO_GBO "/home/u49966568/Projet_Collaboratif";

/* Importation des données */

PROC IMPORT DATAFILE="/home/u49966568/Projet_Collaboratif/fraud_detection_dataset.csv"
    OUT=pro_gbo.fraude
    DBMS=CSV
    REPLACE;
    GETNAMES=YES;
    DELIMITER=";";
RUN;

PROC CONTENTS DATA=pro_gbo.fraude;
RUN;

/* Vérification des valeurs manquantes */

PROC MEANS DATA=pro_gbo.fraude NMISS;
    VAR Time Amount V1-V28;
    TITLE "Nombre de valeurs manquantes par variable";
RUN;

/* Suppression des observations incomplètes */

DATA fraud_clean;
    SET pro_gbo.fraude;
    IF NMISS(Time, Amount, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10,
             V11, V12, V13, V14, V15, V16, V17, V18, V19, V20,
             V21, V22, V23, V24, V25, V26, V27, V28) = 0;
RUN;

/* Vérification du nombre d'observations */

PROC SQL;
    SELECT COUNT(*) AS Nb_obs_apres_nettoyage
    FROM fraud_clean;
QUIT;

/* Analyse du déséquilibre de classes*/

PROC FREQ DATA=fraud_clean;
    TABLES Class / NOCUM;
    TITLE "Répartition des transactions frauduleuses";
RUN;

proc sgplot data=fraud_clean;
    vbar Class;
    title "Déséquilibre des classes";
    xaxis label="Classe";
    yaxis label="Fréquence";
run;

/* Statistiques descriptives sur le montant*/

PROC MEANS DATA=fraud_clean MEAN MEDIAN STD MIN MAX;
    CLASS Class;
    VAR Amount;
    TITLE "Statistiques descriptives du montant selon la classe";
RUN;

proc sgplot data=fraud_clean;
    histogram Amount;
    density Amount;
    title "Distribution du montant";
run;

proc sgpanel data=fraud_clean;
    panelby Class;
    histogram Amount;
    title "Montant par classe";
run;

proc sgplot data=fraud_clean;
    vbox Amount / category=Class;
    title "Boxplot du montant par classe";
run;

/*Comparaison statistique (test de moyenne)*/

proc ttest data=fraud_clean;
    class Class;
    var Amount;
    title "Test de comparaison des montants entre fraude et non fraude";
RUN;

/*Régression logistique explicative*/

proc logistic data=fraud_clean descending;
    model Class = Amount V1-V28;
    title "Régression logistique";
run;

proc logistic data=fraud_clean descending;
    model Class = Amount V1-V28 / expb;
    title "Régression logistique avec Odds Ratios";
run;

PROC LOGISTIC DATA=fraud_clean DESCENDING;
    MODEL Class =
        Time V1 V2 V3 V4 V5 V6 V7 V8 V9 V10
        V11 V12 V13 V14 V15 V16 V17 V18 V19 V20
        V21 V22 V23 V24 V25 V26 V27 V28
        Amount
    / SELECTION=STEPWISE;
    TITLE "Régression logistique explicative de la fraude bancaire";
RUN;

proc logistic data=fraud_clean descending;
    model Class = Amount V1-V28;
    roc 'Modèle complet';
    title "Courbe ROC";
run;

proc logistic data=fraud_clean descending;
    model Class = Amount V1-V28;
    output out=pred p=proba;
run;

proc sgplot data=pred;
    histogram proba;
    title "Distribution des probabilités prédites";
run;

/*Matrice de confusion (seuil 0.5)*/

data pred_class;
    set pred;
    if proba > 0.5 then pred_class = 1;
    else pred_class = 0;
run;

proc freq data=pred_class;
    tables Class*pred_class / nopercent norow nocol;
    title "Matrice de confusion";
run;

/* Graphique des Odds Ratios*/

ods graphics on;

proc logistic data=fraud_clean descending plots=oddsratio;
    model Class = Amount V1-V10;
    title "Graphique des Odds Ratios";
run;

ods graphics off;

/*Distribution de variables clés (ex V1)*/

proc sgplot data=fraud_clean;
    histogram V1 / group=Class transparency=0.5;
    density V1 / group=Class;
    title "Distribution de V1 par classe";
run;














