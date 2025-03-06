drop table if exists investimento cascade;
drop table if exists canale cascade;
drop table if exists utente cascade;
drop table if exists azienda cascade;
drop table if exists sede cascade;
drop table if exists campagna cascade;
drop table if exists saldi cascade;
drop table if exists prodotto cascade;
drop table if exists banner cascade;
drop table if exists interessi_sportivi cascade;
drop table if exists utente cascade;
drop table if exists visione cascade;
drop table if exists evento cascade;
drop table if exists sponsorizzazione cascade;
drop table if exists roas cascade;
drop table if exists cac cascade;
drop table if exists reach cascade;
drop table if exists aumento_clienti cascade;
drop table if exists scan_qrcode cascade;
drop table if exists frequency cascade;
drop table if exists impression cascade;
drop table if exists kpi_share cascade;
drop table if exists numero_vendite cascade;
drop table if exists collocazione cascade;


/* Creazione database*/
create table azienda(
	partita_iva char(11),
	data_inizio_validita date,
	data_fine_validita date,
	nome varchar(30) not null,
	data_fondazione date,
	indirizzo_web varchar(100),
	CHECK (data_fine_validita > data_inizio_validita or data_fine_validita is null),
	primary key(partita_iva,data_inizio_validita)
);
create table sede(
	cap char(5),
	via varchar(30),
	numero_civico integer,
	telefono varchar(20) not null unique,
	email varchar(319) not null CHECK (email LIKE'%_@__%.__%'),
	primary key(cap,via,numero_civico)
);
create table collocazione(
	cap char(5),
	via varchar(30),
	numero_civico integer,
	aziendaId char(11),
	data_azienda date,
	primary key(cap,via,numero_civico,aziendaId,data_azienda),
	foreign key(cap,via,numero_civico) references sede(cap,via,numero_civico)on delete cascade on update cascade,
	foreign key (aziendaID,data_azienda) references azienda(partita_iva,data_inizio_validita) on delete cascade on update cascade deferrable initially deferred
);

create table roas( 
	aziendaID char(11),
	data_azienda date,  
	valore numeric(5,2) not null check(valore >= 0),
	data_inizio date,
	data_fine date,
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null),
	CHECK (data_fine > data_inizio or data_fine is null),
	foreign key (aziendaID,data_azienda) references azienda(partita_iva,data_inizio_validita) on delete cascade on update cascade,
	primary key(data_inizio,aziendaID,data_azienda)
);

create table aumento_clienti(
    aziendaID char(11),
	data_azienda date, 
	valore numeric(5,2) not null check(valore >= 0),
	data_inizio date,
	data_fine date,
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null),
	CHECK (data_fine > data_inizio or data_fine is null),
	foreign key (aziendaID,data_azienda) references azienda(partita_iva,data_inizio_validita) on delete cascade on update cascade,
	primary key(data_inizio,aziendaID,data_azienda)
);

create table campagna(
	campagnaID varchar(10) primary key,
	nome varchar(50) not null, 
	data_inizio timestamp not null,
	target varchar(50) not null,
	status varchar(9) not null CHECK (status IN ('attivo','terminato')),
	tipo_prodotti varchar(30) not null,
	budget numeric(11,2) not null default 0,
	tipo varchar(15) not null CHECK (tipo IN ('lancio', 'mantenimento'))
);

create table investimento(
	data_investimento date,
	campagnaID varchar(10) references campagna(campagnaID) on delete cascade on update cascade deferrable initially deferred,
	aziendaID char(11),
	data_azienda date,
	capitale_investito numeric(10,2) not null,
	foreign key (aziendaID,data_azienda) references azienda(partita_iva,data_inizio_validita) on delete cascade on update cascade,
	primary key(data_investimento,campagnaID,aziendaID,data_azienda)
);

create table cac(
    campagnaID varchar(10) references campagna(campagnaID) on delete cascade on update cascade,
	valuta varchar(30) not null,  
	valore numeric(5,2) not null check(valore >= 0),
	data_inizio date,
	data_fine date,
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null),
	CHECK (data_fine > data_inizio or data_fine is null),
	primary key(data_inizio,campagnaID)
);

create table reach(
    campagnaID varchar(10) references campagna(campagnaID) on delete cascade on update cascade, 
	valore integer not null check(valore >= 0),
	data_inizio date,
	data_fine date,
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null),
	CHECK (data_fine > data_inizio or data_fine is null),
	primary key(data_inizio,campagnaID)
);

create table prodotto(
	prodottoID varchar(30) primary key,
	nome varchar(30) not null,
	marca varchar(30) not null,
	categoria varchar(30) not null,
	prezzo numeric(8,2) not null check(prezzo > 0.00),
	colore varchar(30) not null,
	luogo_produzione varchar(20) not null,
	materiale varchar(30) not null,
	genere varchar(30) not null
);

create table numero_vendite(
	prodottoID varchar(30) references prodotto(prodottoID) on delete cascade on update cascade,
	valore integer not null check(valore >= 0),
	data_inizio date,
	data_fine date,
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null),
	CHECK (data_fine > data_inizio),
	primary key(prodottoID,data_inizio)
);

create table saldi(
    campagnaID varchar(10) references campagna(campagnaID) on update cascade on delete cascade,
    prodottoID varchar(30) references prodotto(prodottoID) on update cascade on delete cascade deferrable initially deferred,
    sconto_percentuale integer CHECK (sconto_percentuale >= 0 AND sconto_percentuale <= 80),
    primary key(campagnaID,prodottoID)
);

create table banner(
	bannerID varchar(20) primary key,
	costo_per_secondo numeric(5,3) not null check(costo_per_secondo > 0.000),
	lunghezza integer not null check(lunghezza >= 0),
	larghezza integer not null check(larghezza >= 0),
	forma varchar(30) not null,
	colore varchar(30) not null,
	qr_code varchar(15),
	scritta varchar(100),
	lingua varchar(30),
	prodottoID varchar(30) references prodotto(prodottoID) on delete set null on update cascade,
	campagnaID varchar(10) not null references campagna(campagnaID) on delete cascade on update cascade,
	check((qr_code is not null and prodottoID is not null)or qr_code is null),
	check((scritta is not null and lingua is not null)or(scritta is null and lingua is null))
);

create table scan_qrcode(
	bannerID varchar(20) primary key references banner(bannerID) on delete cascade on update cascade,
	valore integer not null check(valore >= 0),
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null)
);

create table frequency(
    bannerID varchar(20) primary key references banner(bannerID) on delete cascade on update cascade,
	valore numeric(5,2) not null check(valore >= 0),
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null)
);

create table impression(
    bannerID varchar(20) primary key references banner(bannerID) on delete cascade on update cascade,
	valore integer not null check(valore >= 0),
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null)
);

create table canale(
	nome varchar(30) primary key,
	categoria varchar(30)
);

create table evento(
	nome varchar(50),
	descrizione varchar(250) not null,
	data_evento timestamp,
	canaleID varchar(30) not null references canale(nome) on delete set null on update cascade,
	primary key(nome,data_evento)
);

create table kpi_share(
    evento varchar(50)not null,
	data_evento timestamp not null,
	valore numeric(5,2) not null check(valore >= 0),
	priorita varchar(30) CHECK (priorita IN ('bassa', 'media', 'alta') or priorita is null),
	foreign key (evento,data_evento) references evento(nome,data_evento) on delete cascade on update cascade,
	primary key(evento,data_evento)
);

create table sponsorizzazione(
	bannerID varchar(20) references banner(bannerID) deferrable initially deferred,
	evento varchar(50) not null,
	data_evento timestamp not null,
	durata_banner integer not null CHECK (durata_banner > 0),
	posizione varchar(30) not null,
	foreign key (evento,data_evento) references evento(nome,data_evento) on delete cascade on update cascade,
	primary key(bannerID,evento,data_evento)
);

create table utente(
	codice_profilo varchar(30) primary key,
	email varchar(319) not null unique CHECK (email LIKE'%_@__%.__%'),
	nome varchar(30) not null,
	cognome varchar(30) not null,
	data_di_nascita date not null,
	sesso char(1) not null CHECK (sesso IN ('m', 'f')),
	numero_di_dispositivi integer not null CHECK (numero_di_dispositivi <= 4)
);

create table interessi_sportivi(
	sport varchar(30),
	utenteID varchar(30) references utente(codice_profilo) on delete cascade on update cascade,
	primary key(sport,utenteID)
);

create table visione(
	evento varchar(50)not null,
	data_evento timestamp not null,
	utenteID varchar(30) references utente(codice_profilo),
	foreign key (evento,data_evento) references evento(nome,data_evento) on delete cascade on update cascade,
	primary key(evento,data_evento,utenteID)
);

