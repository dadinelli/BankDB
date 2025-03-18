--Creazione Tabelle
DROP TABLE IF EXISTS banca CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS conto CASCADE;
DROP TABLE IF EXISTS beneficiario CASCADE;
DROP TABLE IF EXISTS transazione CASCADE;
DROP TABLE IF EXISTS filiale CASCADE;
DROP TABLE IF EXISTS indirizzo CASCADE;
DROP TABLE IF EXISTS dipendente CASCADE;
DROP TABLE IF EXISTS contratto CASCADE;
DROP TABLE IF EXISTS ferie CASCADE; 
DROP TYPE IF EXISTS type_tipobanca;
DROP TYPE IF EXISTS type_tipotransazione;
DROP TYPE IF EXISTS type_ruolo;

CREATE TYPE type_tipobanca AS ENUM('Popolare', 'Nazionale');
CREATE TYPE type_tipotransazione AS ENUM('Bonifico', 'Assegno', 'Carta');
CREATE TYPE type_ruolo AS ENUM('Manager', 'Dipendente Ufficio', 'Dirigente Filiale');

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
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
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


--Popolamento tabelle 
INSERT INTO banca (ABI, numeroTel, nomeBanca, email, tipobanca) VALUES
('03069', '335 576 1184', 'Intesa San Paolo', 'info@isp.it', 'Nazionale'),
('05034', '354 842 1009', 'Banco BPM', 'info@bpm.it', 'Popolare'),
('03015', '325 720 5252', 'Fineco', 'helpdesk@finecobank.com', 'Nazionale'),
('02008', '394 649 0656', 'UniCredit', 'info@unicredit.it', 'Nazionale'),
('01030', '393 918 0366', 'Monte Paschi di Siena', 'info@mps.it', 'Nazionale'),
('01005', '348 926 8119', 'BNL', 'info@bnl.it', 'Nazionale'),
('05728', '329 979 2908', 'Banca popolare di Vicenza', 'lcabancapopolaredivicenza@pecliquidazioni.it', 'Popolare');

INSERT INTO filiale (CAB, numeroTel, orarioApertura, codiceBanca) VALUES
('41588', '328 677 2252', '9:00:00', '01005'),
('75341', '304 838 1485', '8:00:00', '05034'),
('90619', '355 528 0128', '8:00:00', '01005'),
('92509', '326 495 7310', '8:30:00', '03069'),
('42650', '351 322 9566', '9:00:00', '01030'),
('36720', '365 327 6426', '9:00:00', '05728'),
('48203', '351 687 8007', '8:30:00', '05034'),
('52737', '365 716 6560', '9:00:00', '01005'),
('95268', '349 599 6514', '8:30:00', '05728'),
('77238', '362 019 8240', '8:00:00', '02008'),
('25415', '349 970 6111', '8:00:00', '03015');
	
INSERT INTO indirizzo (CAP, via, numero, citta, CAB) VALUES
('91599', 'via Incrocio Ammaniti', 55, 'Sesto Rosina', null),
('81216', 'Borgo Germana', 48, 'Borgo Oreste', null),
('31746', 'via Piccinni', 78, 'Borgo Oreste', null),
('95666', 'via Strada Enrico', 57, 'Settimo Sebastiano', null),
('43519', 'via Contrada Alfredo', 33, 'Pezzali a mare', null),
('64027', 'via Rotonda Nanni', 32, 'Liberto terme', null),
('73762', 'Contrada Gaglian', 53, 'Borgo Flavio sardo', null),
('77883', 'Canale Pin', 53, 'Benedetto nell emilia', null),
('54276', 'Incrocio Fuseli', 80, 'Carli ligure', null),
('38996', 'Viale Gian', 60, 'Donatoni sardo', null),
('14680', 'Contrada Angeli', 91, 'Gaetano ligure', null),
('25792', 'Viale Mauro', 45, 'Morricone ligure', null),
('93001', 'Via Lucrezia', 22, 'Bragadin sardo', null),
('42561', 'Viale Severino', 20, 'Sesto Nedda laziale', null),
('60148', 'Incrocio Borromeo', 80, 'Giulia del friuli', null),
('88877', 'Canale Adinolfi', 74, 'Nitto del friuli', null),
('19729', 'Viale Gussoni', 4, 'Bologna', null),
('67892', 'Piazza Vittorio', 65, 'Sesto Edoardo del friuli', '41588'),
('25282', 'Piazza Paloma', 48, 'San Coriolano', '75341'),
('35361', 'via Stretto Calbo', 52, 'Gottardi nell emilia', '90619'),
('88057', 'via Contrada Arturo', 24, 'Sesto Rosina', '92509'),
('53483', 'via Strada Dallara', 78, 'Borgo Oreste', '42650'),
('41905', 'via Contrada Elvira', 74, 'Vicenza', '36720'),
('52763', 'via Vicolo Veneziano', 59, 'Cattaneo ligure', '48203'),
('39881', 'via Contrada Cociarelli', 25, 'Bocelli lido', '52737'),
('73291', 'via Borgo Naccari', 28, 'Vicenza', '95268'),
('66338', 'via Enzo Moro', 37, 'Carmelo sardo', '77238'),
('87023', 'Rotonda Sauro', 69, 'San Temistocle del friuli', '25415');

