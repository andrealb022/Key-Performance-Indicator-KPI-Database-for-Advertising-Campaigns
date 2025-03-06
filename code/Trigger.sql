/*TRIGGER WP1*/
/*Trigger per aggiornare budget campagna*/
CREATE OR REPLACE FUNCTION update_budget_campagna()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE campagna
    SET budget = campagna.budget + NEW.capitale_investito
    WHERE campagna.campagnaID = NEW.campagnaID;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_budget_campagna_trigger
AFTER INSERT ON investimento
FOR EACH ROW
EXECUTE FUNCTION update_budget_campagna();

/*Controlla che ogni campagna abbia un investimento*/
create or replace function checkInvestimento() returns trigger as $$
BEGIN
if (exists (select * from campagna where campagnaID not in (select campagnaID from investimento))) then
   raise exception 'Campagna non associata a nessun investimento';
end if;

RETURN NULL;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER atLeastOneInv
After INSERT ON Prodotto
FOR EACH ROW EXECUTE PROCEDURE checkInvestimento();

CREATE OR REPLACE TRIGGER atLeastOneInv2
After DELETE or UPDATE ON Saldi
FOR EACH ROW EXECUTE PROCEDURE checkInvestimento();

/*Trigger per controllare che ogni azienda abbia almeno una sede*/
create or replace function checkSede() returns trigger as $$
BEGIN
if (exists (select * from azienda where partita_iva not in (select aziendaID from collocazione) and data_inizio_validita not in (select data_azienda from collocazione))) then
   raise exception 'Azienda non associata a nessuna sede';
end if;

RETURN NULL;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER atLeastOneSede
After INSERT ON Azienda
FOR EACH ROW EXECUTE PROCEDURE checkSede();

CREATE OR REPLACE TRIGGER atLeastOneSede2
After DELETE or UPDATE ON collocazione
FOR EACH ROW EXECUTE PROCEDURE checkSede();

/*Controlla che il prodotto è associato ad una campagna*/
create or replace function checkProdotto() returns trigger as $$
BEGIN
if (exists (select * from Prodotto where prodottoID not in (select prodottoID from Saldi))) then
   raise exception 'Prodotto non associato a nessuna campagna';
end if;

RETURN NULL;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER atLeastOneProd
After INSERT ON Prodotto
FOR EACH ROW EXECUTE PROCEDURE checkProdotto();

CREATE OR REPLACE TRIGGER atLeastOneProd2
After DELETE or UPDATE ON Saldi
FOR EACH ROW EXECUTE PROCEDURE checkProdotto();

/*Controlla che il banner è associato ad una sponsorizzazione*/
create or replace function checkBanner() returns trigger as $$
BEGIN
if (exists (select * from banner where bannerID not in (select bannerID from sponsorizzazione))) then
   raise exception 'Banner non associato a nessuna Sponsorizzazione';
end if;

RETURN NULL;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER atLeastOneBanner
After INSERT ON banner
FOR EACH ROW EXECUTE PROCEDURE checkBanner();

CREATE OR REPLACE TRIGGER atLeastOneBanner2
After DELETE or UPDATE ON sponsorizzazione
FOR EACH ROW EXECUTE PROCEDURE checkBanner();


/*Trigger WP4*/
/*Trigger per assicurarsi che lo sconto è presente solo nelle campagna di mantenimento*/
CREATE OR REPLACE FUNCTION check_tipo_campagna()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.sconto_percentuale IS NULL) THEN
        IF (SELECT tipo FROM campagna WHERE campagnaID = NEW.campagnaID) <> 'lancio' THEN
            RAISE EXCEPTION 'Devi inserire uno sconto percentuale per una campagna di mantenimento';
        END IF;
    ELSE
        IF (SELECT tipo FROM campagna WHERE campagnaID = NEW.campagnaID) <> 'mantenimento' THEN
            RAISE EXCEPTION 'Non devi inserire uno sconto percentuale per una campagna di lancio';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_tipo_campagna_trigger
BEFORE INSERT or Update ON saldi
FOR EACH ROW
EXECUTE FUNCTION check_tipo_campagna();

/*Trigger per controllare che scan qr code sia associato a un banner interattivo */
CREATE OR REPLACE FUNCTION check_banner_interattivo()
RETURNS TRIGGER AS $$
BEGIN
	IF not exists(select * from banner where bannerID= new.bannerID and qr_code is not null) then
	      raise exception 'Scan QR_Code associato a banner non interattivo';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_banner_interattivo_trigger
BEFORE INSERT or Update ON scan_qrcode
FOR EACH ROW
EXECUTE FUNCTION check_banner_interattivo();

/*Trigger per controllare che un utente abbia <=3 interessi sportivi */
CREATE OR REPLACE FUNCTION check_interessi_sportivi()
RETURNS TRIGGER AS $$
BEGIN
	IF (SELECT count(*) FROM interessi_sportivi WHERE utenteID = NEW.utenteID) = 3 THEN
            RAISE EXCEPTION 'L''utente ha già 3 interessi sportivi, modificare quelli precedenti';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_interessi_sportivi_trigger
BEFORE INSERT ON interessi_sportivi
FOR EACH ROW
EXECUTE FUNCTION check_interessi_sportivi();


/*Trigger per non avere due aziende con lo storico valido */
CREATE OR REPLACE FUNCTION check_azienda_storico()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.data_fine_validita IS NULL THEN
       IF EXISTS(SELECT * FROM azienda WHERE partita_iva=NEW.partita_iva and data_fine_validita is null)THEN
            RAISE EXCEPTION 'Non possono esistere due aziende con la stessa partita IVA senza la data fine validità.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER azienda_storico_trigger
BEFORE INSERT OR UPDATE ON azienda
FOR EACH ROW
EXECUTE FUNCTION check_azienda_storico();