/* Popolamento database*/
/*Sedi*/
insert into sede values ('20090','VIALE MILANO FIORI',2,'025753901','andrea.trentin@nike.com');
insert into sede values ('20900','VIA BOSCO',2,'025753904','andrea.trentin@nike.com');
insert into sede values ('20900',' VIA MONTE SAN PRIMO',1,'0399300008','info.italy@adidas.com');
insert into sede values ('20057 ','VIA ROGGIA BARTOLOMEA',9,'028939111','service@puma.com');
insert into sede values ('10040','VIA GALVANI',4,'0110620464','info@spalding1876.com');
insert into sede values ('62019','VIA SAN FRANCESCO',10,'0717574422','info@wilson.com');
insert into sede values ('39100','VIA GALILEO GALILEI',2,'0823609107','customercare@newbalance.eu');
insert into sede values ('20154','VIA CERESIO',7,'0220521401','domande@footlocker.eu');
insert into sede values ('31031','VIA MONTELLO',80,'80020145420','privacy@diadora.com');
insert into sede values ('80038','VIA F.TERRACCIANO',213,'0818842345','customer@robedikappa.com');
insert into sede values ('12100','VIA CEIRANO FRATELLI',3,'0171416111','consumatore-it@asics.com');
insert into sede values ('20035','VIALE VALASSINA',268,'0395979792','decathlonitalia@pec.it');

/*collocazione e azienda*/
begin transaction;
insert into collocazione values ('20090','VIALE MILANO FIORI',2,'05359451001','1971-05-30');
insert into azienda values('05359451001','1971-05-30',null,'Nike','1964-01-25','www.Nike.com');
commit;

begin transaction;
insert into collocazione values ('20900','VIA BOSCO',2,'05359451001','1964-01-25');
insert into azienda values('05359451001','1964-01-25','1971-05-30','Blue Ribbon Sports','1964-01-25',null);
commit;

begin transaction;
insert into collocazione values ('20900',' VIA MONTE SAN PRIMO',1,'03188230969','1963-07-18');
insert into azienda values ('03188230969','1963-07-18',null,'Adidas','1949-08-18','www.Adidas.com');
commit;

begin transaction;
insert into collocazione values ('20057','VIA ROGGIA BARTOLOMEA',9,'11904560155','1948-03-12');
insert into azienda values ('11904560155','1948-03-12','1975-03-30','Puma','1948-03-12','null');
commit;

begin transaction;
insert into collocazione values ('20057 ','VIA ROGGIA BARTOLOMEA',9,'11904560155','1975-03-30');
insert into azienda values ('11904560155','1975-03-30',null,'Puma','1948-03-12','www.Puma.com');
commit;

begin transaction;
insert into collocazione values ('10040','VIA GALVANI',4,'02084910393','1876-02-15');
insert into azienda values ('02084910393','1876-02-15',null,'Spalding','1876-06-30','www.Spalding.com');
commit;

begin transaction;
insert into collocazione values ('62019','VIA SAN FRANCESCO',10,'14095911005','1986-04-23');
insert into azienda values ('14095911005','1986-04-23',null,'Wilson','1913-04-23','www.Wilson.com');
commit;

begin transaction;
insert into collocazione values ('39100','VIA GALILEO GALILEI',2,'01715070213','1999-02-06');
insert into azienda values ('01715070213','1999-02-06',null,'New Balance','1906-05-09','www.NewBalance.com');
commit;

begin transaction;
insert into collocazione values ('20154','VIA CERESIO',7,'10322270157','1974-09-12');
insert into azienda values ('10322270157','1974-09-12','1993-05-16','FootLocker','1974-05-12','null');
commit;

begin transaction;
insert into collocazione values ('20154','VIA CERESIO',7,'10322270157','1993-05-16');
insert into azienda values ('10322270157','1993-05-16',null,'FootLocker','1974-05-12','www.footlocker.com');
commit;

begin transaction;
insert into collocazione values ('31031','VIA MONTELLO',80,'04308510264','1969-03-15');
insert into azienda values ('04308510264','1969-03-15',null,'Diadora','1948-03-11','www.Diadora.com');
commit;

begin transaction;
insert into collocazione values ('80038','VIA F.TERRACCIANO',213,'10796170966','1980-06-02');
insert into azienda values ('10796170966 ','1980-06-02',null,'Robe di Kappa','1978-04-28','www.Kappa.com');
commit;

begin transaction;
insert into collocazione values ('12100','VIA CEIRANO FRATELLI',3,'02234250047','1999-01-24');
insert into azienda values ('02234250047','1999-01-24',null,'Asics','1977-07-21','www.Asics.com');
commit;

begin transaction;
insert into collocazione values ('20035','VIALE VALASSINA',268,'11005760159','1976-02-15');
insert into azienda values ('11005760159','1976-02-15',null,'Decathlon','1977-02-17','www.Decathlon');
commit;

/*Campagna*/
begin transaction;
insert into investimento values('2020-11-10','0000000000','11005760159','1976-02-15',5000000);/*decathlon-boxe*/
insert into campagna values ('0000000000','CampagnaIncotriBox','2020-11-10 08:00:00','Persone interessate al Box','attivo','Guantoni',0,'lancio');
commit;

begin transaction;
insert into investimento values('2020-09-23','0000000001','05359451001','1971-05-30',15000000.75);/*nike-scarpettedacalcio*/
insert into campagna values ('0000000001','CampagnaScarpetteDaCalcio','2019-05-15 08:00:00','Persone interessate al Calcio','attivo','Scarpette da calcio',0,'lancio');
commit;

begin transaction;
insert into investimento values('2021-07-06','0000000002','01715070213','1999-02-06',9000000);/*newBalance-saldiestivi*/
insert into campagna values ('0000000002','SaldiEstivi','2021-07-05 08:00:00','Persone interessate agli Sconti Estivi','terminato','Articoli estivi in saldo',0,'mantenimento');
commit;

begin transaction;
insert into investimento values('2021-01-15','0000000003','01715070213','1999-02-06',6000000);/*newBalance-saldiInvernali*/
insert into campagna values ('0000000003','SaldiInvernali','2021-01-15 08:00:00','Persone interessate agi Sconti Invernali','attivo','Articoli invernali in saldo',0,'mantenimento');
commit;

begin transaction;
insert into investimento values('2022-10-25','0000000004','11904560155','1975-03-30',5000000);/*puma-blackFriday*/
insert into campagna values ('0000000004','BlackFriday','2022-10-25 08:00:00','Persone interessate al BlackFriday','terminato','Articoli con 25% di sconto',0,'mantenimento');
commit;

begin transaction;
insert into investimento values('2020-06-21','0000000005','14095911005','1986-04-23',12000000.5);/*wilson-racchettetennis*/
insert into campagna values ('0000000005','CampagnaRacchetteDaTennis','2020-06-20 08:00:00','Persone interessate al Tennis','attivo','Racchettte da tennis',0,'lancio');
commit;

begin transaction;
insert into investimento values('2023-03-22','0000000006','05359451001','1971-05-30',15300000.75);/*nike-completodacalcio*/
insert into campagna values ('0000000006','CampagnaCompletiniDaCalcio','2023-03-22 08:00:00','Persone interessate al calcio','attivo','Completini da calcio',0,'lancio');
commit;

begin transaction;
insert into investimento values('2020-06-30','0000000007','02084910393','1876-02-15',48000000);/*spalding-pallonidabasket*/
insert into campagna values	('0000000007','CampagnaPalloniDaBasket','2020-06-30 08:00:00','Persone interessate al Basket','attivo','Palloni da Basket',0,'lancio');
commit;

begin transaction;
insert into investimento values('2021-06-13','0000000008','01715070213','1999-02-06',4250000.75);/*newBalance-sneakers*/
insert into campagna values ('0000000008','CampagnaSneakers','2021-06-13 08:00:00','Persone interessate alle sneakers','attivo','Sneakers',0,'lancio');
commit;

begin transaction;
insert into investimento values('2021-05-01','0000000009','11005760159','1976-02-15',2750000.75);/*decathlon-piscina*/
insert into campagna values	('0000000009','CampagnaArticoliPiscina','2021-05-01 08:00:00','Persone interessate al nuoto','terminato','Articoli per la piscina',0,'lancio');
commit;

begin transaction;
insert into investimento values('2022-04-06','0000000010','01715070213','1999-02-06',6000000);/*newBalance-saldiPrimavera*/
insert into campagna values	('0000000010','SaldiPrimaverili','2022-04-01 08:00:00','Persone interessate agli Articoli in Sconto','attivo','Articoli primaverili in saldo',0,'mantenimento');
commit;

/*Transazione tra Prodotto e saldi*/
begin transaction;
insert into saldi  values('0000000000','1',null);
insert into prodotto values('1','Guantone proX6','decathlon','Guantone',92.50,'nero','Cina','pelle','unisex');
commit;

begin transaction;
insert into saldi values('0000000000','2',null);
insert into prodotto values('2','Guantone proX6','decathlon','Guantone',92.50,'bianco','Cina','pelle','unisex');
commit;

begin transaction;
insert into saldi values('0000000000','3',null);
insert into prodotto values('3','Guantone basic2F','nike','Guantone',76.50,'nero','Cina','pelle','unisex');
commit;

begin transaction;
insert into saldi values('0000000000','4',null);
insert into prodotto values('4','Guantone mediumD3F','adidas','Guantone',33.99,'rosso','Cina','pelle','unisex');
commit;

begin transaction;
insert into saldi values('0000000000','5',null);
insert into prodotto values('5','Guantone basic36F','puma','Guantone',20.75,'bianco','Cina','pelle','unisex');
commit;

begin transaction;
insert into saldi values('0000000001','6',null);
insert into prodotto values('6','air fly 3','nike','scarpa da calcio',112.99,'verde','Stati Uniti','stoffa','maschio');
commit;

