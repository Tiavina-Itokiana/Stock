CREATE TABLE
    typesortie(
        id SERIAL PRIMARY KEY,
        nom VARCHAR
    );

CREATE TABLE
    unite (
        id SERIAL PRIMARY KEY,
        nomUnite VARCHAR,
        unite VARCHAR
    );

CREATE TABLE
    ARTICLE (
        ID SERIAL PRIMARY KEY,
        code VARCHAR,
        idUnite INT REFERENCES unite (id),
        idTypeSortie INT REFERENCES typesortie (id),
        nom VARCHAR
    );

CREATE TABLE
    magasin(
        id SERIAL PRIMARY KEY,
        nom VARCHAR,
        lieu VARCHAR
    );

INSERT INTO magasin
VALUES (default, 'M1', 'Antananarivo'), (default, 'M2', 'Tamatave'), (default, 'M2', 'Analakely');

-- Ito ny liste ana movements rehetra, hita ao @ type oe entree le izy sa sortie min'ny alalan'ny type

-- Type : 1 -> entree, 2 -> sortie

CREATE TABLE
    mouvement (
        id SERIAL PRIMARY KEY,
        idArticle INT REFERENCES Article (id),
        idMagasin INT REFERENCES Magasin (id),
        qantite FLOAT,
        dateMouvement TIMESTAMP,
        type INT
    );

-- Mipetaka ato ny entree ana article azo avy any anaty mouvement izany oe any anaty mouvement ihany koa ny date any

CREATE TABLE
    entree(
        id SERIAL PRIMARY KEY,
        idMouvement INT REFERENCES mouvement (id),
        quantite FLOAT,
        prixUnitaire FLOAT
    );

-- Liste an'ny sortie an'ny article, efa detaillé ilay iz, izany oe efa mipetaka ato ilay quantité mizarazara be ireny

CREATE TABLE
    sortie (
        id SERIAL PRIMARY KEY,
        idMouvement INT REFERENCES mouvement (id),
        idEntree INT REFERENCES entree (id),
        qantite FLOAT
    );

-- table an'ny reste ana stock ao anaty magasin, an'ny article

CREATE TABLE
    etat_stock (
        id SERIAL PRIMARY KEY,
        idEntree INT REFERENCES entree (id),
        /* Ito tsy maintsy oe entree */
        idMagasin INT REFERENCES magasin(id),
        reste FLOAT,
        dateEtat TIMESTAMP
    );

-- Données de test

--Unite(id,nomUnite,uunite)

insert INTO unite
VALUES (DEFAULT, 'kilogramme', 'kg'), (DEFAULT, 'litre', 'l');

-- Typesortie(id,nom)

INSERT INTO typesortie
VALUES (DEFAULT, 'FIFO'), (DEFAULT, 'LIFO');

-- Article (id,code,idUnite,idTypesortie,nom)

INSERT INTO ARTICLE
VALUES (DEFAULT, 'V0001', 1, 1, 'Vary'), (
        DEFAULT,
        'V0002',
        1,
        1,
        'Vary Mena'
    ), (
        DEFAULT,
        'V0003',
        1,
        1,
        'Vary Fotsy'
    );

-- mouvement(id,idArticle,idMagasin,quantite,dateMouvement)

INSERT INTO mouvement
VALUES
(
        DEFAULT,
        1,
        1,
        100,
        '2023-01-01 10:00:00',
        1
    );

INSERT INTO mouvement
VALUES
(
        DEFAULT,
        1,
        1,
        50,
        '2023-01-15 10:00:00',
        1
    );

--entree(id,idMouvement,quantite,prixUnit)

INSERT INTO entree VALUES (DEFAULT,2,50,125);

INSERT INTO entree VALUES (DEFAULT,2,100,500);

INSERT INTO entree VALUES (DEFAULT,3,75,750)

--etat_stock(id,idEntree,idMagasins,reste,dateetat)

INSERT INTO
    etat_stock
VALUES (
        DEFAULT,
        3,
        1,
        75,
        '2023-11-09 10:45:00'
    )

-- Hanao sortie ana 160 kg ana Vary en FIFO zah zao

-- Mampiditra an'ilay mouvement aloha zah

INSERT INTO
    mouvement
VALUES (
        DEFAULT,
        1,
        1,
        160,
        '2023-11-18 07:40:00'
    );

--Mampidirta an'ireo karazana sortie ilay efa mizarazara be

-- sortie(id,idMouvement,idEntree,quantite)

INSERT INTO
    sortie
VALUES (DEFAULT, 4, 1, 100), (DEFAULT, 4, 2, 50), (DEFAULT, 4, 3, 10);

--Mampiditra an'ireo etat de stock niova sisa de zay vita ny sortie

INSERT INTO
    etat_stock
