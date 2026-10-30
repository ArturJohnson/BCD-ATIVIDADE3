--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.veterinario_especialidade DROP CONSTRAINT IF EXISTS fk_ve_veterinario;
ALTER TABLE IF EXISTS ONLY public.veterinario_especialidade DROP CONSTRAINT IF EXISTS fk_ve_especialidade;
ALTER TABLE IF EXISTS ONLY public.veterinario_dia_atendimento DROP CONSTRAINT IF EXISTS fk_vd_veterinario;
ALTER TABLE IF EXISTS ONLY public.raca DROP CONSTRAINT IF EXISTS fk_raca_especie;
ALTER TABLE IF EXISTS ONLY public.microchip DROP CONSTRAINT IF EXISTS fk_microchip_animal;
ALTER TABLE IF EXISTS ONLY public.consulta DROP CONSTRAINT IF EXISTS fk_consulta_veterinario;
ALTER TABLE IF EXISTS ONLY public.consulta DROP CONSTRAINT IF EXISTS fk_consulta_animal;
ALTER TABLE IF EXISTS ONLY public.consulta_medicamento DROP CONSTRAINT IF EXISTS fk_cm_medicamento;
ALTER TABLE IF EXISTS ONLY public.consulta_medicamento DROP CONSTRAINT IF EXISTS fk_cm_consulta;
ALTER TABLE IF EXISTS ONLY public.aplicacao_vacina DROP CONSTRAINT IF EXISTS fk_av_veterinario;
ALTER TABLE IF EXISTS ONLY public.aplicacao_vacina DROP CONSTRAINT IF EXISTS fk_av_vacina;
ALTER TABLE IF EXISTS ONLY public.aplicacao_vacina DROP CONSTRAINT IF EXISTS fk_av_animal;
ALTER TABLE IF EXISTS ONLY public.animal DROP CONSTRAINT IF EXISTS fk_animal_tutor;
ALTER TABLE IF EXISTS ONLY public.animal DROP CONSTRAINT IF EXISTS fk_animal_raca;
DROP INDEX IF EXISTS public.idx_consulta_veterinario;
DROP INDEX IF EXISTS public.idx_consulta_data;
DROP INDEX IF EXISTS public.idx_consulta_animal;
DROP INDEX IF EXISTS public.idx_av_animal;
DROP INDEX IF EXISTS public.idx_animal_tutor;
DROP INDEX IF EXISTS public.idx_animal_raca;
ALTER TABLE IF EXISTS ONLY public.veterinario DROP CONSTRAINT IF EXISTS veterinario_pkey;
ALTER TABLE IF EXISTS ONLY public.veterinario DROP CONSTRAINT IF EXISTS veterinario_crmv_key;
ALTER TABLE IF EXISTS ONLY public.vacina DROP CONSTRAINT IF EXISTS vacina_pkey;
ALTER TABLE IF EXISTS ONLY public.vacina DROP CONSTRAINT IF EXISTS vacina_nome_key;
ALTER TABLE IF EXISTS ONLY public.raca DROP CONSTRAINT IF EXISTS uq_raca_nome_especie;
ALTER TABLE IF EXISTS ONLY public.aplicacao_vacina DROP CONSTRAINT IF EXISTS uq_av_animal_vacina_data;
ALTER TABLE IF EXISTS ONLY public.tutor DROP CONSTRAINT IF EXISTS tutor_pkey;
ALTER TABLE IF EXISTS ONLY public.tutor DROP CONSTRAINT IF EXISTS tutor_email_key;
ALTER TABLE IF EXISTS ONLY public.tutor DROP CONSTRAINT IF EXISTS tutor_cpf_key;
ALTER TABLE IF EXISTS ONLY public.raca DROP CONSTRAINT IF EXISTS raca_pkey;
ALTER TABLE IF EXISTS ONLY public.veterinario_especialidade DROP CONSTRAINT IF EXISTS pk_veterinario_especialidade;
ALTER TABLE IF EXISTS ONLY public.veterinario_dia_atendimento DROP CONSTRAINT IF EXISTS pk_veterinario_dia;
ALTER TABLE IF EXISTS ONLY public.consulta_medicamento DROP CONSTRAINT IF EXISTS pk_consulta_medicamento;
ALTER TABLE IF EXISTS ONLY public.microchip DROP CONSTRAINT IF EXISTS microchip_pkey;
ALTER TABLE IF EXISTS ONLY public.microchip DROP CONSTRAINT IF EXISTS microchip_numero_key;
ALTER TABLE IF EXISTS ONLY public.medicamento DROP CONSTRAINT IF EXISTS medicamento_pkey;
ALTER TABLE IF EXISTS ONLY public.medicamento DROP CONSTRAINT IF EXISTS medicamento_nome_key;
ALTER TABLE IF EXISTS ONLY public.especie DROP CONSTRAINT IF EXISTS especie_pkey;
ALTER TABLE IF EXISTS ONLY public.especie DROP CONSTRAINT IF EXISTS especie_nome_key;
ALTER TABLE IF EXISTS ONLY public.especialidade DROP CONSTRAINT IF EXISTS especialidade_pkey;
ALTER TABLE IF EXISTS ONLY public.especialidade DROP CONSTRAINT IF EXISTS especialidade_nome_key;
ALTER TABLE IF EXISTS ONLY public.consulta DROP CONSTRAINT IF EXISTS consulta_pkey;
ALTER TABLE IF EXISTS ONLY public.aplicacao_vacina DROP CONSTRAINT IF EXISTS aplicacao_vacina_pkey;
ALTER TABLE IF EXISTS ONLY public.animal DROP CONSTRAINT IF EXISTS animal_pkey;
DROP TABLE IF EXISTS public.veterinario_especialidade;
DROP TABLE IF EXISTS public.veterinario_dia_atendimento;
DROP TABLE IF EXISTS public.veterinario;
DROP TABLE IF EXISTS public.vacina;
DROP TABLE IF EXISTS public.tutor;
DROP TABLE IF EXISTS public.raca;
DROP TABLE IF EXISTS public.microchip;
DROP TABLE IF EXISTS public.medicamento;
DROP TABLE IF EXISTS public.especie;
DROP TABLE IF EXISTS public.especialidade;
DROP TABLE IF EXISTS public.consulta_medicamento;
DROP TABLE IF EXISTS public.consulta;
DROP TABLE IF EXISTS public.aplicacao_vacina;
DROP TABLE IF EXISTS public.animal;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: animal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.animal (
    id_animal integer NOT NULL,
    nome character varying(60) NOT NULL,
    data_nascimento date NOT NULL,
    sexo character(1) NOT NULL,
    peso_kg numeric(6,2) NOT NULL,
    id_tutor integer NOT NULL,
    id_raca integer NOT NULL,
    CONSTRAINT ck_animal_peso CHECK ((peso_kg > (0)::numeric)),
    CONSTRAINT ck_animal_sexo CHECK ((sexo = ANY (ARRAY['M'::bpchar, 'F'::bpchar])))
);


