-- =====================================================================
-- PetVida (Clínica Veterinária e Pet Shop) - versão MySQL 8.0+
-- Script único: cria o banco, as 14 tabelas e insere os dados.
-- Para gerar o diagrama: MySQL Workbench > Database > Reverse Engineer...
-- =====================================================================

DROP DATABASE IF EXISTS petvida;
CREATE DATABASE petvida CHARACTER SET utf8mb4;
USE petvida;

-- ---------------------------------------------------------------------
-- Tabelas de apoio
-- ---------------------------------------------------------------------
CREATE TABLE especie (
    id_especie   INT AUTO_INCREMENT PRIMARY KEY,
    nome         VARCHAR(40) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE raca (
    id_raca      INT AUTO_INCREMENT PRIMARY KEY,
    nome         VARCHAR(60) NOT NULL,
    id_especie   INT NOT NULL,
    CONSTRAINT fk_raca_especie FOREIGN KEY (id_especie) REFERENCES especie (id_especie),
    CONSTRAINT uq_raca_nome_especie UNIQUE (nome, id_especie)
) ENGINE=InnoDB;

CREATE TABLE especialidade (
    id_especialidade INT AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Tutores e animais
-- ---------------------------------------------------------------------
CREATE TABLE tutor (
    id_tutor       INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    cpf            CHAR(11)     NOT NULL UNIQUE,
    telefone       VARCHAR(15),
    email          VARCHAR(100) UNIQUE,
    cidade         VARCHAR(60)  NOT NULL,
    data_cadastro  DATE         NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE animal (
    id_animal        INT AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(60)  NOT NULL,
    data_nascimento  DATE         NOT NULL,
    sexo             CHAR(1)      NOT NULL,
    peso_kg          DECIMAL(6,2) NOT NULL,
    id_tutor         INT          NOT NULL,
    id_raca          INT          NOT NULL,
    CONSTRAINT fk_animal_tutor FOREIGN KEY (id_tutor) REFERENCES tutor (id_tutor),
    CONSTRAINT fk_animal_raca  FOREIGN KEY (id_raca)  REFERENCES raca (id_raca),
    CONSTRAINT ck_animal_sexo CHECK (sexo IN ('M', 'F')),
    CONSTRAINT ck_animal_peso CHECK (peso_kg > 0)
) ENGINE=InnoDB;

-- Relacionamento 1:1 com animal (a PK também é FK)
CREATE TABLE microchip (
    id_animal      INT PRIMARY KEY,
    numero         CHAR(15) NOT NULL UNIQUE,
    data_implante  DATE     NOT NULL,
    CONSTRAINT fk_microchip_animal FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Veterinários
-- ---------------------------------------------------------------------
CREATE TABLE veterinario (
    id_veterinario  INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    crmv            VARCHAR(15)  NOT NULL UNIQUE,
    telefone        VARCHAR(15),
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- N:N veterinário x especialidade
CREATE TABLE veterinario_especialidade (
    id_veterinario   INT NOT NULL,
    id_especialidade INT NOT NULL,
    CONSTRAINT pk_veterinario_especialidade PRIMARY KEY (id_veterinario, id_especialidade),
    CONSTRAINT fk_ve_veterinario   FOREIGN KEY (id_veterinario)   REFERENCES veterinario (id_veterinario)
        ON DELETE CASCADE,
    CONSTRAINT fk_ve_especialidade FOREIGN KEY (id_especialidade) REFERENCES especialidade (id_especialidade)
) ENGINE=InnoDB;

-- Dias de atendimento (fato independente das especialidades -> 4FN)
CREATE TABLE veterinario_dia_atendimento (
    id_veterinario  INT     NOT NULL,
    dia_semana      CHAR(3) NOT NULL,
    CONSTRAINT pk_veterinario_dia PRIMARY KEY (id_veterinario, dia_semana),
    CONSTRAINT fk_vd_veterinario FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_veterinario)
        ON DELETE CASCADE,
    CONSTRAINT ck_vd_dia CHECK (dia_semana IN ('SEG','TER','QUA','QUI','SEX','SAB','DOM'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Atendimento clínico
-- ---------------------------------------------------------------------
CREATE TABLE consulta (
    id_consulta     INT AUTO_INCREMENT PRIMARY KEY,
    data_hora       DATETIME      NOT NULL,
    motivo          VARCHAR(150)  NOT NULL,
    diagnostico     VARCHAR(200),
    valor           DECIMAL(8,2)  NOT NULL,
    status          VARCHAR(10)   NOT NULL DEFAULT 'AGENDADA',
    id_animal       INT           NOT NULL,
    id_veterinario  INT           NOT NULL,
    CONSTRAINT fk_consulta_animal      FOREIGN KEY (id_animal)      REFERENCES animal (id_animal),
    CONSTRAINT fk_consulta_veterinario FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_veterinario),
    CONSTRAINT ck_consulta_valor  CHECK (valor >= 0),
    CONSTRAINT ck_consulta_status CHECK (status IN ('AGENDADA','REALIZADA','CANCELADA'))
) ENGINE=InnoDB;

CREATE TABLE medicamento (
    id_medicamento  INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(80)  NOT NULL UNIQUE,
    fabricante      VARCHAR(60)  NOT NULL,
    preco_unitario  DECIMAL(8,2) NOT NULL,
    estoque         INT          NOT NULL DEFAULT 0,
    CONSTRAINT ck_medicamento_preco   CHECK (preco_unitario >= 0),
    CONSTRAINT ck_medicamento_estoque CHECK (estoque >= 0)
) ENGINE=InnoDB;

-- N:N consulta x medicamento
CREATE TABLE consulta_medicamento (
    id_consulta     INT          NOT NULL,
    id_medicamento  INT          NOT NULL,
    quantidade      INT          NOT NULL,
    posologia       VARCHAR(100) NOT NULL,
    CONSTRAINT pk_consulta_medicamento PRIMARY KEY (id_consulta, id_medicamento),
    CONSTRAINT fk_cm_consulta    FOREIGN KEY (id_consulta)    REFERENCES consulta (id_consulta)
        ON DELETE CASCADE,
    CONSTRAINT fk_cm_medicamento FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento),
    CONSTRAINT ck_cm_quantidade CHECK (quantidade > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Vacinação
-- ---------------------------------------------------------------------
CREATE TABLE vacina (
    id_vacina              INT AUTO_INCREMENT PRIMARY KEY,
    nome                   VARCHAR(60)  NOT NULL UNIQUE,
    doenca_alvo            VARCHAR(120) NOT NULL,
    intervalo_reforco_dias INT          NOT NULL,
    preco                  DECIMAL(8,2) NOT NULL,
    CONSTRAINT ck_vacina_intervalo CHECK (intervalo_reforco_dias > 0),
    CONSTRAINT ck_vacina_preco     CHECK (preco >= 0)
) ENGINE=InnoDB;

-- N:N animal x vacina (cada linha é uma aplicação)
CREATE TABLE aplicacao_vacina (
    id_aplicacao    INT AUTO_INCREMENT PRIMARY KEY,
    id_animal       INT         NOT NULL,
    id_vacina       INT         NOT NULL,
    id_veterinario  INT         NOT NULL,
    data_aplicacao  DATE        NOT NULL,
    lote            VARCHAR(20) NOT NULL,
    CONSTRAINT fk_av_animal      FOREIGN KEY (id_animal)      REFERENCES animal (id_animal),
    CONSTRAINT fk_av_vacina      FOREIGN KEY (id_vacina)      REFERENCES vacina (id_vacina),
    CONSTRAINT fk_av_veterinario FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_veterinario),
    CONSTRAINT uq_av_animal_vacina_data UNIQUE (id_animal, id_vacina, data_aplicacao)
) ENGINE=InnoDB;

CREATE INDEX idx_consulta_data ON consulta (data_hora);

-- ---------------------------------------------------------------------
-- Dados (mínimo de 5 registros por tabela)
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- especie (5)
-- ---------------------------------------------------------------------
INSERT INTO especie (nome) VALUES
    ('Cão'),        -- 1
    ('Gato'),       -- 2
    ('Coelho'),     -- 3
    ('Ave'),        -- 4
    ('Roedor');     -- 5

-- ---------------------------------------------------------------------
-- raca (10)
-- ---------------------------------------------------------------------
INSERT INTO raca (nome, id_especie) VALUES
    ('Labrador',           1),  -- 1
    ('Poodle',             1),  -- 2
    ('Shih Tzu',           1),  -- 3
    ('Sem raça definida',  1),  -- 4
    ('Siamês',             2),  -- 5
    ('Persa',              2),  -- 6
    ('Sem raça definida',  2),  -- 7
    ('Mini Lop',           3),  -- 8
    ('Calopsita',          4),  -- 9
    ('Hamster Sírio',      5);  -- 10

-- ---------------------------------------------------------------------
-- especialidade (5)
-- ---------------------------------------------------------------------
INSERT INTO especialidade (nome) VALUES
    ('Clínica Geral'),     -- 1
    ('Cardiologia'),       -- 2
    ('Dermatologia'),      -- 3
    ('Ortopedia'),         -- 4
    ('Animais Exóticos');  -- 5

-- ---------------------------------------------------------------------
-- tutor (6)
-- ---------------------------------------------------------------------
INSERT INTO tutor (nome, cpf, telefone, email, cidade, data_cadastro) VALUES
    ('Ana Beatriz Souza',   '11122233301', '(11) 98111-0001', 'ana.souza@email.com',     'São Paulo',   '2024-02-10'),  -- 1
    ('Carlos Eduardo Lima', '11122233302', '(11) 98111-0002', 'carlos.lima@email.com',   'Guarulhos',   '2024-05-21'),  -- 2
    ('Mariana Ferreira',    '11122233303', '(11) 98111-0003', 'mariana.f@email.com',     'Osasco',      '2024-08-03'),  -- 3
    ('João Pedro Alves',    '11122233304', '(11) 98111-0004', 'joao.alves@email.com',    'São Paulo',   '2025-01-15'),  -- 4
    ('Fernanda Oliveira',   '11122233305', '(11) 98111-0005', 'fernanda.o@email.com',    'Santo André', '2025-04-09'),  -- 5
    ('Ricardo Gomes',       '11122233306', '(11) 98111-0006', 'ricardo.gomes@email.com', 'São Paulo',   '2025-09-30');  -- 6

-- ---------------------------------------------------------------------
-- animal (10)
-- ---------------------------------------------------------------------
INSERT INTO animal (nome, data_nascimento, sexo, peso_kg, id_tutor, id_raca) VALUES
    ('Thor',    '2019-03-10', 'M', 32.50, 1, 1),   -- 1  Labrador, tutora Ana
    ('Mel',     '2020-07-22', 'F',  6.80, 1, 2),   -- 2  Poodle, tutora Ana
    ('Luna',    '2021-01-15', 'F',  4.20, 2, 5),   -- 3  Siamês, tutor Carlos
    ('Bob',     '2018-11-05', 'M',  9.10, 3, 3),   -- 4  Shih Tzu, tutora Mariana
    ('Mimi',    '2022-05-30', 'F',  3.90, 4, 7),   -- 5  Gata SRD, tutor João
    ('Nina',    '2023-02-14', 'F',  5.30, 5, 6),   -- 6  Persa, tutora Fernanda
    ('Pipoca',  '2023-09-01', 'F',  1.80, 6, 8),   -- 7  Coelho Mini Lop, tutor Ricardo
    ('Rex',     '2017-06-18', 'M', 28.00, 3, 4),   -- 8  Cão SRD, tutora Mariana
    ('Tico',    '2024-01-20', 'M',  0.09, 5, 9),   -- 9  Calopsita, tutora Fernanda
    ('Bolinha', '2025-03-03', 'M',  0.12, 4, 10);  -- 10 Hamster, tutor João

-- ---------------------------------------------------------------------
-- microchip (5)  -- relacionamento 1:1 com animal
-- ---------------------------------------------------------------------
INSERT INTO microchip (id_animal, numero, data_implante) VALUES
    (1, '985112000000001', '2019-05-02'),
    (2, '985112000000002', '2020-09-15'),
    (3, '985112000000003', '2021-03-20'),
    (4, '985112000000004', '2019-01-10'),
    (8, '985112000000008', '2017-09-01');

-- ---------------------------------------------------------------------
-- veterinario (5)
-- ---------------------------------------------------------------------
INSERT INTO veterinario (nome, crmv, telefone, ativo) VALUES
    ('Dra. Helena Martins', 'CRMV-SP 12345', '(11) 97000-0001', TRUE),  -- 1
    ('Dr. Paulo Ribeiro',   'CRMV-SP 23456', '(11) 97000-0002', TRUE),  -- 2
    ('Dra. Camila Torres',  'CRMV-SP 34567', '(11) 97000-0003', TRUE),  -- 3
    ('Dr. Marcos Vieira',   'CRMV-SP 45678', '(11) 97000-0004', TRUE),  -- 4
    ('Dra. Juliana Prado',  'CRMV-SP 56789', '(11) 97000-0005', TRUE);  -- 5

-- ---------------------------------------------------------------------
-- veterinario_especialidade (7)
-- ---------------------------------------------------------------------
INSERT INTO veterinario_especialidade (id_veterinario, id_especialidade) VALUES
    (1, 1),   -- Helena: Clínica Geral
    (2, 2),   -- Paulo:  Cardiologia
    (2, 1),   -- Paulo:  Clínica Geral
    (3, 3),   -- Camila: Dermatologia
    (4, 4),   -- Marcos: Ortopedia
    (5, 5),   -- Juliana: Animais Exóticos
    (5, 1);   -- Juliana: Clínica Geral

-- ---------------------------------------------------------------------
-- veterinario_dia_atendimento (11)
-- ---------------------------------------------------------------------
INSERT INTO veterinario_dia_atendimento (id_veterinario, dia_semana) VALUES
    (1, 'SEG'), (1, 'QUA'), (1, 'SEX'),
    (2, 'TER'), (2, 'QUI'),
    (3, 'SEG'), (3, 'QUI'),
    (4, 'QUA'), (4, 'SEX'),
    (5, 'TER'), (5, 'SAB');

-- ---------------------------------------------------------------------
-- consulta (16)
-- ---------------------------------------------------------------------
INSERT INTO consulta (data_hora, motivo, diagnostico, valor, status, id_animal, id_veterinario) VALUES
    ('2026-01-12 09:00', 'Check-up anual',               'Animal saudável',            150.00, 'REALIZADA', 1, 1),   -- 1
    ('2026-01-12 10:30', 'Coceira intensa',              'Dermatite alérgica',         220.00, 'REALIZADA', 2, 3),   -- 2
    ('2026-02-03 14:00', 'Cansaço ao brincar',           'Sopro cardíaco leve',        350.00, 'REALIZADA', 3, 2),   -- 3
    ('2026-02-17 11:00', 'Mancando da pata traseira',    'Displasia coxofemoral',      400.00, 'REALIZADA', 4, 4),   -- 4
    ('2026-03-05 15:30', 'Vômitos frequentes',           'Gastrite',                   180.00, 'REALIZADA', 5, 1),   -- 5
    ('2026-03-20 09:30', 'Check-up anual',               'Animal saudável',            150.00, 'REALIZADA', 6, 1),   -- 6
    ('2026-04-08 16:00', 'Perda de apetite',             'Má oclusão dentária',        280.00, 'REALIZADA', 7, 5),   -- 7
    ('2026-04-22 10:00', 'Dificuldade ao levantar',      'Artrose',                    380.00, 'REALIZADA', 8, 4),   -- 8
    ('2026-05-14 08:30', 'Balançar de cabeça e dor',     'Otite externa',              210.00, 'REALIZADA', 1, 3),   -- 9
    ('2026-06-02 14:30', 'Penas arrepiadas e espirros',  'Infecção respiratória',      260.00, 'REALIZADA', 9, 5),   -- 10
    ('2026-07-15 09:00', 'Retorno - dermatite',          'Melhora clínica',            120.00, 'REALIZADA', 2, 3),   -- 11
    ('2026-08-11 11:30', 'Diarreia',                     'Gastroenterite leve',        240.00, 'REALIZADA', 10, 5),  -- 12
    ('2026-09-09 13:00', 'Retorno - gastrite',           'Recuperada',                 120.00, 'REALIZADA', 5, 1),   -- 13
    ('2026-10-06 10:00', 'Retorno - cardiologia',        'Quadro estável',             300.00, 'REALIZADA', 3, 2),   -- 14
    ('2026-09-23 15:00', 'Reavaliação ortopédica',       NULL,                         200.00, 'CANCELADA', 8, 4),   -- 15
    ('2026-11-05 09:00', 'Reavaliação ortopédica',       NULL,                         200.00, 'AGENDADA',  4, 4);   -- 16

-- ---------------------------------------------------------------------
-- medicamento (7)
-- ---------------------------------------------------------------------
INSERT INTO medicamento (nome, fabricante, preco_unitario, estoque) VALUES
    ('Amoxicilina 250 mg',     'VetFarma',  32.90, 120),   -- 1
    ('Prednisolona 20 mg',     'BioPet',    28.50,  80),   -- 2
    ('Omeprazol 10 mg',        'PetSaúde',  24.00,  60),   -- 3
    ('Enalapril 5 mg',         'CardioVet', 45.90,  40),   -- 4
    ('Meloxicam 1 mg',         'OrtoVet',   38.00,  90),   -- 5
    ('Gotas otológicas 20 ml', 'DermaCare', 41.50,  35),   -- 6
    ('Probiótico oral',        'NutriPet',  29.90,  50);   -- 7

-- ---------------------------------------------------------------------
-- consulta_medicamento (11)
-- ---------------------------------------------------------------------
INSERT INTO consulta_medicamento (id_consulta, id_medicamento, quantidade, posologia) VALUES
    (2,  2, 10, '1 comprimido a cada 12h por 5 dias'),
    (3,  4, 30, '1 comprimido a cada 24h por 30 dias'),
    (4,  5, 15, '1 comprimido a cada 24h por 15 dias'),
    (5,  3, 14, '1 comprimido a cada 24h por 14 dias'),
    (5,  7,  7, '1 dose ao dia por 7 dias'),
    (7,  7, 10, '1 dose ao dia por 10 dias'),
    (8,  5, 20, '1 comprimido a cada 24h por 20 dias'),
    (9,  6,  1, '5 gotas em cada ouvido, 2x ao dia por 10 dias'),
    (9,  1, 14, '1 comprimido a cada 12h por 7 dias'),
    (10, 1, 14, '1 comprimido a cada 12h por 7 dias'),
    (14, 4, 30, '1 comprimido a cada 24h por 30 dias');

-- ---------------------------------------------------------------------
-- vacina (5)
-- ---------------------------------------------------------------------
INSERT INTO vacina (nome, doenca_alvo, intervalo_reforco_dias, preco) VALUES
    ('V10 Múltipla Canina', 'Cinomose, parvovirose, hepatite, leptospirose e outras', 365,  95.00),  -- 1
    ('Antirrábica',         'Raiva',                                                  365,  60.00),  -- 2
    ('V4 Felina',           'Rinotraqueíte, calicivirose e panleucopenia',            365,  90.00),  -- 3
    ('Giárdia',             'Giardíase',                                              365,  85.00),  -- 4
    ('Leishmaniose',        'Leishmaniose visceral canina',                           365, 150.00);  -- 5

-- ---------------------------------------------------------------------
-- aplicacao_vacina (12)
-- ---------------------------------------------------------------------
INSERT INTO aplicacao_vacina (id_animal, id_vacina, id_veterinario, data_aplicacao, lote) VALUES
    (1, 1, 1, '2026-01-12', 'L2025A01'),
    (1, 2, 1, '2026-01-12', 'R2025B07'),
    (2, 1, 3, '2026-01-12', 'L2025A02'),
    (3, 3, 2, '2026-02-03', 'F2025C11'),
    (4, 2, 1, '2026-03-05', 'R2025B08'),
    (5, 3, 1, '2026-03-05', 'F2025C12'),
    (6, 3, 1, '2026-03-20', 'F2025C12'),
    (6, 2, 1, '2026-03-20', 'R2025B08'),
    (8, 2, 4, '2026-04-22', 'R2025B09'),
    (8, 1, 4, '2026-04-22', 'L2025A03'),
    (2, 5, 3, '2026-07-15', 'LM2026D01'),
    (4, 1, 1, '2026-03-05', 'L2025A02');