begin transaction;
insert into saldi values('0000000001','7',null);
insert into prodotto values('7','air fly 3','nike','scarpa da calcio',79.99,'verde','Stati Uniti','stoffa','bambino');
commit;

begin transaction;
insert into saldi values('0000000001','8',null);
insert into prodotto values('8','future ultimate','puma','scarpa da calcio',69.99,'rosa','Cina','cuoio','donna');
commit;

begin transaction;
insert into saldi values('0000000001','9',null);
insert into prodotto values('9','airbox low','diadora','scarpa da calcio',49.99,'rosa','Stati Uniti','stoffa','maschio');
commit;

begin transaction;
insert into saldi values('0000000001','10',null);
insert into prodotto values('10','airflex low','asics','scarpa da calcio',29.99,'rosa','Stati Uniti','stoffa','bambino');
commit;

begin transaction;
insert into saldi values('0000000001','11',null);
insert into prodotto values('11','fresh low','kappa','scarpa da calcio',39.99,'nero','Stati Uniti','stoffa','maschio');
commit;

begin transaction;
insert into saldi values ('0000000010','12',50);
insert into prodotto values('12','550 low','new balance','sneakers',149.99,'blu','Cina','pelle','maschio');
commit;

begin transaction;
insert into saldi values ('0000000010','13',50);
insert into prodotto values('13','lakers 2019','footlocker','tuta sportiva',49.99,'blu','Cina','tessuto','unisex');
commit;

begin transaction;
insert into saldi values ('0000000003','14',20);
insert into prodotto values('14','550 low','new balance','sneakers',149.99,'bianco','Stati uniti','pelle','maschio');
commit;

begin transaction;
insert into saldi values ('0000000010','15',50);
insert into prodotto values('15','chicago bulls 1990','decathlon','tuta sportiva',119.99,'rosso','Cina','tessuto','unisex');
commit;

begin transaction;
insert into saldi values ('0000000005','16',null);
insert into prodotto values('16','easy 100','decathlon','racchetta da tennis',39.99,'bianco','Cina','acciaio','unisex');
commit;

begin transaction;
insert into saldi values ('0000000003','17',20);
insert into prodotto values('17','basic 1000','wilson','racchetta da tennis',69.99,'nero','Cina','carbonio','unisex');
commit;

begin transaction;
insert into saldi values ('0000000005','18',null);
insert into prodotto values('18','pro 1000','wilson','racchetta da tennis',99.99,'nero','Cina','carbonio','unisex');
commit;

begin transaction;
insert into saldi values('0000000002','19',50);
insert into prodotto values('19','jordan legacy pro2','spalding','pallone da basket',99.99,'arancione','Cina','cuoio','unisex');
commit;

begin transaction;
insert into saldi values ('0000000003','20',20);
insert into prodotto values('20','jordan legacy','spalding','pallone da basket',69.99,'arancione','Cina','cuoio','unisex');
commit;

begin transaction;
insert into saldi values('0000000002','21',80);
insert into prodotto values('21','MVP N7','wilson','pallone da basket',19.99,'nero','Cina','gomma','bambino');
commit;

begin transaction;
insert into saldi values('0000000002','22',30);
insert into prodotto values('22','MVP N5','wilson','pallone da basket',39.99,'arancione','Cina','cuoio','unisex');
commit;

begin transaction;
insert into saldi values('0000000002','23',50);
insert into prodotto values('23','swim 2TR','decathlon','cuffia da piscina',19.99,'blu','Cina','gomma','bambino');
commit;

begin transaction;
insert into saldi values ('0000000009','24',null);
insert into prodotto values('24','swim tech 3','nike','costume',39.99,'rosa','Stati Uniti','tessuto','donna');
commit;

begin transaction;
insert into saldi values ('0000000009','25',null);
insert into prodotto values('25','swim tech 3','nike','costume',39.99,'nero','Stati Uniti','tessuto','uomo');
commit;

begin transaction;
insert into saldi values ('0000000007','26',null);
insert into prodotto values('26','MVP N7','wilson','pallone da basket',19.99,'nero','Cina','gomma','bambino');
commit;

begin transaction;
insert into saldi values ('0000000004','27',65);
insert into prodotto values('27','MVP N5','wilson','pallone da basket',39.99,'arancione','Stati Uniti','cuoio','unisex');
commit;

begin transaction;
insert into saldi values ('0000000003','28',20);
insert into prodotto values('28','450 low','new balance','sneakers',99.99,'blu','Stati Uniti','pelle','unisex');
commit;

begin transaction;
insert into saldi values ('0000000008','29',null);
insert into prodotto values('29','air force 1','nike','sneakers',99.99,'bianco','Stati Uniti','pelle','unisex');
commit;

begin transaction;
insert into saldi values('0000000002','30',40);
insert into prodotto values('30','air force 1','nike','sneakers',109.99,'nero','Stati Uniti','pelle','unisex');
commit;

begin transaction;
insert into saldi values ('0000000003','31',20);
insert into prodotto values('31','dunk low','nike','sneakers',119.99,'nero','Stati Uniti','pelle','unisex');
commit;

begin transaction;
insert into saldi values ('0000000006','32',null);
insert into prodotto values('32','juventus casa 2022-2023','nike','completo da calcio',112.99,'verde','Stati Uniti','stoffa','maschio');
commit;

begin transaction;
insert into saldi values ('0000000010','33',50);
insert into prodotto values('33','inter casa 2022-2023','nike','completo da calcio',79.99,'verde','Stati Uniti','stoffa','bambino');
commit;

begin transaction;
insert into saldi values ('0000000006','34',null);
insert into prodotto values('34','milan ospite 2022-2023','puma','completo da calcio',69.99,'rosa','Cina','cuoio','donna');
commit;

begin transaction;
insert into saldi values ('0000000004','35',25);
insert into prodotto values('35','napoli ospite 2022-2023','diadora','completo da calcio',59.99,'rosa','Stati Uniti','stoffa','maschio');
commit;

begin transaction;
insert into saldi values ('0000000006','36',null);
insert into prodotto values('36','salernitana ospite 2022-2023','asics','completo da calcio',29.99,'rosa','Stati Uniti','stoffa','bambino');
commit;

begin transaction;
insert into saldi values ('0000000003','37',20);
insert into prodotto values('37','salernitana casa 2022-2023','kappa','completo da calcio',49.99,'nero','Stati Uniti','stoffa','maschio');
commit;

/*SALDI*/
insert into saldi values('0000000002','17',50);
insert into saldi values('0000000002','5',30);
insert into saldi values('0000000002','1',20);
insert into saldi values('0000000002','20',50);
insert into saldi values('0000000002','7',50);
insert into saldi values('0000000002','8',70);
insert into saldi values('0000000002','10',50);
insert into saldi values('0000000002','25',20);
insert into saldi values('0000000002','2',10);
insert into saldi values ('0000000003','1',20);
insert into saldi values ('0000000003','2',20);
insert into saldi values ('0000000003','10',20);
insert into saldi values ('0000000003','12',20);
insert into saldi values ('0000000003','25',20);
insert into saldi values ('0000000003','30',20);
insert into saldi values ('0000000003','35',20);
insert into saldi values ('0000000003','24',20);
insert into saldi values ('0000000003','8',20);
insert into saldi values ('0000000003','3',20);
insert into saldi values ('0000000003','9',20);
insert into saldi values ('0000000003','29',20);
insert into saldi values ('0000000004','1',25);
insert into saldi values ('0000000004','2',50);
insert into saldi values ('0000000004','3',45);
insert into saldi values ('0000000004','4',35);
insert into saldi values ('0000000004','5',65);
insert into saldi values ('0000000004','6',70);
insert into saldi values ('0000000004','7',15);
insert into saldi values ('0000000004','8',10);
insert into saldi values ('0000000004','20',55);
insert into saldi values ('0000000004','22',25);
insert into saldi values ('0000000004','30',25);
insert into saldi values ('0000000004','37',35);
insert into saldi values ('0000000004','10',25);
insert into saldi values ('0000000005','17',null);
insert into saldi values ('0000000006','35',null);
insert into saldi values ('0000000006','37',null);
insert into saldi values ('0000000007','19',null);
insert into saldi values ('0000000007','20',null);
insert into saldi values ('0000000007','21',null);
insert into saldi values ('0000000007','22',null);
insert into saldi values ('0000000007','27',null);
insert into saldi values ('0000000008','28',null);
insert into saldi values ('0000000008','30',null);
insert into saldi values ('0000000009','23',null);
insert into saldi values ('0000000010','30',50);
insert into saldi values ('0000000010','20',50);
insert into saldi values ('0000000010','1',50);
insert into saldi values ('0000000010','10',50);
insert into saldi values ('0000000010','31',50);
insert into saldi values ('0000000010','36',50);
insert into saldi values ('0000000010','37',50);
insert into saldi values ('0000000010','9',50);
insert into saldi values ('0000000010','8',50);
insert into saldi values ('0000000010','11',50);
insert into saldi values ('0000000010','24',50);