--
-- Name: animal_id_animal_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.animal ALTER COLUMN id_animal ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.animal_id_animal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: aplicacao_vacina; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aplicacao_vacina (
    id_aplicacao integer NOT NULL,
    id_animal integer NOT NULL,
    id_vacina integer NOT NULL,
    id_veterinario integer NOT NULL,
    data_aplicacao date NOT NULL,
    lote character varying(20) NOT NULL
);


--
-- Name: aplicacao_vacina_id_aplicacao_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.aplicacao_vacina ALTER COLUMN id_aplicacao ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.aplicacao_vacina_id_aplicacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consulta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consulta (
    id_consulta integer NOT NULL,
    data_hora timestamp without time zone NOT NULL,
    motivo character varying(150) NOT NULL,
    diagnostico character varying(200),
    valor numeric(8,2) NOT NULL,
    status character varying(10) DEFAULT 'AGENDADA'::character varying NOT NULL,
    id_animal integer NOT NULL,
    id_veterinario integer NOT NULL,
    CONSTRAINT ck_consulta_status CHECK (((status)::text = ANY ((ARRAY['AGENDADA'::character varying, 'REALIZADA'::character varying, 'CANCELADA'::character varying])::text[]))),
    CONSTRAINT ck_consulta_valor CHECK ((valor >= (0)::numeric))
);


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.consulta ALTER COLUMN id_consulta ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.consulta_id_consulta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: consulta_medicamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consulta_medicamento (
    id_consulta integer NOT NULL,
    id_medicamento integer NOT NULL,
    quantidade integer NOT NULL,
    posologia character varying(100) NOT NULL,
    CONSTRAINT ck_cm_quantidade CHECK ((quantidade > 0))
);


