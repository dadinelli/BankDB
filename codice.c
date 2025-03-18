#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dependencies/include/libpq-fe.h"

#define PG_HOST     "127.0.0.1"
#define PG_USER     "postgres" 
#define PG_DB       "BankDB"
#define PG_PASS     "0000"
#define PG_PORT     5432

//controllo la connessione al database
void check_connection(PGconn *conn) {
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connessione al database fallita: %s", PQerrorMessage(conn));
        PQfinish(conn);
        exit(1);
    } else {
        printf("Connessione al database riuscita!\n");
    }
}

//esecuzione della query sul database
void execute_query(PGconn *conn, const char *query) {
    PGresult *res = PQexec(conn, query); //risultato della query viene memorizzato qui

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query fallita: %s", PQerrorMessage(conn));
        PQclear(res);
        return;
    }

    int nFields = PQnfields(res); //numero colonne restituite dalla query
    int *col_widths = (int *)malloc(nFields * sizeof(int)); //array x memorizzare la larghezza delle colonne

    //inizializza le larghezze delle colonne con la lunghezza dei nomi delle colonne
    for (int i = 0; i < nFields; i++) {
        col_widths[i] = strlen(PQfname(res, i)); //funzione PQfname restituisce il nome delle colonne
    }

    //aggiorna le larghezze delle colonne se troviamo un valore più lungo nei dati della colonna
    for (int i = 0; i < PQntuples(res); i++) {
        for (int j = 0; j < nFields; j++) {
            int value_length = strlen(PQgetvalue(res, i, j));
            if (value_length > col_widths[j]) {
                col_widths[j] = value_length;
            }
        }
    }

    //stampa intestazioni della tabella
    for (int i = 0; i < nFields; i++) {
        printf("%-*s    ", col_widths[i], PQfname(res, i)); //allinea a sinistra e imposta la larghezza della colonna
    }
    printf("\n");

    //stampa i dati
    for (int i = 0; i < PQntuples(res); i++) {
        for (int j = 0; j < nFields; j++) {
            printf("%-*s    ", col_widths[j], PQgetvalue(res, i, j)); //come prima
        }
        printf("\n");
    }

    free(col_widths); //libera memoria allocata da malloc
    PQclear(res);
}