/*Investimento*/
insert into investimento values('2020-11-26','0000000000','03188230969','1963-07-18',10000000);/*adidas-boxe*/
insert into investimento values('2020-11-30','0000000000','11005760159','1976-02-15',15000000.75);/*decathlon-boxe*/
insert into investimento values('2020-12-09','0000000000','05359451001','1971-05-30',17500000);/*nike-boxe*/
insert into investimento values('2020-11-10','0000000000','11904560155','1975-03-30',5000000);/*puma-boxe*/
insert into investimento values('2020-11-10','0000000000','05359451001','1971-05-30',800000);/*nike-boxe*/
insert into investimento values('2019-05-17','0000000001','11904560155','1975-03-30',5000000);/*puma-scarpettedacalcio*/
insert into investimento values('2020-09-23','0000000001','04308510264','1969-03-15',7000000);/*diadora-scarpettedacalcio*/
insert into investimento values('2020-09-23','0000000001','10796170966','1980-06-02',7000000);/*kappa-scarpettedacalcio*/
insert into investimento values('2020-09-23','0000000001','02234250047','1999-01-24',7000000);/*asics-scarpettedacalcio*/
insert into investimento values('2019-05-17','0000000001','03188230969','1963-07-18',40000000.75);/*adidas-scarpettedacalcio*/
insert into investimento values('2021-07-06','0000000002','10322270157','1993-05-16',50000000.5);/*FootLocker-saldiestivi*/
insert into investimento values('2021-07-14','0000000002','01715070213','1999-02-06',2400000);/*newBalance-saldiestivi*/
insert into investimento values('2021-08-09','0000000002','11005760159','1976-02-15',37000000);/*decathlon-saldiestivi*/
insert into investimento values('2021-01-19','0000000003','10322270157','1993-05-16',47000000);/*Footlocker-saldiInvernali*/
insert into investimento values('2021-01-25','0000000003','01715070213','1999-02-06',3450000.75);/*newBalance-saldiInvernali*/
insert into investimento values('2021-02-01','0000000003','11005760159','1976-02-15',46200000.5);/*decathlon-saldiInvernali*/
insert into investimento values('2022-10-25','0000000004','05359451001','1971-05-30',800000);/*nike-blackFriday*/
insert into investimento values('2022-10-26','0000000004','05359451001','1971-05-30',63500000.50);/*nike-blackFriday*/
insert into investimento values('2022-10-26','0000000004','11904560155','1975-03-30',1200000);/*puma-blackFriday*/
insert into investimento values('2022-10-25','0000000004','01715070213','1999-02-06',7550000);/*newBalance-blackFriday*/
insert into investimento values('2022-10-26','0000000004','10322270157','1993-05-16',23000000.5);/*footLocker-blackFriday*/
insert into investimento values('2022-10-26','0000000004','01715070213','1999-02-06',3400000);/*newBalance-blackFriday*/
insert into investimento values('2020-06-27','0000000005','11005760159','1976-02-15',7400000);/*decathlon-racchettetennis*/
insert into investimento values('2021-03-27','0000000005','14095911005','1986-04-23',4000000);/*wilson-racchettetennis*/
insert into investimento values('2023-03-22','0000000006','11904560155','1975-03-30',21000000);/*puma-completodacalcio*/
insert into investimento values('2023-03-22','0000000006','04308510264','1969-03-15',7000000);/*diadora-completodacalcio*/
insert into investimento values('2023-03-23','0000000006','10796170966','1980-06-02',7320000);/*kappa-completodacalcio*/
insert into investimento values('2023-03-27','0000000006','02234250047','1999-01-24',1200000);/*asics-completodacalcio*/
insert into investimento values('2023-03-29','0000000006','03188230969','1963-07-18',40000000.75);/*adidas-completodacalcio*/
insert into investimento values('2020-07-01','0000000007','14095911005','1986-04-23',4000000);/*wilson-pallonidabasket*/
insert into investimento values('2020-07-12','0000000007','14095911005','1986-04-23',7200000);/*wilson-pallonidabasket*/
insert into investimento values('2021-06-15','0000000008','01715070213','1999-02-06',30000.50);/*newBalance-sneakers*/
insert into investimento values('2021-06-16','0000000008','05359451001','1971-05-30',8000000);/*nike-sneakers*/
insert into investimento values('2021-05-02','0000000009','05359451001','1971-05-30',42200000.5);/*nike-piscina*/
insert into investimento values('2022-04-12','0000000010','10322270157','1993-05-16',47000000);/*Footlocker-saldiPrimavera*/
insert into investimento values('2022-04-15','0000000010','01715070213','1999-02-06',7420000.75);/*newBalance-saldiPrimavera*/
insert into investimento values('2022-04-23','0000000010','11005760159','1976-02-15',23200000.5);/*decathlon-saldiPrimavera*/

/*UTENTE*/
insert into utente values ('0','luigialberti@gmail.com','Luigi','Alberti','1988-05-23','m',2);
insert into utente values ('1','giacomoesposito@gmail.com','Giacomo','Esposito','1999-07-14','m',4);
insert into utente values ('2','alessiodonnarumma@gmail.com','Alessio','Donnarumma','1958-06-13','m',1);
insert into utente values ('3','annamariannunziata@gmail.com','Annamaria','Annunziata','2001-07-05','f',2);
insert into utente values ('4','diegoesposito1926@libero.it','Diego','Esposito','2002-11-23','m',4);
insert into utente values ('5','alfonsogiamundo@gmail.com','Alfonso','Giamundo','1954-12-30','m',3);
insert into utente values ('6','albertocitarella@hotmail.it','Alberto','Citarella','1960-02-09','m',2);
insert into utente values ('7','lucasru@gmail.com','Luca','Russo','2000-10-10','m',4);
insert into utente values ('8','chiaraavino@libero.it','Chiara','Avino','1997-09-20','f',4);
insert into utente values ('9','mikebosco98@gmail.com','Michele','Bosco','1998-05-23','m',1);
insert into utente values ('10','renatoverdi@gmail.com','Renato','Verdi','1948-06-01','m',3);
insert into utente values ('11','pierorossi888@gmail.com','Piero','Rossi','1974-10-30','m',4);
insert into utente values ('12','francescacuomo@libero.it','Francesca','Cuomo','1976-02-20','f',3);
insert into utente values ('13','alfonso0002@gmail.com','Alfonso','Vastola','1966-03-10','m',4);
insert into utente values ('14','francescoruocco@gmail.com','Francesco','Ruocco','1999-08-15','m',1);
insert into utente values ('15','sergiodesio45@gmail.com','Sergio','Desio','1945-12-08','m',3);
insert into utente values ('16','rosarioluccio@gmail.com','Rosario','Luccio','1986-10-23','m',4);
insert into utente values ('17','marco010@gmail.com','Marco','Italia','1966-12-13','m',4);
insert into utente values ('18','martaattianese@libero.it','Marta','Attianese','1977-02-14','f',1);
insert into utente values ('19','memoli34@gmail.com','Ivano','Memoli','1963-01-17','m',3);
insert into utente values ('20','federicaredi00@gmail.com','Federica','Redi','2000-09-10','f',3);
insert into utente values ('21','massimocarboni78@gmail.com','Massimo','Carboni','1978-10-02','m',2);
insert into utente values ('22','ivo56@gmail.com','Ivo','Liguori','1956-08-15','m',4);
insert into utente values ('23','vincenzopepe@gmail.com','Vincenzo','Pepe','2001-10-27','m',1);
insert into utente values ('24','soniaruggieri@gmail.com','Sonia','Ruggieri','1976-09-10','f',4);
insert into utente values ('25','ivandrago77@gmail.com','Ivan','Giamundo','1977-12-20','m',1);
insert into utente values ('26','serenapire@gmail.com','Serena','Pirelli','1965-10-12','f',1);
insert into utente values ('27','nicolapaoletti65@libero.it','Nicola','Paoletti','1965-10-04','f',2);
insert into utente values ('28','papi00@gmail.com','Gabriele','Di Vitto','1953-03-27','m',4);
insert into utente values ('29','martinaliguori@hotmail.it','Martina','Liguori','1978-10-20','f',1);
insert into utente values ('30','lorenzo01@gmail.com','Lorenzo','Sorrentino','2001-12-25','m',4);

