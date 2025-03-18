DROP TABLE IF EXISTS banca cascade;
DROP TABLE IF EXISTS cliente cascade;
DROP TABLE IF EXISTS conto cascade;
DROP TABLE IF EXISTS beneficiario cascade;
DROP TABLE IF EXISTS transazione cascade;
DROP TABLE IF EXISTS filiale cascade;
DROP TABLE IF EXISTS indirizzo cascade;
DROP TABLE IF EXISTS dipendente cascade;
DROP TABLE IF EXISTS contratto cascade;
DROP TABLE IF EXISTS ferie cascade; 
DROP TYPE IF EXISTS type_tipobanca;
DROP TYPE IF EXISTS type_tipotransazione;
DROP TYPE IF EXISTS type_ruolo;

CREATE TYPE type_tipobanca AS enum('Popolare', 'Nazionale');
CREATE TYPE type_tipotransazione AS enum('Bonifico', 'Assegno', 'Carta');
CREATE TYPE type_ruolo AS enum('Manager', 'Dipendente Ufficio', 'Dirigente Filiale');

CREATE TABLE banca(
    ABI VARCHAR(5) NOT NULL,
    numeroTel VARCHAR(12) NOT NULL,
    nomeBanca VARCHAR(30) NOT NULL,
	tipobanca type_tipobanca NOT NULL,
    email VARCHAR(60) NOT NULL,

    PRIMARY KEY (ABI)
);

CREATE TABLE filiale(
    CAB VARCHAR(5) NOT NULL,
    numeroTel VARCHAR(12) NOT NULL,
    orarioApertura TIME NOT NULL,
    codiceBanca VARCHAR(5) NOT NULL,
    
    PRIMARY KEY (CAB),

    FOREIGN KEY (codiceBanca) REFERENCES banca(ABI)
);

CREATE TABLE indirizzo(
    CAP VARCHAR(5) NOT NULL,
    via VARCHAR(30) NOT NULL,
    numero INT NOT NULL,
    citta VARCHAR(30) NOT NULL,
    CAB VARCHAR(5),

    PRIMARY KEY(CAP, via, numero),
    
    FOREIGN KEY (CAB) REFERENCES filiale(CAB)
);

CREATE TABLE cliente(
    CF VARCHAR(16) NOT NULL,
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
    dataNascita DATE NOT NULL,
    email VARCHAR(60) NOT NULL,
    numeroTel VARCHAR(12) NOT NULL,
    codiceBanca VARCHAR(5) NOT NULL,                             
    via_indirizzo VARCHAR(30) NOT NULL,
    CAP_indirizzo VARCHAR(5) NOT NULL,
    numero_indirizzo INT NOT NULL,

    PRIMARY KEY(codiceBanca, CF),
    
    FOREIGN KEY (codiceBanca) REFERENCES banca(ABI),
    FOREIGN KEY (via_indirizzo, CAP_indirizzo, numero_indirizzo) REFERENCES indirizzo(via, CAP, numero)
);

CREATE TABLE conto(                                      	
    numeroConto VARCHAR(12) NOT NULL,                     
    saldo NUMERIC(10, 2) NOT NULL,
    IBAN VARCHAR(27) NOT NULL,
    dataApertura DATE NOT NULL,
    tipoConto VARCHAR(20) NOT NULL,
    titolare VARCHAR(16) NOT NULL,
    codiceFiliale VARCHAR(5) NOT NULL,
	codiceBanca VARCHAR(5) NOT NULL,

	PRIMARY KEY (numeroConto),

    FOREIGN KEY (codiceFiliale) REFERENCES filiale(CAB),
    FOREIGN KEY (titolare, codiceBanca) REFERENCES cliente(CF, codiceBanca)
    
); 

CREATE TABLE beneficiario(
    numeroContoBeneficiario VARCHAR(12) NOT NULL,						
    titolo VARCHAR(20) NOT NULL,                                 
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
    numeroTel VARCHAR(12) NOT NULL,
    email VARCHAR(60) NOT NULL,

    PRIMARY KEY (numeroContoBeneficiario) 
);

CREATE TABLE transazione(
    numeroContoSender VARCHAR(12) NOT NULL,
    numeroContoReceiver VARCHAR(12) NOT NULL,
    importo NUMERIC(10, 2) NOT NULL,
    dataora TIMESTAMP NOT NULL,
    tipoTransazione type_tipotransazione NOT NULL,                        

    PRIMARY KEY (numeroContoSender, numeroContoReceiver, dataora),

    FOREIGN KEY (numeroContoSender) REFERENCES conto(numeroConto),
    FOREIGN KEY (numeroContoReceiver) REFERENCES beneficiario(numeroContoBeneficiario)
);

CREATE TABLE dipendente(
    CF VARCHAR(16) NOT NULL,
    nome VARCHAR(10) NOT NULL,
    cognome VARCHAR(10) NOT NULL,
    numeroTel VARCHAR(12) NOT NULL,
    email VARCHAR(60) NOT NULL,
    ruolo type_ruolo NOT NULL,                                       
    codiceBanca VARCHAR(5) NOT NULL,
	codiceFiliale VARCHAR(5) NOT NULL,

    PRIMARY KEY (CF),

    FOREIGN KEY (codiceBanca) REFERENCES banca(ABI),
	FOREIGN KEY (codiceFiliale) REFERENCES filiale(CAB)
);

CREATE TABLE contratto(	
    titolare VARCHAR(16) NOT NULL,
    tipoContratto VARCHAR(15) NOT NULL,
    stipendioMensile NUMERIC(6, 2) NOT NULL,
    dataInizio DATE NOT NULL,
    dataFine DATE,

    PRIMARY KEY (titolare),
    
    FOREIGN KEY (titolare) REFERENCES dipendente(CF)
);

CREATE TABLE ferie(
    dataInizio DATE NOT NULL,
    dataFine DATE NOT NULL,
    statoRichiesta VARCHAR(10) NOT NULL,
    richiedente VARCHAR(16) NOT NULL,

    PRIMARY KEY (dataInizio, dataFine),
    
    FOREIGN KEY (richiedente) REFERENCES dipendente(CF)
);

ALTER TABLE contratto ADD CONSTRAINT contratto_check CHECK (contratto.dataInizio < contratto.dataFine);
ALTER TABLE ferie ADD CONSTRAINT ferie_check CHECK (ferie.dataInizio < ferie.dataFine);