/* Création du schéma jo, en précisant qu'on veut l'effacer s'il existe déjà */

DROP SCHEMA IF EXISTS jo;
CREATE SCHEMA jo;



/* Création de la table games qui contient les détails de chaque édition des JO, liée à la table athlètes par le nom précis de l'édition */
DROP TABLE IF EXISTS jo.games;
CREATE TABLE jo.games
(
	name VARCHAR(15) PRIMARY KEY NOT NULL,
    year INT,
    season VARCHAR(8),
    city VARCHAR(30)
);


/* Création de la table regions qui contient les informations des pays ou entités que les athlètes représentent, liée à la table athlète par le code npc */
DROP TABLE IF EXISTS jo.regions;
CREATE TABLE jo.regions
(
	code VARCHAR(5) PRIMARY KEY NOT NULL,
    region VARCHAR(60),
    notes VARCHAR(60)
);


/* Création de la table athlètes avec leurs principales informations, toujours en précisant le DROP TABLE pour pouvoir relancer le code sans problème */
DROP TABLE IF EXISTS jo.athletes;
CREATE TABLE jo.athletes
(
	auto_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	id VARCHAR(8),
    name VARCHAR(200),
    sex VARCHAR(3),
    age INT,
    height INT,
    weight FLOAT,
    team VARCHAR(50),
    noc VARCHAR(5),
    games VARCHAR(15),
    sport VARCHAR(50),
    event VARCHAR(100),
    medal VARCHAR(8),
    FOREIGN KEY (games) REFERENCES jo.games(name),
    FOREIGN KEY (noc) REFERENCES jo.regions(code)
);




/* Importation des données vers la table régions !!!! Changement d'acronyme pour Singapour qui est SIN sur le fichier régions mais SGP sur le fichier athlètes */
/* ATTENTION !!!! MySQL Server est par défaut en mode secure, les fichiers ne peuvent être upload que depuis un répertoire précis ! 
Utiliser la commande "SHOW VARIABLES LIKE "secure_file_priv"" pour l'afficher */
LOAD DATA INFILE "/var/lib/mysql-files/noc_regions.csv"
INTO TABLE jo.regions
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES;




/* Importation des données vers la table games. Modification du fichier CSV pour ne garder que les colonnes voulues */
/* Création d'une table temporaire pour stocker le fichier csv, nécessaire car besoin d'un ID spécifique */
CREATE TABLE jo.new_table
(
	event_id INT NOT NULL AUTO_INCREMENT,
    games VARCHAR(15) NOT NULL,
    year INT,
    season VARCHAR(8),
    city VARCHAR(30),
    PRIMARY KEY (event_id)
);

/* Importation des données dans la table temporaire */
LOAD DATA INFILE "/var/lib/mysql-files/events.csv"
INTO TABLE jo.new_table
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES
(Games, Year, Season, City);

/* Transfert des données dans la table jo.games en ne gardant que les valeurs uniques, plus besoin des ID */
INSERT IGNORE INTO jo.games
SELECT games, year, season, city
FROM jo.new_table;

/* Suppression de la table temporaire */
DROP TABLE jo.new_table;


/* Importation des données vers la table athletes. Modification du ficher CSV au préalable pour enlever les colonnes non voulues. Pas besoin d'une table temporaire car on ne veut pas enlever les valeurs uniques.
ATTENTION !!! Par défaut MySQL est en mode strict, ce qui empêche l'importation de données nulles à la place d'intégrales. Soit enlever le mode restrictif via le fichier my.ini (sql-mode="") soit remplacer les NA par zéro dans le fichier à importer */
LOAD DATA INFILE "/var/lib/mysql-files/athletes_linux.csv"
INTO TABLE jo.athletes
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES
(ID, Name, Sex, Age, Height, Weight, Team, NOC, Games, Sport, Event, Medal);