--
-- Name: especialidade; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.especialidade (
    id_especialidade integer NOT NULL,
    nome character varying(60) NOT NULL
);


--
-- Name: especialidade_id_especialidade_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.especialidade ALTER COLUMN id_especialidade ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.especialidade_id_especialidade_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: especie; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.especie (
    id_especie integer NOT NULL,
    nome character varying(40) NOT NULL
);


--
-- Name: especie_id_especie_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.especie ALTER COLUMN id_especie ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.especie_id_especie_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: medicamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medicamento (
    id_medicamento integer NOT NULL,
    nome character varying(80) NOT NULL,
    fabricante character varying(60) NOT NULL,
    preco_unitario numeric(8,2) NOT NULL,
    estoque integer DEFAULT 0 NOT NULL,
    CONSTRAINT ck_medicamento_estoque CHECK ((estoque >= 0)),
    CONSTRAINT ck_medicamento_preco CHECK ((preco_unitario >= (0)::numeric))
);


--
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.medicamento ALTER COLUMN id_medicamento ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.medicamento_id_medicamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: microchip; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.microchip (
    id_animal integer NOT NULL,
    numero character(15) NOT NULL,
    data_implante date NOT NULL
);


--
-- Name: raca; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.raca (
    id_raca integer NOT NULL,
    nome character varying(60) NOT NULL,
    id_especie integer NOT NULL
);


--
-- Name: raca_id_raca_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.raca ALTER COLUMN id_raca ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.raca_id_raca_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tutor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tutor (
    id_tutor integer NOT NULL,
    nome character varying(100) NOT NULL,
    cpf character(11) NOT NULL,
    telefone character varying(15),
    email character varying(100),
    cidade character varying(60) NOT NULL,
    data_cadastro date DEFAULT CURRENT_DATE NOT NULL
);


--
-- Name: tutor_id_tutor_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tutor ALTER COLUMN id_tutor ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tutor_id_tutor_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vacina; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vacina (
    id_vacina integer NOT NULL,
    nome character varying(60) NOT NULL,
    doenca_alvo character varying(120) NOT NULL,
    intervalo_reforco_dias integer NOT NULL,
    preco numeric(8,2) NOT NULL,
    CONSTRAINT ck_vacina_intervalo CHECK ((intervalo_reforco_dias > 0)),
    CONSTRAINT ck_vacina_preco CHECK ((preco >= (0)::numeric))
);


--
-- Name: vacina_id_vacina_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.vacina ALTER COLUMN id_vacina ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.vacina_id_vacina_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: veterinario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.veterinario (
    id_veterinario integer NOT NULL,
    nome character varying(100) NOT NULL,
    crmv character varying(15) NOT NULL,
    telefone character varying(15),
    ativo boolean DEFAULT true NOT NULL
);


--
-- Name: veterinario_dia_atendimento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.veterinario_dia_atendimento (
    id_veterinario integer NOT NULL,
    dia_semana character(3) NOT NULL,
    CONSTRAINT ck_vd_dia CHECK ((dia_semana = ANY (ARRAY['SEG'::bpchar, 'TER'::bpchar, 'QUA'::bpchar, 'QUI'::bpchar, 'SEX'::bpchar, 'SAB'::bpchar, 'DOM'::bpchar])))
);


--
-- Name: veterinario_especialidade; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.veterinario_especialidade (
    id_veterinario integer NOT NULL,
    id_especialidade integer NOT NULL
);


--
-- Name: veterinario_id_veterinario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.veterinario ALTER COLUMN id_veterinario ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.veterinario_id_veterinario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: animal; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.animal VALUES (1, 'Thor', '2019-03-10', 'M', 32.50, 1, 1);
INSERT INTO public.animal VALUES (2, 'Mel', '2020-07-22', 'F', 6.80, 1, 2);
INSERT INTO public.animal VALUES (3, 'Luna', '2021-01-15', 'F', 4.20, 2, 5);
INSERT INTO public.animal VALUES (4, 'Bob', '2018-11-05', 'M', 9.10, 3, 3);
INSERT INTO public.animal VALUES (5, 'Mimi', '2022-05-30', 'F', 3.90, 4, 7);
INSERT INTO public.animal VALUES (6, 'Nina', '2023-02-14', 'F', 5.30, 5, 6);
INSERT INTO public.animal VALUES (7, 'Pipoca', '2023-09-01', 'F', 1.80, 6, 8);
INSERT INTO public.animal VALUES (8, 'Rex', '2017-06-18', 'M', 28.00, 3, 4);
INSERT INTO public.animal VALUES (9, 'Tico', '2024-01-20', 'M', 0.09, 5, 9);
INSERT INTO public.animal VALUES (10, 'Bolinha', '2025-03-03', 'M', 0.12, 4, 10);