INSERT INTO cliente (CF, nome, cognome, dataNascita, email, numeroTel, codiceBanca, via_indirizzo, cap_indirizzo, numero_indirizzo) VALUES
('RSSMRA85M01H501Z', 'Mario', 'Rossi', '1985-04-23', 'mario.rossi@gmail.com', '320 123 4567', '05034', 'via Incrocio Ammaniti', '91599', 55),
('VRDLGI90A01F205X', 'Luigi', 'Verdi', '1990-10-15', 'luigi.verdi@libero.it', '320 234 5678', '05034', 'Borgo Germana', '81216', 48),
('VRDLGI90A01F205X', 'Luigi', 'Verdi', '1990-10-15', 'luigi.verdi@libero.it', '320 234 5678', '02008', 'Borgo Germana', '81216', 48),
('BNCLRA95L01H501Z', 'Lara', 'Bianchi', '1995-07-19', 'lara.bianchi@protonmail.com', '320 345 6789', '03015', 'via Piccinni', '31746', 78),
('BRNGIU70A01D206W', 'Giulia', 'Bruno', '1970-03-11', 'giulia.bruno@alice.it', '320 456 7890', '05728', 'via Strada Enrico', '95666', 57),
('MNZFRN85C01H501Z', 'Franco', 'Manzi', '1985-01-30', 'franco.manzi@inwind.it', '320 567 8901', '03069', 'via Contrada Alfredo', '43519', 33),
('PIVA-01333550323', 'Assicurazioni Generali', 'S.p.a.', '1960-02-21', 'generali@generali.com', '043 211 5704', '01030', 'via Rotonda Nanni', '64027', 32),
('ZCCLGU51D61K9TRL', 'Luigi', 'Zacco', '1951-04-21', 'luigi.zacco@gmail.com', '327 425 1990', '01005', 'Contrada Gaglian', '73762', 53),
('FGGNGC78B41M2LQM', 'Angelica', 'Faggiani', '1978-11-01', 'angelica.faggiani@protonmail.com', '378 052 9643', '05034', 'Canale Pin', '77883', 53),
('CMBPMN45E51W7YZJ', 'Pomponio', 'Combi', '1945-05-11', 'pomponio.combi@gmail.com', '320 356 9938', '02008', 'Incrocio Fuseli', '54276', 80),
('PRGENR47T63H8JAU', 'Enrico', 'Pergolesi', '1947-12-23', 'enrico.pergolesi@alice.it', '346 739 2882', '03069', 'Viale Gian', '38996', 60),
('LTTMNL41L61F4SBS', 'Manuel', 'Lattuada', '1941-07-30', 'manuel.lattuada@inwind.it', '376 682 7978', '01030', 'Contrada Angeli', '14680', 91),
('SRCFRZ90D10V6WXT', 'Fabrizio', 'Saraceno', '1990-04-10', 'fabrizio.saraceno@protonmail.com', '314 542 7270', '05728', 'Viale Mauro', '25792', 45),
('SRCFRZ90D10V6WXT', 'Fabrizio', 'Saraceno', '1990-04-10', 'fabrizio.saraceno@protonmail.com', '314 542 7270', '02008', 'Viale Mauro', '25792', 45),
('SRCFRZ90D10V6WXT', 'Fabrizio', 'Saraceno', '1990-04-10', 'fabrizio.saraceno@protonmail.com', '314 542 7270', '01030', 'Viale Mauro', '25792', 45),
('NNCDLA28C17P5CVG', 'Adele', 'Iannucci', '1928-03-17', 'adele.iannucci@libero.it', '392 881 2623', '05034', 'Via Lucrezia', '93001', 22),
('VRRTTE62M21G0BKO', 'Etta', 'Verri', '1962-08-21', 'etta.verri@gmail.com', '318 750 9091', '01005', 'Viale Severino', '42561', 20),
('SLRRTT77E22J3QDR', 'Loretta', 'Salieri', '1977-05-22', 'loretta.salieri@protonmail.com', '373 609 8061', '05728', 'Incrocio Borromeo', '60148', 80),
('MSTVRG94C20Y1PFE', 'Virginia', 'Mastandrea', '1994-03-20', 'virginia.mastandrea@gmail.com', '324 747 0658', '05034', 'Canale Adinolfi', '88877', 74),
('PIVA-03320960374', 'Conad', 'Società Cooperativa', '1962-05-13', 'conadcoop@info.com', '386 811 5704', '01005', 'Viale Gussoni', '19729', 4);