int main() {
    char conninfo[256]; //dim stringa di connessione
    snprintf(conninfo, sizeof(conninfo), "host = %s port = %d dbname = %s user = %s password = %s",
             PG_HOST, PG_PORT, PG_DB, PG_USER, PG_PASS);

    PGconn *conn = PQconnectdb(conninfo);
    check_connection(conn);

    int choice;
    while (1) {
        printf("Scegli una query da eseguire:\n");
        printf("1. Mostra tutti i conti di una banca specifica e i dettagli dei loro titolari:\n");
        printf("2. Mostra il numero totale di conti per ogni banca, con un raggruppamento per banca:\n");
        printf("3. Conta il numero di transazioni effettuate dal cliente e calcola il totale degli importi delle transazioni:\n");
        printf("4. Seleziona il totale delle transazioni per ogni conto inviante (Sender) con un saldo superiore a 1000 euro:\n");
        printf("5. Seleziona il numero di dipendenti per ogni filiale specificando l'indirizzo:\n");
        printf("6. Seleziona lo stipendio per ogni dipendente:\n");
        printf("7. Seleziona l'IBAN, la filiale e il nome della banca con relativo indirizzo a cui si devono riferire i clienti:\n");
        printf("8. Esci.\n");
        printf("Inserisci il numero della tua scelta: \n");
        scanf("%d", &choice);

        char bank_name[100]; //nome banca Query 1.
        char query[1024];

        switch (choice) {
            case 1:
                printf("Inserisci il nome della banca, scegliendo tra:\n "
                    "Intesa San Paolo, UniCredit, Monte Paschi di Siena, BNL, Banco BPM, Fineco, Banca popolare di Vicenza.\n");
                getchar();
                fgets(bank_name, sizeof(bank_name), stdin);
                bank_name[strcspn(bank_name, "\n")] = 0;

                //Query dinamica
                snprintf(query, sizeof(query),
                         "SELECT c.numeroConto, c.tipoConto, c.saldo, c.dataApertura, cl.nome, cl.cognome "
                         "FROM conto c "
                         "JOIN cliente cl ON c.titolare = cl.CF "
                         "JOIN banca b ON cl.codiceBanca = b.ABI "
                         "WHERE b.nomeBanca = '%s';", bank_name);

                execute_query(conn, query);
                break;
            case 2:
                execute_query(conn, "SELECT b.nomeBanca AS Banca, COUNT(c.numeroConto) AS TotaleConti "
                                    "FROM banca b "
                                    "JOIN cliente cl ON b.ABI = cl.codiceBanca "
                                    "JOIN conto c ON cl.CF = c.titolare "
                                    "GROUP BY b.nomeBanca;");
                break;
            case 3:
                int min_transazioni;
                printf("Inserisci il numero minimo di transazioni, compreso tra 0 e 6: ");
                scanf("%d", &min_transazioni);

                char query_3[1024];
                //query dinamica
                snprintf(query_3, sizeof(query_3),
                        "SELECT c.CF, c.nome, c.cognome, COUNT(*) AS num_transazioni, SUM(t.importo) AS totale_transazioni "
                        "FROM cliente c "
                        "INNER JOIN conto co ON c.CF = co.titolare "
                        "INNER JOIN transazione t ON co.numeroConto = t.numeroContoSender "
                        "GROUP BY c.CF, c.nome, c.cognome "
                        "HAVING COUNT(*) > %d AND SUM(t.importo) > 1000;", min_transazioni);

                execute_query(conn, query_3);
            break;
            case 4:
                double min_saldo;
                printf("Inserisci il saldo minimo desiderato (1000,1MLN,5MLN,7MLN, 9MLN): "); //per vedere un cambiamento nei dati inserire questi numeri (7MLN = 7000000)
                scanf("%lf", &min_saldo);

                char query_4[1024];
                //query dinamica
                snprintf(query_4, sizeof(query_4),
                        "DROP INDEX IF EXISTS idx_saldo_conto; "
                        "CREATE INDEX idx_saldo_conto ON conto(saldo); "

                        "SELECT t.numeroContoSender, COUNT(*) AS TotaleTransazioni "
                        "FROM transazione AS t "
                        "JOIN conto c ON t.numeroContoSender = c.numeroConto "
                        "GROUP BY t.numeroContoSender "
                        "HAVING MAX(c.saldo) > %.2lf; ", min_saldo);

                execute_query(conn, query_4);
                break;
            case 5:
                execute_query(conn, "SELECT indirizzo.citta, indirizzo.via, indirizzo.numero, "
	                                "COUNT(dipendente.cf) AS numero_dipendenti, filiale.cab, banca.nomebanca "
                                    "FROM dipendente "
                                    "JOIN filiale ON (filiale.cab = dipendente.codicefiliale) "
                                    "JOIN indirizzo ON (filiale.cab = indirizzo.cab) "
                                    "JOIN banca ON (filiale.codicebanca = banca.abi) "
                                    "GROUP BY indirizzo.citta, indirizzo.via, indirizzo.numero, filiale.cab, banca.nomebanca;");
                break;
            case 6:
                execute_query(conn, "SELECT nome, cognome, tipocontratto, ruolo, stipendiomensile "
                                    "FROM dipendente JOIN contratto ON (contratto.titolare = dipendente.cf) "
                                    "ORDER BY stipendiomensile DESC;");
                break;
            case 7:
                execute_query(conn, "DROP VIEW IF EXISTS cliente_conto; "
                                    "DROP VIEW IF EXISTS filiale_indirizzo; "

                                    "CREATE VIEW cliente_conto AS (SELECT cliente.nome, cliente.cognome, conto.iban, conto.codiceFiliale, banca.nomeBanca "
	                                    "FROM cliente JOIN conto ON (cliente.cf = conto.titolare AND cliente.codiceBanca = conto.codiceBanca) "
	                                    "JOIN banca ON (cliente.codiceBanca = banca.ABI)); "

                                    "CREATE VIEW filiale_indirizzo AS (SELECT filiale.cab, indirizzo.via, indirizzo.numero, indirizzo.citta, indirizzo.cap "
	                                    "FROM filiale JOIN indirizzo ON (filiale.cab = indirizzo.cab)); "

                                    "SELECT co.nome, co.cognome, co.iban, co.nomeBanca, fi.citta, fi.via, fi.numero "
                                    "FROM cliente_conto AS co, filiale_indirizzo AS fi "
                                    "WHERE fi.cab = co.codiceFiliale;");
                break;
            case 8:
                PQfinish(conn);
                exit(0);
            default:
                printf("Scelta non valida. Riprova.\n");
        }
    }

    PQfinish(conn);
    return 0;
}