VALUES (
        DEFAULT,
        1,
        1,
        0,
        '2023-11-18 07:40:00'
    ), (
        DEFAULT,
        2,
        1,
        0,
        '2023-11-18 07:40:00'
    ), (
        DEFAULT,
        3,
        1,
        65,
        '2023-11-18 07:40:00'
    );

--VIEWS

create
or
REPLACE VIEW v_entree AS
select
    entree.id as idEntree,
    mouvement.id as idMouvement,
    magasin.id as idMagasin,
    article.id as idArticle,
    --article
    article.nom as article,
    article.code as code,
    entree.quantite,
    unite.unite,
    entree.prixunitaire as prixunitaire,
    typesortie.nom as typesortie,
    --Magasin
    magasin.nom as magasin,
    magasin.lieu as lieumagasin,
    --mouvement
    mouvement.datemouvement as dateentree
from entree
    JOIN mouvement ON entree.idmouvement = mouvement.id
    JOIN article ON mouvement.idarticle = article.id
    JOIN unite ON article.idunite = unite.id
    JOIN magasin ON mouvement.idmagasin = magasin.id
    JOIN typesortie ON article.idtypesortie = typesortie.id

create
or
REPLACE VIEW v_sortie AS
select
    sortie.id as idSortie,
    m.id as idMouvement,
    magasin.id as idMagasin,
    article.id as idArticle,
    --article
    article.nom as article,
    article.code as code,
    --entree angalana anazy
    entree.id as idEntree,
    entree.quantite,
    unite.unite,
    entree.prixunitaire as prixunitaire,
    --Magasin
    magasin.nom as magasin,
    magasin.lieu as lieumagasin,
    --mouvement
    m.datemouvement as dateSortie
from sortie
    JOIN mouvement m ON sortie.idmouvement = m.id
    JOIN article ON article.id = m.idarticle
    JOIN unite ON article.idunite = unite.id
    JOIN magasin ON m.idmagasin = magasin.id
    JOIN entree ON sortie.identree = entree.id;

-- Mamoaka etat de stick ana magasin distinct

select *
FROM etat_stock
where reste > 0 AND idmagasin = 1
ORDER BY dateetat DESC;

select *
FROM etat_stock
    JOIN entree ON etat_stock.identree = entree.id
    JOIN mouvement ON entree.idmouvement = mouvement.id
    JOIN article ON mouvement.idarticle = article.id
    JOIN typesortie on article.idtypesortie = typesortie.id
    JOIN magasin ON etat_stock.idmagasin = magasin.id;

-- View an'illay etat de stock

CREATE
or
REPLACE VIEW v_etat_stock AS
select
    etat_stock.id as idEtat,
    etat_stock.identree as idEntree,
    etat_stock.idmagasin as idMagasin,
    article.id as idarticle,
    article.code as code,
    article.nom as article,
    etat_stock.reste as reste,
    magasin.nom as magasin,
    mouvement.datemouvement as dateEntree,
    etat_stock.dateetat as dateetat
FROM etat_stock
    JOIN entree ON etat_stock.identree = entree.id
    JOIN mouvement ON entree.idmouvement = mouvement.id
    JOIN article ON mouvement.idarticle = article.id
    JOIN typesortie on article.idtypesortie = typesortie.id
    JOIN magasin ON etat_stock.idmagasin = magasin.id;

-- View an'ilay article

select *
from article
    JOIN unite ON article.idunite = unite.id
    JOIN typesortie ON article.idtypesortie = typesortie.id;

CREATE
or
REPLACE VIEW v_article AS
select
    article.id as idArticle,
    article.code,
    article.nom as nom,
    unite.id as idUnite,
    unite.unite as unite,
    typesortie.id as idtypesortie,
    typesortie.nom as typesorite
from article
    JOIN unite ON article.idunite = unite.id
    JOIN typesortie ON article.idtypesortie = typesortie.id;

select * from v_etat_stock ORDER BY dateentree,dateetat;

-- Mamarina ny entree rehetra en mode FIFO, de efa le resyte any sisa no hita eo, izany oe hita eo izany izay entree en mode fifo, miaraka @ quantite restante any

CREATE
OR
REPLACE VIEW v_etat_reste AS
select s1.*
from v_etat_stock s1
    JOIN(
        SELECT
            identree,
            MAX(dateetat) as etatRecente
        FROM v_etat_stock
        GROUP BY
            identree
    ) s2 ON s1.identree = s2.identree
    AND s1.dateetat = s2.etatRecente
ORDER by s1.dateentree;

-- Maka ao anaty v_etat_reste en FIFO

SELECT * from v_etat_reste ORDER BY dateentree ASC;

-- Maka ao anaty v_etat_reste en LIFO

SELECT * from v_etat_reste ORDER BY dateentree DESC;