INSERT INTO conto (numeroConto, saldo, IBAN, dataApertura, tipoConto, titolare, codiceFiliale, codiceBanca) VALUES
('497933745241', 9907975.84, 'IT24X0306941124497933745241', '2019-09-28', 'Deposito', 'MNZFRN85C01H501Z', '92509', '03069'),
('786629298389', 9859767.31, 'IT45O0301528797786629298389', '1998-11-10', 'Corrente', 'RSSMRA85M01H501Z', '75341', '05034'),
('118031943539', 8214384.38, 'IT52S0301538598118031943539', '1972-03-04', 'Deposito', 'VRDLGI90A01F205X', '48203', '05034'),
('286482269098', 3234459.84, 'IT91I0306988025286482269098', '1985-04-14', 'Corrente', 'VRDLGI90A01F205X', '77238', '02008'),
('693740880451', 0196390.24, 'IT34V0103030208693740880451', '2018-03-12', 'Corrente', 'BRNGIU70A01D206W', '36720', '05728'),
('184338094693', 5016967.19, 'IT63P0100513660184338094693', '1983-09-25', 'Deposito', 'PIVA-01333550323', '42650', '01030'),
('943685504536', 8361980.93, 'IT73R0503450566943685504536', '2005-02-07', 'Corrente', 'ZCCLGU51D61K9TRL', '41588', '01005'),
('795917981125', 3887949.00, 'IT56D0306968687795917981125', '2013-04-26', 'Deposito', 'FGGNGC78B41M2LQM', '75341', '05034'),
('925833077389', 3407592.60, 'IT88U0503475559925833077389', '1962-06-02', 'Corrente', 'CMBPMN45E51W7YZJ', '77238', '02008'),
('616515058712', 3721213.71, 'IT15C0301526584616515058712', '1962-06-02', 'Deposito', 'CMBPMN45E51W7YZJ', '77238', '02008'),
('344660121412', 9796464.47, 'IT36G0306944499344660121412', '1977-09-24', 'Deposito', 'PRGENR47T63H8JAU', '92509', '03069'),
('459086496721', 3716403.66, 'IT65H0100526867459086496721', '2018-06-05', 'Corrente', 'LTTMNL41L61F4SBS', '42650', '01030'),
('514420132508', 5150334.93, 'IT55T0572826519514420132508', '2022-05-30', 'Deposito', 'SRCFRZ90D10V6WXT', '36720', '05728'),
('807423430230', 2831660.56, 'IT99U0503419871807423430230', '1998-08-16', 'Corrente', 'NNCDLA28C17P5CVG', '48203', '05034'),
('823730232912', 4185611.38, 'IT52L0100533642823730232912', '1979-04-22', 'Deposito', 'VRRTTE62M21G0BKO', '52737', '01005'),
('993333750876', 9952477.71, 'IT87G0503496331993333750876', '2002-11-20', 'Corrente', 'SLRRTT77E22J3QDR', '95268', '05728'),
('339759179962', 5102853.77, 'IT24J0301594573339759179962', '1981-05-25', 'Corrente', 'PIVA-03320960374', '41588', '01005'),
('788251284763', 6768050.47, 'IT90F0301567812788251284763', '2021-06-09', 'Deposito', 'MSTVRG94C20Y1PFE', '48203', '05034'),
('465736289456', 2034546.57 ,'IT55F0301525415000000050876', '2015-06-07', 'Corrente', 'BNCLRA95L01H501Z', '25415', '03015');