--
-- Data for Name: aplicacao_vacina; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.aplicacao_vacina VALUES (1, 1, 1, 1, '2026-01-12', 'L2025A01');
INSERT INTO public.aplicacao_vacina VALUES (2, 1, 2, 1, '2026-01-12', 'R2025B07');
INSERT INTO public.aplicacao_vacina VALUES (3, 2, 1, 3, '2026-01-12', 'L2025A02');
INSERT INTO public.aplicacao_vacina VALUES (4, 3, 3, 2, '2026-02-03', 'F2025C11');
INSERT INTO public.aplicacao_vacina VALUES (5, 4, 2, 1, '2026-03-05', 'R2025B08');
INSERT INTO public.aplicacao_vacina VALUES (6, 5, 3, 1, '2026-03-05', 'F2025C12');
INSERT INTO public.aplicacao_vacina VALUES (7, 6, 3, 1, '2026-03-20', 'F2025C12');
INSERT INTO public.aplicacao_vacina VALUES (8, 6, 2, 1, '2026-03-20', 'R2025B08');
INSERT INTO public.aplicacao_vacina VALUES (9, 8, 2, 4, '2026-04-22', 'R2025B09');
INSERT INTO public.aplicacao_vacina VALUES (10, 8, 1, 4, '2026-04-22', 'L2025A03');
INSERT INTO public.aplicacao_vacina VALUES (11, 2, 5, 3, '2026-07-15', 'LM2026D01');
INSERT INTO public.aplicacao_vacina VALUES (12, 4, 1, 1, '2026-03-05', 'L2025A02');


--
-- Data for Name: consulta; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.consulta VALUES (1, '2026-01-12 09:00:00', 'Check-up anual', 'Animal saudável', 150.00, 'REALIZADA', 1, 1);
INSERT INTO public.consulta VALUES (2, '2026-01-12 10:30:00', 'Coceira intensa', 'Dermatite alérgica', 220.00, 'REALIZADA', 2, 3);
INSERT INTO public.consulta VALUES (3, '2026-02-03 14:00:00', 'Cansaço ao brincar', 'Sopro cardíaco leve', 350.00, 'REALIZADA', 3, 2);
INSERT INTO public.consulta VALUES (4, '2026-02-17 11:00:00', 'Mancando da pata traseira', 'Displasia coxofemoral', 400.00, 'REALIZADA', 4, 4);
INSERT INTO public.consulta VALUES (5, '2026-03-05 15:30:00', 'Vômitos frequentes', 'Gastrite', 180.00, 'REALIZADA', 5, 1);
INSERT INTO public.consulta VALUES (6, '2026-03-20 09:30:00', 'Check-up anual', 'Animal saudável', 150.00, 'REALIZADA', 6, 1);
INSERT INTO public.consulta VALUES (7, '2026-04-08 16:00:00', 'Perda de apetite', 'Má oclusão dentária', 280.00, 'REALIZADA', 7, 5);
INSERT INTO public.consulta VALUES (8, '2026-04-22 10:00:00', 'Dificuldade ao levantar', 'Artrose', 380.00, 'REALIZADA', 8, 4);
INSERT INTO public.consulta VALUES (9, '2026-05-14 08:30:00', 'Balançar de cabeça e dor', 'Otite externa', 210.00, 'REALIZADA', 1, 3);
INSERT INTO public.consulta VALUES (10, '2026-06-02 14:30:00', 'Penas arrepiadas e espirros', 'Infecção respiratória', 260.00, 'REALIZADA', 9, 5);
INSERT INTO public.consulta VALUES (11, '2026-07-15 09:00:00', 'Retorno - dermatite', 'Melhora clínica', 120.00, 'REALIZADA', 2, 3);
INSERT INTO public.consulta VALUES (12, '2026-08-11 11:30:00', 'Diarreia', 'Gastroenterite leve', 240.00, 'REALIZADA', 10, 5);
INSERT INTO public.consulta VALUES (13, '2026-09-09 13:00:00', 'Retorno - gastrite', 'Recuperada', 120.00, 'REALIZADA', 5, 1);
INSERT INTO public.consulta VALUES (14, '2026-10-06 10:00:00', 'Retorno - cardiologia', 'Quadro estável', 300.00, 'REALIZADA', 3, 2);
INSERT INTO public.consulta VALUES (15, '2026-09-23 15:00:00', 'Reavaliação ortopédica', NULL, 200.00, 'CANCELADA', 8, 4);
INSERT INTO public.consulta VALUES (16, '2026-11-05 09:00:00', 'Reavaliação ortopédica', NULL, 200.00, 'AGENDADA', 4, 4);