/*Interessi sportivi*/
insert into interessi_sportivi values('Calcio','1');
insert into interessi_sportivi values('Calcio','2');
insert into interessi_sportivi values('Nuoto','3');
insert into interessi_sportivi values('Calcio','4');
insert into interessi_sportivi values('Calcio','5');
insert into interessi_sportivi values('Calcio','6');
insert into interessi_sportivi values('Calcio','7');
insert into interessi_sportivi values('Nuoto','8');
insert into interessi_sportivi values('Calcio','9');
insert into interessi_sportivi values('Calcio','10');
insert into interessi_sportivi values('Nuoto','11');
insert into interessi_sportivi values('Calcio','12');
insert into interessi_sportivi values('Calcio','13');
insert into interessi_sportivi values('Nuoto','14');
insert into interessi_sportivi values('Calcio','15');
insert into interessi_sportivi values('Calcio','16');
insert into interessi_sportivi values('Nuoto','17');
insert into interessi_sportivi values('Nuoto','18');
insert into interessi_sportivi values('Calcio','19');
insert into interessi_sportivi values('Nuoto','20');
insert into interessi_sportivi values('Calcio','21');
insert into interessi_sportivi values('Calcio','22');
insert into interessi_sportivi values('Calcio','23');
insert into interessi_sportivi values('Calcio','24');
insert into interessi_sportivi values('Calcio','25');
insert into interessi_sportivi values('Calcio','26');
insert into interessi_sportivi values('Nuoto','27');
insert into interessi_sportivi values('Calcio','28');
insert into interessi_sportivi values('Calcio','29');
insert into interessi_sportivi values('Nuoto','30');
insert into interessi_sportivi values('Basket','1');
insert into interessi_sportivi values('Basket','2');
insert into interessi_sportivi values('Boxe','3');
insert into interessi_sportivi values('Basket','4');
insert into interessi_sportivi values('Boxe','5');
insert into interessi_sportivi values('Basket','6');
insert into interessi_sportivi values('Basket','7');
insert into interessi_sportivi values('Basket','8');
insert into interessi_sportivi values('Boxe','9');
insert into interessi_sportivi values('Basket','10');
insert into interessi_sportivi values('Basket','11');
insert into interessi_sportivi values('Basket','12');
insert into interessi_sportivi values('Basket','13');
insert into interessi_sportivi values('Boxe','14');
insert into interessi_sportivi values('Basket','15');
insert into interessi_sportivi values('Basket','16');
insert into interessi_sportivi values('Basket','17');
insert into interessi_sportivi values('Boxe','18');
insert into interessi_sportivi values('Basket','19');
insert into interessi_sportivi values('Basket','20');
insert into interessi_sportivi values('Basket','21');
insert into interessi_sportivi values('Boxe','22');
insert into interessi_sportivi values('Basket','23');
insert into interessi_sportivi values('Basket','24');
insert into interessi_sportivi values('Basket','25');
insert into interessi_sportivi values('Boxe','26');
insert into interessi_sportivi values('Basket','27');
insert into interessi_sportivi values('Boxe','28');
insert into interessi_sportivi values('Basket','29');
insert into interessi_sportivi values('Basket','30');
insert into interessi_sportivi values('Tennis','1');
insert into interessi_sportivi values('Tennis','2');
insert into interessi_sportivi values('Tennis','4');
insert into interessi_sportivi values('Tennis','5');
insert into interessi_sportivi values('Tennis','6');
insert into interessi_sportivi values('Tennis','9');
insert into interessi_sportivi values('Tennis','10');
insert into interessi_sportivi values('Tennis','11');
insert into interessi_sportivi values('Tennis','12');
insert into interessi_sportivi values('Tennis','13');
insert into interessi_sportivi values('Tennis','16');
insert into interessi_sportivi values('Tennis','17');
insert into interessi_sportivi values('Tennis','18');
insert into interessi_sportivi values('Tennis','19');
insert into interessi_sportivi values('Tennis','20');
insert into interessi_sportivi values('Tennis','21');
insert into interessi_sportivi values('Tennis','22');
insert into interessi_sportivi values('Tennis','26');
insert into interessi_sportivi values('Tennis','27');
insert into interessi_sportivi values('Tennis','28');
insert into interessi_sportivi values('Tennis','29');

/*CANALE*/
insert into canale values ('DAZN 1','Calcio');
insert into canale values ('DAZN 2','Box');
insert into canale values ('DAZN 3','MMA');
insert into canale values ('DAZN 4','Nuoto');
insert into canale values ('DAZN 5','NBA');
insert into canale values ('DAZN 6','tennis');
insert into canale values ('DAZN 7 Serie A','Calcio');
insert into canale values ('DAZN 8 Premier League','Calcio');
insert into canale values ('DAZN 9','Basket');

/*Evento*/
insert into evento values ('Napoli-Juve','Big Match Serie a Lotta scudetto','2023-02-12 19:00:00','DAZN 7 Serie A');
insert into evento values ('Napoli-Juve','Big Match Serie a Lotta scudetto','2022-02-12 19:00:00','DAZN 7 Serie A');
insert into evento values ('Manchester City - Manchester United','Big Match domenicale inPremier','2023-04-02 19:00:00 ','DAZN 8 Premier League');
insert into evento values ('Manchester City - Manchester United','Big Match domenicale inPremier','2022-04-02 19:00:00','DAZN 8 Premier League');
insert into evento values ('Manchester City - Manchester United','Big Match domenicale inPremier','2021-04-02 19:00:00','DAZN 8 Premier League');
insert into evento values ('Spezia-Lecce',' Lotta salvezza serie a','2023-01-22 19:00:00','DAZN 7 Serie A');
insert into evento values ('Spezia-Lecce',' Lotta salvezza serie a','2022-01-22 19:00:00','DAZN 7 Serie A');
insert into evento values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','Incontro tra campioni di box','2019-02-25 18:00:00','DAZN 2');
insert into evento values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','Incontro tra boxers','2015-10-22 18:00:00','DAZN 2');
insert into evento values ('Mediterranean Cup','gara di nuoto','2022-06-16 11:00:00','DAZN 4');
insert into evento values ('Campionato italiano di categoria nuoto','gara di nuoto sui 50m','2022-07-22 11:00:00','DAZN 4');
insert into evento values ('Miami Heat VS. Denver Nuggets','Finali-Partita 4 (Den conduce per 2 a 1)','2023-06-01 02:00:00','DAZN 5');
insert into evento values ('Lakers VS. Denver Nuggets','Finali di conference','2023-05-23 02:00:00 ','DAZN 5');
insert into evento values ('Djokovic B. VS. Federer','Incontro tra BIG del tennis a Wimbledon ','2022-06-07 12:00:00','DAZN 6');
insert into evento values ('Federer b. VS. Nadal','Finale Austrialn Oper','2022-06-24 12:00:00','DAZN 6');
insert into evento values ('Olimpia Milano VS. Virtus Bologna','Partita per la vittoria campionato ','2023-06-10 19:00:00','DAZN 9');

/*Sponsorizzazioni+banner*/
begin transaction;
insert into sponsorizzazione values ('0','FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00',600,'laterale destro');
insert into banner values ('0','0.35',100,100,'quadrata','rosso','132596784032147','Lancio guantone super performante','italiano','1','0000000000');
commit;

begin transaction;
insert into sponsorizzazione values ('1','FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00',680,'laterale sinistro');
insert into banner values ('1','1.00',200,200,'quadrata','rosso scuro',null,'Lancio Nuovi Guantoni da Boxe','italiano',null,'0000000000');
commit;

begin transaction;
insert into sponsorizzazione values ('2','FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00',400,'laterale destro');
insert into banner values ('2','0.50',300,300,'quadrata','blu',null,'Lancio articoli box','italiano','3','0000000000');
commit;

begin transaction;
insert into sponsorizzazione values ('3','Napoli-Juve','2023-02-12 19:00:00',450,'laterale sinistro');
insert into banner values ('3','2.00',100,400,'rettangolare','giallo','12365289654785','Lancio nuove scarpe da calcio','italiano','4','0000000001');
commit;

begin transaction;
insert into sponsorizzazione values ('4','Napoli-Juve','2023-02-12 19:00:00',600,'laterale sinistro');
insert into banner values ('4','0.60',100,100,'quadrato','arancio',null,'Lancio scarpe da calcio con nuova tecnologia','italiano','6','0000000001');
commit;

begin transaction;
insert into sponsorizzazione values ('5','Napoli-Juve','2023-02-12 19:00:00',370,'laterale destro');
insert into banner values ('5','3.00',400,400,'quadrato','rosso',null,'Lancio articoli da calcio','italiano','9','0000000001');
commit;

begin transaction;
insert into sponsorizzazione values ('6','Napoli-Juve','2023-02-12 19:00:00',430,'laterale destro');
insert into banner values ('6','0.50',200,100,'rettangolo','viola','123654796321478','Prodotti speciali per i Saldi Estivi','italiano','23','0000000002');
commit;

begin transaction;
insert into sponsorizzazione values ('7','Napoli-Juve','2023-02-12 19:00:00',600,'laterale sinistro');
insert into banner values ('7','1.00',200,200,'quadrato','magenta',null,'Saldi estivi','italiano',null,'0000000002');
commit;

begin transaction;
insert into sponsorizzazione values ('8','Napoli-Juve','2023-02-12 19:00:00',600,'laterale sinistro');
insert into banner values ('8','4.00',500,200,'rettangolo','rosso',null,'Prodotti sport estivi in saldo','italiano','25','0000000002');
commit;

begin transaction;
insert into sponsorizzazione values ('9','Napoli-Juve','2023-02-12 19:00:00',600,'laterale destro');
insert into banner values ('9','0.40',300,100,'rettangolo','verde','120365474123652','Prodotti speciali per saldi invernali','italiano','30','0000000003');
commit;

begin transaction;
insert into sponsorizzazione values ('10','Napoli-Juve','2023-02-12 19:00:00',375,'laterale destro');
insert into banner values ('10','0.60',100,100,'quadrato','turchese',null,'Saldi invernali','italiano',null,'0000000003');
commit;

begin transaction;
insert into sponsorizzazione values ('11','Napoli-Juve','2023-02-12 19:00:00',300,'laterale sinistro');
insert into banner values ('11','0.70',200,100,'rettangolare','giallo',null,'Prodotti sport invernali in saldo','italiano','14','0000000003');
commit;

