/*Query non banali WP3*/
/*Query 7.1, mostra, per ogni azienda il ROAS, classificando le aziende per l'investimento totale*/

select A.nome,sum(capitale_investito) as Investimento_Totale, R.valore as roas, R.data_inizio,R.data_fine 
from azienda A 
join investimento I on (partita_iva = aziendaID and data_inizio_validita = data_azienda) 
join roas R on (R.aziendaID = A.partita_iva and R.data_azienda = A.data_inizio_validita) 
group by A.nome,R.valore, R.data_inizio,R.data_fine
order by Investimento_Totale desc;

/*Query 7.2 per vedere i prodotti delle campagne di lancio che hanno ricevuto almeno un
investimento particolarmente importante e considerabile vincente valutando il CAC */

select K.valore as cac, C.nome as nome_campagna, C.data_inizio, P.marca, P.nome as prodotto_lanciato, P.colore, P.prodottoID as ID
from campagna C
join saldi S on C.campagnaID = S.campagnaID
join prodotto P on s.prodottoID = P.prodottoID
join cac K on C.campagnaID = K.campagnaID
where C.tipo = 'lancio'
    and C.status = 'attivo'
    and exists (
        select *
        from investimento I
        join azienda A on I.aziendaID = A.partita_iva
        where I.campagnaID = C.campagnaID
            and I.capitale_investito > 40000000
    )
    and exists (
        select *
        from CAC K
        where K.campagnaID = C.campagnaID
            and K.valore < 50
    )
   
ORDER BY c.data_inizio DESC;

/*Query 7.3 per valutare l'efficienza dei banner interattivi con i QRCode*/ 

select P.nome,P.marca,P.prodottoID
from prodotto P join numero_vendite V on P.prodottoID = V.prodottoID
where V.valore > 2000000

intersect

select P.nome,P.marca,P.prodottoID
from prodotto P join banner B on P.prodottoID = B.prodottoID
join scan_qrcode Q on B.bannerID = Q.bannerID
where Q.valore > 1000000;

/*Query 7.4.1 per visualizzare gli utenti minorenni che guardano eventi su canali di boxe o mma*/

select U.email,U.data_di_nascita from utente U
join visione V on V.utenteID = U.codice_profilo
join evento E on (E.nome = V.evento and E.data_evento = V.data_evento)
join canale C on C.nome = E.canaleID
where U.data_di_nascita > current_date - interval '18 years'
and (C.categoria = 'Boxe' or C.categoria = 'MMA');

/*Query 7.4.2 per calcolare il costo sostenuto per i banner
da ogni singola campagna ordinandole per tale costo,
inoltre mostra il budget rimanente (preso dall'operazione 7 da 4.1.1.2)*/

select C.nome,sum(durata_banner * costo_per_secondo) Costo_tot,C.budget, 
C.budget - sum(durata_banner * costo_per_secondo) as Budget_rimanente
from campagna C
join banner B on B.campagnaID = C.campagnaID
join sponsorizzazione S on S.bannerID = B.bannerID 
group by C.nome,C.budget
order by Costo_tot desc;


/*Viste e query*/
/*Prima Vista: Calcola per ogni banner interattivo le scannerizzazioni totali*/
create or replace view MassimoScan as
	select E.nome,E.data_Evento, sum(Q.valore) TotScannerizzazioni
	from scan_qrcode Q 
	join banner B on (Q.bannerID = B.bannerID)
	join Sponsorizzazione S on (S.bannerID = B.bannerID)
	join Evento E on (E.Nome = S.Evento and E.data_evento = S.data_evento)
	group by E.nome, E.data_evento
	order by  TotScannerizzazioni desc;
/*Query 1.1: Visualizza gli utenti che hanno visto l'evento con più scanerizzazioni*/
select distinct email from utente 
join visione V on (V.utenteID = codice_profilo)
join evento E on (E.nome =V.evento and E.data_evento = V.data_evento)
where (E.nome, E.data_evento) in 
(Select nome,data_evento from MassimoScan
where TotScannerizzazioni = (select max(TotScannerizzazioni)from MassimoScan));

/*Query 1.2: Visualizza gli utenti che hanno visto l'evento con meno scannerizzazioni*/
select distinct email from utente 
join visione V on (V.utenteID = codice_profilo)
join evento E on (E.nome =V.evento and E.data_evento = V.data_evento)
where (E.nome, E.data_evento) in 
(Select nome,data_evento from MassimoScan
where TotScannerizzazioni = (select min(TotScannerizzazioni)from MassimoScan));

/*Seconda Vista: Visualizza le campagne con le rispettive vendite totali dei prodotti */
create or replace view SumProdotti as
	select  C.nome Campagna,sum(N.valore) Somma
	from  campagna C
	join saldi S on (C.campagnaID = S.campagnaID)
	join prodotto P on (P.prodottoID = S.prodottoID)
	join numero_vendite N on (N.prodottoID = P.prodottoID)
	group by  C.nome
	order by Somma desc;

/*Query 2.1:vedere tutti i prodotti che sono stati venduti della campagna che ha venduto più prodotti*/
select C.nome ,P.prodottoID,P.nome,P.marca,N.valore from  campagna C
	join saldi S on (C.campagnaID = S.campagnaID)
	join prodotto P on (P.prodottoID = S.prodottoID)
	join numero_vendite N on (N.prodottoID = P.prodottoID)
where C.nome = (select campagna from SumProdotti where somma = any (select max(somma) from SumProdotti))
order by valore desc;

/*Query 2.2: Visualizzare le aziende che hanno investito in una determinata campagna*/
select distinct C.nome,A.nome,I.capitale_investito,I.data_investimento from  campagna C
	join investimento I on (C.campagnaID = I.campagnaID)
	join azienda A on (I.aziendaID = A.partita_IVA)
where C.nome = (select campagna from SumProdotti where somma = any (select max(somma) from SumProdotti))
order by capitale_investito desc;