--
-- Data for Name: consulta_medicamento; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.consulta_medicamento VALUES (2, 2, 10, '1 comprimido a cada 12h por 5 dias');
INSERT INTO public.consulta_medicamento VALUES (3, 4, 30, '1 comprimido a cada 24h por 30 dias');
INSERT INTO public.consulta_medicamento VALUES (4, 5, 15, '1 comprimido a cada 24h por 15 dias');
INSERT INTO public.consulta_medicamento VALUES (5, 3, 14, '1 comprimido a cada 24h por 14 dias');
INSERT INTO public.consulta_medicamento VALUES (5, 7, 7, '1 dose ao dia por 7 dias');
INSERT INTO public.consulta_medicamento VALUES (7, 7, 10, '1 dose ao dia por 10 dias');
INSERT INTO public.consulta_medicamento VALUES (8, 5, 20, '1 comprimido a cada 24h por 20 dias');
INSERT INTO public.consulta_medicamento VALUES (9, 6, 1, '5 gotas em cada ouvido, 2x ao dia por 10 dias');
INSERT INTO public.consulta_medicamento VALUES (9, 1, 14, '1 comprimido a cada 12h por 7 dias');
INSERT INTO public.consulta_medicamento VALUES (10, 1, 14, '1 comprimido a cada 12h por 7 dias');
INSERT INTO public.consulta_medicamento VALUES (14, 4, 30, '1 comprimido a cada 24h por 30 dias');


--
-- Data for Name: especialidade; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.especialidade VALUES (1, 'Clínica Geral');
INSERT INTO public.especialidade VALUES (2, 'Cardiologia');
INSERT INTO public.especialidade VALUES (3, 'Dermatologia');
INSERT INTO public.especialidade VALUES (4, 'Ortopedia');
INSERT INTO public.especialidade VALUES (5, 'Animais Exóticos');


--
-- Data for Name: especie; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.especie VALUES (1, 'Cão');
INSERT INTO public.especie VALUES (2, 'Gato');
INSERT INTO public.especie VALUES (3, 'Coelho');
INSERT INTO public.especie VALUES (4, 'Ave');
INSERT INTO public.especie VALUES (5, 'Roedor');


--
-- Data for Name: medicamento; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.medicamento VALUES (1, 'Amoxicilina 250 mg', 'VetFarma', 32.90, 120);
INSERT INTO public.medicamento VALUES (2, 'Prednisolona 20 mg', 'BioPet', 28.50, 80);
INSERT INTO public.medicamento VALUES (3, 'Omeprazol 10 mg', 'PetSaúde', 24.00, 60);
INSERT INTO public.medicamento VALUES (4, 'Enalapril 5 mg', 'CardioVet', 45.90, 40);
INSERT INTO public.medicamento VALUES (5, 'Meloxicam 1 mg', 'OrtoVet', 38.00, 90);
INSERT INTO public.medicamento VALUES (6, 'Gotas otológicas 20 ml', 'DermaCare', 41.50, 35);
INSERT INTO public.medicamento VALUES (7, 'Probiótico oral', 'NutriPet', 29.90, 50);


--
-- Data for Name: microchip; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.microchip VALUES (1, '985112000000001', '2019-05-02');
INSERT INTO public.microchip VALUES (2, '985112000000002', '2020-09-15');
INSERT INTO public.microchip VALUES (3, '985112000000003', '2021-03-20');
INSERT INTO public.microchip VALUES (4, '985112000000004', '2019-01-10');
INSERT INTO public.microchip VALUES (8, '985112000000008', '2017-09-01');