begin transaction;
insert into sponsorizzazione values ('12','Spezia-Lecce','2023-01-22 19:00:00',200,'laterale destro');
insert into banner values ('12','0.10',200,600,'rettangolare','rosa','123789456546230','Prodotti speciali per il BlackFriday','italiano','13','0000000004');
commit;

begin transaction;
insert into sponsorizzazione values ('13','Spezia-Lecce','2023-01-22 19:00:00',400,'laterale destro');
insert into banner values ('13','0.60',200,200,'quadrata','rosso',null,'BlackFriday','italiano',null,'0000000004');
commit;

begin transaction;
insert into sponsorizzazione values ('14','Spezia-Lecce','2023-01-22 19:00:00',500,'laterale destro');
insert into banner values ('14','2.00',100,100,'quadrata','blu scuro',null,'Prodotti sport in sconto col BlackFriday','italiano',null,'0000000004');
commit;

begin transaction;
insert into sponsorizzazione values ('15','Djokovic B. VS. Federer','2022-06-07 12:00:00',350,'laterale sinistro');
insert into banner values ('15','0.80',700,300,'rettangolare','marrone','146320232314789','Lancio Nuove racchette da tennis','italiano','31','0000000005');
commit;

begin transaction;
insert into sponsorizzazione values ('16','Federer b. VS. Nadal','2022-06-24 12:00:00',600,'laterale destro');
insert into banner values ('16','0.30',400,300,'rettangolare','celeste',null,'Lancio racchetta tennis usata alle Olmpiadi','italiano','16','0000000005');
commit;

begin transaction;
insert into sponsorizzazione values ('17','Djokovic B. VS. Federer','2022-06-07 12:00:00',600,'laterale destro');
insert into banner values ('17','1.90',300,300,'quadrato','indaco',null,'Lancio articoli da tennis','italiano','17','0000000005');
commit;

begin transaction;
insert into sponsorizzazione values ('18','Napoli-Juve','2023-02-12 19:00:00',600,'laterale sinistro');
insert into banner values ('18','0.90',100,400,'rettangolare','giallo','123020131526968','Lancio nuovi completini da calcio','italiano','35','0000000006');
commit;

begin transaction;
insert into sponsorizzazione values ('19','Napoli-Juve','2023-02-12 19:00:00',650,'laterale sinistro');
insert into banner values ('19','1.60',250,100,'rettangolare','rosso',null,'Lancio completini super elastici','italiano',null,'0000000006');
commit;

begin transaction;
insert into sponsorizzazione values ('20','Napoli-Juve','2023-02-12 19:00:00',600,'laterale destro');
insert into banner values ('20','0.56',270,190,'rettangolare','blu',null,'Lancio vestiario da calcio','italiano','36','0000000006');
commit;

begin transaction;
insert into sponsorizzazione values ('21','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',543,'laterale destro');
insert into banner values ('21','0.70',180,180,'quadrato','nero','123032125478965','Lancio pallone basket usato nel DRAFT','italiano','27','0000000007');
commit;

begin transaction;
insert into sponsorizzazione values ('22','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale destro');
insert into banner values ('22','5.00',500,500,'quadrato','rosso fuoco',null,'Lancio nuovi palloni da basket','italiano',null,'0000000007');
commit;

begin transaction;
insert into sponsorizzazione values ('23','Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',600,'laterale destro');
insert into banner values ('23','2.50',200,200,'quadrato','giallo',null,'Lancio palloni super resistenti','italiano','22','0000000007');
commit;

begin transaction;
insert into sponsorizzazione values ('24','Spezia-Lecce','2023-01-22 19:00:00',500,'laterale sinistro');
insert into banner values ('24','0.55',300,400,'rettangolare','blu','151505871632178','Lancio nuove sneakers','italiano','29','0000000008');
commit;

begin transaction;
insert into sponsorizzazione values ('25','FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00',500,'laterale destro');
insert into banner values ('25','1.40',100,400,'rettangolare','verde',null,'Lancio scarpe con nuova tecnologia','italiano',null,'0000000008');
commit;

begin transaction;
insert into sponsorizzazione values ('26','Spezia-Lecce','2023-01-22 19:00:00',670,'laterale centrale');
insert into banner values ('26','10.00',700,700,'quadrato','turchese',null,'Lancio calzature','italiano','28','0000000008');
commit;

begin transaction;
insert into sponsorizzazione values ('27','Campionato italiano di categoria nuoto','2022-07-22 11:00:00',740,'laterale destro');
insert into banner values ('27','0.90',100,200,'rettangolare','magenta','123025896325414','Lancio costume con nuova tessuto','italiano','25','0000000009');
commit;

begin transaction;
insert into sponsorizzazione values ('28','Mediterranean Cup','2022-06-16 11:00:00',600,'laterale sinistro');
insert into banner values ('28','1.50',100,100,'quadrato','rosso',null,'Lancio nuovi articoli piscina','italiano',null,'0000000009');
commit;

begin transaction;
insert into sponsorizzazione values ('29','Mediterranean Cup','2022-06-16 11:00:00',600,'laterale destro');
insert into banner values ('29','1.30',100,400,'rettangolare','blu',null,'Lancio articoli nuoto','italiano','24','0000000009');
commit;

begin transaction;
insert into sponsorizzazione values ('30','Campionato italiano di categoria nuoto','2022-07-22 11:00:00',600,'laterale sinistro');
insert into banner values ('30','0.50',100,100,'quadrato','viola','123032524189632','Prodotti speciali per i saldi primaverili','italiano','32','0000000010');
commit;

begin transaction;
insert into sponsorizzazione values ('31','Spezia-Lecce','2023-01-22 19:00:00',600,'laterale sinistro');
insert into banner values ('31','1.00',200,200,'quadrato','magenta',null,'Saldi Primaverili','italiano',null,'0000000010');
commit;

begin transaction;
insert into sponsorizzazione values ('32','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale destro');
insert into banner values ('32','4.00',500,200,'rettangolo','rosso',null,'Prodotti sport primaverili in saldo','italiano','15','0000000010');
commit;

/*SCAN QRCODE*/
insert into scan_qrcode values ('0',1000000,null);
insert into scan_qrcode values ('3',3000000,'alta');
insert into scan_qrcode values ('6',1500000,'alta');
insert into scan_qrcode values ('9',3500000,null);
insert into scan_qrcode values ('12',4000000,'media');
insert into scan_qrcode values ('15',2500000,'bassa');
insert into scan_qrcode values ('18',3000000,null);
insert into scan_qrcode values ('21',3500000,'alta');
insert into scan_qrcode values ('24',4000000,'alta');
insert into scan_qrcode values ('27',1000000,'bassa');
insert into scan_qrcode values ('30',3000000,null);

/*Visione*/
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','6');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','0');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','2');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','3');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','5');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','8');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','20');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','11');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','10');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','4');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','1');
insert into visione values ('Napoli-Juve','2023-02-12 19:00:00','25');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','6');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','30');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','29');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','0');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','2');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','5');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','4');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','1');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','25');
insert into visione values ('Spezia-Lecce','2023-01-22 19:00:00','20');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','0');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','1');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','4');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','6');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','8');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','9');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','10');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','12');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','13');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','15');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','16');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','17');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','20');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','21');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','22');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','25');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','26');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','23');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','27');
insert into visione values ('Manchester City - Manchester United','2023-04-02 19:00:00','30');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','0');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','1');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','4');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','5');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','7');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','9');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','10');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','12');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','20');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','22');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','25');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','30');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','29');
insert into visione values ('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00','11');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','0');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','1');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','10');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','11');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','12');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','15');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','17');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','20');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','21');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','22');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','23');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','26');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','30');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','19');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','4');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','5');
insert into visione values ('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00','6');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','9');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','0');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','1');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','10');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','23');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','24');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','30');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','6');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','7');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','16');
insert into visione values ('Mediterranean Cup','2022-06-16 11:00:00','11');
insert into visione values ('Campionato italiano di categoria nuoto','2022-07-22 11:00:00','0');
insert into visione values ('Campionato italiano di categoria nuoto','2022-07-22 11:00:00','10');
insert into visione values ('Campionato italiano di categoria nuoto','2022-07-22 11:00:00','20');
insert into visione values ('Campionato italiano di categoria nuoto','2022-07-22 11:00:00','24');
insert into visione values ('Campionato italiano di categoria nuoto','2022-07-22 11:00:00','30');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','0');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','1');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','2');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','3');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','4');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','5');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','6');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','7');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','8');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','9');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','10');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','11');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','12');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','13');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','14');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','15');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','16');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','17');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','18');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','19');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','20');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','21');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','22');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','23');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','24');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','25');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','26');
insert into visione values ('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00','27');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','0');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','1');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','13');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','15');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','20');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','10');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','5');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','19');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','22');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','30');
insert into visione values ('Lakers VS. Denver Nuggets','2023-05-23 02:00:00','29');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','0');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','10');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','20');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','30');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','15');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','6');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','8');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','9');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','18');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','19');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','22');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','25');
insert into visione values ('Djokovic B. VS. Federer','2022-06-07 12:00:00','27');
insert into visione values ('Federer b. VS. Nadal','2022-06-24 12:00:00','0');
insert into visione values ('Federer b. VS. Nadal','2022-06-24 12:00:00','2');
insert into visione values ('Federer b. VS. Nadal','2022-06-24 12:00:00','10');
insert into visione values ('Federer b. VS. Nadal','2022-06-24 12:00:00','11');
insert into visione values ('Federer b. VS. Nadal','2022-06-24 12:00:00','20');
insert into visione values ('Federer b. VS. Nadal','2022-06-24 12:00:00','30');
insert into visione values ('Federer b. VS. Nadal','2022-06-24 12:00:00','15');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','0');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','5');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','10');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','11');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','20');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','30');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','15');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','22');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','23');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','25');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','21');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','26');
insert into visione values ('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00','6');