INSERT INTO beneficiario (numeroContoBeneficiario, titolo, nome, cognome, numeroTel, email) VALUES
('761713664468', 'Azienda', 'Padova', 'ASL', '2085255029', 'padovaasl@info.it'),
('963548097663', 'Azienda', 'Montebelluna', 'Trattoria Al Giardino', '9101211473', 'trattoriagiardino@gmail.com'),
('747976441501', 'Azienda', 'Osoppo', 'Cooperativa', '4450298795', 'osoppocoop@info.it'),
('749896583897', 'Privato', 'Fortunata', 'Ramazzotti', '7724445067', 'Fortunata.Ramazzotti@inwind.it'),
('725103498772', 'Privato', 'Adriano', 'Abbagnale', '0016488824', 'Adriano.Abbagnale@libero.it'),
('693740880451', 'Privato', 'Giulia', 'Bruno', '3204567890', 'giulia.bruno@alice.it'),
('184338094693', 'Azienda','Assicurazioni Generali', 'S.p.a.', '0432115704', 'generali@generali.com'),
('326079974497', 'Privato', 'Lisa', 'Lucarelli', '344 650 7858', 'lisa.lucarelli@gmail.com'),
('642721067701', 'Privato', 'Arturo', 'Morpurgo', '364 859 8406', 'arturo.morpurgo@alice.it'),
('660285554106', 'Privato', 'Romana', 'Vivaldi', '318 968 2379', 'romana.vivaldi@inwind.it'),
('596206760004', 'Privato', 'Ermenegildo', 'Buonauro', '370 974 6670', 'ermenegildo.buonauro@inwind.it'),
('427820658344', 'Privato', 'Paulina', 'Canil', '305 448 3960', 'paulina.canil@inwind.it');


INSERT INTO transazione (numeroContoSender, numeroContoReceiver, dataora, importo, tipoTransazione) VALUES
('497933745241', '747976441501', '2007-06-13 17:47:19', 5000, 'Bonifico'),
('118031943539', '693740880451', '2024-05-26 14:47:38', 50, 'Carta'),
('786629298389', '761713664468', '2018-04-10 13:41:15', 300, 'Bonifico'),
('786629298389', '963548097663', '2007-11-25 06:40:03', 150, 'Carta'),
('118031943539', '749896583897', '2002-12-15 05:42:24', 1000, 'Assegno'),
('286482269098', '747976441501', '2007-06-14 18:37:42', 4500, 'Bonifico'),
('693740880451', '749896583897', '2024-05-25 08:20:03', 5000, 'Bonifico'),
('184338094693', '725103498772', '2024-05-23 08:32:21', 10500, 'Assegno'),
('184338094693', '761713664468', '2024-05-25 18:58:45', 1100, 'Assegno'),
('184338094693', '761713664468', '2024-05-27 20:23:01', 1200, 'Assegno'),
('925833077389', '642721067701', '1994-05-30 04:09:52', 1200, 'Bonifico'),
('788251284763', '660285554106', '2000-06-08 13:28:51', 1400, 'Assegno'),
('788251284763', '660285554106', '2024-04-11 20:23:01', 560, 'Assegno'),
('823730232912', '747976441501', '2013-05-02 17:10:13', 200, 'Carta'),
('616515058712', '761713664468', '1980-04-21 04:42:29', 1200, 'Assegno');