--
-- Data for Name: raca; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.raca VALUES (1, 'Labrador', 1);
INSERT INTO public.raca VALUES (2, 'Poodle', 1);
INSERT INTO public.raca VALUES (3, 'Shih Tzu', 1);
INSERT INTO public.raca VALUES (4, 'Sem raça definida', 1);
INSERT INTO public.raca VALUES (5, 'Siamês', 2);
INSERT INTO public.raca VALUES (6, 'Persa', 2);
INSERT INTO public.raca VALUES (7, 'Sem raça definida', 2);
INSERT INTO public.raca VALUES (8, 'Mini Lop', 3);
INSERT INTO public.raca VALUES (9, 'Calopsita', 4);
INSERT INTO public.raca VALUES (10, 'Hamster Sírio', 5);


--
-- Data for Name: tutor; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tutor VALUES (1, 'Ana Beatriz Souza', '11122233301', '(11) 98111-0001', 'ana.souza@email.com', 'São Paulo', '2024-02-10');
INSERT INTO public.tutor VALUES (2, 'Carlos Eduardo Lima', '11122233302', '(11) 98111-0002', 'carlos.lima@email.com', 'Guarulhos', '2024-05-21');
INSERT INTO public.tutor VALUES (3, 'Mariana Ferreira', '11122233303', '(11) 98111-0003', 'mariana.f@email.com', 'Osasco', '2024-08-03');
INSERT INTO public.tutor VALUES (4, 'João Pedro Alves', '11122233304', '(11) 98111-0004', 'joao.alves@email.com', 'São Paulo', '2025-01-15');
INSERT INTO public.tutor VALUES (5, 'Fernanda Oliveira', '11122233305', '(11) 98111-0005', 'fernanda.o@email.com', 'Santo André', '2025-04-09');
INSERT INTO public.tutor VALUES (6, 'Ricardo Gomes', '11122233306', '(11) 98111-0006', 'ricardo.gomes@email.com', 'São Paulo', '2025-09-30');


--
-- Data for Name: vacina; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vacina VALUES (1, 'V10 Múltipla Canina', 'Cinomose, parvovirose, hepatite, leptospirose e outras', 365, 95.00);
INSERT INTO public.vacina VALUES (2, 'Antirrábica', 'Raiva', 365, 60.00);
INSERT INTO public.vacina VALUES (3, 'V4 Felina', 'Rinotraqueíte, calicivirose e panleucopenia', 365, 90.00);
INSERT INTO public.vacina VALUES (4, 'Giárdia', 'Giardíase', 365, 85.00);
INSERT INTO public.vacina VALUES (5, 'Leishmaniose', 'Leishmaniose visceral canina', 365, 150.00);


--
-- Data for Name: veterinario; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.veterinario VALUES (1, 'Dra. Helena Martins', 'CRMV-SP 12345', '(11) 97000-0001', true);
INSERT INTO public.veterinario VALUES (2, 'Dr. Paulo Ribeiro', 'CRMV-SP 23456', '(11) 97000-0002', true);
INSERT INTO public.veterinario VALUES (3, 'Dra. Camila Torres', 'CRMV-SP 34567', '(11) 97000-0003', true);
INSERT INTO public.veterinario VALUES (4, 'Dr. Marcos Vieira', 'CRMV-SP 45678', '(11) 97000-0004', true);
INSERT INTO public.veterinario VALUES (5, 'Dra. Juliana Prado', 'CRMV-SP 56789', '(11) 97000-0005', true);


--
-- Data for Name: veterinario_dia_atendimento; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.veterinario_dia_atendimento VALUES (1, 'SEG');
INSERT INTO public.veterinario_dia_atendimento VALUES (1, 'QUA');
INSERT INTO public.veterinario_dia_atendimento VALUES (1, 'SEX');
INSERT INTO public.veterinario_dia_atendimento VALUES (2, 'TER');
INSERT INTO public.veterinario_dia_atendimento VALUES (2, 'QUI');
INSERT INTO public.veterinario_dia_atendimento VALUES (3, 'SEG');
INSERT INTO public.veterinario_dia_atendimento VALUES (3, 'QUI');
INSERT INTO public.veterinario_dia_atendimento VALUES (4, 'QUA');
INSERT INTO public.veterinario_dia_atendimento VALUES (4, 'SEX');
INSERT INTO public.veterinario_dia_atendimento VALUES (5, 'TER');
INSERT INTO public.veterinario_dia_atendimento VALUES (5, 'SAB');