/*ROAS*/
insert into roas values('11005760159','1976-02-15',1.4,'2020-11-14','2021-11-14','media'); /*Decathlon*/
insert into roas values('01715070213','1999-02-06',2.3,'2021-07-09','2022-07-09','alta');/*NewBalance*/
insert into roas values('01715070213','1999-02-06',1.2,'2022-11-01','2023-11-01','alta'); /*NewBalance*/
insert into roas values('03188230969','1963-07-18',2.1,'2023-04-02','2024-04-02','alta'); /*Adidas*/
insert into roas values('10322270157','1993-05-16',0.9,'2021-01-25','2022-01-25','bassa'); /*Footlocker*/
insert into roas values('11904560155','1975-03-30',1.3,'2019-05-24','2020-05-24','media'); /*Puma*/
insert into roas values('05359451001','1971-05-30',1.9,'2021-06-20','2022-06-20','alta'); /*Nike*/
insert into roas values('14095911005','1986-04-23',1.1,'2020-07-06','2021-07-06','media'); /*Wilson*/
insert into roas values('02084910393','1876-02-15',1.7,'2020-07-03','2021-07-03','alta'); /*Spalding*/
insert into roas values('02234250047','1999-01-24',1.3,'2023-03-01','2024-03-01','bassa'); /*Asics*/
insert into roas values('05359451001','1971-05-30',1.5,'2020-11-10','2021-11-17','alta'); /*Nike*/
insert into roas values('10796170966','1980-06-02',0.7,'2023-03-28','2024-03-28','bassa'); /*Kappa*/
insert into roas values('04308510264','1969-03-15',1.2,'2023-03-25','2024-03-25','media'); /*Diadora*/

/*Aumento Clienti*/
insert into aumento_clienti values('11005760159','1976-02-15',2.13,'2020-11-14','2021-11-14','media'); /*Decathlon*/
insert into aumento_clienti values('01715070213','1999-02-06',9.2,'2021-07-09','2022-07-09','alta');/*NewBalance*/
insert into aumento_clienti values('01715070213','1999-02-06',3.3,'2022-11-01','2023-11-01','alta'); /*NewBalance*/
insert into aumento_clienti values('03188230969','1963-07-18',4.92,'2023-04-02','2024-04-02','alta'); /*Adidas*/
insert into aumento_clienti values('10322270157','1993-05-16',2.42,'2021-01-25','2022-01-25','bassa'); /*Footlocker*/
insert into aumento_clienti values('11904560155','1975-03-30',1.32,'2019-05-24','2020-05-24','media'); /*Puma*/
insert into aumento_clienti values('05359451001','1971-05-30',4.76,'2021-06-20','2022-06-20','alta'); /*Nike*/
insert into aumento_clienti values('14095911005','1986-04-23',6.54,'2020-07-06','2021-07-06','media'); /*Wilson*/
insert into aumento_clienti values('02084910393','1876-02-15',3.53,'2020-07-03','2021-07-03','alta'); /*Spalding*/
insert into aumento_clienti values('02234250047','1999-01-24',0.43,'2023-03-01','2024-03-01','bassa'); /*Asics*/
insert into aumento_clienti values('05359451001','1971-05-30',5.48,'2020-11-10','2021-11-17','alta'); /*Nike*/
insert into aumento_clienti values('10796170966','1980-06-02',1.55,'2023-03-28','2024-03-28','bassa'); /*Kappa*/
insert into aumento_clienti values('04308510264','1969-03-15',1.25,'2023-03-25','2024-03-25','media'); /*Diadora*/

