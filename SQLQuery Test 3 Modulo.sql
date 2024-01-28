CREATE DATABASE TEST3MODULO;
USE TEST3MODULO

CREATE TABLE PRODOTTI
(IDProdotto INT,
NomeProdotto VARCHAR (40),
Categoria VARCHAR (30),
Prezzo DECIMAL (10,2),
ProdottoFinito BIT,
Disponibilità BIT,
CONSTRAINT PK_IDProdotto PRIMARY KEY (IDProdotto))

INSERT INTO PRODOTTI
VALUES
(1,'Dudù', 'Peluche',8,1,1),
(2,'Playstation', 'Svago', 200,1,1),
(3,'Barbie', 'Bambola', 15,1,0),
(4,'Gameboy', 'Svago', 80,1,1),
(5,'Puzzle', 'Giochi Didattici',10,1,0),
(6,'Chitarra', 'Svago', 20,0,1);

CREATE TABLE VENDITE
(IDVendite INT,
IDProdotto INT,
IDRegione INT,
DataVendita DATE,
Quantità INT,
ImportoVendite DECIMAL(10,2),
CONSTRAINT PK_IDVendite PRIMARY KEY(IDVendite),
CONSTRAINT FK_IDProdotto FOREIGN KEY (IDProdotto) REFERENCES PRODOTTI(IDProdotto),
CONSTRAINT FK_IDRegione FOREIGN KEY (IDRegione) REFERENCES REGIONE(IDRegione));

EXEC SP_RENAME 'Vendite.ImportoVendite', 'RigaOrdine', 'COLUMN';
INSERT INTO VENDITE
VALUES
(001,1,01, '10-05-2023',40,220),
(002,2,02, '12-06-2023',30,320),
(003,3,03, '20-01-2022',55,155),
(004,4,04, '23-02-2022',35,130),
(005,5,05, '11-05-2023',50,240),
(006,6,06, '14-08-2021',35,120);



CREATE TABLE REGIONE
(IDRegione INT,
NomeRegione VARCHAR (30),
Stato VARCHAR (30),
CONSTRAINT PK_IDRegione PRIMARY KEY (IDRegione));

INSERT INTO REGIONE
VALUES 
(01,'Europa','Italia'),
(02,'Asia', 'Giappone'),
(03,'America','Messico'),
(04,'Europa','Spagna'),
(05,'Africa','Tanzania'),
(06,'Asia','Cina');

SELECT COUNT(*) IDProdotto
FROM PRODOTTI
GROUP BY IDProdotto
HAVING COUNT(*)>1

SELECT COUNT(*) IDVendite
FROM VENDITE
GROUP BY IDVendite
HAVING COUNT(*)>1

SELECT COUNT(*) IDRegione
FROM REGIONE
GROUP BY IDRegione
HAVING COUNT(*)>1

/*	Esporre l’elenco delle transazioni indicando nel result set il codice documento, la data, il nome del prodotto, la categoria del prodotto, 
il nome dello stato, il nome della regione di vendita e un campo booleano valorizzato in base alla condizione che siano passati
più di 180 giorni dalla data vendita o meno (>180 -> True, <= 180 -> False)*/

SELECT V.IDVendite AS CodiceDoc,
V.DataVendita AS DataVend,
P.NomeProdotto,
P.Categoria,
R.Stato,
R.NomeRegione,
CASE WHEN DATEDIFF (DAY,V.DataVendita,GETDATE())>180 THEN 'TRUE'
ELSE 'FALSE'
END AS Trascorsi180gg
FROM VENDITE AS V
INNER JOIN PRODOTTI AS P
ON V.IDProdotto=P.IDProdotto
INNER JOIN REGIONE AS R
ON V.IDRegione=R.IDRegione

--Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno. 

SELECT  P.IDProdotto, 
P.NomeProdotto,
YEAR (V.DataVendita) AS AnnoVendita,
SUM (P.Prezzo * V.Quantità) AS FatturatoTot
FROM PRODOTTI AS P
INNER JOIN VENDITE AS V
ON P.IDProdotto=V.IDProdotto
GROUP BY YEAR (V.DataVendita),
P.IDProdotto,
P.NomeProdotto;

--Esporre il fatturato totale per stato per anno. Ordina il risultato per data e per fatturato decrescente.

SELECT  P.IDProdotto, 
R.Stato,
YEAR (V.DataVendita) AS AnnoVendita,
SUM (P.Prezzo * V.Quantità) AS FatturatoTot
FROM PRODOTTI AS P
INNER JOIN VENDITE AS V
ON P.IDProdotto=V.IDProdotto
INNER JOIN REGIONE AS R
ON V.IDRegione=R.IDRegione
GROUP BY P.IDProdotto,
R.Stato,
YEAR(V.DataVendita)
ORDER BY AnnoVendita DESC,
FatturatoTot DESC;

--Rispondere alla seguente domanda: qual è la categoria di articoli maggiormente richiesta dal mercato?

SELECT MAX (Categoria) AS CategPiùRichiesta
FROM PRODOTTI

--Rispondere alla seguente domanda: quali sono, se ci sono, i prodotti invenduti? Proponi due approcci risolutivi differenti.

SELECT NomeProdotto,
ProdottoFinito
FROM PRODOTTI
WHERE ProdottoFinito=0

SELECT NomeProdotto,
ProdottoFinito,
CASE WHEN (ProdottoFinito)=0 THEN 'NON VENDUTO'
ELSE 'VENDUTO'
END AS Giacenza
FROM PRODOTTI

--Esporre l’elenco dei prodotti con la rispettiva ultima data di vendita (la data di vendita più recente).

SELECT MAX (DataVendita) AS VenditaPiùRecente,
P.NomeProdotto
FROM VENDITE AS V
INNER JOIN
PRODOTTI AS P
ON V.IDProdotto=P.IDProdotto
GROUP BY P.NomeProdotto

/*Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” delle
informazioni utili (codice prodotto, nome prodotto, nome categoria)*/

CREATE VIEW VW_SD_PRODOTTI AS (
SELECT IDProdotto,NomeProdotto,Categoria
FROM PRODOTTI)

SELECT *
FROM VW_SD_PRODOTTI

--Creare una vista per restituire una versione “denormalizzata” delle informazioni geografiche

CREATE VIEW VW_SD_INFOREGIONI AS (
SELECT R.IDRegione,
R.NomeRegione,
R.Stato,
V.DataVendita,
P.NomeProdotto
FROM REGIONE AS R
INNER JOIN VENDITE AS V 
ON  R.IDRegione=V.IDRegione
INNER JOIN PRODOTTI AS P
ON P.IDProdotto= V.IDProdotto
GROUP BY R.IDRegione, P.NomeProdotto,R.NomeRegione,R.Stato,V.DataVendita
);


CREATE VIEW VW_SD_VENDITE AS (
SELECT V.IDRegione,
V.IDVendite,
P.IDProdotto,
P.NomeProdotto, 
V.DataVendita,
SUM (P.Prezzo * V.Quantità) AS FatturatoTot
FROM VENDITE AS V
INNER JOIN PRODOTTI AS P
ON V.IDProdotto=P.IDProdotto
GROUP BY P.IDProdotto,P.NomeProdotto, V.DataVendita, V.IDRegione,V.IDVendite);

SELECT *
FROM VW_SD_INFOREGIONI
SELECT *
FROM VW_SD_PRODOTTI
SELECT *
FROM VW_SD_VENDITE