--
-- Data for Name: veterinario_especialidade; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.veterinario_especialidade VALUES (1, 1);
INSERT INTO public.veterinario_especialidade VALUES (2, 2);
INSERT INTO public.veterinario_especialidade VALUES (2, 1);
INSERT INTO public.veterinario_especialidade VALUES (3, 3);
INSERT INTO public.veterinario_especialidade VALUES (4, 4);
INSERT INTO public.veterinario_especialidade VALUES (5, 5);
INSERT INTO public.veterinario_especialidade VALUES (5, 1);


--
-- Name: animal_id_animal_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.animal_id_animal_seq', 10, true);


--
-- Name: aplicacao_vacina_id_aplicacao_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.aplicacao_vacina_id_aplicacao_seq', 12, true);


--
-- Name: consulta_id_consulta_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.consulta_id_consulta_seq', 16, true);


--
-- Name: especialidade_id_especialidade_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.especialidade_id_especialidade_seq', 5, true);


--
-- Name: especie_id_especie_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.especie_id_especie_seq', 5, true);


--
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.medicamento_id_medicamento_seq', 7, true);


--
-- Name: raca_id_raca_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.raca_id_raca_seq', 10, true);


--
-- Name: tutor_id_tutor_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tutor_id_tutor_seq', 6, true);


--
-- Name: vacina_id_vacina_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vacina_id_vacina_seq', 5, true);


--
-- Name: veterinario_id_veterinario_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.veterinario_id_veterinario_seq', 5, true);


--
-- Name: animal animal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_pkey PRIMARY KEY (id_animal);


--
-- Name: aplicacao_vacina aplicacao_vacina_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aplicacao_vacina
    ADD CONSTRAINT aplicacao_vacina_pkey PRIMARY KEY (id_aplicacao);


--
-- Name: consulta consulta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT consulta_pkey PRIMARY KEY (id_consulta);


--
-- Name: especialidade especialidade_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.especialidade
    ADD CONSTRAINT especialidade_nome_key UNIQUE (nome);


--
-- Name: especialidade especialidade_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.especialidade
    ADD CONSTRAINT especialidade_pkey PRIMARY KEY (id_especialidade);


--
-- Name: especie especie_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.especie
    ADD CONSTRAINT especie_nome_key UNIQUE (nome);


--
-- Name: especie especie_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.especie
    ADD CONSTRAINT especie_pkey PRIMARY KEY (id_especie);


--
-- Name: medicamento medicamento_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicamento
    ADD CONSTRAINT medicamento_nome_key UNIQUE (nome);


--
-- Name: medicamento medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medicamento
    ADD CONSTRAINT medicamento_pkey PRIMARY KEY (id_medicamento);


--
-- Name: microchip microchip_numero_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.microchip
    ADD CONSTRAINT microchip_numero_key UNIQUE (numero);


--
-- Name: microchip microchip_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.microchip
    ADD CONSTRAINT microchip_pkey PRIMARY KEY (id_animal);


--
-- Name: consulta_medicamento pk_consulta_medicamento; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta_medicamento
    ADD CONSTRAINT pk_consulta_medicamento PRIMARY KEY (id_consulta, id_medicamento);


--
-- Name: veterinario_dia_atendimento pk_veterinario_dia; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veterinario_dia_atendimento
    ADD CONSTRAINT pk_veterinario_dia PRIMARY KEY (id_veterinario, dia_semana);


--
-- Name: veterinario_especialidade pk_veterinario_especialidade; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veterinario_especialidade
    ADD CONSTRAINT pk_veterinario_especialidade PRIMARY KEY (id_veterinario, id_especialidade);


--
-- Name: raca raca_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raca
    ADD CONSTRAINT raca_pkey PRIMARY KEY (id_raca);


--
-- Name: tutor tutor_cpf_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor
    ADD CONSTRAINT tutor_cpf_key UNIQUE (cpf);


--
-- Name: tutor tutor_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor
    ADD CONSTRAINT tutor_email_key UNIQUE (email);


--
-- Name: tutor tutor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor
    ADD CONSTRAINT tutor_pkey PRIMARY KEY (id_tutor);


--
-- Name: aplicacao_vacina uq_av_animal_vacina_data; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aplicacao_vacina
    ADD CONSTRAINT uq_av_animal_vacina_data UNIQUE (id_animal, id_vacina, data_aplicacao);