/*Sponsorizzazione*/
insert into sponsorizzazione values ('25','Spezia-Lecce','2023-01-22 19:00:00',550,'laterale centrale');
insert into sponsorizzazione values ('30','Spezia-Lecce','2023-01-22 19:00:00',870,'laterale sinistro');
insert into sponsorizzazione values ('3','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale destro');
insert into sponsorizzazione values ('4','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('5','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('18','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('19','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('20','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('13','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale destro');
insert into sponsorizzazione values ('14','Manchester City - Manchester United','2023-04-02 19:00:00',600,'laterale destro');
insert into sponsorizzazione values ('24','FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00',200,'laterale destro');
insert into sponsorizzazione values ('26','FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00',200,'laterale sinistro');
insert into sponsorizzazione values ('27','Mediterranean Cup','2022-06-16 11:00:00',400,'laterale destro');
insert into sponsorizzazione values ('6','Mediterranean Cup','2022-06-16 11:00:00',600,'laterale destro');
insert into sponsorizzazione values ('7','Mediterranean Cup','2022-06-16 11:00:00',800,'laterale destro');
insert into sponsorizzazione values ('8','Mediterranean Cup','2022-06-16 11:00:00',300,'laterale sinistro');
insert into sponsorizzazione values ('9','Mediterranean Cup','2022-06-16 11:00:00',450,'laterale sinistro');
insert into sponsorizzazione values ('10','Mediterranean Cup','2022-06-16 11:00:00',760,'laterale sinistro');
insert into sponsorizzazione values ('11','Mediterranean Cup','2022-06-16 11:00:00',600,'laterale destro');
insert into sponsorizzazione values ('12','Mediterranean Cup','2022-06-16 11:00:00',600,'laterale destro');
insert into sponsorizzazione values ('13','Mediterranean Cup','2022-06-16 11:00:00',600,'laterale destro');
insert into sponsorizzazione values ('28','Campionato italiano di categoria nuoto','2022-07-22 11:00:00',320,'laterale destro');
insert into sponsorizzazione values ('29','Campionato italiano di categoria nuoto','2022-07-22 11:00:00',140,'laterale destro');
insert into sponsorizzazione values ('31','Campionato italiano di categoria nuoto','2022-07-22 11:00:00',600,'laterale destro');
insert into sponsorizzazione values ('23','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale destro');
insert into sponsorizzazione values ('6','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('7','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('8','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale destro');
insert into sponsorizzazione values ('11','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',435,'laterale destro');
insert into sponsorizzazione values ('12','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',450,'laterale destro');
insert into sponsorizzazione values ('13','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale destro');
insert into sponsorizzazione values ('14','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale destro');
insert into sponsorizzazione values ('24','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',535,'laterale sinistro');
insert into sponsorizzazione values ('25','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('26','Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('21','Lakers VS. Denver Nuggets','2023-05-23 02:00:00',350,'laterale sinistro');
insert into sponsorizzazione values ('22','Lakers VS. Denver Nuggets','2023-05-23 02:00:00',250,'laterale destro');
insert into sponsorizzazione values ('23','Lakers VS. Denver Nuggets','2023-05-23 02:00:00',600,'laterale destro');
insert into sponsorizzazione values ('30','Lakers VS. Denver Nuggets','2023-05-23 02:00:00',600,'laterale destro');
insert into sponsorizzazione values ('31','Lakers VS. Denver Nuggets','2023-05-23 02:00:00',150,'laterale sinistro');
insert into sponsorizzazione values ('32','Lakers VS. Denver Nuggets','2023-05-23 02:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('24','Djokovic B. VS. Federer','2022-06-07 12:00:00',600,'laterale destro');
insert into sponsorizzazione values ('25','Djokovic B. VS. Federer','2022-06-07 12:00:00',450,'laterale sinistro');
insert into sponsorizzazione values ('26','Djokovic B. VS. Federer','2022-06-07 12:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('6','Djokovic B. VS. Federer','2022-06-07 12:00:00',600,'laterale destro');
insert into sponsorizzazione values ('7','Djokovic B. VS. Federer','2022-06-07 12:00:00',400,'laterale sinistro');
insert into sponsorizzazione values ('8','Federer b. VS. Nadal','2022-06-24 12:00:00',100,'laterale destro');
insert into sponsorizzazione values ('15','Federer b. VS. Nadal','2022-06-24 12:00:00',600,'laterale destro');
insert into sponsorizzazione values ('17','Federer b. VS. Nadal','2022-06-24 12:00:00',350,'laterale sinistro');
insert into sponsorizzazione values ('21','Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',600,'laterale destro');
insert into sponsorizzazione values ('22','Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('30','Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('31','Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',400,'laterale sinistro');
insert into sponsorizzazione values ('32','Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',600,'laterale sinistro');
insert into sponsorizzazione values ('24','Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',500,'laterale sinistro');
insert into sponsorizzazione values ('25','Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',600,'laterale sinistro');

/*CAC*/
insert into cac values ('0000000000','euro',59.52,'2020-11-15','2021-05-15','media');
insert into cac values ('0000000001','dollari',46.98,'2019-05-20','2019-10-20','alta');
insert into cac values ('0000000002','dollari',67.45,'2020-11-15','2021-05-15','alta');
insert into cac values ('0000000003','dollari',41.36,'2021-01-20','2021-07-20',null);
insert into cac values ('0000000004','euro',78.21,'2022-10-30','2023-04-30','media');
insert into cac values ('0000000005','dollari',43.11,'2020-06-23','2020-12-23','alta');
insert into cac values ('0000000006','dollari',89.10,'2023-03-26','2023-09-26','bassa');
insert into cac values ('0000000003','dollari',30.65,'2022-03-22','2022-09-22','media');
insert into cac values ('0000000007','dollari',39.30,'2020-07-02','2021-01-02','media');
insert into cac values ('0000000008','dollari',71.64,'2021-06-16','2021-12-16','alta');
insert into cac values ('0000000002','dollari',55.54,'2021-03-11','2021-09-11','bassa');
insert into cac values ('0000000009','euro',28.91,'2021-05-06','2021-11-06','media');
insert into cac values ('0000000010','dollari',69.96,'2022-04-07','2022-10-07','bassa');

/*REACH*/
insert into reach values ('0000000000',553.651,'2020-11-15','2021-05-15','media');
insert into reach values ('0000000001',841.975,'2019-05-20','2019-10-20','alta');
insert into reach values ('0000000002',792.114,'2020-11-15','2021-05-15','alta');
insert into reach values ('0000000003',301.421,'2021-01-20','2021-07-20','bassa');
insert into reach values ('0000000004',476.111,'2022-10-30','2023-04-30','media');
insert into reach values ('0000000005',902.872,'2020-06-23','2020-12-23','alta');
insert into reach values ('0000000006',256.529,'2023-03-26','2023-09-26','bassa');
insert into reach values ('0000000001',488.792,'2022-08-12','2023-02-12',null);
insert into reach values ('0000000007',520.664,'2020-07-02','2021-01-02','media');
insert into reach values ('0000000008',882.909,'2021-06-16','2021-12-16','alta');
insert into reach values ('0000000008',291.002,'2022-03-11','2022-09-11','bassa');
insert into reach values ('0000000009',398.658,'2021-05-06','2021-11-06','media');
insert into reach values ('0000000010',193.320,'2022-04-07','2022-10-07','bassa');

/*frequency*/
insert into frequency values ('1',6.04,'media');
insert into frequency values ('2',11.52,'alta');
insert into frequency values ('4',9.11,null);
insert into frequency values ('6',4.83,null);
insert into frequency values ('7',5.72,'media');
insert into frequency values ('9',2.19,'bassa');
insert into frequency values ('11',7.07,null);
insert into frequency values ('13',9.13,'alta');
insert into frequency values ('15',10.11,'alta');
insert into frequency values ('17',1.97,'bassa');
insert into frequency values ('20',3.46,null);
insert into frequency values ('21',7.34,'media');
insert into frequency values ('22',11.24,'alta');
insert into frequency values ('24',6.41,null);
insert into frequency values ('27',4.24,null);
insert into frequency values ('28',6.12,'media');
insert into frequency values ('29',1.92,'bassa');
insert into frequency values ('30',5.07,null);
insert into frequency values ('32',4.33,null);

/*Impression*/
insert into impression values ('1',208,'bassa');
insert into impression values ('2',1134,'alta');
insert into impression values ('3',175,null);
insert into impression values ('6',677,null);
insert into impression values ('8',349,'media');
insert into impression values ('10',788,'alta');
insert into impression values ('11',444,null);
insert into impression values ('12',769,null);
insert into impression values ('14',1457,'alta');
insert into impression values ('15',356,'media');
insert into impression values ('16',988,'alta');
insert into impression values ('17',311,'media');
insert into impression values ('19',1008,'alta');
insert into impression values ('20',552,null);
insert into impression values ('22',863,null);
insert into impression values ('23',444,'media');
insert into impression values ('24',221,'bassa');
insert into impression values ('25',379,null);
insert into impression values ('27',777,'alta');
insert into impression values ('28',998,'alta');
insert into impression values ('29',195,'bassa');
insert into impression values ('30',379,null);
insert into impression values ('31',670,null);
insert into impression values ('32',936,'alta');

/*kpi_share*/
insert into kpi_share values('Napoli-Juve','2023-02-12 19:00:00',30.47,'alta');
insert into kpi_share values('Napoli-Juve','2022-02-12 19:00:00',27.49,'alta');
insert into kpi_share values('Manchester City - Manchester United','2023-04-02 19:00:00',32.47,'alta');
insert into kpi_share values('Manchester City - Manchester United','2022-04-02 19:00:00',27.31,'alta');
insert into kpi_share values('Manchester City - Manchester United','2021-04-02 19:00:00',24.67,'media');
insert into kpi_share values('Spezia-Lecce','2023-01-22 19:00:00',11.97,'media');
insert into kpi_share values('Spezia-Lecce','2022-01-22 19:00:00',3.95,'bassa');
insert into kpi_share values('FLOYD MAYWEATHER VS. CONOR MCGREGOR','2019-02-25 18:00:00',47.33,'alta');
insert into kpi_share values('FLOYD MAYWEATHER VS. MANNY PACQUIAO','2015-10-22 18:00:00',19.86,'media');
insert into kpi_share values('Mediterranean Cup','2022-06-16 11:00:00',3.65,'bassa');
insert into kpi_share values('Campionato italiano di categoria nuoto','2022-07-22 11:00:00',2.96,'bassa');
insert into kpi_share values('Miami Heat VS. Denver Nuggets','2023-06-01 02:00:00',35.65,'alta');
insert into kpi_share values('Olimpia Milano VS. Virtus Bologna','2023-06-10 19:00:00',11.65,'media');
insert into kpi_share values('Djokovic B. VS. Federer','2022-06-07 12:00:00',41.5,'alta');
insert into kpi_share values('Federer b. VS. Nadal','2022-06-24 12:00:00',38.75,'alta');

/*Numero Vendite*/
insert into numero_vendite values('1',1000000,'2021-01-30','2022-01-30','media');
insert into numero_vendite values('2',1000000,'2021-01-30','2022-01-30','media');
insert into numero_vendite values('3',2500000,'2021-01-30','2022-01-30','alta');
insert into numero_vendite values('4',3000000,'2021-01-30','2022-01-30','alta');
insert into numero_vendite values('5',500000,'2020-01-30','2022-01-30','bassa');
insert into numero_vendite values('6',5000000,'2019-07-15','2021-07-01','alta');
insert into numero_vendite values('7',4500000,'2019-07-15','2021-07-01','alta');
insert into numero_vendite values('8',2000000,'2019-07-15','2021-07-01','media');
insert into numero_vendite values('9',1500000,'2019-07-15','2021-07-01','bassa');
insert into numero_vendite values('10',1000000,'2019-07-15','2021-07-01','bassa');
insert into numero_vendite values('11',1000000,'2019-07-15','2021-07-01','bassa');
insert into numero_vendite values('12',5000000,'2021-10-13','2022-12-23','alta');
insert into numero_vendite values('13',5000000,'2022-05-01','2023-05-01','alta');
insert into numero_vendite values('14',4000000,'2021-10-13','2022-12-23','alta');
insert into numero_vendite values('15',4000000,'2022-05-01','2023-05-01','alta');
insert into numero_vendite values('16',3500000,'2020-07-20','2021-07-21','bassa');
insert into numero_vendite values('17',3000000,'2020-07-20','2021-07-21','media');
insert into numero_vendite values('18',2500000,'2020-07-20','2021-07-21','media');
insert into numero_vendite values('19',4000000,'2020-10-30','2021-10-30','alta');
insert into numero_vendite values('20',5000000,'2020-10-30','2021-10-30','alta');
insert into numero_vendite values('21',2000000,'2020-10-30','2021-10-30','media');
insert into numero_vendite values('22',3000000,'2020-10-30','2021-10-30','bassa');
insert into numero_vendite values('23',500000,'2021-06-01','2022-07-01','bassa');
insert into numero_vendite values('24',400000,'2021-06-01','2022-07-01','bassa');
insert into numero_vendite values('25',1000000,'2021-06-01','2022-07-01','alta');
insert into numero_vendite values('26',2000000,'2020-10-30','2021-10-30','bassa');
insert into numero_vendite values('27',1000000,'2020-10-30','2021-10-30','media');
insert into numero_vendite values('28',4500000,'2021-10-13','2022-12-23','alta');
insert into numero_vendite values('29',6000000,'2021-10-13','2022-12-23','alta');
insert into numero_vendite values('30',5000000,'2021-10-13','2022-12-23','alta');
insert into numero_vendite values('31',7000000,'2021-10-13','2022-12-23','alta');
insert into numero_vendite values('32',4000000,'2023-04-22','2024-10-28','media');
insert into numero_vendite values('33',3000000,'2023-04-22','2024-10-28','media');
insert into numero_vendite values('34',2500000,'2023-04-22','2024-10-28','bassa');
insert into numero_vendite values('35',3000000,'2023-04-22','2024-10-28','media');
insert into numero_vendite values('36',1000000,'2023-04-22','2024-10-28','bassa');
insert into numero_vendite values('37',1000000,'2023-04-22','2024-10-28','media');