INSERT INTO dipendente(CF, nome, cognome, numeroTel, email, ruolo, codiceBanca, codiceFiliale) VALUES
('PZZGFR65L18H501K' ,'Gioffre', 'Piazzi', '377 048 4799', 'Gioffre.Piazzi@protonmail.com', 'Dipendente Ufficio', '05034', '92509'),
('CNTLGN82C49F205U', 'Luigina', 'Conte', '375 041 4729', 'Luigina.Conte@inwind.it', 'Dipendente Ufficio', '03015', '92509'),
('TRNGDU75S22L219H', 'Guido', 'Tarantino', '317 023 4522', 'Guido.Tarantino@gmail.com', 'Manager', '02008', '48203'),
('PZZLNI90M53G273F','Lina', 'Opizzi', '317 048 4799', 'Lina.Opizzi@gmail.com', 'Dirigente Filiale', '02008', '77238'),
('GLPSSL50E30A944I', 'Osvaldo', 'Galuppi', '374 048 4799', 'Osvaldo.Galuppi@protonmail.com', 'Dipendente Ufficio', '05034', '92509'),
('RMLGNN80A01H501U', 'Giovanni', 'Rossi', '306 712 0527', 'giovanni.rossi@libero.it', 'Manager', '02008', '48203'),
('LMBMRZ60A01H501Y', 'Maurizio', 'Lombroso', '389 610 2513', 'maurizio.lombroso@gmail.com', 'Manager', '01030', '90619'),
('GVNMRZ65T50E564N', 'Maria', 'Giovine', '319 363 6667', 'maria.giovine@libero.it', 'Manager', '02008', '95268'),
('MNMDRA68S20C523U', 'Dario', 'Mimun', '365 437 3907', 'dario.mimun@libero.it', 'Dirigente Filiale', '02008', '36720'),
('SGSTNN66P20A794R', 'Tonino', 'Sagese', '374 808 8708', 'tonino.sagese@alice.it', 'Dirigente Filiale', '02008', '75341'),
('BRBNNZ70R60L838Z', 'Annunziata', 'Barberini', '388 246 4307', 'annunziata.barberini@inwind.it', 'Dirigente Filiale', '02008', '48203');

INSERT INTO contratto (titolare, tipoContratto, stipendioMensile, dataInizio, dataFine) VALUES
('PZZGFR65L18H501K', 'Determinato', 1440, '1995-02-01', '1998-02-01'),
('CNTLGN82C49F205U', 'Indeterminato', 1520, '1981-01-19', null),
('TRNGDU75S22L219H', 'Indeterminato', 2120, '1989-04-12', null),
('PZZLNI90M53G273F', 'Determinato', 1750, '1999-07-15', '2002-07-15'),
('GLPSSL50E30A944I', 'Stage', 1100, '2023-05-01', '2023-06-01'),
('RMLGNN80A01H501U', 'Indeterminato', 1250, '2024-1-21', null),
('GVNMRZ65T50E564N', 'Indeterminato', 1700, '1981-04-25', null),
('MNMDRA68S20C523U', 'Determinato', 1200, '1998-01-13', '2001-01-13'),
('SGSTNN66P20A794R', 'Stage', 1000, '1998-05-02', '2001-05-01'),
('BRBNNZ70R60L838Z', 'Indeterminato', 1900, '1974-09-10', null);

INSERT INTO ferie (dataInizio, dataFine, statoRichiesta, richiedente) VALUES
('2024-07-01', '2024-07-15', 'Accettata', 'PZZGFR65L18H501K'),
('2023-09-01', '2023-09-15', 'Rifiutata', 'CNTLGN82C49F205U'),
('2024-08-07', '2024-08-10', 'In Attesa', 'TRNGDU75S22L219H'),
('2024-06-12', '2024-06-15', 'In Attesa', 'PZZLNI90M53G273F'),
('2022-12-20', '2023-01-07', 'Rifiutata', 'GLPSSL50E30A944I');