--
-- Name: raca uq_raca_nome_especie; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raca
    ADD CONSTRAINT uq_raca_nome_especie UNIQUE (nome, id_especie);


--
-- Name: vacina vacina_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vacina
    ADD CONSTRAINT vacina_nome_key UNIQUE (nome);


--
-- Name: vacina vacina_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vacina
    ADD CONSTRAINT vacina_pkey PRIMARY KEY (id_vacina);


--
-- Name: veterinario veterinario_crmv_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veterinario
    ADD CONSTRAINT veterinario_crmv_key UNIQUE (crmv);


--
-- Name: veterinario veterinario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veterinario
    ADD CONSTRAINT veterinario_pkey PRIMARY KEY (id_veterinario);


--
-- Name: idx_animal_raca; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_animal_raca ON public.animal USING btree (id_raca);


--
-- Name: idx_animal_tutor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_animal_tutor ON public.animal USING btree (id_tutor);


--
-- Name: idx_av_animal; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_av_animal ON public.aplicacao_vacina USING btree (id_animal);


--
-- Name: idx_consulta_animal; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_consulta_animal ON public.consulta USING btree (id_animal);


--
-- Name: idx_consulta_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_consulta_data ON public.consulta USING btree (data_hora);


--
-- Name: idx_consulta_veterinario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_consulta_veterinario ON public.consulta USING btree (id_veterinario);


--
-- Name: animal fk_animal_raca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT fk_animal_raca FOREIGN KEY (id_raca) REFERENCES public.raca(id_raca);


--
-- Name: animal fk_animal_tutor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT fk_animal_tutor FOREIGN KEY (id_tutor) REFERENCES public.tutor(id_tutor);


--
-- Name: aplicacao_vacina fk_av_animal; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aplicacao_vacina
    ADD CONSTRAINT fk_av_animal FOREIGN KEY (id_animal) REFERENCES public.animal(id_animal);


--
-- Name: aplicacao_vacina fk_av_vacina; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aplicacao_vacina
    ADD CONSTRAINT fk_av_vacina FOREIGN KEY (id_vacina) REFERENCES public.vacina(id_vacina);


--
-- Name: aplicacao_vacina fk_av_veterinario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aplicacao_vacina
    ADD CONSTRAINT fk_av_veterinario FOREIGN KEY (id_veterinario) REFERENCES public.veterinario(id_veterinario);


--
-- Name: consulta_medicamento fk_cm_consulta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta_medicamento
    ADD CONSTRAINT fk_cm_consulta FOREIGN KEY (id_consulta) REFERENCES public.consulta(id_consulta) ON DELETE CASCADE;


--
-- Name: consulta_medicamento fk_cm_medicamento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta_medicamento
    ADD CONSTRAINT fk_cm_medicamento FOREIGN KEY (id_medicamento) REFERENCES public.medicamento(id_medicamento);


--
-- Name: consulta fk_consulta_animal; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT fk_consulta_animal FOREIGN KEY (id_animal) REFERENCES public.animal(id_animal);


--
-- Name: consulta fk_consulta_veterinario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consulta
    ADD CONSTRAINT fk_consulta_veterinario FOREIGN KEY (id_veterinario) REFERENCES public.veterinario(id_veterinario);


--
-- Name: microchip fk_microchip_animal; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.microchip
    ADD CONSTRAINT fk_microchip_animal FOREIGN KEY (id_animal) REFERENCES public.animal(id_animal) ON DELETE CASCADE;


--
-- Name: raca fk_raca_especie; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.raca
    ADD CONSTRAINT fk_raca_especie FOREIGN KEY (id_especie) REFERENCES public.especie(id_especie);


--
-- Name: veterinario_dia_atendimento fk_vd_veterinario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veterinario_dia_atendimento
    ADD CONSTRAINT fk_vd_veterinario FOREIGN KEY (id_veterinario) REFERENCES public.veterinario(id_veterinario) ON DELETE CASCADE;


--
-- Name: veterinario_especialidade fk_ve_especialidade; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veterinario_especialidade
    ADD CONSTRAINT fk_ve_especialidade FOREIGN KEY (id_especialidade) REFERENCES public.especialidade(id_especialidade);


--
-- Name: veterinario_especialidade fk_ve_veterinario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veterinario_especialidade
    ADD CONSTRAINT fk_ve_veterinario FOREIGN KEY (id_veterinario) REFERENCES public.veterinario(id_veterinario) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