--Query ed Indici

--1. Query che mostra tutti i conti di una banca specifica e i dettagli dei loro titolari:
SELECT c.numeroConto, c.tipoConto, c.saldo, c.dataApertura, cl.nome, cl.cognome
FROM conto c
JOIN cliente cl ON c.titolare = cl.CF
JOIN banca b ON cl.codiceBanca = b.ABI
WHERE b.nomeBanca = 'Intesa San Paolo';


--2. Seleziona il numero totale di conti per ogni banca, con un raggruppamento per banca:
SELECT b.nomeBanca AS Banca, COUNT(c.numeroConto) AS TotaleConti
FROM banca b
JOIN cliente cl ON b.ABI = cl.codiceBanca
JOIN conto c ON cl.CF = c.titolare
GROUP BY b.nomeBanca;


--3. Conta il numero di transazioni effettuate dal cliente e calcola il totale degli importi delle transazioni: 

SELECT c.CF, c.nome, c.cognome, COUNT(*) AS num_transazioni, SUM(t.importo) AS totale_transazioni
FROM cliente c
INNER JOIN conto co ON c.CF = co.titolare
INNER JOIN transazione t ON co.numeroConto = t.numeroContoSender
GROUP BY c.CF, c.nome, c.cognome
HAVING COUNT(*) > 2 AND SUM(t.importo) > 1000;

--4. Seleziona il totale delle transazioni per ogni conto inviante (Sender) con un saldo superiore a 1000 euro, utilizzando HAVING e creando un INDICE: 
DROP INDEX IF EXISTS idx_saldo_conto;
CREATE INDEX idx_saldo_conto ON conto(saldo);

SELECT t.numeroContoSender, COUNT(*) AS TotaleTransazioni
FROM transazione AS t
JOIN conto c ON t.numeroContoSender = c.numeroConto
GROUP BY t.numeroContoSender
HAVING MAX(c.saldo) > 1000.00;


--5. Seleziona il numero di dipendenti per ogni filiale specificando l'indirizzo:
SELECT indirizzo.citta, indirizzo.via, indirizzo.numero, 
	COUNT(dipendente.cf) AS numero_dipendenti, filiale.cab, banca.nomebanca 
FROM dipendente 
JOIN filiale ON (filiale.cab = dipendente.codicefiliale) 
JOIN indirizzo ON (filiale.cab = indirizzo.cab) 
JOIN banca ON (filiale.codicebanca = banca.abi)
GROUP BY indirizzo.citta, indirizzo.via, indirizzo.numero, filiale.cab, banca.nomebanca;


--6. Seleziona lo stipendio per ogni dipendente:
SELECT nome, cognome, tipocontratto, ruolo, stipendiomensile
FROM dipendente JOIN contratto ON (contratto.titolare = dipendente.cf)
ORDER BY stipendiomensile DESC;

--7. Seleziona l'IBAN, la filiale e il nome della banca con relativo indirizzo a cui si devono riferire i clienti:
DROP VIEW IF EXISTS cliente_conto;
DROP VIEW IF EXISTS filiale_indirizzo;

CREATE VIEW cliente_conto AS (SELECT cliente.nome, cliente.cognome, conto.iban, conto.codiceFiliale, banca.nomeBanca
	FROM cliente JOIN conto ON (cliente.cf = conto.titolare AND cliente.codiceBanca = conto.codiceBanca)
	JOIN banca ON (cliente.codiceBanca = banca.ABI));

CREATE VIEW filiale_indirizzo AS (SELECT filiale.cab, indirizzo.via, indirizzo.numero, indirizzo.citta, indirizzo.cap
	FROM filiale JOIN indirizzo ON (filiale.cab = indirizzo.cab));

SELECT co.nome, co.cognome, co.iban, co.nomeBanca, fi.citta, fi.via, fi.numero
FROM cliente_conto AS co, filiale_indirizzo AS fi
WHERE fi.cab = co.codiceFiliale;

