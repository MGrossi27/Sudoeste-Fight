--
-- PostgreSQL database dump
--

\restrict zET9Cg6hqtLqrEENqmPfCCX5UetkixI5CqnnN8mGContitOaBzRHlh50z2eVhOr

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: gym_admin
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO gym_admin;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: gym_admin
--

COMMENT ON SCHEMA public IS '';


--
-- Name: sexo_aluno; Type: TYPE; Schema: public; Owner: gym_admin
--

CREATE TYPE public.sexo_aluno AS ENUM (
    'Masculino',
    'Feminino',
    'Outro'
);


ALTER TYPE public.sexo_aluno OWNER TO gym_admin;

--
-- Name: status_matricula; Type: TYPE; Schema: public; Owner: gym_admin
--

CREATE TYPE public.status_matricula AS ENUM (
    'ativa',
    'cancelada',
    'pausada',
    'finalizada'
);


ALTER TYPE public.status_matricula OWNER TO gym_admin;

--
-- Name: status_pagamento; Type: TYPE; Schema: public; Owner: gym_admin
--

CREATE TYPE public.status_pagamento AS ENUM (
    'pago',
    'pendente',
    'atrasado'
);


ALTER TYPE public.status_pagamento OWNER TO gym_admin;

--
-- Name: tipo_desconto; Type: TYPE; Schema: public; Owner: gym_admin
--

CREATE TYPE public.tipo_desconto AS ENUM (
    'percentual',
    'valor_fixo'
);


ALTER TYPE public.tipo_desconto OWNER TO gym_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alunos; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.alunos (
    matricula character varying(6) NOT NULL,
    nome_completo character varying(255) NOT NULL,
    sexo public.sexo_aluno,
    cpf character varying(14) NOT NULL,
    data_nascimento date NOT NULL,
    email character varying(255) NOT NULL,
    telefone character varying(20),
    data_cadastro timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.alunos OWNER TO gym_admin;

--
-- Name: inscricoes; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.inscricoes (
    id_inscricao integer NOT NULL,
    id_aluno character varying(6) NOT NULL,
    id_plano integer NOT NULL,
    id_promocao integer,
    id_unidade integer NOT NULL,
    data_inicio date NOT NULL,
    data_fim date,
    status public.status_matricula DEFAULT 'ativa'::public.status_matricula NOT NULL
);


ALTER TABLE public.inscricoes OWNER TO gym_admin;

--
-- Name: inscricoes_id_inscricao_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.inscricoes_id_inscricao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inscricoes_id_inscricao_seq OWNER TO gym_admin;

--
-- Name: inscricoes_id_inscricao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.inscricoes_id_inscricao_seq OWNED BY public.inscricoes.id_inscricao;


--
-- Name: inscricoes_modalidades; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.inscricoes_modalidades (
    id_inscricao integer NOT NULL,
    id_modalidade integer NOT NULL
);


ALTER TABLE public.inscricoes_modalidades OWNER TO gym_admin;

--
-- Name: itens_pagamento; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.itens_pagamento (
    id_item_pagamento integer NOT NULL,
    id_pagamento integer NOT NULL,
    id_tipo_transacao integer NOT NULL,
    valor numeric(10,2) NOT NULL,
    descricao_item character varying(255)
);


ALTER TABLE public.itens_pagamento OWNER TO gym_admin;

--
-- Name: itens_pagamento_id_item_pagamento_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.itens_pagamento_id_item_pagamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itens_pagamento_id_item_pagamento_seq OWNER TO gym_admin;

--
-- Name: itens_pagamento_id_item_pagamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.itens_pagamento_id_item_pagamento_seq OWNED BY public.itens_pagamento.id_item_pagamento;


--
-- Name: modalidades; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.modalidades (
    id_modalidade integer NOT NULL,
    nome character varying(100) NOT NULL
);


ALTER TABLE public.modalidades OWNER TO gym_admin;

--
-- Name: modalidades_id_modalidade_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.modalidades_id_modalidade_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.modalidades_id_modalidade_seq OWNER TO gym_admin;

--
-- Name: modalidades_id_modalidade_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.modalidades_id_modalidade_seq OWNED BY public.modalidades.id_modalidade;


--
-- Name: pagamentos; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.pagamentos (
    id_pagamento integer NOT NULL,
    id_inscricao integer NOT NULL,
    data_vencimento date NOT NULL,
    valor_total_devido numeric(10,2) NOT NULL,
    valor_total_pago numeric(10,2),
    status public.status_pagamento DEFAULT 'pendente'::public.status_pagamento NOT NULL,
    data_pagamento date
);


ALTER TABLE public.pagamentos OWNER TO gym_admin;

--
-- Name: pagamentos_id_pagamento_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.pagamentos_id_pagamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pagamentos_id_pagamento_seq OWNER TO gym_admin;

--
-- Name: pagamentos_id_pagamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.pagamentos_id_pagamento_seq OWNED BY public.pagamentos.id_pagamento;


--
-- Name: plano_modalidades; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.plano_modalidades (
    id_plano integer NOT NULL,
    id_modalidade integer NOT NULL
);


ALTER TABLE public.plano_modalidades OWNER TO gym_admin;

--
-- Name: planos; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.planos (
    id_plano integer NOT NULL,
    nome character varying(100) NOT NULL,
    descricao text,
    preco_mensal numeric(10,2) NOT NULL,
    ativo boolean DEFAULT true,
    CONSTRAINT planos_preco_mensal_check CHECK ((preco_mensal >= (0)::numeric))
);


ALTER TABLE public.planos OWNER TO gym_admin;

--
-- Name: planos_id_plano_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.planos_id_plano_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.planos_id_plano_seq OWNER TO gym_admin;

--
-- Name: planos_id_plano_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.planos_id_plano_seq OWNED BY public.planos.id_plano;


--
-- Name: promocoes; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.promocoes (
    id_promocao integer NOT NULL,
    nome_campanha character varying(150) NOT NULL,
    descricao text,
    tipo public.tipo_desconto NOT NULL,
    valor numeric(10,2) NOT NULL,
    duracao_meses integer,
    data_inicio_validade date NOT NULL,
    data_fim_validade date NOT NULL,
    ativa boolean DEFAULT true
);


ALTER TABLE public.promocoes OWNER TO gym_admin;

--
-- Name: promocoes_id_promocao_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.promocoes_id_promocao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.promocoes_id_promocao_seq OWNER TO gym_admin;

--
-- Name: promocoes_id_promocao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.promocoes_id_promocao_seq OWNED BY public.promocoes.id_promocao;


--
-- Name: tipos_transacao; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.tipos_transacao (
    id_tipo_transacao integer NOT NULL,
    nome character varying(100) NOT NULL,
    descricao text
);


ALTER TABLE public.tipos_transacao OWNER TO gym_admin;

--
-- Name: tipos_transacao_id_tipo_transacao_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.tipos_transacao_id_tipo_transacao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tipos_transacao_id_tipo_transacao_seq OWNER TO gym_admin;

--
-- Name: tipos_transacao_id_tipo_transacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.tipos_transacao_id_tipo_transacao_seq OWNED BY public.tipos_transacao.id_tipo_transacao;


--
-- Name: unidades; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.unidades (
    id_unidade integer NOT NULL,
    nome character varying(100) NOT NULL,
    endereco text,
    telefone character varying(20)
);


ALTER TABLE public.unidades OWNER TO gym_admin;

--
-- Name: unidades_id_unidade_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.unidades_id_unidade_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unidades_id_unidade_seq OWNER TO gym_admin;

--
-- Name: unidades_id_unidade_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.unidades_id_unidade_seq OWNED BY public.unidades.id_unidade;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: gym_admin
--

CREATE TABLE public.usuarios (
    id_usuario integer NOT NULL,
    username character varying(50) NOT NULL,
    senha_hash character varying(255) NOT NULL,
    nome_completo character varying(100),
    email character varying(100),
    ativo boolean DEFAULT true,
    data_criacao timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    ultimo_acesso timestamp with time zone
);


ALTER TABLE public.usuarios OWNER TO gym_admin;

--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: gym_admin
--

CREATE SEQUENCE public.usuarios_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usuarios_id_usuario_seq OWNER TO gym_admin;

--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gym_admin
--

ALTER SEQUENCE public.usuarios_id_usuario_seq OWNED BY public.usuarios.id_usuario;


--
-- Name: inscricoes id_inscricao; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes ALTER COLUMN id_inscricao SET DEFAULT nextval('public.inscricoes_id_inscricao_seq'::regclass);


--
-- Name: itens_pagamento id_item_pagamento; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.itens_pagamento ALTER COLUMN id_item_pagamento SET DEFAULT nextval('public.itens_pagamento_id_item_pagamento_seq'::regclass);


--
-- Name: modalidades id_modalidade; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.modalidades ALTER COLUMN id_modalidade SET DEFAULT nextval('public.modalidades_id_modalidade_seq'::regclass);


--
-- Name: pagamentos id_pagamento; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.pagamentos ALTER COLUMN id_pagamento SET DEFAULT nextval('public.pagamentos_id_pagamento_seq'::regclass);


--
-- Name: planos id_plano; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.planos ALTER COLUMN id_plano SET DEFAULT nextval('public.planos_id_plano_seq'::regclass);


--
-- Name: promocoes id_promocao; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.promocoes ALTER COLUMN id_promocao SET DEFAULT nextval('public.promocoes_id_promocao_seq'::regclass);


--
-- Name: tipos_transacao id_tipo_transacao; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.tipos_transacao ALTER COLUMN id_tipo_transacao SET DEFAULT nextval('public.tipos_transacao_id_tipo_transacao_seq'::regclass);


--
-- Name: unidades id_unidade; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.unidades ALTER COLUMN id_unidade SET DEFAULT nextval('public.unidades_id_unidade_seq'::regclass);


--
-- Name: usuarios id_usuario; Type: DEFAULT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuarios_id_usuario_seq'::regclass);


--
-- Data for Name: alunos; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.alunos (matricula, nome_completo, sexo, cpf, data_nascimento, email, telefone, data_cadastro) FROM stdin;
000001	Maria Ferreira Gomes	Masculino	001.000.000-01	2006-11-01	maria.ferreira.gomes1@email.com	(77) 98001-1007	2025-11-01 00:00:00-03
000003	Ana Correia Rocha	Feminino	001.000.000-03	2004-10-30	ana.correia.rocha3@email.com	(77) 98003-1021	2025-10-30 00:00:00-03
000004	Pedro Costa Rodrigues	Masculino	001.000.000-04	2003-10-29	pedro.costa.rodrigues4@email.com	(77) 98004-1028	2025-10-29 00:00:00-03
000005	Juliana Gomes Correia	Masculino	001.000.000-05	2002-10-28	juliana.gomes.correia5@email.com	(77) 98005-1035	2025-10-28 00:00:00-03
000006	Carlos Cardoso Carvalho	Feminino	001.000.000-06	2001-10-27	carlos.cardoso.carvalho6@email.com	(77) 98006-1042	2025-10-27 00:00:00-03
000007	Fernanda Pereira Souza	Masculino	001.000.000-07	2000-10-26	fernanda.pereira.souza7@email.com	(77) 98007-1049	2025-10-26 00:00:00-03
000008	Ricardo Carvalho Castro	Masculino	001.000.000-08	1999-10-25	ricardo.carvalho.castro8@email.com	(77) 98008-1056	2025-10-25 00:00:00-03
000009	Paula Monteiro Ferreira	Feminino	001.000.000-09	1998-10-24	paula.monteiro.ferreira9@email.com	(77) 98009-1063	2025-10-24 00:00:00-03
000010	Rafael Lima Cardoso	Masculino	001.000.000-10	1997-10-23	rafael.lima.cardoso10@email.com	(77) 98010-1070	2025-10-23 00:00:00-03
000012	Bruno Dias Oliveira	Feminino	001.000.000-12	1995-10-21	bruno.dias.oliveira12@email.com	(77) 98012-1084	2025-10-21 00:00:00-03
000013	Beatriz Souza Ribeiro	Masculino	001.000.000-13	1994-10-20	beatriz.souza.ribeiro13@email.com	(77) 98013-1091	2025-10-20 00:00:00-03
000014	Felipe Nascimento Costa	Masculino	001.000.000-14	1993-10-19	felipe.nascimento.costa14@email.com	(77) 98014-1098	2025-10-19 00:00:00-03
000015	Larissa Rocha Monteiro	Feminino	001.000.000-15	1992-10-18	larissa.rocha.monteiro15@email.com	(77) 98015-1105	2025-10-18 00:00:00-03
000016	Gustavo Oliveira Nascimento	Masculino	001.000.000-16	1991-10-17	gustavo.oliveira.nascimento16@email.com	(77) 98016-1112	2025-10-17 00:00:00-03
000017	Amanda Almeida Santos	Masculino	001.000.000-17	1990-10-16	amanda.almeida.santos17@email.com	(77) 98017-1119	2025-10-16 00:00:00-03
000018	Rodrigo Castro Martins	Feminino	001.000.000-18	1989-10-15	rodrigo.castro.martins18@email.com	(77) 98018-1126	2025-10-15 00:00:00-03
000019	Gabriela Santos Pereira	Masculino	001.000.000-19	1988-10-14	gabriela.santos.pereira19@email.com	(77) 98019-1133	2025-10-14 00:00:00-03
000020	Daniel Rodrigues Dias	Masculino	001.000.000-20	1987-10-13	daniel.rodrigues.dias20@email.com	(77) 98020-1140	2025-10-13 00:00:00-03
000021	Mariana Ribeiro Almeida	Feminino	001.000.000-21	1986-10-12	mariana.ribeiro.almeida21@email.com	(77) 98021-1147	2025-10-12 00:00:00-03
000022	Thiago Silva Silva	Outro	001.000.000-22	1985-10-11	thiago.silva.silva22@email.com	(77) 98022-1154	2025-10-11 00:00:00-03
000023	Carolina Ferreira Gomes	Masculino	001.000.000-23	1984-10-10	carolina.ferreira.gomes23@email.com	(77) 98023-1161	2025-10-10 00:00:00-03
000024	Marcelo Martins Lima	Feminino	001.000.000-24	1983-10-09	marcelo.martins.lima24@email.com	(77) 98024-1168	2025-10-09 00:00:00-03
000025	Renata Correia Rocha	Masculino	001.000.000-25	1982-10-08	renata.correia.rocha25@email.com	(77) 98025-1175	2025-10-08 00:00:00-03
000028	Leonardo Cardoso Carvalho	Masculino	001.000.000-28	1979-10-05	leonardo.cardoso.carvalho28@email.com	(77) 98028-1196	2025-10-05 00:00:00-03
000029	Vanessa Pereira Souza	Masculino	001.000.000-29	1978-10-04	vanessa.pereira.souza29@email.com	(77) 98029-1203	2025-10-04 00:00:00-03
000030	Vinicius Carvalho Castro	Feminino	001.000.000-30	1977-10-03	vinicius.carvalho.castro30@email.com	(77) 98030-1210	2025-10-03 00:00:00-03
000031	Cristina Monteiro Ferreira	Masculino	001.000.000-31	1976-10-02	cristina.monteiro.ferreira31@email.com	(77) 98031-1217	2025-10-02 00:00:00-03
000032	Matheus Lima Cardoso	Masculino	001.000.000-32	2007-10-01	matheus.lima.cardoso32@email.com	(77) 98032-1224	2025-10-01 00:00:00-03
000034	Diego Dias Oliveira	Masculino	001.000.000-34	2005-09-29	diego.dias.oliveira34@email.com	(77) 98034-1238	2025-09-29 00:00:00-03
000035	Simone Souza Ribeiro	Masculino	001.000.000-35	2004-09-28	simone.souza.ribeiro35@email.com	(77) 98035-1245	2025-09-28 00:00:00-03
000036	Lucas Nascimento Costa	Feminino	001.000.000-36	2003-09-27	lucas.nascimento.costa36@email.com	(77) 98036-1252	2025-09-27 00:00:00-03
000037	Maria Rocha Monteiro	Masculino	001.000.000-37	2002-09-26	maria.rocha.monteiro37@email.com	(77) 98037-1259	2025-09-26 00:00:00-03
000039	Ana Almeida Santos	Feminino	001.000.000-39	2000-09-24	ana.almeida.santos39@email.com	(77) 98039-1273	2025-09-24 00:00:00-03
000040	Pedro Castro Martins	Masculino	001.000.000-40	1999-09-23	pedro.castro.martins40@email.com	(77) 98040-1280	2025-09-23 00:00:00-03
000041	Juliana Santos Pereira	Masculino	001.000.000-41	1998-09-22	juliana.santos.pereira41@email.com	(77) 98041-1287	2025-09-22 00:00:00-03
000042	Carlos Rodrigues Dias	Feminino	001.000.000-42	1997-09-21	carlos.rodrigues.dias42@email.com	(77) 98042-1294	2025-09-21 00:00:00-03
000043	Fernanda Ribeiro Almeida	Masculino	001.000.000-43	1996-09-20	fernanda.ribeiro.almeida43@email.com	(77) 98043-1301	2025-09-20 00:00:00-03
000044	Ricardo Silva Silva	Outro	001.000.000-44	1995-09-19	ricardo.silva.silva44@email.com	(77) 98044-1308	2025-09-19 00:00:00-03
000045	Paula Ferreira Gomes	Feminino	001.000.000-45	1994-09-18	paula.ferreira.gomes45@email.com	(77) 98045-1315	2025-09-18 00:00:00-03
000046	Rafael Martins Lima	Masculino	001.000.000-46	1993-09-17	rafael.martins.lima46@email.com	(77) 98046-1322	2025-09-17 00:00:00-03
000047	Camila Correia Rocha	Masculino	001.000.000-47	1992-09-16	camila.correia.rocha47@email.com	(77) 98047-1329	2025-09-16 00:00:00-03
000048	Bruno Costa Rodrigues	Feminino	001.000.000-48	1991-09-15	bruno.costa.rodrigues48@email.com	(77) 98048-1336	2025-09-15 00:00:00-03
000049	Beatriz Gomes Correia	Masculino	001.000.000-49	1990-09-14	beatriz.gomes.correia49@email.com	(77) 98049-1343	2025-09-14 00:00:00-03
000050	Felipe Cardoso Carvalho	Masculino	001.000.000-50	1989-09-13	felipe.cardoso.carvalho50@email.com	(77) 98050-1350	2025-09-13 00:00:00-03
000051	Larissa Pereira Souza	Feminino	001.000.000-51	1988-09-12	larissa.pereira.souza51@email.com	(77) 98051-1357	2025-09-12 00:00:00-03
000052	Gustavo Carvalho Castro	Masculino	001.000.000-52	1987-09-11	gustavo.carvalho.castro52@email.com	(77) 98052-1364	2025-09-11 00:00:00-03
000053	Amanda Monteiro Ferreira	Masculino	001.000.000-53	1986-09-10	amanda.monteiro.ferreira53@email.com	(77) 98053-1371	2025-09-10 00:00:00-03
000054	Rodrigo Lima Cardoso	Feminino	001.000.000-54	1985-09-09	rodrigo.lima.cardoso54@email.com	(77) 98054-1378	2025-09-09 00:00:00-03
000056	Daniel Dias Oliveira	Masculino	001.000.000-56	1983-09-07	daniel.dias.oliveira56@email.com	(77) 98056-1392	2025-09-07 00:00:00-03
000057	Mariana Souza Ribeiro	Feminino	001.000.000-57	1982-09-06	mariana.souza.ribeiro57@email.com	(77) 98057-1399	2025-09-06 00:00:00-03
000058	Thiago Nascimento Costa	Masculino	001.000.000-58	1981-09-05	thiago.nascimento.costa58@email.com	(77) 98058-1406	2025-09-05 00:00:00-03
000059	Carolina Rocha Monteiro	Masculino	001.000.000-59	1980-09-04	carolina.rocha.monteiro59@email.com	(77) 98059-1413	2025-09-04 00:00:00-03
000060	Marcelo Oliveira Nascimento	Feminino	001.000.000-60	1979-09-03	marcelo.oliveira.nascimento60@email.com	(77) 98060-1420	2025-09-03 00:00:00-03
000061	Renata Almeida Santos	Masculino	001.000.000-61	1978-09-02	renata.almeida.santos61@email.com	(77) 98061-1427	2025-09-02 00:00:00-03
000064	Leonardo Rodrigues Dias	Masculino	001.000.000-64	2007-08-30	leonardo.rodrigues.dias64@email.com	(77) 98064-1448	2025-08-30 00:00:00-03
000065	Vanessa Ribeiro Almeida	Masculino	001.000.000-65	2006-08-29	vanessa.ribeiro.almeida65@email.com	(77) 98065-1455	2025-08-29 00:00:00-03
000066	Vinicius Silva Silva	Feminino	001.000.000-66	2005-08-28	vinicius.silva.silva66@email.com	(77) 98066-1462	2025-08-28 00:00:00-03
000067	Cristina Ferreira Gomes	Masculino	001.000.000-67	2004-08-27	cristina.ferreira.gomes67@email.com	(77) 98067-1469	2025-08-27 00:00:00-03
000068	Matheus Martins Lima	Masculino	001.000.000-68	2003-08-26	matheus.martins.lima68@email.com	(77) 98068-1476	2025-08-26 00:00:00-03
000070	Diego Costa Rodrigues	Masculino	001.000.000-70	2001-08-24	diego.costa.rodrigues70@email.com	(77) 98070-1490	2025-08-24 00:00:00-03
000071	Simone Gomes Correia	Masculino	001.000.000-71	2000-08-23	simone.gomes.correia71@email.com	(77) 98071-1497	2025-08-23 00:00:00-03
000072	Lucas Cardoso Carvalho	Feminino	001.000.000-72	1999-08-22	lucas.cardoso.carvalho72@email.com	(77) 98072-1504	2025-08-22 00:00:00-03
000073	Maria Pereira Souza	Masculino	001.000.000-73	1998-08-21	maria.pereira.souza73@email.com	(77) 98073-1511	2025-08-21 00:00:00-03
000075	Ana Monteiro Ferreira	Feminino	001.000.000-75	1996-08-19	ana.monteiro.ferreira75@email.com	(77) 98075-1525	2025-08-19 00:00:00-03
000076	Pedro Lima Cardoso	Masculino	001.000.000-76	1995-08-18	pedro.lima.cardoso76@email.com	(77) 98076-1532	2025-08-18 00:00:00-03
000078	Carlos Dias Oliveira	Feminino	001.000.000-78	1993-08-16	carlos.dias.oliveira78@email.com	(77) 98078-1546	2025-08-16 00:00:00-03
000079	Fernanda Souza Ribeiro	Masculino	001.000.000-79	1992-08-15	fernanda.souza.ribeiro79@email.com	(77) 98079-1553	2025-08-15 00:00:00-03
000080	Ricardo Nascimento Costa	Masculino	001.000.000-80	1991-08-14	ricardo.nascimento.costa80@email.com	(77) 98080-1560	2025-08-14 00:00:00-03
000081	Paula Rocha Monteiro	Feminino	001.000.000-81	1990-08-13	paula.rocha.monteiro81@email.com	(77) 98081-1567	2025-08-13 00:00:00-03
000082	Rafael Oliveira Nascimento	Masculino	001.000.000-82	1989-08-12	rafael.oliveira.nascimento82@email.com	(77) 98082-1574	2025-08-12 00:00:00-03
000083	Camila Almeida Santos	Masculino	001.000.000-83	1988-08-11	camila.almeida.santos83@email.com	(77) 98083-1581	2025-08-11 00:00:00-03
000084	Bruno Castro Martins	Feminino	001.000.000-84	1987-08-10	bruno.castro.martins84@email.com	(77) 98084-1588	2025-08-10 00:00:00-03
000085	Beatriz Santos Pereira	Masculino	001.000.000-85	1986-08-09	beatriz.santos.pereira85@email.com	(77) 98085-1595	2025-08-09 00:00:00-03
000086	Felipe Rodrigues Dias	Masculino	001.000.000-86	1985-08-08	felipe.rodrigues.dias86@email.com	(77) 98086-1602	2025-08-08 00:00:00-03
000087	Larissa Ribeiro Almeida	Feminino	001.000.000-87	1984-08-07	larissa.ribeiro.almeida87@email.com	(77) 98087-1609	2025-08-07 00:00:00-03
000088	Gustavo Silva Silva	Outro	001.000.000-88	1983-08-06	gustavo.silva.silva88@email.com	(77) 98088-1616	2025-08-06 00:00:00-03
000089	Amanda Ferreira Gomes	Masculino	001.000.000-89	1982-08-05	amanda.ferreira.gomes89@email.com	(77) 98089-1623	2025-08-05 00:00:00-03
000090	Rodrigo Martins Lima	Feminino	001.000.000-90	1981-08-04	rodrigo.martins.lima90@email.com	(77) 98090-1630	2025-08-04 00:00:00-03
000091	Gabriela Correia Rocha	Masculino	001.000.000-91	1980-08-03	gabriela.correia.rocha91@email.com	(77) 98091-1637	2025-08-03 00:00:00-03
000092	Daniel Costa Rodrigues	Masculino	001.000.000-92	1979-08-02	daniel.costa.rodrigues92@email.com	(77) 98092-1644	2025-08-02 00:00:00-03
000093	Mariana Gomes Correia	Feminino	001.000.000-93	1978-08-01	mariana.gomes.correia93@email.com	(77) 98093-1651	2025-08-01 00:00:00-03
000094	Thiago Cardoso Carvalho	Masculino	001.000.000-94	1977-07-31	thiago.cardoso.carvalho94@email.com	(77) 98094-1658	2025-07-31 00:00:00-03
000095	Carolina Pereira Souza	Masculino	001.000.000-95	1976-07-30	carolina.pereira.souza95@email.com	(77) 98095-1665	2025-07-30 00:00:00-03
000096	Marcelo Carvalho Castro	Feminino	001.000.000-96	2007-07-29	marcelo.carvalho.castro96@email.com	(77) 98096-1672	2025-07-29 00:00:00-03
000097	Renata Monteiro Ferreira	Masculino	001.000.000-97	2006-07-28	renata.monteiro.ferreira97@email.com	(77) 98097-1679	2025-07-28 00:00:00-03
000100	Leonardo Dias Oliveira	Masculino	001.000.001-00	2003-07-25	leonardo.dias.oliveira100@email.com	(77) 98100-1700	2025-07-25 00:00:00-03
000101	Vanessa Souza Ribeiro	Masculino	001.000.001-01	2002-07-24	vanessa.souza.ribeiro101@email.com	(77) 98101-1707	2025-07-24 00:00:00-03
000102	Vinicius Nascimento Costa	Feminino	001.000.001-02	2001-07-23	vinicius.nascimento.costa102@email.com	(77) 98102-1714	2025-07-23 00:00:00-03
000103	Cristina Rocha Monteiro	Masculino	001.000.001-03	2000-07-22	cristina.rocha.monteiro103@email.com	(77) 98103-1721	2025-07-22 00:00:00-03
000104	Matheus Oliveira Nascimento	Masculino	001.000.001-04	1999-07-21	matheus.oliveira.nascimento104@email.com	(77) 98104-1728	2025-07-21 00:00:00-03
000106	Diego Castro Martins	Masculino	001.000.001-06	1997-07-19	diego.castro.martins106@email.com	(77) 98106-1742	2025-07-19 00:00:00-03
000107	Simone Santos Pereira	Masculino	001.000.001-07	1996-07-18	simone.santos.pereira107@email.com	(77) 98107-1749	2025-07-18 00:00:00-03
000108	Lucas Rodrigues Dias	Feminino	001.000.001-08	1995-07-17	lucas.rodrigues.dias108@email.com	(77) 98108-1756	2025-07-17 00:00:00-03
000109	Maria Ribeiro Almeida	Masculino	001.000.001-09	1994-07-16	maria.ribeiro.almeida109@email.com	(77) 98109-1763	2025-07-16 00:00:00-03
000111	Ana Ferreira Gomes	Feminino	001.000.001-11	1992-07-14	ana.ferreira.gomes111@email.com	(77) 98111-1777	2025-07-14 00:00:00-03
000112	Pedro Martins Lima	Masculino	001.000.001-12	1991-07-13	pedro.martins.lima112@email.com	(77) 98112-1784	2025-07-13 00:00:00-03
000113	Juliana Correia Rocha	Masculino	001.000.001-13	1990-07-12	juliana.correia.rocha113@email.com	(77) 98113-1791	2025-07-12 00:00:00-03
000114	Carlos Costa Rodrigues	Feminino	001.000.001-14	1989-07-11	carlos.costa.rodrigues114@email.com	(77) 98114-1798	2025-07-11 00:00:00-03
000115	Fernanda Gomes Correia	Masculino	001.000.001-15	1988-07-10	fernanda.gomes.correia115@email.com	(77) 98115-1805	2025-07-10 00:00:00-03
000116	Ricardo Cardoso Carvalho	Masculino	001.000.001-16	1987-07-09	ricardo.cardoso.carvalho116@email.com	(77) 98116-1812	2025-07-09 00:00:00-03
000117	Paula Pereira Souza	Feminino	001.000.001-17	1986-07-08	paula.pereira.souza117@email.com	(77) 98117-1819	2025-07-08 00:00:00-03
000118	Rafael Carvalho Castro	Masculino	001.000.001-18	1985-07-07	rafael.carvalho.castro118@email.com	(77) 98118-1826	2025-07-07 00:00:00-03
000119	Camila Monteiro Ferreira	Masculino	001.000.001-19	1984-07-06	camila.monteiro.ferreira119@email.com	(77) 98119-1833	2025-07-06 00:00:00-03
000120	Bruno Lima Cardoso	Feminino	001.000.001-20	1983-07-05	bruno.lima.cardoso120@email.com	(77) 98120-1840	2025-07-05 00:00:00-03
000122	Felipe Dias Oliveira	Masculino	001.000.001-22	1981-07-03	felipe.dias.oliveira122@email.com	(77) 98122-1854	2025-07-03 00:00:00-03
000123	Larissa Souza Ribeiro	Feminino	001.000.001-23	1980-07-02	larissa.souza.ribeiro123@email.com	(77) 98123-1861	2025-07-02 00:00:00-03
000124	Gustavo Nascimento Costa	Masculino	001.000.001-24	1979-07-01	gustavo.nascimento.costa124@email.com	(77) 98124-1868	2025-07-01 00:00:00-03
000125	Amanda Rocha Monteiro	Masculino	001.000.001-25	1978-06-30	amanda.rocha.monteiro125@email.com	(77) 98125-1875	2025-06-30 00:00:00-03
000126	Rodrigo Oliveira Nascimento	Feminino	001.000.001-26	1977-06-29	rodrigo.oliveira.nascimento126@email.com	(77) 98126-1882	2025-06-29 00:00:00-03
000127	Gabriela Almeida Santos	Masculino	001.000.001-27	1976-06-28	gabriela.almeida.santos127@email.com	(77) 98127-1889	2025-06-28 00:00:00-03
000128	Daniel Castro Martins	Masculino	001.000.001-28	2007-06-27	daniel.castro.martins128@email.com	(77) 98128-1896	2025-06-27 00:00:00-03
000129	Mariana Santos Pereira	Feminino	001.000.001-29	2006-06-26	mariana.santos.pereira129@email.com	(77) 98129-1903	2025-06-26 00:00:00-03
000130	Thiago Rodrigues Dias	Masculino	001.000.001-30	2005-06-25	thiago.rodrigues.dias130@email.com	(77) 98130-1910	2025-06-25 00:00:00-03
000131	Carolina Ribeiro Almeida	Masculino	001.000.001-31	2004-06-24	carolina.ribeiro.almeida131@email.com	(77) 98131-1917	2025-06-24 00:00:00-03
000132	Marcelo Silva Silva	Feminino	001.000.001-32	2003-06-23	marcelo.silva.silva132@email.com	(77) 98132-1924	2025-06-23 00:00:00-03
000133	Renata Ferreira Gomes	Masculino	001.000.001-33	2002-06-22	renata.ferreira.gomes133@email.com	(77) 98133-1931	2025-06-22 00:00:00-03
000136	Leonardo Costa Rodrigues	Masculino	001.000.001-36	1999-06-19	leonardo.costa.rodrigues136@email.com	(77) 98136-1952	2025-06-19 00:00:00-03
000137	Vanessa Gomes Correia	Masculino	001.000.001-37	1998-06-18	vanessa.gomes.correia137@email.com	(77) 98137-1959	2025-06-18 00:00:00-03
000138	Vinicius Cardoso Carvalho	Feminino	001.000.001-38	1997-06-17	vinicius.cardoso.carvalho138@email.com	(77) 98138-1966	2025-06-17 00:00:00-03
000139	Cristina Pereira Souza	Masculino	001.000.001-39	1996-06-16	cristina.pereira.souza139@email.com	(77) 98139-1973	2025-06-16 00:00:00-03
000140	Matheus Carvalho Castro	Masculino	001.000.001-40	1995-06-15	matheus.carvalho.castro140@email.com	(77) 98140-1980	2025-06-15 00:00:00-03
000142	Diego Lima Cardoso	Masculino	001.000.001-42	1993-06-13	diego.lima.cardoso142@email.com	(77) 98142-1994	2025-06-13 00:00:00-03
000144	Lucas Dias Oliveira	Feminino	001.000.001-44	1991-06-11	lucas.dias.oliveira144@email.com	(77) 98144-2008	2025-06-11 00:00:00-03
000145	Maria Souza Ribeiro	Masculino	001.000.001-45	1990-06-10	maria.souza.ribeiro145@email.com	(77) 98145-2015	2025-06-10 00:00:00-03
000147	Ana Rocha Monteiro	Feminino	001.000.001-47	1988-06-08	ana.rocha.monteiro147@email.com	(77) 98147-2029	2025-06-08 00:00:00-03
000148	Pedro Oliveira Nascimento	Masculino	001.000.001-48	1987-06-07	pedro.oliveira.nascimento148@email.com	(77) 98148-2036	2025-06-07 00:00:00-03
000149	Juliana Almeida Santos	Masculino	001.000.001-49	1986-06-06	juliana.almeida.santos149@email.com	(77) 98149-2043	2025-06-06 00:00:00-03
000150	Carlos Castro Martins	Feminino	001.000.001-50	1985-06-05	carlos.castro.martins150@email.com	(77) 98150-2050	2025-06-05 00:00:00-03
000151	Fernanda Santos Pereira	Masculino	001.000.001-51	1984-06-04	fernanda.santos.pereira151@email.com	(77) 98151-2057	2025-06-04 00:00:00-03
000152	Ricardo Rodrigues Dias	Masculino	001.000.001-52	1983-06-03	ricardo.rodrigues.dias152@email.com	(77) 98152-2064	2025-06-03 00:00:00-03
000153	Paula Ribeiro Almeida	Feminino	001.000.001-53	1982-06-02	paula.ribeiro.almeida153@email.com	(77) 98153-2071	2025-06-02 00:00:00-03
000154	Rafael Silva Silva	Outro	001.000.001-54	1981-06-01	rafael.silva.silva154@email.com	(77) 98154-2078	2025-06-01 00:00:00-03
000155	Camila Ferreira Gomes	Masculino	001.000.001-55	1980-05-31	camila.ferreira.gomes155@email.com	(77) 98155-2085	2025-05-31 00:00:00-03
000156	Bruno Martins Lima	Feminino	001.000.001-56	1979-05-30	bruno.martins.lima156@email.com	(77) 98156-2092	2025-05-30 00:00:00-03
000157	Beatriz Correia Rocha	Masculino	001.000.001-57	1978-05-29	beatriz.correia.rocha157@email.com	(77) 98157-2099	2025-05-29 00:00:00-03
000158	Felipe Costa Rodrigues	Masculino	001.000.001-58	1977-05-28	felipe.costa.rodrigues158@email.com	(77) 98158-2106	2025-05-28 00:00:00-03
000159	Larissa Gomes Correia	Feminino	001.000.001-59	1976-05-27	larissa.gomes.correia159@email.com	(77) 98159-2113	2025-05-27 00:00:00-03
000160	Gustavo Cardoso Carvalho	Masculino	001.000.001-60	2007-05-26	gustavo.cardoso.carvalho160@email.com	(77) 98160-2120	2025-05-26 00:00:00-03
000161	Amanda Pereira Souza	Masculino	001.000.001-61	2006-05-25	amanda.pereira.souza161@email.com	(77) 98161-2127	2025-05-25 00:00:00-03
000162	Rodrigo Carvalho Castro	Feminino	001.000.001-62	2005-05-24	rodrigo.carvalho.castro162@email.com	(77) 98162-2134	2025-05-24 00:00:00-03
000163	Gabriela Monteiro Ferreira	Masculino	001.000.001-63	2004-05-23	gabriela.monteiro.ferreira163@email.com	(77) 98163-2141	2025-05-23 00:00:00-03
000164	Daniel Lima Cardoso	Masculino	001.000.001-64	2003-05-22	daniel.lima.cardoso164@email.com	(77) 98164-2148	2025-05-22 00:00:00-03
000166	Thiago Dias Oliveira	Masculino	001.000.001-66	2001-05-20	thiago.dias.oliveira166@email.com	(77) 98166-2162	2025-05-20 00:00:00-03
000167	Carolina Souza Ribeiro	Masculino	001.000.001-67	2000-05-19	carolina.souza.ribeiro167@email.com	(77) 98167-2169	2025-05-19 00:00:00-03
000168	Marcelo Nascimento Costa	Feminino	001.000.001-68	1999-05-18	marcelo.nascimento.costa168@email.com	(77) 98168-2176	2025-05-18 00:00:00-03
000169	Renata Rocha Monteiro	Masculino	001.000.001-69	1998-05-17	renata.rocha.monteiro169@email.com	(77) 98169-2183	2025-05-17 00:00:00-03
000172	Leonardo Castro Martins	Masculino	001.000.001-72	1995-05-14	leonardo.castro.martins172@email.com	(77) 98172-2204	2025-05-14 00:00:00-03
000173	Vanessa Santos Pereira	Masculino	001.000.001-73	1994-05-13	vanessa.santos.pereira173@email.com	(77) 98173-2211	2025-05-13 00:00:00-03
000174	Vinicius Rodrigues Dias	Feminino	001.000.001-74	1993-05-12	vinicius.rodrigues.dias174@email.com	(77) 98174-2218	2025-05-12 00:00:00-03
000175	Cristina Ribeiro Almeida	Masculino	001.000.001-75	1992-05-11	cristina.ribeiro.almeida175@email.com	(77) 98175-2225	2025-05-11 00:00:00-03
000176	Matheus Silva Silva	Outro	001.000.001-76	1991-05-10	matheus.silva.silva176@email.com	(77) 98176-2232	2025-05-10 00:00:00-03
000178	Diego Martins Lima	Masculino	001.000.001-78	1989-05-08	diego.martins.lima178@email.com	(77) 98178-2246	2025-05-08 00:00:00-03
000179	Simone Correia Rocha	Masculino	001.000.001-79	1988-05-07	simone.correia.rocha179@email.com	(77) 98179-2253	2025-05-07 00:00:00-03
000180	Lucas Costa Rodrigues	Feminino	001.000.001-80	1987-05-06	lucas.costa.rodrigues180@email.com	(77) 98180-2260	2025-05-06 00:00:00-03
000181	Maria Gomes Correia	Masculino	001.000.001-81	1986-05-05	maria.gomes.correia181@email.com	(77) 98181-2267	2025-05-05 00:00:00-03
000183	Ana Pereira Souza	Feminino	001.000.001-83	1984-05-03	ana.pereira.souza183@email.com	(77) 98183-2281	2025-05-03 00:00:00-03
000184	Pedro Carvalho Castro	Masculino	001.000.001-84	1983-05-02	pedro.carvalho.castro184@email.com	(77) 98184-2288	2025-05-02 00:00:00-03
000185	Juliana Monteiro Ferreira	Masculino	001.000.001-85	1982-05-01	juliana.monteiro.ferreira185@email.com	(77) 98185-2295	2025-05-01 00:00:00-03
000186	Carlos Lima Cardoso	Feminino	001.000.001-86	1981-04-30	carlos.lima.cardoso186@email.com	(77) 98186-2302	2025-04-30 00:00:00-03
000188	Ricardo Dias Oliveira	Masculino	001.000.001-88	1979-04-28	ricardo.dias.oliveira188@email.com	(77) 98188-2316	2025-04-28 00:00:00-03
000189	Paula Souza Ribeiro	Feminino	001.000.001-89	1978-04-27	paula.souza.ribeiro189@email.com	(77) 98189-2323	2025-04-27 00:00:00-03
000190	Rafael Nascimento Costa	Masculino	001.000.001-90	1977-04-26	rafael.nascimento.costa190@email.com	(77) 98190-2330	2025-04-26 00:00:00-03
000191	Camila Rocha Monteiro	Masculino	001.000.001-91	1976-04-25	camila.rocha.monteiro191@email.com	(77) 98191-2337	2025-04-25 00:00:00-03
000192	Bruno Oliveira Nascimento	Feminino	001.000.001-92	2007-04-24	bruno.oliveira.nascimento192@email.com	(77) 98192-2344	2025-04-24 00:00:00-03
000193	Beatriz Almeida Santos	Masculino	001.000.001-93	2006-04-23	beatriz.almeida.santos193@email.com	(77) 98193-2351	2025-04-23 00:00:00-03
000194	Felipe Castro Martins	Masculino	001.000.001-94	2005-04-22	felipe.castro.martins194@email.com	(77) 98194-2358	2025-04-22 00:00:00-03
000195	Larissa Santos Pereira	Feminino	001.000.001-95	2004-04-21	larissa.santos.pereira195@email.com	(77) 98195-2365	2025-04-21 00:00:00-03
000196	Gustavo Rodrigues Dias	Masculino	001.000.001-96	2003-04-20	gustavo.rodrigues.dias196@email.com	(77) 98196-2372	2025-04-20 00:00:00-03
000197	Amanda Ribeiro Almeida	Masculino	001.000.001-97	2002-04-19	amanda.ribeiro.almeida197@email.com	(77) 98197-2379	2025-04-19 00:00:00-03
000198	Rodrigo Silva Silva	Feminino	001.000.001-98	2001-04-18	rodrigo.silva.silva198@email.com	(77) 98198-2386	2025-04-18 00:00:00-03
000199	Gabriela Ferreira Gomes	Masculino	001.000.001-99	2000-04-17	gabriela.ferreira.gomes199@email.com	(77) 98199-2393	2025-04-17 00:00:00-03
000200	Daniel Martins Lima	Masculino	001.000.002-00	1999-04-16	daniel.martins.lima200@email.com	(77) 98200-2400	2025-04-16 00:00:00-03
000201	Mariana Correia Rocha	Feminino	001.000.002-01	1998-04-15	mariana.correia.rocha201@email.com	(77) 98201-2407	2025-04-15 00:00:00-03
000202	Thiago Costa Rodrigues	Masculino	001.000.002-02	1997-04-14	thiago.costa.rodrigues202@email.com	(77) 98202-2414	2025-04-14 00:00:00-03
000203	Carolina Gomes Correia	Masculino	001.000.002-03	1996-04-13	carolina.gomes.correia203@email.com	(77) 98203-2421	2025-04-13 00:00:00-03
000204	Marcelo Cardoso Carvalho	Feminino	001.000.002-04	1995-04-12	marcelo.cardoso.carvalho204@email.com	(77) 98204-2428	2025-04-12 00:00:00-03
000205	Renata Pereira Souza	Masculino	001.000.002-05	1994-04-11	renata.pereira.souza205@email.com	(77) 98205-2435	2025-04-11 00:00:00-03
000208	Leonardo Lima Cardoso	Masculino	001.000.002-08	1991-04-08	leonardo.lima.cardoso208@email.com	(77) 98208-2456	2025-04-08 00:00:00-03
000210	Vinicius Dias Oliveira	Feminino	001.000.002-10	1989-04-06	vinicius.dias.oliveira210@email.com	(77) 98210-2470	2025-04-06 00:00:00-03
000211	Cristina Souza Ribeiro	Masculino	001.000.002-11	1988-04-05	cristina.souza.ribeiro211@email.com	(77) 98211-2477	2025-04-05 00:00:00-03
000212	Matheus Nascimento Costa	Masculino	001.000.002-12	1987-04-04	matheus.nascimento.costa212@email.com	(77) 98212-2484	2025-04-04 00:00:00-03
000214	Diego Oliveira Nascimento	Masculino	001.000.002-14	1985-04-02	diego.oliveira.nascimento214@email.com	(77) 98214-2498	2025-04-02 00:00:00-03
000215	Simone Almeida Santos	Masculino	001.000.002-15	1984-04-01	simone.almeida.santos215@email.com	(77) 98215-2505	2025-04-01 00:00:00-03
000216	Lucas Castro Martins	Feminino	001.000.002-16	1983-03-31	lucas.castro.martins216@email.com	(77) 98216-2512	2025-03-31 00:00:00-03
000217	Maria Santos Pereira	Masculino	001.000.002-17	1982-03-30	maria.santos.pereira217@email.com	(77) 98217-2519	2025-03-30 00:00:00-03
000219	Ana Ribeiro Almeida	Feminino	001.000.002-19	1980-03-28	ana.ribeiro.almeida219@email.com	(77) 98219-2533	2025-03-28 00:00:00-03
000220	Pedro Silva Silva	Outro	001.000.002-20	1979-03-27	pedro.silva.silva220@email.com	(77) 98220-2540	2025-03-27 00:00:00-03
000221	Juliana Ferreira Gomes	Masculino	001.000.002-21	1978-03-26	juliana.ferreira.gomes221@email.com	(77) 98221-2547	2025-03-26 00:00:00-03
000222	Carlos Martins Lima	Feminino	001.000.002-22	1977-03-25	carlos.martins.lima222@email.com	(77) 98222-2554	2025-03-25 00:00:00-03
000223	Fernanda Correia Rocha	Masculino	001.000.002-23	1976-03-24	fernanda.correia.rocha223@email.com	(77) 98223-2561	2025-03-24 00:00:00-03
000224	Ricardo Costa Rodrigues	Masculino	001.000.002-24	2007-03-23	ricardo.costa.rodrigues224@email.com	(77) 98224-2568	2025-03-23 00:00:00-03
000225	Paula Gomes Correia	Feminino	001.000.002-25	2006-03-22	paula.gomes.correia225@email.com	(77) 98225-2575	2025-03-22 00:00:00-03
000226	Rafael Cardoso Carvalho	Masculino	001.000.002-26	2005-03-21	rafael.cardoso.carvalho226@email.com	(77) 98226-2582	2025-03-21 00:00:00-03
000227	Camila Pereira Souza	Masculino	001.000.002-27	2004-03-20	camila.pereira.souza227@email.com	(77) 98227-2589	2025-03-20 00:00:00-03
000228	Bruno Carvalho Castro	Feminino	001.000.002-28	2003-03-19	bruno.carvalho.castro228@email.com	(77) 98228-2596	2025-03-19 00:00:00-03
000229	Luiza Ariel Santana	Feminino	123.201.977-30	2005-12-07	luizaborboleta1@outlook.com	21120397120	2025-11-11 00:00:00-03
000002	Joao Martins Lima	Masculino	001.000.000-02	2005-10-31	joao.martins.lima2@email.com	(77) 98002-1014	2025-10-31 00:00:00-03
000011	Camila Araújo Araújo	Outro	001.000.000-11	1996-10-22	camila.araujo.araujo11@email.com	(77) 98011-1077	2025-10-22 00:00:00-03
000026	André Costa Rodrigues	Masculino	001.000.000-26	1981-10-07	andre.costa.rodrigues26@email.com	(77) 98026-1182	2025-10-07 00:00:00-03
000027	Patrícia Gomes Correia	Feminino	001.000.000-27	1980-10-06	patricia.gomes.correia27@email.com	(77) 98027-1189	2025-10-06 00:00:00-03
000033	Débora Araújo Araújo	Feminino	001.000.000-33	2006-09-30	debora.araujo.araujo33@email.com	(77) 98033-1231	2025-09-30 00:00:00-03
000038	João Oliveira Nascimento	Masculino	001.000.000-38	2001-09-25	joao.oliveira.nascimento38@email.com	(77) 98038-1266	2025-09-25 00:00:00-03
000055	Gabriela Araújo Araújo	Outro	001.000.000-55	1984-09-08	gabriela.araujo.araujo55@email.com	(77) 98055-1385	2025-09-08 00:00:00-03
000062	André Castro Martins	Masculino	001.000.000-62	1977-09-01	andre.castro.martins62@email.com	(77) 98062-1434	2025-09-01 00:00:00-03
000063	Patrícia Santos Pereira	Feminino	001.000.000-63	1976-08-31	patricia.santos.pereira63@email.com	(77) 98063-1441	2025-08-31 00:00:00-03
000069	Débora Correia Rocha	Feminino	001.000.000-69	2002-08-25	debora.correia.rocha69@email.com	(77) 98069-1483	2025-08-25 00:00:00-03
000074	João Carvalho Castro	Masculino	001.000.000-74	1997-08-20	joao.carvalho.castro74@email.com	(77) 98074-1518	2025-08-20 00:00:00-03
000077	Juliana Araújo Araújo	Outro	001.000.000-77	1994-08-17	juliana.araujo.araujo77@email.com	(77) 98077-1539	2025-08-17 00:00:00-03
000098	André Lima Cardoso	Masculino	001.000.000-98	2005-07-27	andre.lima.cardoso98@email.com	(77) 98098-1686	2025-07-27 00:00:00-03
000099	Patrícia Araújo Araújo	Feminino	001.000.000-99	2004-07-26	patricia.araujo.araujo99@email.com	(77) 98099-1693	2025-07-26 00:00:00-03
000105	Débora Almeida Santos	Feminino	001.000.001-05	1998-07-20	debora.almeida.santos105@email.com	(77) 98105-1735	2025-07-20 00:00:00-03
000110	João Silva Silva	Outro	001.000.001-10	1993-07-15	joao.silva.silva110@email.com	(77) 98110-1770	2025-07-15 00:00:00-03
000121	Beatriz Araújo Araújo	Outro	001.000.001-21	1982-07-04	beatriz.araujo.araujo121@email.com	(77) 98121-1847	2025-07-04 00:00:00-03
000134	André Martins Lima	Masculino	001.000.001-34	2001-06-21	andre.martins.lima134@email.com	(77) 98134-1938	2025-06-21 00:00:00-03
000135	Patrícia Correia Rocha	Feminino	001.000.001-35	2000-06-20	patricia.correia.rocha135@email.com	(77) 98135-1945	2025-06-20 00:00:00-03
000141	Débora Monteiro Ferreira	Feminino	001.000.001-41	1994-06-14	debora.monteiro.ferreira141@email.com	(77) 98141-1987	2025-06-14 00:00:00-03
000143	Simone Araújo Araújo	Outro	001.000.001-43	1992-06-12	simone.araujo.araujo143@email.com	(77) 98143-2001	2025-06-12 00:00:00-03
000146	João Nascimento Costa	Masculino	001.000.001-46	1989-06-09	joao.nascimento.costa146@email.com	(77) 98146-2022	2025-06-09 00:00:00-03
000165	Mariana Araújo Araújo	Feminino	001.000.001-65	2002-05-21	mariana.araujo.araujo165@email.com	(77) 98165-2155	2025-05-21 00:00:00-03
000170	André Oliveira Nascimento	Masculino	001.000.001-70	1997-05-16	andre.oliveira.nascimento170@email.com	(77) 98170-2190	2025-05-16 00:00:00-03
000171	Patrícia Almeida Santos	Feminino	001.000.001-71	1996-05-15	patricia.almeida.santos171@email.com	(77) 98171-2197	2025-05-15 00:00:00-03
000177	Débora Ferreira Gomes	Feminino	001.000.001-77	1990-05-09	debora.ferreira.gomes177@email.com	(77) 98177-2239	2025-05-09 00:00:00-03
000182	João Cardoso Carvalho	Masculino	001.000.001-82	1985-05-04	joao.cardoso.carvalho182@email.com	(77) 98182-2274	2025-05-04 00:00:00-03
000187	Fernanda Araújo Araújo	Outro	001.000.001-87	1980-04-29	fernanda.araujo.araujo187@email.com	(77) 98187-2309	2025-04-29 00:00:00-03
000206	André Carvalho Castro	Masculino	001.000.002-06	1993-04-10	andre.carvalho.castro206@email.com	(77) 98206-2442	2025-04-10 00:00:00-03
000207	Patrícia Monteiro Ferreira	Feminino	001.000.002-07	1992-04-09	patricia.monteiro.ferreira207@email.com	(77) 98207-2449	2025-04-09 00:00:00-03
000209	Vanessa Araújo Araújo	Outro	001.000.002-09	1990-04-07	vanessa.araujo.araujo209@email.com	(77) 98209-2463	2025-04-07 00:00:00-03
000213	Débora Rocha Monteiro	Feminino	001.000.002-13	1986-04-03	debora.rocha.monteiro213@email.com	(77) 98213-2491	2025-04-03 00:00:00-03
000218	João Rodrigues Dias	Masculino	001.000.002-18	1981-03-29	joao.rodrigues.dias218@email.com	(77) 98218-2526	2025-03-29 00:00:00-03
\.


--
-- Data for Name: inscricoes; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.inscricoes (id_inscricao, id_aluno, id_plano, id_promocao, id_unidade, data_inicio, data_fim, status) FROM stdin;
2	000002	1	\N	3	2025-03-07	\N	ativa
3	000003	2	\N	1	2025-02-05	\N	ativa
4	000004	3	\N	2	2025-01-06	\N	ativa
6	000006	2	\N	1	2024-11-07	\N	ativa
195	000195	4	\N	1	2024-10-08	\N	cancelada
196	000196	1	\N	2	2024-09-08	\N	cancelada
197	000197	2	\N	3	2024-08-09	\N	cancelada
198	000198	3	\N	1	2024-07-10	\N	cancelada
199	000199	4	\N	2	2024-06-10	\N	cancelada
200	000200	1	\N	3	2025-01-06	\N	cancelada
201	000201	2	\N	1	2024-12-07	\N	cancelada
202	000202	3	\N	2	2024-11-07	\N	cancelada
203	000203	4	\N	3	2024-10-08	\N	cancelada
204	000204	1	\N	1	2024-09-08	\N	cancelada
205	000205	2	\N	2	2024-08-09	\N	cancelada
206	000206	3	\N	3	2024-07-10	\N	cancelada
207	000207	4	\N	1	2024-06-10	\N	cancelada
208	000208	1	\N	2	2025-01-06	\N	cancelada
209	000209	2	\N	3	2024-12-07	\N	cancelada
210	000210	3	\N	1	2024-11-07	\N	cancelada
211	000211	4	\N	2	2024-10-08	\N	cancelada
212	000212	1	\N	3	2024-09-08	\N	cancelada
215	000215	4	\N	3	2024-06-10	\N	cancelada
216	000216	1	\N	1	2025-01-06	\N	cancelada
217	000217	2	\N	2	2024-12-07	\N	cancelada
218	000218	3	\N	3	2025-03-07	2025-10-03	cancelada
219	000219	4	\N	1	2025-02-05	2025-11-02	cancelada
220	000220	1	\N	2	2025-01-06	2025-10-18	cancelada
221	000221	2	\N	3	2024-12-07	2025-10-03	cancelada
222	000222	3	\N	1	2025-05-06	2025-11-02	cancelada
223	000223	4	\N	2	2025-04-06	2025-10-18	cancelada
224	000224	1	\N	3	2025-03-07	2025-10-03	cancelada
225	000225	2	\N	1	2025-02-05	2025-11-02	cancelada
226	000226	3	\N	2	2025-01-06	2025-10-18	cancelada
227	000227	4	\N	3	2024-12-07	2025-10-03	cancelada
228	000228	1	\N	1	2025-05-06	2025-11-02	cancelada
1	000001	2	\N	2	2025-04-06	\N	ativa
62	000062	1	\N	3	2024-09-08	\N	ativa
167	000167	4	\N	3	2024-04-11	\N	ativa
168	000168	1	\N	1	2025-03-07	\N	ativa
63	000063	2	\N	1	2024-08-09	\N	ativa
64	000064	3	\N	2	2024-07-10	\N	ativa
65	000065	4	\N	3	2024-06-10	\N	ativa
66	000066	2	\N	1	2024-05-11	\N	ativa
67	000067	1	\N	2	2024-04-11	\N	ativa
69	000069	2	\N	1	2024-02-11	\N	ativa
70	000070	4	\N	2	2024-01-12	\N	ativa
74	000074	1	\N	3	2025-03-07	\N	ativa
77	000077	1	\N	3	2024-12-07	\N	ativa
78	000078	2	\N	1	2024-11-07	\N	ativa
79	000079	1	\N	2	2024-10-08	\N	ativa
80	000080	4	\N	3	2024-09-08	\N	ativa
81	000081	2	\N	1	2024-08-09	\N	ativa
82	000082	1	\N	2	2024-07-10	\N	ativa
84	000084	3	\N	1	2024-05-11	\N	ativa
86	000086	1	\N	3	2024-03-12	\N	ativa
87	000087	2	\N	1	2024-02-11	\N	ativa
88	000088	3	\N	2	2024-01-12	\N	ativa
89	000089	1	\N	3	2023-12-13	\N	ativa
91	000091	1	\N	2	2025-04-06	\N	ativa
92	000092	3	\N	3	2025-03-07	\N	ativa
93	000093	2	\N	1	2025-02-05	\N	ativa
95	000095	4	\N	3	2024-12-07	\N	ativa
96	000096	3	\N	1	2024-11-07	\N	ativa
97	000097	1	\N	2	2024-10-08	\N	ativa
98	000098	1	\N	3	2024-09-08	\N	ativa
99	000099	2	\N	1	2024-08-09	\N	ativa
100	000100	4	\N	2	2024-07-10	\N	ativa
102	000102	2	\N	1	2024-05-11	\N	ativa
104	000104	3	\N	3	2024-03-12	\N	ativa
108	000108	3	\N	1	2025-05-06	\N	ativa
110	000110	4	\N	3	2025-03-07	\N	ativa
111	000111	2	\N	1	2025-02-05	\N	ativa
76	000076	4	\N	2	2025-01-06	\N	ativa
128	000128	4	\N	3	2025-03-07	\N	ativa
31	000031	4	\N	2	2024-04-11	\N	ativa
20	000020	2	\N	3	2025-03-07	\N	ativa
25	000025	2	\N	2	2024-10-08	\N	ativa
35	000035	2	\N	3	2023-12-13	\N	ativa
40	000040	2	\N	2	2025-01-06	\N	ativa
45	000045	2	\N	1	2024-08-09	\N	ativa
50	000050	2	\N	3	2024-03-12	\N	ativa
60	000060	2	\N	1	2024-11-07	\N	ativa
75	000075	2	\N	1	2025-02-05	\N	ativa
85	000085	2	\N	2	2024-04-11	\N	ativa
138	000138	2	\N	1	2024-05-11	\N	ativa
139	000139	1	\N	2	2024-04-11	\N	ativa
140	000140	4	\N	3	2024-03-12	\N	ativa
141	000141	2	\N	1	2024-02-11	\N	ativa
142	000142	1	\N	2	2024-01-12	\N	ativa
144	000144	3	\N	1	2025-05-06	\N	ativa
145	000145	4	\N	2	2025-04-06	\N	ativa
146	000146	1	\N	3	2025-03-07	\N	ativa
147	000147	2	\N	1	2025-02-05	\N	ativa
150	000150	4	\N	1	2024-11-07	\N	ativa
153	000153	2	\N	1	2024-08-09	\N	ativa
156	000156	3	\N	1	2024-05-11	\N	ativa
158	000158	1	\N	3	2024-03-12	\N	ativa
159	000159	2	\N	1	2024-02-11	\N	ativa
161	000161	2	\N	3	2024-10-08	\N	ativa
162	000162	3	\N	1	2024-09-08	\N	ativa
163	000163	4	\N	2	2024-08-09	\N	ativa
165	000165	2	\N	1	2024-06-10	\N	ativa
112	000112	3	\N	2	2025-01-06	\N	ativa
113	000113	1	\N	3	2024-12-07	\N	ativa
114	000114	2	\N	1	2024-11-07	\N	ativa
115	000115	4	\N	2	2024-10-08	\N	ativa
117	000117	2	\N	1	2024-08-09	\N	ativa
118	000118	1	\N	2	2024-07-10	\N	ativa
119	000119	1	\N	3	2024-06-10	\N	ativa
120	000120	4	\N	1	2024-05-11	\N	ativa
123	000123	2	\N	1	2024-02-11	\N	ativa
125	000125	4	\N	3	2023-12-13	\N	ativa
126	000126	2	\N	1	2025-05-06	\N	ativa
129	000129	2	\N	1	2025-02-05	\N	ativa
130	000130	4	\N	2	2025-01-06	\N	ativa
131	000131	1	\N	3	2024-12-07	\N	ativa
132	000132	3	\N	1	2024-11-07	\N	ativa
133	000133	1	\N	2	2024-10-08	\N	ativa
134	000134	1	\N	3	2024-09-08	\N	ativa
135	000135	4	\N	1	2024-08-09	\N	ativa
136	000136	3	\N	2	2024-07-10	\N	ativa
5	000005	2	\N	3	2024-12-07	\N	ativa
73	000073	3	\N	2	2025-04-06	\N	ativa
83	000083	3	\N	3	2024-06-10	\N	ativa
94	000094	3	\N	2	2025-01-06	\N	ativa
101	000101	3	\N	3	2024-06-10	\N	ativa
103	000103	3	\N	2	2024-04-11	\N	ativa
107	000107	3	\N	3	2023-12-13	\N	ativa
109	000109	3	\N	2	2025-04-06	\N	ativa
16	000016	4	\N	2	2024-01-12	\N	ativa
169	000169	2	\N	2	2025-02-05	\N	ativa
170	000170	3	\N	3	2025-01-06	\N	ativa
172	000172	1	\N	2	2024-11-07	\N	ativa
173	000173	2	\N	3	2024-10-08	\N	ativa
174	000174	3	\N	1	2024-09-08	\N	ativa
177	000177	2	\N	1	2024-06-10	\N	ativa
178	000178	3	\N	2	2024-05-11	\N	ativa
179	000179	4	\N	3	2024-04-11	\N	ativa
181	000181	2	\N	2	2025-02-05	\N	ativa
183	000183	4	\N	1	2024-12-07	\N	ativa
185	000185	2	\N	3	2024-10-08	\N	ativa
186	000186	3	\N	1	2024-09-08	\N	ativa
187	000187	4	\N	2	2024-08-09	\N	ativa
188	000188	1	\N	3	2024-07-10	\N	ativa
189	000189	2	\N	1	2024-06-10	\N	ativa
191	000191	4	\N	3	2024-04-11	\N	ativa
193	000193	2	\N	2	2025-02-05	\N	ativa
194	000194	3	\N	3	2025-01-06	\N	ativa
213	000213	2	\N	1	2024-08-09	\N	ativa
214	000214	3	\N	2	2024-07-10	\N	ativa
11	000011	2	\N	3	2024-06-10	\N	ativa
19	000019	2	\N	2	2025-04-06	\N	ativa
22	000022	2	\N	2	2025-01-06	\N	ativa
29	000029	2	\N	3	2024-06-10	\N	ativa
34	000034	2	\N	2	2024-01-12	\N	ativa
37	000037	2	\N	2	2025-04-06	\N	ativa
49	000049	2	\N	2	2024-04-11	\N	ativa
71	000071	2	\N	3	2023-12-13	\N	ativa
106	000106	2	\N	2	2024-01-12	\N	ativa
121	000121	2	\N	2	2024-04-11	\N	ativa
122	000122	2	\N	3	2024-03-12	\N	ativa
127	000127	2	\N	2	2025-04-06	\N	ativa
137	000137	2	\N	3	2024-06-10	\N	ativa
143	000143	2	\N	3	2023-12-13	\N	ativa
151	000151	2	\N	2	2024-10-08	\N	ativa
154	000154	2	\N	2	2024-07-10	\N	ativa
157	000157	2	\N	2	2024-04-11	\N	ativa
7	000007	1	\N	2	2024-10-08	\N	ativa
8	000008	3	\N	3	2024-09-08	\N	ativa
9	000009	2	\N	1	2024-08-09	\N	ativa
10	000010	4	\N	2	2024-07-10	\N	ativa
229	000229	1	\N	1	2025-11-11	\N	ativa
12	000012	3	\N	1	2024-05-11	\N	ativa
13	000013	1	\N	2	2024-04-11	\N	ativa
14	000014	1	\N	3	2024-03-12	\N	ativa
15	000015	4	\N	1	2024-02-11	\N	ativa
17	000017	1	\N	3	2023-12-13	\N	ativa
18	000018	2	\N	1	2025-05-06	\N	ativa
21	000021	2	\N	1	2025-02-05	\N	ativa
23	000023	1	\N	3	2024-12-07	\N	ativa
24	000024	3	\N	1	2024-11-07	\N	ativa
26	000026	1	\N	3	2024-09-08	\N	ativa
27	000027	2	\N	1	2024-08-09	\N	ativa
28	000028	3	\N	2	2024-07-10	\N	ativa
30	000030	4	\N	1	2024-05-11	\N	ativa
33	000033	2	\N	1	2024-02-11	\N	ativa
36	000036	3	\N	1	2025-05-06	\N	ativa
38	000038	1	\N	3	2025-03-07	\N	ativa
39	000039	2	\N	1	2025-02-05	\N	ativa
41	000041	1	\N	3	2024-12-07	\N	ativa
42	000042	2	\N	1	2024-11-07	\N	ativa
43	000043	1	\N	2	2024-10-08	\N	ativa
44	000044	3	\N	3	2024-09-08	\N	ativa
46	000046	1	\N	2	2024-07-10	\N	ativa
184	000184	2	\N	2	2024-11-07	\N	ativa
149	000149	3	\N	3	2024-12-07	\N	ativa
164	000164	3	\N	3	2024-07-10	\N	ativa
176	000176	3	\N	3	2024-07-10	\N	ativa
180	000180	3	\N	1	2025-03-07	\N	ativa
90	000090	2	\N	1	2025-05-06	\N	ativa
148	000148	4	\N	2	2025-01-06	\N	ativa
166	000166	4	\N	2	2024-05-11	\N	ativa
192	000192	4	\N	1	2025-03-07	\N	ativa
105	000105	2	\N	1	2024-02-11	\N	ativa
32	000032	2	\N	3	2024-03-12	\N	ativa
68	000068	2	\N	3	2024-03-12	\N	ativa
72	000072	2	\N	1	2025-05-06	\N	ativa
116	000116	2	\N	3	2024-09-08	\N	ativa
124	000124	2	\N	2	2024-01-12	\N	ativa
155	000155	2	\N	3	2024-06-10	\N	ativa
160	000160	2	\N	2	2024-01-12	\N	ativa
171	000171	2	\N	1	2024-12-07	\N	ativa
175	000175	2	\N	2	2024-08-09	\N	ativa
152	000152	2	\N	3	2024-09-08	\N	ativa
47	000047	1	\N	3	2024-06-10	\N	ativa
48	000048	3	\N	1	2024-05-11	\N	ativa
51	000051	2	\N	1	2024-02-11	\N	ativa
52	000052	3	\N	2	2024-01-12	\N	ativa
53	000053	1	\N	3	2023-12-13	\N	ativa
54	000054	2	\N	1	2025-05-06	\N	ativa
55	000055	4	\N	2	2025-04-06	\N	ativa
56	000056	3	\N	3	2025-03-07	\N	ativa
57	000057	2	\N	1	2025-02-05	\N	ativa
58	000058	1	\N	2	2025-01-06	\N	ativa
59	000059	1	\N	3	2024-12-07	\N	ativa
61	000061	1	\N	2	2024-10-08	\N	ativa
182	000182	2	\N	3	2025-01-06	\N	ativa
190	000190	2	\N	2	2024-05-11	\N	ativa
\.


--
-- Data for Name: inscricoes_modalidades; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.inscricoes_modalidades (id_inscricao, id_modalidade) FROM stdin;
3	4
3	7
4	5
4	7
4	1
4	3
5	1
5	2
5	3
5	4
5	5
5	6
5	7
5	8
6	7
6	2
7	8
8	1
8	3
8	5
8	7
9	2
9	5
10	1
10	2
10	3
10	4
10	5
10	6
10	7
10	8
11	4
12	5
12	7
12	1
12	3
13	6
14	7
15	1
15	2
15	3
15	4
15	5
15	6
15	7
15	8
16	1
16	3
16	5
16	7
17	2
18	3
18	6
19	4
20	1
20	2
20	3
20	4
20	5
20	6
20	7
20	8
21	6
21	1
22	7
23	8
24	1
24	3
24	5
24	7
25	1
25	2
25	3
25	4
25	5
25	6
25	7
25	8
26	3
27	4
27	7
28	5
28	7
28	1
28	3
29	6
30	1
30	2
30	3
30	4
30	5
30	6
30	7
30	8
31	8
32	1
32	3
32	5
32	7
33	2
33	5
34	3
35	1
35	2
35	3
35	4
35	5
35	6
35	7
35	8
36	5
36	7
36	1
36	3
37	6
38	7
39	8
39	3
40	1
40	2
40	3
40	4
40	5
40	6
40	7
40	8
41	2
42	3
42	6
43	4
44	5
44	7
44	1
44	3
45	1
45	2
45	3
45	4
45	5
45	6
45	7
45	8
46	7
47	8
48	1
48	3
48	5
48	7
49	2
50	1
50	2
50	3
50	4
50	5
50	6
50	7
50	8
51	4
51	7
52	5
52	7
52	1
52	3
53	6
54	7
54	2
55	1
55	2
55	3
55	4
55	5
55	6
55	7
55	8
56	1
56	3
56	5
56	7
57	2
57	5
58	3
59	4
60	1
60	2
60	3
60	4
60	5
60	6
60	7
60	8
61	6
62	7
63	8
63	3
64	1
64	3
64	5
64	7
65	1
65	2
65	3
65	4
65	5
65	6
65	7
65	8
66	3
66	6
67	4
68	5
68	7
68	1
68	3
69	6
69	1
70	1
70	2
70	3
70	4
70	5
70	6
70	7
70	8
71	8
72	1
72	3
72	5
72	7
73	2
74	3
75	1
75	2
75	3
75	4
75	5
75	6
75	7
75	8
76	5
76	7
76	1
76	3
77	6
78	7
78	2
79	8
80	1
80	2
80	3
80	4
80	5
80	6
80	7
80	8
81	2
81	5
82	3
83	4
84	5
84	7
84	1
84	3
85	1
85	2
85	3
85	4
85	5
85	6
85	7
85	8
86	7
87	8
87	3
88	1
88	3
88	5
88	7
89	2
90	1
90	2
90	3
90	4
90	5
90	6
90	7
90	8
91	4
92	5
92	7
92	1
92	3
93	6
93	1
94	7
95	1
95	2
95	3
95	4
95	5
95	6
95	7
95	8
96	1
96	3
96	5
96	7
97	2
98	3
99	4
99	7
100	1
100	2
100	3
100	4
100	5
100	6
100	7
100	8
101	6
102	7
102	2
103	8
104	1
104	3
104	5
104	7
105	1
105	2
105	3
105	4
105	5
105	6
105	7
105	8
106	3
107	4
108	5
108	7
108	1
108	3
109	6
110	1
110	2
110	3
110	4
110	5
110	6
110	7
110	8
111	8
111	3
112	1
112	3
112	5
112	7
113	2
114	3
114	6
115	1
115	2
115	3
115	4
115	5
115	6
115	7
115	8
116	5
116	7
116	1
116	3
117	6
117	1
118	7
119	8
120	1
120	2
120	3
120	4
120	5
120	6
120	7
120	8
121	2
122	3
123	4
123	7
124	5
124	7
124	1
124	3
125	1
125	2
125	3
125	4
125	5
125	6
125	7
125	8
126	7
126	2
127	8
128	1
128	3
128	5
128	7
129	2
129	5
130	1
130	2
130	3
130	4
130	5
130	6
130	7
130	8
131	4
132	5
132	7
132	1
132	3
133	6
134	7
135	1
135	2
135	3
135	4
135	5
135	6
135	7
135	8
136	1
136	3
136	5
136	7
137	2
138	3
138	6
139	4
140	1
140	2
140	3
140	4
140	5
140	6
140	7
140	8
141	6
141	1
142	7
143	8
144	1
144	3
144	5
144	7
145	1
145	2
145	3
145	4
145	5
145	6
145	7
145	8
146	3
147	4
147	7
148	5
148	7
148	1
148	3
149	6
150	1
150	2
150	3
150	4
150	5
150	6
150	7
150	8
151	8
152	1
152	3
152	5
152	7
153	2
153	5
154	3
155	1
155	2
155	3
155	4
155	5
155	6
155	7
155	8
156	5
156	7
156	1
156	3
157	6
158	7
159	8
159	3
160	1
160	2
160	3
160	4
160	5
160	6
160	7
160	8
161	2
161	5
162	3
162	5
162	7
162	1
163	1
163	2
163	3
163	4
163	5
163	6
163	7
163	8
164	5
165	6
165	1
166	7
166	1
166	3
166	5
167	1
167	2
167	3
167	4
167	5
167	6
167	7
167	8
168	1
169	2
169	5
170	3
170	5
170	7
170	1
171	1
171	2
171	3
171	4
171	5
171	6
171	7
171	8
172	5
173	6
173	1
174	7
174	1
174	3
174	5
175	1
175	2
175	3
175	4
175	5
175	6
175	7
175	8
176	1
177	2
177	5
178	3
178	5
178	7
178	1
179	1
179	2
179	3
179	4
179	5
179	6
179	7
179	8
180	5
181	6
181	1
182	7
182	1
182	3
182	5
183	1
183	2
183	3
183	4
183	5
183	6
183	7
183	8
184	1
185	2
185	5
186	3
186	5
186	7
186	1
187	1
187	2
187	3
187	4
187	5
187	6
187	7
187	8
188	5
189	6
189	1
190	7
190	1
190	3
190	5
191	1
191	2
191	3
191	4
191	5
191	6
191	7
191	8
192	1
193	2
193	5
194	3
194	5
194	7
194	1
195	1
195	2
195	3
195	4
195	5
195	6
195	7
195	8
196	5
197	6
197	1
198	7
198	1
198	3
198	5
199	1
199	2
199	3
199	4
199	5
199	6
199	7
199	8
200	1
201	2
201	5
202	3
202	5
202	7
202	1
203	1
203	2
203	3
203	4
203	5
203	6
203	7
203	8
204	5
205	6
205	1
206	7
206	1
206	3
206	5
207	1
207	2
207	3
207	4
207	5
207	6
207	7
207	8
208	1
209	2
209	5
210	3
210	5
210	7
210	1
211	1
211	2
211	3
211	4
211	5
211	6
211	7
211	8
212	5
213	6
213	1
214	7
214	1
214	3
214	5
215	1
215	2
215	3
215	4
215	5
215	6
215	7
215	8
216	1
217	2
217	5
218	3
218	5
218	7
218	1
219	1
219	2
219	3
219	4
219	5
219	6
219	7
219	8
220	5
221	6
221	1
222	7
222	1
222	3
222	5
223	1
223	2
223	3
223	4
223	5
223	6
223	7
223	8
224	1
225	2
225	5
226	3
226	5
226	7
226	1
227	1
227	2
227	3
227	4
227	5
227	6
227	7
227	8
228	5
229	3
2	3
1	2
1	3
\.


--
-- Data for Name: itens_pagamento; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.itens_pagamento (id_item_pagamento, id_pagamento, id_tipo_transacao, valor, descricao_item) FROM stdin;
4	4	1	150.00	Mensalidade 12/2025
8	8	1	150.00	Mensalidade 12/2025
12	12	1	250.00	Mensalidade 12/2025
16	16	1	350.00	Mensalidade 12/2025
20	20	1	450.00	Mensalidade 12/2025
24	24	1	250.00	Mensalidade 12/2025
28	28	1	150.00	Mensalidade 12/2025
32	32	1	350.00	Mensalidade 12/2025
36	36	1	250.00	Mensalidade 12/2025
40	40	1	450.00	Mensalidade 12/2025
44	44	1	150.00	Mensalidade 12/2025
48	48	1	350.00	Mensalidade 12/2025
52	52	1	150.00	Mensalidade 12/2025
56	56	1	150.00	Mensalidade 12/2025
60	60	1	450.00	Mensalidade 12/2025
64	64	1	350.00	Mensalidade 12/2025
68	68	1	150.00	Mensalidade 12/2025
72	72	1	250.00	Mensalidade 12/2025
76	76	1	150.00	Mensalidade 12/2025
80	80	1	450.00	Mensalidade 12/2025
84	84	1	250.00	Mensalidade 12/2025
88	88	1	150.00	Mensalidade 12/2025
92	92	1	150.00	Mensalidade 12/2025
96	96	1	350.00	Mensalidade 12/2025
100	100	1	450.00	Mensalidade 12/2025
104	104	1	150.00	Mensalidade 12/2025
108	108	1	250.00	Mensalidade 12/2025
112	112	1	350.00	Mensalidade 12/2025
116	116	1	150.00	Mensalidade 12/2025
120	120	1	450.00	Mensalidade 12/2025
124	124	1	150.00	Mensalidade 12/2025
128	128	1	350.00	Mensalidade 12/2025
132	132	1	250.00	Mensalidade 12/2025
136	136	1	150.00	Mensalidade 12/2025
140	140	1	450.00	Mensalidade 12/2025
144	144	1	350.00	Mensalidade 12/2025
148	148	1	150.00	Mensalidade 12/2025
152	152	1	150.00	Mensalidade 12/2025
156	156	1	250.00	Mensalidade 12/2025
160	160	1	450.00	Mensalidade 12/2025
164	164	1	150.00	Mensalidade 12/2025
168	168	1	250.00	Mensalidade 12/2025
172	172	1	150.00	Mensalidade 12/2025
176	176	1	350.00	Mensalidade 12/2025
180	180	1	450.00	Mensalidade 12/2025
184	184	1	150.00	Mensalidade 12/2025
188	188	1	150.00	Mensalidade 12/2025
192	192	1	350.00	Mensalidade 12/2025
196	196	1	150.00	Mensalidade 12/2025
200	200	1	450.00	Mensalidade 12/2025
204	204	1	250.00	Mensalidade 12/2025
208	208	1	350.00	Mensalidade 12/2025
212	212	1	150.00	Mensalidade 12/2025
216	216	1	250.00	Mensalidade 12/2025
220	220	1	450.00	Mensalidade 12/2025
224	224	1	350.00	Mensalidade 12/2025
228	228	1	250.00	Mensalidade 12/2025
232	232	1	150.00	Mensalidade 12/2025
236	236	1	150.00	Mensalidade 12/2025
240	240	1	450.00	Mensalidade 12/2025
244	244	1	150.00	Mensalidade 12/2025
248	248	1	150.00	Mensalidade 12/2025
252	252	1	250.00	Mensalidade 12/2025
256	256	1	350.00	Mensalidade 12/2025
260	260	1	450.00	Mensalidade 12/2025
264	264	1	250.00	Mensalidade 12/2025
268	268	1	150.00	Mensalidade 12/2025
272	272	1	350.00	Mensalidade 12/2025
276	276	1	250.00	Mensalidade 12/2025
280	280	1	450.00	Mensalidade 12/2025
284	284	1	150.00	Mensalidade 12/2025
288	288	1	350.00	Mensalidade 12/2025
292	292	1	150.00	Mensalidade 12/2025
296	296	1	150.00	Mensalidade 12/2025
300	300	1	450.00	Mensalidade 12/2025
304	304	1	350.00	Mensalidade 12/2025
308	308	1	150.00	Mensalidade 12/2025
312	312	1	250.00	Mensalidade 12/2025
316	316	1	150.00	Mensalidade 12/2025
320	320	1	450.00	Mensalidade 12/2025
324	324	1	250.00	Mensalidade 12/2025
328	328	1	150.00	Mensalidade 12/2025
332	332	1	150.00	Mensalidade 12/2025
336	336	1	350.00	Mensalidade 12/2025
340	340	1	450.00	Mensalidade 12/2025
344	344	1	150.00	Mensalidade 12/2025
348	348	1	250.00	Mensalidade 12/2025
352	352	1	350.00	Mensalidade 12/2025
356	356	1	150.00	Mensalidade 12/2025
360	360	1	450.00	Mensalidade 12/2025
364	364	1	150.00	Mensalidade 12/2025
368	368	1	350.00	Mensalidade 12/2025
372	372	1	250.00	Mensalidade 12/2025
376	376	1	150.00	Mensalidade 12/2025
380	380	1	450.00	Mensalidade 12/2025
384	384	1	350.00	Mensalidade 12/2025
388	388	1	150.00	Mensalidade 12/2025
392	392	1	150.00	Mensalidade 12/2025
396	396	1	250.00	Mensalidade 12/2025
400	400	1	450.00	Mensalidade 12/2025
404	404	1	150.00	Mensalidade 12/2025
408	408	1	250.00	Mensalidade 12/2025
412	412	1	150.00	Mensalidade 12/2025
416	416	1	350.00	Mensalidade 12/2025
420	420	1	450.00	Mensalidade 12/2025
424	424	1	150.00	Mensalidade 12/2025
428	428	1	150.00	Mensalidade 12/2025
432	432	1	350.00	Mensalidade 12/2025
436	436	1	150.00	Mensalidade 12/2025
440	440	1	450.00	Mensalidade 12/2025
444	444	1	250.00	Mensalidade 12/2025
448	448	1	350.00	Mensalidade 12/2025
452	452	1	150.00	Mensalidade 12/2025
456	456	1	250.00	Mensalidade 12/2025
460	460	1	450.00	Mensalidade 12/2025
464	464	1	350.00	Mensalidade 12/2025
468	468	1	250.00	Mensalidade 12/2025
472	472	1	150.00	Mensalidade 12/2025
476	476	1	150.00	Mensalidade 12/2025
480	480	1	450.00	Mensalidade 12/2025
484	484	1	150.00	Mensalidade 12/2025
488	488	1	150.00	Mensalidade 12/2025
492	492	1	250.00	Mensalidade 12/2025
496	496	1	350.00	Mensalidade 12/2025
500	500	1	450.00	Mensalidade 12/2025
504	504	1	250.00	Mensalidade 12/2025
508	508	1	150.00	Mensalidade 12/2025
512	512	1	350.00	Mensalidade 12/2025
516	516	1	250.00	Mensalidade 12/2025
520	520	1	450.00	Mensalidade 12/2025
524	524	1	150.00	Mensalidade 12/2025
528	528	1	350.00	Mensalidade 12/2025
532	532	1	150.00	Mensalidade 12/2025
536	536	1	150.00	Mensalidade 12/2025
540	540	1	450.00	Mensalidade 12/2025
544	544	1	350.00	Mensalidade 12/2025
548	548	1	150.00	Mensalidade 12/2025
552	552	1	250.00	Mensalidade 12/2025
556	556	1	150.00	Mensalidade 12/2025
560	560	1	450.00	Mensalidade 12/2025
564	564	1	250.00	Mensalidade 12/2025
568	568	1	150.00	Mensalidade 12/2025
572	572	1	150.00	Mensalidade 12/2025
576	576	1	350.00	Mensalidade 12/2025
580	580	1	450.00	Mensalidade 12/2025
584	584	1	150.00	Mensalidade 12/2025
588	588	1	250.00	Mensalidade 12/2025
592	592	1	350.00	Mensalidade 12/2025
596	596	1	150.00	Mensalidade 12/2025
600	600	1	450.00	Mensalidade 12/2025
604	604	1	150.00	Mensalidade 12/2025
608	608	1	350.00	Mensalidade 12/2025
612	612	1	250.00	Mensalidade 12/2025
616	616	1	150.00	Mensalidade 12/2025
620	620	1	450.00	Mensalidade 12/2025
624	624	1	350.00	Mensalidade 12/2025
628	628	1	150.00	Mensalidade 12/2025
632	632	1	150.00	Mensalidade 12/2025
636	636	1	250.00	Mensalidade 12/2025
640	640	1	450.00	Mensalidade 12/2025
882	882	1	350.00	Mensalidade Premium - 12/2025
883	883	1	250.00	Mensalidade Light - 12/2025
884	902	1	150.00	Mensalidade Starter - novembro de 2025
885	903	1	150.00	Mensalidade Starter - 01/2026
\.


--
-- Data for Name: modalidades; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.modalidades (id_modalidade, nome) FROM stdin;
1	Jiu-Jitsu
2	MMA
3	Boxe
4	Muay Thai
5	Capoeira
6	Taekwondo
7	Kickboxing
8	Judô
\.


--
-- Data for Name: pagamentos; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.pagamentos (id_pagamento, id_inscricao, data_vencimento, valor_total_devido, valor_total_pago, status, data_pagamento) FROM stdin;
908	6	2025-06-10	250.00	250.00	pago	2025-06-11
904	1	2025-06-10	150.00	150.00	pago	2025-06-10
902	229	2025-12-10	150.00	150.00	pago	2025-11-11
8	2	2025-12-10	150.00	\N	pendente	\N
12	3	2025-12-10	250.00	\N	pendente	\N
16	4	2025-12-10	350.00	\N	pendente	\N
20	5	2025-12-10	450.00	\N	pendente	\N
24	6	2025-12-10	250.00	\N	pendente	\N
28	7	2025-12-10	150.00	\N	pendente	\N
32	8	2025-12-10	350.00	\N	pendente	\N
36	9	2025-12-10	250.00	\N	pendente	\N
40	10	2025-12-10	450.00	\N	pendente	\N
44	11	2025-12-10	150.00	\N	pendente	\N
48	12	2025-12-10	350.00	\N	pendente	\N
52	13	2025-12-10	150.00	\N	pendente	\N
56	14	2025-12-10	150.00	\N	pendente	\N
60	15	2025-12-10	450.00	\N	pendente	\N
64	16	2025-12-10	350.00	\N	pendente	\N
68	17	2025-12-10	150.00	\N	pendente	\N
72	18	2025-12-10	250.00	\N	pendente	\N
76	19	2025-12-10	150.00	\N	pendente	\N
80	20	2025-12-10	450.00	\N	pendente	\N
84	21	2025-12-10	250.00	\N	pendente	\N
88	22	2025-12-10	150.00	\N	pendente	\N
92	23	2025-12-10	150.00	\N	pendente	\N
96	24	2025-12-10	350.00	\N	pendente	\N
100	25	2025-12-10	450.00	\N	pendente	\N
104	26	2025-12-10	150.00	\N	pendente	\N
108	27	2025-12-10	250.00	\N	pendente	\N
112	28	2025-12-10	350.00	\N	pendente	\N
116	29	2025-12-10	150.00	\N	pendente	\N
120	30	2025-12-10	450.00	\N	pendente	\N
124	31	2025-12-10	150.00	\N	pendente	\N
128	32	2025-12-10	350.00	\N	pendente	\N
132	33	2025-12-10	250.00	\N	pendente	\N
136	34	2025-12-10	150.00	\N	pendente	\N
140	35	2025-12-10	450.00	\N	pendente	\N
905	2	2025-06-10	150.00	150.00	pago	2025-06-25
906	3	2025-06-10	250.00	250.00	pago	2025-06-10
907	4	2025-06-10	350.00	350.00	pago	2025-06-07
144	36	2025-12-10	350.00	\N	pendente	\N
921	24	2025-06-10	350.00	350.00	pago	2025-06-11
922	26	2025-06-10	150.00	150.00	pago	2025-06-11
910	8	2025-06-10	350.00	350.00	pago	2025-06-07
148	37	2025-12-10	150.00	\N	pendente	\N
1284	32	2025-07-10	250.00	\N	atrasado	\N
1003	94	2025-06-10	350.00	\N	atrasado	\N
903	229	2026-01-10	150.00	\N	pendente	\N
152	38	2025-12-10	150.00	\N	pendente	\N
156	39	2025-12-10	250.00	\N	pendente	\N
160	40	2025-12-10	450.00	\N	pendente	\N
164	41	2025-12-10	150.00	\N	pendente	\N
168	42	2025-12-10	250.00	\N	pendente	\N
172	43	2025-12-10	150.00	\N	pendente	\N
176	44	2025-12-10	350.00	\N	pendente	\N
180	45	2025-12-10	450.00	\N	pendente	\N
184	46	2025-12-10	150.00	\N	pendente	\N
188	47	2025-12-10	150.00	\N	pendente	\N
192	48	2025-12-10	350.00	\N	pendente	\N
196	49	2025-12-10	150.00	\N	pendente	\N
200	50	2025-12-10	450.00	\N	pendente	\N
204	51	2025-12-10	250.00	\N	pendente	\N
208	52	2025-12-10	350.00	\N	pendente	\N
212	53	2025-12-10	150.00	\N	pendente	\N
216	54	2025-12-10	250.00	\N	pendente	\N
220	55	2025-12-10	450.00	\N	pendente	\N
224	56	2025-12-10	350.00	\N	pendente	\N
228	57	2025-12-10	250.00	\N	pendente	\N
232	58	2025-12-10	150.00	\N	pendente	\N
236	59	2025-12-10	150.00	\N	pendente	\N
240	60	2025-12-10	450.00	\N	pendente	\N
244	61	2025-12-10	150.00	\N	pendente	\N
248	62	2025-12-10	150.00	\N	pendente	\N
252	63	2025-12-10	250.00	\N	pendente	\N
256	64	2025-12-10	350.00	\N	pendente	\N
260	65	2025-12-10	450.00	\N	pendente	\N
264	66	2025-12-10	250.00	\N	pendente	\N
268	67	2025-12-10	150.00	\N	pendente	\N
272	68	2025-12-10	350.00	\N	pendente	\N
276	69	2025-12-10	250.00	\N	pendente	\N
280	70	2025-12-10	450.00	\N	pendente	\N
913	12	2025-06-10	350.00	350.00	pago	2025-06-07
914	13	2025-06-10	150.00	150.00	pago	2025-06-07
1013	25	2025-06-10	250.00	\N	atrasado	\N
916	15	2025-06-10	450.00	450.00	pago	2025-06-08
284	71	2025-12-10	150.00	\N	pendente	\N
288	72	2025-12-10	350.00	\N	pendente	\N
292	73	2025-12-10	150.00	\N	pendente	\N
296	74	2025-12-10	150.00	\N	pendente	\N
300	75	2025-12-10	450.00	\N	pendente	\N
304	76	2025-12-10	350.00	\N	pendente	\N
308	77	2025-12-10	150.00	\N	pendente	\N
312	78	2025-12-10	250.00	\N	pendente	\N
316	79	2025-12-10	150.00	\N	pendente	\N
320	80	2025-12-10	450.00	\N	pendente	\N
324	81	2025-12-10	250.00	\N	pendente	\N
328	82	2025-12-10	150.00	\N	pendente	\N
332	83	2025-12-10	150.00	\N	pendente	\N
336	84	2025-12-10	350.00	\N	pendente	\N
340	85	2025-12-10	450.00	\N	pendente	\N
344	86	2025-12-10	150.00	\N	pendente	\N
348	87	2025-12-10	250.00	\N	pendente	\N
352	88	2025-12-10	350.00	\N	pendente	\N
356	89	2025-12-10	150.00	\N	pendente	\N
360	90	2025-12-10	450.00	\N	pendente	\N
364	91	2025-12-10	150.00	\N	pendente	\N
368	92	2025-12-10	350.00	\N	pendente	\N
372	93	2025-12-10	250.00	\N	pendente	\N
376	94	2025-12-10	150.00	\N	pendente	\N
380	95	2025-12-10	450.00	\N	pendente	\N
384	96	2025-12-10	350.00	\N	pendente	\N
388	97	2025-12-10	150.00	\N	pendente	\N
392	98	2025-12-10	150.00	\N	pendente	\N
396	99	2025-12-10	250.00	\N	pendente	\N
400	100	2025-12-10	450.00	\N	pendente	\N
404	101	2025-12-10	150.00	\N	pendente	\N
408	102	2025-12-10	250.00	\N	pendente	\N
412	103	2025-12-10	150.00	\N	pendente	\N
416	104	2025-12-10	350.00	\N	pendente	\N
420	105	2025-12-10	450.00	\N	pendente	\N
917	17	2025-06-10	150.00	150.00	pago	2025-06-10
919	21	2025-06-10	250.00	250.00	pago	2025-06-08
424	106	2025-12-10	150.00	\N	pendente	\N
428	107	2025-12-10	150.00	\N	pendente	\N
432	108	2025-12-10	350.00	\N	pendente	\N
436	109	2025-12-10	150.00	\N	pendente	\N
440	110	2025-12-10	450.00	\N	pendente	\N
444	111	2025-12-10	250.00	\N	pendente	\N
448	112	2025-12-10	350.00	\N	pendente	\N
452	113	2025-12-10	150.00	\N	pendente	\N
456	114	2025-12-10	250.00	\N	pendente	\N
460	115	2025-12-10	450.00	\N	pendente	\N
464	116	2025-12-10	350.00	\N	pendente	\N
468	117	2025-12-10	250.00	\N	pendente	\N
472	118	2025-12-10	150.00	\N	pendente	\N
476	119	2025-12-10	150.00	\N	pendente	\N
480	120	2025-12-10	450.00	\N	pendente	\N
484	121	2025-12-10	150.00	\N	pendente	\N
488	122	2025-12-10	150.00	\N	pendente	\N
492	123	2025-12-10	250.00	\N	pendente	\N
496	124	2025-12-10	350.00	\N	pendente	\N
500	125	2025-12-10	450.00	\N	pendente	\N
504	126	2025-12-10	250.00	\N	pendente	\N
508	127	2025-12-10	150.00	\N	pendente	\N
512	128	2025-12-10	350.00	\N	pendente	\N
516	129	2025-12-10	250.00	\N	pendente	\N
520	130	2025-12-10	450.00	\N	pendente	\N
524	131	2025-12-10	150.00	\N	pendente	\N
528	132	2025-12-10	350.00	\N	pendente	\N
532	133	2025-12-10	150.00	\N	pendente	\N
536	134	2025-12-10	150.00	\N	pendente	\N
540	135	2025-12-10	450.00	\N	pendente	\N
544	136	2025-12-10	350.00	\N	pendente	\N
4	1	2025-12-10	150.00	150.00	pago	2025-11-17
548	137	2025-12-10	150.00	\N	pendente	\N
552	138	2025-12-10	250.00	\N	pendente	\N
556	139	2025-12-10	150.00	\N	pendente	\N
560	140	2025-12-10	450.00	\N	pendente	\N
920	23	2025-06-10	150.00	150.00	pago	2025-06-11
933	44	2025-06-10	350.00	350.00	pago	2025-06-11
1028	146	2025-06-10	150.00	\N	atrasado	\N
923	27	2025-06-10	250.00	250.00	pago	2025-06-09
564	141	2025-12-10	250.00	\N	pendente	\N
568	142	2025-12-10	150.00	\N	pendente	\N
572	143	2025-12-10	150.00	\N	pendente	\N
576	144	2025-12-10	350.00	\N	pendente	\N
580	145	2025-12-10	450.00	\N	pendente	\N
584	146	2025-12-10	150.00	\N	pendente	\N
588	147	2025-12-10	250.00	\N	pendente	\N
592	148	2025-12-10	350.00	\N	pendente	\N
596	149	2025-12-10	150.00	\N	pendente	\N
600	150	2025-12-10	450.00	\N	pendente	\N
604	151	2025-12-10	150.00	\N	pendente	\N
608	152	2025-12-10	350.00	\N	pendente	\N
612	153	2025-12-10	250.00	\N	pendente	\N
616	154	2025-12-10	150.00	\N	pendente	\N
620	155	2025-12-10	450.00	\N	pendente	\N
624	156	2025-12-10	350.00	\N	pendente	\N
628	157	2025-12-10	150.00	\N	pendente	\N
632	158	2025-12-10	150.00	\N	pendente	\N
636	159	2025-12-10	250.00	\N	pendente	\N
640	160	2025-12-10	450.00	\N	pendente	\N
925	30	2025-06-10	450.00	450.00	pago	2025-06-09
926	33	2025-06-10	250.00	250.00	pago	2025-06-09
927	36	2025-06-10	350.00	350.00	pago	2025-06-09
928	38	2025-06-10	150.00	150.00	pago	2025-06-09
929	39	2025-06-10	250.00	250.00	pago	2025-06-07
930	41	2025-06-10	150.00	150.00	pago	2025-06-10
937	51	2025-06-10	250.00	250.00	pago	2025-06-11
932	43	2025-06-10	150.00	150.00	pago	2025-06-10
938	52	2025-06-10	350.00	350.00	pago	2025-06-20
941	55	2025-06-10	450.00	450.00	pago	2025-06-11
935	47	2025-06-10	150.00	150.00	pago	2025-06-09
936	48	2025-06-10	350.00	350.00	pago	2025-06-10
943	57	2025-06-10	250.00	250.00	pago	2025-06-11
954	70	2025-06-10	450.00	450.00	pago	2025-06-11
955	74	2025-06-10	150.00	150.00	pago	2025-06-29
940	54	2025-06-10	250.00	250.00	pago	2025-06-08
956	77	2025-06-10	150.00	150.00	pago	2025-06-11
942	56	2025-06-10	350.00	350.00	pago	2025-06-07
882	214	2025-12-10	350.00	\N	pendente	\N
883	213	2025-12-10	250.00	\N	pendente	\N
957	78	2025-06-10	250.00	250.00	pago	2025-06-11
944	58	2025-06-10	150.00	150.00	pago	2025-06-09
924	28	2025-06-10	350.00	\N	atrasado	\N
946	61	2025-06-10	150.00	150.00	pago	2025-06-09
947	62	2025-06-10	150.00	150.00	pago	2025-06-07
948	63	2025-06-10	250.00	250.00	pago	2025-06-07
949	64	2025-06-10	350.00	350.00	pago	2025-06-07
950	65	2025-06-10	450.00	450.00	pago	2025-06-09
952	67	2025-06-10	150.00	150.00	pago	2025-06-10
953	69	2025-06-10	250.00	250.00	pago	2025-06-09
965	88	2025-06-10	350.00	350.00	pago	2025-06-22
967	91	2025-06-10	150.00	150.00	pago	2025-06-11
968	92	2025-06-10	350.00	350.00	pago	2025-06-23
971	96	2025-06-10	350.00	350.00	pago	2025-06-21
959	80	2025-06-10	450.00	450.00	pago	2025-06-09
960	81	2025-06-10	250.00	250.00	pago	2025-06-07
962	84	2025-06-10	350.00	350.00	pago	2025-06-09
963	86	2025-06-10	150.00	150.00	pago	2025-06-10
964	87	2025-06-10	250.00	250.00	pago	2025-06-08
974	99	2025-06-10	250.00	250.00	pago	2025-06-11
966	89	2025-06-10	150.00	150.00	pago	2025-06-08
976	102	2025-06-10	250.00	250.00	pago	2025-06-11
988	120	2025-06-10	450.00	450.00	pago	2025-06-11
969	93	2025-06-10	250.00	250.00	pago	2025-06-10
970	95	2025-06-10	450.00	450.00	pago	2025-06-08
989	123	2025-06-10	250.00	250.00	pago	2025-06-11
972	97	2025-06-10	150.00	150.00	pago	2025-06-09
973	98	2025-06-10	150.00	150.00	pago	2025-06-08
991	126	2025-06-10	250.00	250.00	pago	2025-06-11
975	100	2025-06-10	450.00	450.00	pago	2025-06-08
1004	101	2025-06-10	350.00	350.00	pago	2025-06-11
977	104	2025-06-10	350.00	350.00	pago	2025-06-07
1005	103	2025-06-10	350.00	350.00	pago	2025-06-11
979	110	2025-06-10	450.00	450.00	pago	2025-06-10
980	111	2025-06-10	250.00	250.00	pago	2025-06-09
981	112	2025-06-10	350.00	350.00	pago	2025-06-09
982	113	2025-06-10	150.00	150.00	pago	2025-06-07
983	114	2025-06-10	250.00	250.00	pago	2025-06-07
984	115	2025-06-10	450.00	450.00	pago	2025-06-10
985	117	2025-06-10	250.00	250.00	pago	2025-06-07
986	118	2025-06-10	150.00	150.00	pago	2025-06-07
987	119	2025-06-10	150.00	150.00	pago	2025-06-08
1026	144	2025-06-10	350.00	350.00	pago	2025-06-18
1027	145	2025-06-10	450.00	450.00	pago	2025-06-11
990	125	2025-06-10	450.00	450.00	pago	2025-06-08
1029	147	2025-06-10	250.00	250.00	pago	2025-06-11
992	129	2025-06-10	250.00	250.00	pago	2025-06-09
993	130	2025-06-10	450.00	450.00	pago	2025-06-07
994	131	2025-06-10	150.00	150.00	pago	2025-06-10
995	132	2025-06-10	350.00	350.00	pago	2025-06-08
996	133	2025-06-10	150.00	150.00	pago	2025-06-07
997	134	2025-06-10	150.00	150.00	pago	2025-06-10
998	135	2025-06-10	450.00	450.00	pago	2025-06-10
999	136	2025-06-10	350.00	350.00	pago	2025-06-07
1000	5	2025-06-10	250.00	250.00	pago	2025-06-08
1001	73	2025-06-10	350.00	350.00	pago	2025-06-09
1002	83	2025-06-10	350.00	350.00	pago	2025-06-09
958	79	2025-06-10	150.00	\N	atrasado	\N
1032	156	2025-06-10	350.00	\N	atrasado	\N
939	53	2025-06-10	150.00	150.00	pago	2025-06-11
1006	107	2025-06-10	350.00	350.00	pago	2025-06-09
1007	109	2025-06-10	350.00	350.00	pago	2025-06-10
1008	16	2025-06-10	450.00	450.00	pago	2025-06-08
1010	128	2025-06-10	450.00	450.00	pago	2025-06-07
1011	31	2025-06-10	450.00	450.00	pago	2025-06-08
1012	20	2025-06-10	250.00	250.00	pago	2025-06-07
961	82	2025-06-10	150.00	\N	atrasado	\N
1014	35	2025-06-10	250.00	250.00	pago	2025-06-09
1015	40	2025-06-10	250.00	250.00	pago	2025-06-08
1053	187	2025-06-10	450.00	450.00	pago	2025-06-11
1055	189	2025-06-10	250.00	250.00	pago	2025-06-11
1018	60	2025-06-10	250.00	250.00	pago	2025-06-10
1019	75	2025-06-10	250.00	250.00	pago	2025-06-10
1020	85	2025-06-10	250.00	250.00	pago	2025-06-07
1021	138	2025-06-10	250.00	250.00	pago	2025-06-10
1022	139	2025-06-10	150.00	150.00	pago	2025-06-07
951	66	2025-06-10	250.00	\N	atrasado	\N
1024	141	2025-06-10	250.00	250.00	pago	2025-06-07
1025	142	2025-06-10	150.00	150.00	pago	2025-06-07
1068	71	2025-06-10	250.00	250.00	pago	2025-06-11
1078	184	2025-06-10	250.00	250.00	pago	2025-06-11
1084	148	2025-06-10	450.00	450.00	pago	2025-06-17
1009	76	2025-06-10	450.00	\N	atrasado	\N
1031	153	2025-06-10	250.00	250.00	pago	2025-06-10
934	46	2025-06-10	150.00	150.00	pago	2025-11-17
1249	187	2025-07-10	450.00	\N	atrasado	\N
1192	133	2025-07-10	150.00	\N	atrasado	\N
1289	155	2025-07-10	250.00	\N	atrasado	\N
1216	85	2025-07-10	250.00	\N	atrasado	\N
1204	16	2025-07-10	450.00	\N	atrasado	\N
1214	60	2025-07-10	250.00	\N	atrasado	\N
1185	123	2025-07-10	250.00	\N	atrasado	\N
2952	51	2025-02-10	250.00	\N	atrasado	\N
1033	158	2025-06-10	150.00	150.00	pago	2025-06-07
1034	159	2025-06-10	250.00	250.00	pago	2025-06-11
1035	161	2025-06-10	250.00	250.00	pago	2025-06-08
1036	162	2025-06-10	350.00	350.00	pago	2025-06-11
1037	163	2025-06-10	450.00	450.00	pago	2025-06-10
1038	165	2025-06-10	250.00	250.00	pago	2025-06-09
1040	168	2025-06-10	150.00	150.00	pago	2025-06-08
1041	169	2025-06-10	250.00	250.00	pago	2025-06-10
1042	170	2025-06-10	350.00	350.00	pago	2025-06-08
1043	172	2025-06-10	150.00	150.00	pago	2025-06-07
1044	173	2025-06-10	250.00	250.00	pago	2025-06-08
1045	174	2025-06-10	350.00	350.00	pago	2025-06-09
1046	177	2025-06-10	250.00	250.00	pago	2025-06-10
1047	178	2025-06-10	350.00	350.00	pago	2025-06-10
1049	181	2025-06-10	250.00	250.00	pago	2025-06-07
1050	183	2025-06-10	450.00	450.00	pago	2025-06-10
1051	185	2025-06-10	250.00	250.00	pago	2025-06-15
1052	186	2025-06-10	350.00	350.00	pago	2025-06-10
1088	32	2025-06-10	250.00	250.00	pago	2025-06-11
1054	188	2025-06-10	150.00	150.00	pago	2025-06-09
1089	68	2025-06-10	250.00	250.00	pago	2025-06-20
1056	191	2025-06-10	450.00	450.00	pago	2025-06-10
1057	193	2025-06-10	250.00	250.00	pago	2025-06-07
1058	194	2025-06-10	350.00	350.00	pago	2025-06-09
1059	213	2025-06-10	250.00	250.00	pago	2025-06-09
1060	214	2025-06-10	350.00	350.00	pago	2025-06-07
1061	11	2025-06-10	250.00	250.00	pago	2025-06-09
1062	19	2025-06-10	250.00	250.00	pago	2025-06-07
1063	22	2025-06-10	250.00	250.00	pago	2025-06-07
1064	29	2025-06-10	250.00	250.00	pago	2025-06-09
1065	34	2025-06-10	250.00	250.00	pago	2025-06-07
1039	167	2025-06-10	450.00	\N	atrasado	\N
1067	49	2025-06-10	250.00	250.00	pago	2025-06-08
1093	155	2025-06-10	250.00	250.00	pago	2025-06-11
1069	106	2025-06-10	250.00	250.00	pago	2025-06-09
1070	121	2025-06-10	250.00	250.00	pago	2025-06-07
1097	152	2025-06-10	250.00	250.00	pago	2025-06-11
1072	127	2025-06-10	250.00	250.00	pago	2025-06-10
1048	179	2025-06-10	450.00	\N	atrasado	\N
1074	143	2025-06-10	250.00	250.00	pago	2025-06-10
1075	151	2025-06-10	250.00	250.00	pago	2025-06-10
1076	154	2025-06-10	250.00	250.00	pago	2025-06-07
1077	157	2025-06-10	250.00	250.00	pago	2025-06-08
1100	1	2025-07-10	150.00	150.00	pago	2025-07-11
1079	149	2025-06-10	350.00	350.00	pago	2025-06-09
1080	164	2025-06-10	350.00	350.00	pago	2025-06-09
1081	176	2025-06-10	350.00	350.00	pago	2025-06-07
1082	180	2025-06-10	350.00	350.00	pago	2025-06-10
1083	90	2025-06-10	250.00	250.00	pago	2025-06-08
1118	26	2025-07-10	150.00	150.00	pago	2025-07-11
1085	166	2025-06-10	450.00	450.00	pago	2025-06-07
1086	192	2025-06-10	450.00	450.00	pago	2025-06-09
1087	105	2025-06-10	250.00	250.00	pago	2025-06-08
1121	30	2025-07-10	450.00	450.00	pago	2025-07-11
1123	36	2025-07-10	350.00	350.00	pago	2025-07-11
1090	72	2025-06-10	250.00	250.00	pago	2025-06-09
1091	116	2025-06-10	250.00	250.00	pago	2025-06-08
1092	124	2025-06-10	250.00	250.00	pago	2025-06-09
1125	39	2025-07-10	250.00	250.00	pago	2025-07-11
1094	160	2025-06-10	250.00	250.00	pago	2025-06-09
1095	171	2025-06-10	250.00	250.00	pago	2025-06-10
1096	175	2025-06-10	250.00	250.00	pago	2025-06-08
1126	41	2025-07-10	150.00	150.00	pago	2025-07-11
1098	182	2025-06-10	250.00	250.00	pago	2025-06-07
1099	190	2025-06-10	250.00	250.00	pago	2025-06-07
1128	43	2025-07-10	150.00	150.00	pago	2025-07-11
1101	2	2025-07-10	150.00	150.00	pago	2025-07-10
1102	3	2025-07-10	250.00	250.00	pago	2025-07-08
1103	4	2025-07-10	350.00	350.00	pago	2025-07-08
1104	6	2025-07-10	250.00	250.00	pago	2025-07-10
1105	7	2025-07-10	150.00	150.00	pago	2025-07-09
1106	8	2025-07-10	350.00	350.00	pago	2025-07-08
1107	9	2025-07-10	250.00	250.00	pago	2025-07-10
1108	10	2025-07-10	450.00	450.00	pago	2025-07-08
1116	23	2025-07-10	150.00	\N	atrasado	\N
1110	13	2025-07-10	150.00	150.00	pago	2025-07-09
1134	52	2025-07-10	350.00	350.00	pago	2025-07-11
1112	15	2025-07-10	450.00	450.00	pago	2025-07-07
1113	17	2025-07-10	150.00	150.00	pago	2025-07-07
1114	18	2025-07-10	250.00	250.00	pago	2025-07-08
1115	21	2025-07-10	250.00	250.00	pago	2025-07-10
1117	24	2025-07-10	350.00	350.00	pago	2025-07-08
1144	63	2025-07-10	250.00	250.00	pago	2025-07-20
1150	70	2025-07-10	450.00	450.00	pago	2025-07-11
1120	28	2025-07-10	350.00	350.00	pago	2025-07-08
1153	78	2025-07-10	250.00	250.00	pago	2025-07-11
1420	146	2025-08-10	150.00	\N	atrasado	\N
1156	81	2025-07-10	250.00	250.00	pago	2025-07-11
1124	38	2025-07-10	150.00	150.00	pago	2025-07-09
1158	84	2025-07-10	350.00	350.00	pago	2025-07-11
1171	100	2025-07-10	450.00	450.00	pago	2025-07-11
1127	42	2025-07-10	250.00	250.00	pago	2025-07-08
1176	111	2025-07-10	250.00	250.00	pago	2025-07-11
1129	44	2025-07-10	350.00	350.00	pago	2025-07-09
1130	46	2025-07-10	150.00	150.00	pago	2025-07-08
1485	155	2025-08-10	250.00	\N	atrasado	\N
1132	48	2025-07-10	350.00	350.00	pago	2025-07-10
1133	51	2025-07-10	250.00	250.00	pago	2025-07-09
1181	117	2025-07-10	250.00	250.00	pago	2025-07-11
1135	53	2025-07-10	150.00	150.00	pago	2025-07-08
1136	54	2025-07-10	250.00	250.00	pago	2025-07-07
1137	55	2025-07-10	450.00	450.00	pago	2025-07-07
1138	56	2025-07-10	350.00	350.00	pago	2025-07-10
1139	57	2025-07-10	250.00	250.00	pago	2025-07-10
1140	58	2025-07-10	150.00	150.00	pago	2025-07-09
1141	59	2025-07-10	150.00	150.00	pago	2025-07-08
1142	61	2025-07-10	150.00	150.00	pago	2025-07-09
1143	62	2025-07-10	150.00	150.00	pago	2025-07-09
1183	119	2025-07-10	150.00	150.00	pago	2025-07-11
1145	64	2025-07-10	350.00	350.00	pago	2025-07-10
1146	65	2025-07-10	450.00	450.00	pago	2025-07-10
1147	66	2025-07-10	250.00	250.00	pago	2025-07-08
1148	67	2025-07-10	150.00	150.00	pago	2025-07-09
1149	69	2025-07-10	250.00	250.00	pago	2025-07-08
1186	125	2025-07-10	450.00	450.00	pago	2025-07-11
1151	74	2025-07-10	150.00	150.00	pago	2025-07-08
1152	77	2025-07-10	150.00	150.00	pago	2025-07-07
1066	37	2025-06-10	250.00	\N	atrasado	\N
1154	79	2025-07-10	150.00	150.00	pago	2025-07-07
1155	80	2025-07-10	450.00	450.00	pago	2025-07-10
1073	137	2025-06-10	250.00	\N	atrasado	\N
1157	82	2025-07-10	150.00	150.00	pago	2025-07-07
1348	77	2025-08-10	150.00	\N	atrasado	\N
1159	86	2025-07-10	150.00	150.00	pago	2025-07-07
1160	87	2025-07-10	250.00	250.00	pago	2025-07-07
1161	88	2025-07-10	350.00	350.00	pago	2025-07-10
1023	140	2025-06-10	450.00	\N	atrasado	\N
1163	91	2025-07-10	150.00	150.00	pago	2025-07-09
1164	92	2025-07-10	350.00	350.00	pago	2025-07-08
1165	93	2025-07-10	250.00	250.00	pago	2025-07-09
1166	95	2025-07-10	450.00	450.00	pago	2025-07-07
1167	96	2025-07-10	350.00	350.00	pago	2025-07-10
1168	97	2025-07-10	150.00	150.00	pago	2025-07-09
1131	47	2025-07-10	150.00	\N	atrasado	\N
1109	12	2025-07-10	350.00	\N	atrasado	\N
931	42	2025-06-10	250.00	250.00	pago	2025-11-17
2970	80	2025-02-10	450.00	\N	atrasado	\N
1169	98	2025-07-10	150.00	150.00	pago	2025-07-08
1269	137	2025-07-10	250.00	\N	atrasado	\N
1187	126	2025-07-10	250.00	250.00	pago	2025-07-15
1172	102	2025-07-10	250.00	250.00	pago	2025-07-08
1173	104	2025-07-10	350.00	350.00	pago	2025-07-08
1191	132	2025-07-10	350.00	350.00	pago	2025-07-30
1175	110	2025-07-10	450.00	450.00	pago	2025-07-08
1177	112	2025-07-10	350.00	350.00	pago	2025-07-07
1178	113	2025-07-10	150.00	150.00	pago	2025-07-10
1179	114	2025-07-10	250.00	250.00	pago	2025-07-10
1180	115	2025-07-10	450.00	450.00	pago	2025-07-07
1196	5	2025-07-10	250.00	250.00	pago	2025-07-11
1182	118	2025-07-10	150.00	150.00	pago	2025-07-07
1197	73	2025-07-10	350.00	350.00	pago	2025-07-11
1184	120	2025-07-10	450.00	450.00	pago	2025-07-07
1200	101	2025-07-10	350.00	350.00	pago	2025-07-11
1188	129	2025-07-10	250.00	250.00	pago	2025-07-08
1189	130	2025-07-10	450.00	450.00	pago	2025-07-09
1190	131	2025-07-10	150.00	150.00	pago	2025-07-10
1202	107	2025-07-10	350.00	350.00	pago	2025-07-11
1206	128	2025-07-10	450.00	450.00	pago	2025-07-25
1193	134	2025-07-10	150.00	150.00	pago	2025-07-10
1194	135	2025-07-10	450.00	450.00	pago	2025-07-10
1195	136	2025-07-10	350.00	350.00	pago	2025-07-09
1212	45	2025-07-10	250.00	250.00	pago	2025-07-24
1215	75	2025-07-10	250.00	250.00	pago	2025-07-11
1217	138	2025-07-10	250.00	250.00	pago	2025-07-11
1199	94	2025-07-10	350.00	350.00	pago	2025-07-08
1223	145	2025-07-10	450.00	450.00	pago	2025-07-11
1201	103	2025-07-10	350.00	350.00	pago	2025-07-10
1226	150	2025-07-10	450.00	450.00	pago	2025-07-11
1203	109	2025-07-10	350.00	350.00	pago	2025-07-09
1205	76	2025-07-10	450.00	450.00	pago	2025-07-10
1235	167	2025-07-10	450.00	450.00	pago	2025-07-22
1207	31	2025-07-10	450.00	450.00	pago	2025-07-07
1208	20	2025-07-10	250.00	250.00	pago	2025-07-07
1209	25	2025-07-10	250.00	250.00	pago	2025-07-10
1210	35	2025-07-10	250.00	250.00	pago	2025-07-08
1211	40	2025-07-10	250.00	250.00	pago	2025-07-08
1238	170	2025-07-10	350.00	350.00	pago	2025-07-11
1213	50	2025-07-10	250.00	250.00	pago	2025-07-07
1247	185	2025-07-10	250.00	250.00	pago	2025-07-11
1218	139	2025-07-10	150.00	150.00	pago	2025-07-10
1219	140	2025-07-10	450.00	450.00	pago	2025-07-10
1221	142	2025-07-10	150.00	150.00	pago	2025-07-08
1222	144	2025-07-10	350.00	350.00	pago	2025-07-08
1251	189	2025-07-10	250.00	250.00	pago	2025-07-11
1224	146	2025-07-10	150.00	150.00	pago	2025-07-07
1225	147	2025-07-10	250.00	250.00	pago	2025-07-10
1252	191	2025-07-10	450.00	450.00	pago	2025-07-11
1227	153	2025-07-10	250.00	250.00	pago	2025-07-09
1228	156	2025-07-10	350.00	350.00	pago	2025-07-09
1229	158	2025-07-10	150.00	150.00	pago	2025-07-07
1230	159	2025-07-10	250.00	250.00	pago	2025-07-10
1231	161	2025-07-10	250.00	250.00	pago	2025-07-08
1232	162	2025-07-10	350.00	350.00	pago	2025-07-08
1253	193	2025-07-10	250.00	250.00	pago	2025-07-11
1234	165	2025-07-10	250.00	250.00	pago	2025-07-07
1256	214	2025-07-10	350.00	350.00	pago	2025-07-11
1236	168	2025-07-10	150.00	150.00	pago	2025-07-08
1237	169	2025-07-10	250.00	250.00	pago	2025-07-09
1257	11	2025-07-10	250.00	250.00	pago	2025-07-11
1239	172	2025-07-10	150.00	150.00	pago	2025-07-08
1240	173	2025-07-10	250.00	250.00	pago	2025-07-07
1241	174	2025-07-10	350.00	350.00	pago	2025-07-09
1242	177	2025-07-10	250.00	250.00	pago	2025-07-09
1243	178	2025-07-10	350.00	350.00	pago	2025-07-10
1245	181	2025-07-10	250.00	250.00	pago	2025-07-10
1246	183	2025-07-10	450.00	450.00	pago	2025-07-09
1258	19	2025-07-10	250.00	250.00	pago	2025-07-11
1248	186	2025-07-10	350.00	350.00	pago	2025-07-09
1259	22	2025-07-10	250.00	250.00	pago	2025-07-11
1250	188	2025-07-10	150.00	150.00	pago	2025-07-09
1261	34	2025-07-10	250.00	250.00	pago	2025-07-11
1263	49	2025-07-10	250.00	250.00	pago	2025-07-11
1264	71	2025-07-10	250.00	250.00	pago	2025-07-11
1254	194	2025-07-10	350.00	350.00	pago	2025-07-08
1255	213	2025-07-10	250.00	250.00	pago	2025-07-10
1274	184	2025-07-10	250.00	250.00	pago	2025-07-11
1277	176	2025-07-10	350.00	350.00	pago	2025-07-11
1288	124	2025-07-10	250.00	250.00	pago	2025-07-17
1293	152	2025-07-10	250.00	250.00	pago	2025-07-11
1260	29	2025-07-10	250.00	250.00	pago	2025-07-10
1294	182	2025-07-10	250.00	250.00	pago	2025-07-11
1262	37	2025-07-10	250.00	250.00	pago	2025-07-07
1303	9	2025-08-10	250.00	250.00	pago	2025-08-11
1304	10	2025-08-10	450.00	450.00	pago	2025-08-17
1265	106	2025-07-10	250.00	250.00	pago	2025-07-07
1266	121	2025-07-10	250.00	250.00	pago	2025-07-10
1267	122	2025-07-10	250.00	250.00	pago	2025-07-08
1270	143	2025-07-10	250.00	250.00	pago	2025-07-10
1271	151	2025-07-10	250.00	250.00	pago	2025-07-07
1272	154	2025-07-10	250.00	250.00	pago	2025-07-09
1273	157	2025-07-10	250.00	250.00	pago	2025-07-07
1174	108	2025-07-10	350.00	350.00	pago	2025-07-11
1275	149	2025-07-10	350.00	350.00	pago	2025-07-08
1276	164	2025-07-10	350.00	350.00	pago	2025-07-07
1312	23	2025-08-10	150.00	150.00	pago	2025-08-11
1278	180	2025-07-10	350.00	350.00	pago	2025-07-07
1279	90	2025-07-10	250.00	250.00	pago	2025-07-09
1280	148	2025-07-10	450.00	450.00	pago	2025-07-09
1313	24	2025-08-10	350.00	350.00	pago	2025-08-11
1282	192	2025-07-10	450.00	450.00	pago	2025-07-09
1285	68	2025-07-10	250.00	250.00	pago	2025-07-07
1286	72	2025-07-10	250.00	250.00	pago	2025-07-09
1287	116	2025-07-10	250.00	250.00	pago	2025-07-10
1316	28	2025-08-10	350.00	350.00	pago	2025-08-11
1290	160	2025-07-10	250.00	250.00	pago	2025-07-07
1291	171	2025-07-10	250.00	250.00	pago	2025-07-07
1292	175	2025-07-10	250.00	250.00	pago	2025-07-07
1317	30	2025-08-10	450.00	450.00	pago	2025-08-11
1318	33	2025-08-10	250.00	250.00	pago	2025-08-21
1296	1	2025-08-10	150.00	150.00	pago	2025-08-08
1297	2	2025-08-10	150.00	150.00	pago	2025-08-08
1298	3	2025-08-10	250.00	250.00	pago	2025-08-09
1299	4	2025-08-10	350.00	350.00	pago	2025-08-09
1300	6	2025-08-10	250.00	250.00	pago	2025-08-10
1301	7	2025-08-10	150.00	150.00	pago	2025-08-09
1302	8	2025-08-10	350.00	350.00	pago	2025-08-08
945	59	2025-06-10	150.00	\N	atrasado	\N
1030	150	2025-06-10	450.00	\N	atrasado	\N
2201	104	2024-08-10	350.00	350.00	pago	2024-08-09
2202	117	2024-08-10	250.00	250.00	pago	2024-08-15
2203	118	2024-08-10	150.00	150.00	pago	2024-08-10
2204	119	2024-08-10	150.00	150.00	pago	2024-08-09
2205	120	2024-08-10	450.00	450.00	pago	2024-08-13
2206	123	2024-08-10	250.00	250.00	pago	2024-08-09
1305	12	2025-08-10	350.00	350.00	pago	2025-08-08
1306	13	2025-08-10	150.00	150.00	pago	2025-08-08
1307	14	2025-08-10	150.00	150.00	pago	2025-08-11
1308	15	2025-08-10	450.00	450.00	pago	2025-08-10
1309	17	2025-08-10	150.00	150.00	pago	2025-08-08
1310	18	2025-08-10	250.00	250.00	pago	2025-08-09
1341	64	2025-08-10	350.00	\N	atrasado	\N
1320	38	2025-08-10	150.00	150.00	pago	2025-08-11
1322	41	2025-08-10	150.00	150.00	pago	2025-08-11
1314	26	2025-08-10	150.00	150.00	pago	2025-08-08
1315	27	2025-08-10	250.00	250.00	pago	2025-08-07
1338	61	2025-08-10	150.00	150.00	pago	2025-08-11
1340	63	2025-08-10	250.00	250.00	pago	2025-08-11
1347	74	2025-08-10	150.00	150.00	pago	2025-08-11
1319	36	2025-08-10	350.00	350.00	pago	2025-08-09
1350	79	2025-08-10	150.00	150.00	pago	2025-08-11
1321	39	2025-08-10	250.00	250.00	pago	2025-08-07
1351	80	2025-08-10	450.00	450.00	pago	2025-08-11
1324	43	2025-08-10	150.00	150.00	pago	2025-08-08
1325	44	2025-08-10	350.00	350.00	pago	2025-08-08
1326	46	2025-08-10	150.00	150.00	pago	2025-08-07
1327	47	2025-08-10	150.00	150.00	pago	2025-08-09
1328	48	2025-08-10	350.00	350.00	pago	2025-08-08
1329	51	2025-08-10	250.00	250.00	pago	2025-08-10
1330	52	2025-08-10	350.00	350.00	pago	2025-08-07
1331	53	2025-08-10	150.00	150.00	pago	2025-08-10
1332	54	2025-08-10	250.00	250.00	pago	2025-08-08
1333	55	2025-08-10	450.00	450.00	pago	2025-08-08
1334	56	2025-08-10	350.00	350.00	pago	2025-08-08
1335	57	2025-08-10	250.00	250.00	pago	2025-08-08
1336	58	2025-08-10	150.00	150.00	pago	2025-08-10
1337	59	2025-08-10	150.00	150.00	pago	2025-08-10
1358	89	2025-08-10	150.00	150.00	pago	2025-08-11
1339	62	2025-08-10	150.00	150.00	pago	2025-08-08
1363	96	2025-08-10	350.00	350.00	pago	2025-08-11
1368	102	2025-08-10	250.00	250.00	pago	2025-08-24
1343	66	2025-08-10	250.00	250.00	pago	2025-08-08
1344	67	2025-08-10	150.00	150.00	pago	2025-08-08
1345	69	2025-08-10	250.00	250.00	pago	2025-08-07
1346	70	2025-08-10	450.00	450.00	pago	2025-08-09
1369	104	2025-08-10	350.00	350.00	pago	2025-08-11
1370	108	2025-08-10	350.00	350.00	pago	2025-08-11
1349	78	2025-08-10	250.00	250.00	pago	2025-08-10
1371	110	2025-08-10	450.00	450.00	pago	2025-08-11
1376	115	2025-08-10	450.00	450.00	pago	2025-08-16
1352	81	2025-08-10	250.00	250.00	pago	2025-08-08
1353	82	2025-08-10	150.00	150.00	pago	2025-08-10
1354	84	2025-08-10	350.00	350.00	pago	2025-08-09
1355	86	2025-08-10	150.00	150.00	pago	2025-08-10
1356	87	2025-08-10	250.00	250.00	pago	2025-08-09
1357	88	2025-08-10	350.00	350.00	pago	2025-08-09
1381	123	2025-08-10	250.00	250.00	pago	2025-08-11
1359	91	2025-08-10	150.00	150.00	pago	2025-08-08
1360	92	2025-08-10	350.00	350.00	pago	2025-08-10
1361	93	2025-08-10	250.00	250.00	pago	2025-08-09
1391	136	2025-08-10	350.00	\N	atrasado	\N
1111	14	2025-07-10	150.00	150.00	pago	2025-07-25
1364	97	2025-08-10	150.00	150.00	pago	2025-08-07
1365	98	2025-08-10	150.00	150.00	pago	2025-08-09
1366	99	2025-08-10	250.00	250.00	pago	2025-08-10
1367	100	2025-08-10	450.00	450.00	pago	2025-08-07
1119	27	2025-07-10	250.00	250.00	pago	2025-07-25
1162	89	2025-07-10	150.00	150.00	pago	2025-07-25
1071	122	2025-06-10	250.00	250.00	pago	2025-06-25
1482	72	2025-08-10	250.00	250.00	pago	2025-08-11
1372	111	2025-08-10	250.00	250.00	pago	2025-08-10
1373	112	2025-08-10	350.00	350.00	pago	2025-08-09
1374	113	2025-08-10	150.00	150.00	pago	2025-08-08
1375	114	2025-08-10	250.00	250.00	pago	2025-08-07
1377	117	2025-08-10	250.00	250.00	pago	2025-08-07
1378	118	2025-08-10	150.00	150.00	pago	2025-08-07
1379	119	2025-08-10	150.00	150.00	pago	2025-08-08
1380	120	2025-08-10	450.00	450.00	pago	2025-08-10
1486	160	2025-08-10	250.00	250.00	pago	2025-08-15
1382	125	2025-08-10	450.00	450.00	pago	2025-08-10
1489	152	2025-08-10	250.00	250.00	pago	2025-08-11
1384	129	2025-08-10	250.00	250.00	pago	2025-08-09
1497	7	2025-09-10	150.00	150.00	pago	2025-09-11
1386	131	2025-08-10	150.00	150.00	pago	2025-08-08
1498	8	2025-09-10	350.00	350.00	pago	2025-09-19
1388	133	2025-08-10	150.00	150.00	pago	2025-08-09
1389	134	2025-08-10	150.00	150.00	pago	2025-08-10
1390	135	2025-08-10	450.00	450.00	pago	2025-08-10
1439	178	2025-08-10	350.00	\N	atrasado	\N
1499	9	2025-09-10	250.00	250.00	pago	2025-09-11
1394	83	2025-08-10	350.00	350.00	pago	2025-08-09
1395	94	2025-08-10	350.00	350.00	pago	2025-08-08
1396	101	2025-08-10	350.00	350.00	pago	2025-08-10
1502	13	2025-09-10	150.00	150.00	pago	2025-09-11
1398	107	2025-08-10	350.00	350.00	pago	2025-08-08
1399	109	2025-08-10	350.00	350.00	pago	2025-08-10
1504	15	2025-09-10	450.00	450.00	pago	2025-09-11
1506	18	2025-09-10	250.00	250.00	pago	2025-09-11
1402	128	2025-08-10	450.00	450.00	pago	2025-08-08
1403	31	2025-08-10	450.00	450.00	pago	2025-08-09
1405	25	2025-08-10	250.00	250.00	pago	2025-08-09
1406	35	2025-08-10	250.00	250.00	pago	2025-08-10
1407	40	2025-08-10	250.00	250.00	pago	2025-08-09
1409	50	2025-08-10	250.00	250.00	pago	2025-08-08
1410	60	2025-08-10	250.00	250.00	pago	2025-08-10
1411	75	2025-08-10	250.00	250.00	pago	2025-08-07
1412	85	2025-08-10	250.00	250.00	pago	2025-08-10
1413	138	2025-08-10	250.00	250.00	pago	2025-08-10
1414	139	2025-08-10	150.00	150.00	pago	2025-08-07
1516	38	2025-09-10	150.00	150.00	pago	2025-09-11
1416	141	2025-08-10	250.00	250.00	pago	2025-08-09
1417	142	2025-08-10	150.00	150.00	pago	2025-08-09
1517	39	2025-09-10	250.00	250.00	pago	2025-09-15
1519	42	2025-09-10	250.00	250.00	pago	2025-09-11
1421	147	2025-08-10	250.00	250.00	pago	2025-08-08
1422	150	2025-08-10	450.00	450.00	pago	2025-08-10
1423	153	2025-08-10	250.00	250.00	pago	2025-08-07
1424	156	2025-08-10	350.00	350.00	pago	2025-08-08
1244	179	2025-07-10	450.00	\N	atrasado	\N
1426	159	2025-08-10	250.00	250.00	pago	2025-08-10
1427	161	2025-08-10	250.00	250.00	pago	2025-08-07
1428	162	2025-08-10	350.00	350.00	pago	2025-08-10
1429	163	2025-08-10	450.00	450.00	pago	2025-08-10
1430	165	2025-08-10	250.00	250.00	pago	2025-08-10
1431	167	2025-08-10	450.00	450.00	pago	2025-08-09
1220	141	2025-07-10	250.00	\N	atrasado	\N
1433	169	2025-08-10	250.00	250.00	pago	2025-08-08
1434	170	2025-08-10	350.00	350.00	pago	2025-08-08
1435	172	2025-08-10	150.00	150.00	pago	2025-08-08
1408	45	2025-08-10	250.00	\N	atrasado	\N
1437	174	2025-08-10	350.00	350.00	pago	2025-08-09
1438	177	2025-08-10	250.00	250.00	pago	2025-08-10
1440	179	2025-08-10	450.00	450.00	pago	2025-08-09
1323	42	2025-08-10	250.00	\N	atrasado	\N
1511	27	2025-09-10	250.00	\N	atrasado	\N
1833	181	2025-10-10	250.00	\N	atrasado	\N
1727	57	2025-10-10	250.00	\N	atrasado	\N
1864	164	2025-10-10	350.00	\N	atrasado	\N
1753	93	2025-10-10	250.00	\N	atrasado	\N
1751	91	2025-10-10	150.00	\N	atrasado	\N
1821	163	2025-10-10	450.00	\N	atrasado	\N
1441	181	2025-08-10	250.00	250.00	pago	2025-08-11
1442	183	2025-08-10	450.00	450.00	pago	2025-08-10
1443	185	2025-08-10	250.00	250.00	pago	2025-08-07
1444	186	2025-08-10	350.00	350.00	pago	2025-08-08
1523	47	2025-09-10	150.00	150.00	pago	2025-09-27
1446	188	2025-08-10	150.00	150.00	pago	2025-08-08
1448	191	2025-08-10	450.00	450.00	pago	2025-08-09
1480	32	2025-08-10	250.00	\N	atrasado	\N
1450	194	2025-08-10	350.00	350.00	pago	2025-08-10
1451	213	2025-08-10	250.00	250.00	pago	2025-08-09
1452	214	2025-08-10	350.00	350.00	pago	2025-08-09
1453	11	2025-08-10	250.00	250.00	pago	2025-08-07
1533	59	2025-09-10	150.00	150.00	pago	2025-09-11
1455	22	2025-08-10	250.00	250.00	pago	2025-08-07
1538	65	2025-09-10	450.00	450.00	pago	2025-09-11
1447	189	2025-08-10	250.00	\N	atrasado	\N
1458	37	2025-08-10	250.00	250.00	pago	2025-08-09
1539	66	2025-09-10	250.00	250.00	pago	2025-09-11
1546	79	2025-09-10	150.00	150.00	pago	2025-09-11
1548	81	2025-09-10	250.00	250.00	pago	2025-09-11
1462	121	2025-08-10	250.00	250.00	pago	2025-08-07
1463	122	2025-08-10	250.00	250.00	pago	2025-08-10
1614	144	2025-09-10	350.00	\N	atrasado	\N
1465	137	2025-08-10	250.00	250.00	pago	2025-08-10
1466	143	2025-08-10	250.00	250.00	pago	2025-08-08
1665	157	2025-09-10	250.00	\N	atrasado	\N
1468	154	2025-08-10	250.00	250.00	pago	2025-08-08
1469	157	2025-08-10	250.00	250.00	pago	2025-08-10
1470	184	2025-08-10	250.00	250.00	pago	2025-08-08
1471	149	2025-08-10	350.00	350.00	pago	2025-08-07
1472	164	2025-08-10	350.00	350.00	pago	2025-08-08
1473	176	2025-08-10	350.00	350.00	pago	2025-08-08
1474	180	2025-08-10	350.00	350.00	pago	2025-08-07
1475	90	2025-08-10	250.00	250.00	pago	2025-08-09
1476	148	2025-08-10	450.00	450.00	pago	2025-08-10
1477	166	2025-08-10	450.00	450.00	pago	2025-08-07
1478	192	2025-08-10	450.00	450.00	pago	2025-08-10
1479	105	2025-08-10	250.00	250.00	pago	2025-08-09
1481	68	2025-08-10	250.00	250.00	pago	2025-08-07
1549	82	2025-09-10	150.00	150.00	pago	2025-09-11
1483	116	2025-08-10	250.00	250.00	pago	2025-08-08
1484	124	2025-08-10	250.00	250.00	pago	2025-08-08
1551	86	2025-09-10	150.00	150.00	pago	2025-09-11
1554	89	2025-09-10	150.00	150.00	pago	2025-09-11
1487	171	2025-08-10	250.00	250.00	pago	2025-08-07
1488	175	2025-08-10	250.00	250.00	pago	2025-08-07
1490	182	2025-08-10	250.00	250.00	pago	2025-08-08
1491	190	2025-08-10	250.00	250.00	pago	2025-08-10
1492	1	2025-09-10	150.00	150.00	pago	2025-09-08
1493	2	2025-09-10	150.00	150.00	pago	2025-09-07
1494	3	2025-09-10	250.00	250.00	pago	2025-09-10
1495	4	2025-09-10	350.00	350.00	pago	2025-09-09
1496	6	2025-09-10	250.00	250.00	pago	2025-09-09
1561	98	2025-09-10	150.00	150.00	pago	2025-09-11
1562	99	2025-09-10	250.00	250.00	pago	2025-09-24
1566	108	2025-09-10	350.00	350.00	pago	2025-09-30
1500	10	2025-09-10	450.00	450.00	pago	2025-09-10
1501	12	2025-09-10	350.00	350.00	pago	2025-09-07
1570	113	2025-09-10	150.00	\N	atrasado	\N
1503	14	2025-09-10	150.00	150.00	pago	2025-09-08
1576	120	2025-09-10	450.00	450.00	pago	2025-09-23
1505	17	2025-09-10	150.00	150.00	pago	2025-09-10
1509	24	2025-09-10	350.00	350.00	pago	2025-09-25
1507	21	2025-09-10	250.00	250.00	pago	2025-09-10
1508	23	2025-09-10	150.00	150.00	pago	2025-09-08
1454	19	2025-08-10	250.00	250.00	pago	2025-08-25
1510	26	2025-09-10	150.00	150.00	pago	2025-09-10
1591	94	2025-09-10	350.00	350.00	pago	2025-09-11
1512	28	2025-09-10	350.00	350.00	pago	2025-09-07
1513	30	2025-09-10	450.00	450.00	pago	2025-09-09
1515	36	2025-09-10	350.00	350.00	pago	2025-09-08
1596	16	2025-09-10	450.00	450.00	pago	2025-09-22
1601	25	2025-09-10	250.00	250.00	pago	2025-09-11
1518	41	2025-09-10	150.00	150.00	pago	2025-09-09
1602	35	2025-09-10	250.00	250.00	pago	2025-09-11
1520	43	2025-09-10	150.00	150.00	pago	2025-09-10
1521	44	2025-09-10	350.00	350.00	pago	2025-09-07
1522	46	2025-09-10	150.00	150.00	pago	2025-09-07
1607	75	2025-09-10	250.00	250.00	pago	2025-09-11
1524	48	2025-09-10	350.00	350.00	pago	2025-09-07
1514	33	2025-09-10	250.00	\N	atrasado	\N
1526	52	2025-09-10	350.00	350.00	pago	2025-09-10
1527	53	2025-09-10	150.00	150.00	pago	2025-09-10
1528	54	2025-09-10	250.00	250.00	pago	2025-09-08
1560	97	2025-09-10	150.00	\N	atrasado	\N
1530	56	2025-09-10	350.00	350.00	pago	2025-09-10
1531	57	2025-09-10	250.00	250.00	pago	2025-09-10
1532	58	2025-09-10	150.00	150.00	pago	2025-09-07
1611	140	2025-09-10	450.00	450.00	pago	2025-09-11
1612	141	2025-09-10	250.00	250.00	pago	2025-09-12
1535	62	2025-09-10	150.00	150.00	pago	2025-09-08
1536	63	2025-09-10	250.00	250.00	pago	2025-09-10
1537	64	2025-09-10	350.00	350.00	pago	2025-09-08
1613	142	2025-09-10	150.00	150.00	pago	2025-09-11
1540	67	2025-09-10	150.00	150.00	pago	2025-09-08
1541	69	2025-09-10	250.00	250.00	pago	2025-09-09
1542	70	2025-09-10	450.00	450.00	pago	2025-09-09
1867	90	2025-10-10	250.00	\N	atrasado	\N
1544	77	2025-09-10	150.00	150.00	pago	2025-09-08
1545	78	2025-09-10	250.00	250.00	pago	2025-09-07
1632	173	2025-09-10	250.00	250.00	pago	2025-09-11
1547	80	2025-09-10	450.00	450.00	pago	2025-09-10
2968	78	2025-02-10	250.00	\N	atrasado	\N
1642	188	2025-09-10	150.00	150.00	pago	2025-09-11
1550	84	2025-09-10	350.00	350.00	pago	2025-09-10
1646	194	2025-09-10	350.00	350.00	pago	2025-09-11
1552	87	2025-09-10	250.00	250.00	pago	2025-09-09
1553	88	2025-09-10	350.00	350.00	pago	2025-09-09
1655	49	2025-09-10	250.00	250.00	pago	2025-09-11
1555	91	2025-09-10	150.00	150.00	pago	2025-09-07
1556	92	2025-09-10	350.00	350.00	pago	2025-09-08
1557	93	2025-09-10	250.00	250.00	pago	2025-09-08
1558	95	2025-09-10	450.00	450.00	pago	2025-09-08
1559	96	2025-09-10	350.00	350.00	pago	2025-09-07
1660	127	2025-09-10	250.00	250.00	pago	2025-09-20
1672	148	2025-09-10	450.00	450.00	pago	2025-09-11
1563	100	2025-09-10	450.00	450.00	pago	2025-09-10
1564	102	2025-09-10	250.00	250.00	pago	2025-09-09
1565	104	2025-09-10	350.00	350.00	pago	2025-09-08
1677	68	2025-09-10	250.00	250.00	pago	2025-09-11
1567	110	2025-09-10	450.00	450.00	pago	2025-09-09
1568	111	2025-09-10	250.00	250.00	pago	2025-09-07
1569	112	2025-09-10	350.00	350.00	pago	2025-09-10
1571	114	2025-09-10	250.00	250.00	pago	2025-09-10
1268	127	2025-07-10	250.00	\N	atrasado	\N
1573	117	2025-09-10	250.00	250.00	pago	2025-09-07
1574	118	2025-09-10	150.00	150.00	pago	2025-09-07
1575	119	2025-09-10	150.00	150.00	pago	2025-09-07
1283	105	2025-07-10	250.00	\N	atrasado	\N
1525	51	2025-09-10	250.00	\N	atrasado	\N
1637	181	2025-09-10	250.00	\N	atrasado	\N
1624	162	2025-09-10	350.00	\N	atrasado	\N
1529	55	2025-09-10	450.00	\N	atrasado	\N
3072	157	2025-02-10	250.00	\N	atrasado	\N
3088	152	2025-02-10	250.00	\N	atrasado	\N
3074	149	2025-02-10	350.00	\N	atrasado	\N
2987	111	2025-02-10	250.00	\N	atrasado	\N
3032	158	2025-02-10	150.00	\N	atrasado	\N
1578	125	2025-09-10	450.00	450.00	pago	2025-09-10
1579	126	2025-09-10	250.00	250.00	pago	2025-09-10
1580	129	2025-09-10	250.00	250.00	pago	2025-09-08
1581	130	2025-09-10	450.00	450.00	pago	2025-09-13
1582	131	2025-09-10	150.00	150.00	pago	2025-09-08
1584	133	2025-09-10	150.00	150.00	pago	2025-09-10
1583	132	2025-09-10	350.00	\N	atrasado	\N
1586	135	2025-09-10	450.00	450.00	pago	2025-09-09
1587	136	2025-09-10	350.00	350.00	pago	2025-09-08
1588	5	2025-09-10	250.00	250.00	pago	2025-09-08
1589	73	2025-09-10	350.00	350.00	pago	2025-09-10
1683	171	2025-09-10	250.00	250.00	pago	2025-09-11
1684	175	2025-09-10	250.00	250.00	pago	2025-09-28
1592	101	2025-09-10	350.00	350.00	pago	2025-09-10
1593	103	2025-09-10	350.00	350.00	pago	2025-09-07
1685	152	2025-09-10	250.00	250.00	pago	2025-09-11
1595	109	2025-09-10	350.00	350.00	pago	2025-09-09
1694	8	2025-10-10	350.00	350.00	pago	2025-10-11
1597	76	2025-09-10	450.00	450.00	pago	2025-09-07
1702	18	2025-10-10	250.00	250.00	pago	2025-10-11
1599	31	2025-09-10	450.00	450.00	pago	2025-09-08
1600	20	2025-09-10	250.00	250.00	pago	2025-09-10
1577	123	2025-09-10	250.00	\N	atrasado	\N
1618	150	2025-09-10	450.00	450.00	pago	2025-09-11
1604	45	2025-09-10	250.00	250.00	pago	2025-09-10
1605	50	2025-09-10	250.00	250.00	pago	2025-09-07
1606	60	2025-09-10	250.00	250.00	pago	2025-09-09
1598	128	2025-09-10	450.00	450.00	pago	2025-09-25
1608	85	2025-09-10	250.00	250.00	pago	2025-09-09
1609	138	2025-09-10	250.00	250.00	pago	2025-09-09
1656	71	2025-09-10	250.00	\N	atrasado	\N
1718	46	2025-10-10	150.00	150.00	pago	2025-10-11
1729	59	2025-10-10	150.00	150.00	pago	2025-10-23
1732	63	2025-10-10	250.00	250.00	pago	2025-10-18
1615	145	2025-09-10	450.00	450.00	pago	2025-09-07
1616	146	2025-09-10	150.00	150.00	pago	2025-09-09
1617	147	2025-09-10	250.00	250.00	pago	2025-09-10
1733	64	2025-10-10	350.00	350.00	pago	2025-10-11
1619	153	2025-09-10	250.00	250.00	pago	2025-09-10
1620	156	2025-09-10	350.00	350.00	pago	2025-09-09
1621	158	2025-09-10	150.00	150.00	pago	2025-09-08
1622	159	2025-09-10	250.00	250.00	pago	2025-09-07
1603	40	2025-09-10	250.00	\N	atrasado	\N
1736	67	2025-10-10	150.00	150.00	pago	2025-10-11
1625	163	2025-09-10	450.00	450.00	pago	2025-09-07
1626	165	2025-09-10	250.00	250.00	pago	2025-09-09
1627	167	2025-09-10	450.00	450.00	pago	2025-09-07
1628	168	2025-09-10	150.00	150.00	pago	2025-09-09
1629	169	2025-09-10	250.00	250.00	pago	2025-09-07
1630	170	2025-09-10	350.00	350.00	pago	2025-09-10
1631	172	2025-09-10	150.00	150.00	pago	2025-09-08
1741	78	2025-10-10	250.00	250.00	pago	2025-10-11
1633	174	2025-09-10	350.00	350.00	pago	2025-09-09
1634	177	2025-09-10	250.00	250.00	pago	2025-09-08
1635	178	2025-09-10	350.00	350.00	pago	2025-09-09
1636	179	2025-09-10	450.00	450.00	pago	2025-09-09
1744	81	2025-10-10	250.00	250.00	pago	2025-10-11
1638	183	2025-09-10	450.00	450.00	pago	2025-09-07
1639	185	2025-09-10	250.00	250.00	pago	2025-09-07
1640	186	2025-09-10	350.00	350.00	pago	2025-09-08
1641	187	2025-09-10	450.00	450.00	pago	2025-09-08
1693	7	2025-10-10	150.00	\N	atrasado	\N
1728	58	2025-10-10	150.00	\N	atrasado	\N
1644	191	2025-09-10	450.00	450.00	pago	2025-09-10
1645	193	2025-09-10	250.00	250.00	pago	2025-09-07
1746	84	2025-10-10	350.00	350.00	pago	2025-10-14
1647	213	2025-09-10	250.00	250.00	pago	2025-09-07
1648	214	2025-09-10	350.00	350.00	pago	2025-09-09
1649	11	2025-09-10	250.00	250.00	pago	2025-09-10
1650	19	2025-09-10	250.00	250.00	pago	2025-09-07
1651	22	2025-09-10	250.00	250.00	pago	2025-09-07
1652	29	2025-09-10	250.00	250.00	pago	2025-09-09
1653	34	2025-09-10	250.00	250.00	pago	2025-09-08
1654	37	2025-09-10	250.00	250.00	pago	2025-09-07
1750	89	2025-10-10	150.00	150.00	pago	2025-10-12
1657	106	2025-09-10	250.00	250.00	pago	2025-09-09
1658	121	2025-09-10	250.00	250.00	pago	2025-09-10
1659	122	2025-09-10	250.00	250.00	pago	2025-09-10
1755	96	2025-10-10	350.00	350.00	pago	2025-10-11
1661	137	2025-09-10	250.00	250.00	pago	2025-09-07
1662	143	2025-09-10	250.00	250.00	pago	2025-09-10
1663	151	2025-09-10	250.00	250.00	pago	2025-09-07
1664	154	2025-09-10	250.00	250.00	pago	2025-09-09
1764	111	2025-10-10	250.00	250.00	pago	2025-10-11
1666	184	2025-09-10	250.00	250.00	pago	2025-09-10
1667	149	2025-09-10	350.00	350.00	pago	2025-09-07
1668	164	2025-09-10	350.00	350.00	pago	2025-09-07
1669	176	2025-09-10	350.00	350.00	pago	2025-09-07
1670	180	2025-09-10	350.00	350.00	pago	2025-09-08
1671	90	2025-09-10	250.00	250.00	pago	2025-09-08
1772	120	2025-10-10	450.00	450.00	pago	2025-10-11
1673	166	2025-09-10	450.00	450.00	pago	2025-09-07
1674	192	2025-09-10	450.00	450.00	pago	2025-09-08
1675	105	2025-09-10	250.00	250.00	pago	2025-09-09
1676	32	2025-09-10	250.00	250.00	pago	2025-09-09
1776	129	2025-10-10	250.00	250.00	pago	2025-10-11
1678	72	2025-09-10	250.00	250.00	pago	2025-09-10
1679	116	2025-09-10	250.00	250.00	pago	2025-09-10
1680	124	2025-09-10	250.00	250.00	pago	2025-09-09
1681	155	2025-09-10	250.00	250.00	pago	2025-09-07
1682	160	2025-09-10	250.00	250.00	pago	2025-09-10
1777	130	2025-10-10	450.00	450.00	pago	2025-10-11
1778	131	2025-10-10	150.00	150.00	pago	2025-10-11
1779	132	2025-10-10	350.00	350.00	pago	2025-11-01
1687	190	2025-09-10	250.00	250.00	pago	2025-09-08
1688	1	2025-10-10	150.00	150.00	pago	2025-10-09
1689	2	2025-10-10	150.00	150.00	pago	2025-10-08
1690	3	2025-10-10	250.00	250.00	pago	2025-10-07
1691	4	2025-10-10	350.00	350.00	pago	2025-10-09
1692	6	2025-10-10	250.00	250.00	pago	2025-10-09
1781	134	2025-10-10	150.00	150.00	pago	2025-10-11
1695	9	2025-10-10	250.00	250.00	pago	2025-10-07
1696	10	2025-10-10	450.00	450.00	pago	2025-10-10
1170	99	2025-07-10	250.00	\N	atrasado	\N
1698	13	2025-10-10	150.00	150.00	pago	2025-10-10
1699	14	2025-10-10	150.00	150.00	pago	2025-10-08
1700	15	2025-10-10	450.00	450.00	pago	2025-10-10
1701	17	2025-10-10	150.00	150.00	pago	2025-10-07
1122	33	2025-07-10	250.00	\N	atrasado	\N
1703	21	2025-10-10	250.00	250.00	pago	2025-10-09
1704	23	2025-10-10	150.00	150.00	pago	2025-10-08
1705	24	2025-10-10	350.00	350.00	pago	2025-10-07
1706	26	2025-10-10	150.00	150.00	pago	2025-10-09
1707	27	2025-10-10	250.00	250.00	pago	2025-10-08
1708	28	2025-10-10	350.00	350.00	pago	2025-10-08
1709	30	2025-10-10	450.00	450.00	pago	2025-10-07
1710	33	2025-10-10	250.00	250.00	pago	2025-10-09
1711	36	2025-10-10	350.00	350.00	pago	2025-10-10
1295	190	2025-07-10	250.00	\N	atrasado	\N
1712	38	2025-10-10	150.00	\N	atrasado	\N
1745	82	2025-10-10	150.00	\N	atrasado	\N
2737	191	2024-12-10	450.00	\N	atrasado	\N
2759	32	2024-12-10	250.00	\N	atrasado	\N
2753	184	2024-12-10	250.00	\N	atrasado	\N
2760	68	2024-12-10	250.00	\N	atrasado	\N
2705	35	2024-12-10	250.00	\N	atrasado	\N
2728	177	2024-12-10	250.00	\N	atrasado	\N
1713	39	2025-10-10	250.00	250.00	pago	2025-10-11
1714	41	2025-10-10	150.00	150.00	pago	2025-10-10
1715	42	2025-10-10	250.00	250.00	pago	2025-10-09
1716	43	2025-10-10	150.00	150.00	pago	2025-10-09
1717	44	2025-10-10	350.00	350.00	pago	2025-10-10
1786	83	2025-10-10	350.00	350.00	pago	2025-10-11
1719	47	2025-10-10	150.00	150.00	pago	2025-10-10
1720	48	2025-10-10	350.00	350.00	pago	2025-10-08
1721	51	2025-10-10	250.00	250.00	pago	2025-10-09
1722	52	2025-10-10	350.00	350.00	pago	2025-10-08
1723	53	2025-10-10	150.00	150.00	pago	2025-10-09
1724	54	2025-10-10	250.00	250.00	pago	2025-10-10
1725	55	2025-10-10	450.00	450.00	pago	2025-10-10
1726	56	2025-10-10	350.00	350.00	pago	2025-10-10
1787	94	2025-10-10	350.00	350.00	pago	2025-10-11
1789	103	2025-10-10	350.00	350.00	pago	2025-10-11
1730	61	2025-10-10	150.00	150.00	pago	2025-10-08
1731	62	2025-10-10	150.00	150.00	pago	2025-10-09
1791	109	2025-10-10	350.00	350.00	pago	2025-10-11
1796	20	2025-10-10	250.00	250.00	pago	2025-10-11
1734	65	2025-10-10	450.00	450.00	pago	2025-10-07
1735	66	2025-10-10	250.00	250.00	pago	2025-10-07
1799	40	2025-10-10	250.00	250.00	pago	2025-10-19
1737	69	2025-10-10	250.00	250.00	pago	2025-10-08
1738	70	2025-10-10	450.00	450.00	pago	2025-10-09
1739	74	2025-10-10	150.00	150.00	pago	2025-10-07
1740	77	2025-10-10	150.00	150.00	pago	2025-10-09
1805	138	2025-10-10	250.00	250.00	pago	2025-10-11
1742	79	2025-10-10	150.00	150.00	pago	2025-10-09
1743	80	2025-10-10	450.00	450.00	pago	2025-10-09
1809	142	2025-10-10	150.00	150.00	pago	2025-10-11
1810	144	2025-10-10	350.00	350.00	pago	2025-10-11
1823	167	2025-10-10	450.00	450.00	pago	2025-10-16
1747	86	2025-10-10	150.00	150.00	pago	2025-10-09
1748	87	2025-10-10	250.00	250.00	pago	2025-10-09
1749	88	2025-10-10	350.00	350.00	pago	2025-10-10
1824	168	2025-10-10	150.00	150.00	pago	2025-10-11
1752	92	2025-10-10	350.00	350.00	pago	2025-10-09
1828	173	2025-10-10	250.00	250.00	pago	2025-10-11
1829	174	2025-10-10	350.00	350.00	pago	2025-10-11
1756	97	2025-10-10	150.00	150.00	pago	2025-10-07
1831	178	2025-10-10	350.00	350.00	pago	2025-10-11
1759	100	2025-10-10	450.00	450.00	pago	2025-10-09
1760	102	2025-10-10	250.00	250.00	pago	2025-10-08
1761	104	2025-10-10	350.00	350.00	pago	2025-10-07
1762	108	2025-10-10	350.00	350.00	pago	2025-10-08
2210	83	2024-08-10	350.00	350.00	pago	2024-08-09
1834	183	2025-10-10	450.00	450.00	pago	2025-10-11
1765	112	2025-10-10	350.00	350.00	pago	2025-10-09
1766	113	2025-10-10	150.00	150.00	pago	2025-10-10
1767	114	2025-10-10	250.00	250.00	pago	2025-10-10
1768	115	2025-10-10	450.00	450.00	pago	2025-10-07
1769	117	2025-10-10	250.00	250.00	pago	2025-10-10
1770	118	2025-10-10	150.00	150.00	pago	2025-10-07
1771	119	2025-10-10	150.00	150.00	pago	2025-10-10
1840	191	2025-10-10	450.00	450.00	pago	2025-10-11
1773	123	2025-10-10	250.00	250.00	pago	2025-10-10
1774	125	2025-10-10	450.00	450.00	pago	2025-10-07
1775	126	2025-10-10	250.00	250.00	pago	2025-10-10
1842	194	2025-10-10	350.00	350.00	pago	2025-10-11
1843	213	2025-10-10	250.00	250.00	pago	2025-10-11
1845	11	2025-10-10	250.00	250.00	pago	2025-10-11
1758	99	2025-10-10	250.00	250.00	pago	2025-10-11
1780	133	2025-10-10	150.00	150.00	pago	2025-10-10
1827	172	2025-10-10	150.00	150.00	pago	2025-10-11
1782	135	2025-10-10	450.00	450.00	pago	2025-10-08
1783	136	2025-10-10	350.00	350.00	pago	2025-10-08
1784	5	2025-10-10	250.00	250.00	pago	2025-10-07
1785	73	2025-10-10	350.00	350.00	pago	2025-10-07
1393	73	2025-08-10	350.00	350.00	pago	2025-08-25
1788	101	2025-10-10	350.00	350.00	pago	2025-10-10
1198	83	2025-07-10	350.00	\N	atrasado	\N
1757	98	2025-10-10	150.00	\N	atrasado	\N
1754	95	2025-10-10	450.00	\N	atrasado	\N
1792	16	2025-10-10	450.00	450.00	pago	2025-10-08
1793	76	2025-10-10	450.00	450.00	pago	2025-10-07
1794	128	2025-10-10	450.00	450.00	pago	2025-10-09
1795	31	2025-10-10	450.00	450.00	pago	2025-10-08
2207	125	2024-08-10	450.00	450.00	pago	2024-08-10
1797	25	2025-10-10	250.00	250.00	pago	2025-10-10
1798	35	2025-10-10	250.00	250.00	pago	2025-10-09
2208	135	2024-08-10	450.00	450.00	pago	2024-08-08
1800	45	2025-10-10	250.00	250.00	pago	2025-10-08
1801	50	2025-10-10	250.00	250.00	pago	2025-10-10
1802	60	2025-10-10	250.00	250.00	pago	2025-10-09
1803	75	2025-10-10	250.00	250.00	pago	2025-10-08
1804	85	2025-10-10	250.00	250.00	pago	2025-10-08
2209	136	2024-08-10	350.00	350.00	pago	2024-08-08
1806	139	2025-10-10	150.00	150.00	pago	2025-10-07
1807	140	2025-10-10	450.00	450.00	pago	2025-10-09
1808	141	2025-10-10	250.00	250.00	pago	2025-10-08
2211	101	2024-08-10	350.00	350.00	pago	2024-08-09
2212	103	2024-08-10	350.00	350.00	pago	2024-08-13
1811	145	2025-10-10	450.00	450.00	pago	2025-10-08
1812	146	2025-10-10	150.00	150.00	pago	2025-10-07
1813	147	2025-10-10	250.00	250.00	pago	2025-10-07
1814	150	2025-10-10	450.00	450.00	pago	2025-10-10
1815	153	2025-10-10	250.00	250.00	pago	2025-10-09
1816	156	2025-10-10	350.00	350.00	pago	2025-10-07
1817	158	2025-10-10	150.00	150.00	pago	2025-10-09
1818	159	2025-10-10	250.00	250.00	pago	2025-10-09
1820	162	2025-10-10	350.00	350.00	pago	2025-10-10
1822	165	2025-10-10	250.00	250.00	pago	2025-10-10
2213	107	2024-08-10	350.00	350.00	pago	2024-08-10
2214	16	2024-08-10	450.00	450.00	pago	2024-08-12
1825	169	2025-10-10	250.00	250.00	pago	2025-10-08
1826	170	2025-10-10	350.00	350.00	pago	2025-10-07
2215	31	2024-08-10	450.00	450.00	pago	2024-08-10
2216	35	2024-08-10	250.00	250.00	pago	2024-08-10
2217	45	2024-08-10	250.00	250.00	pago	2024-08-09
1830	177	2025-10-10	250.00	250.00	pago	2025-10-10
2218	50	2024-08-10	250.00	250.00	pago	2024-08-10
1832	179	2025-10-10	450.00	450.00	pago	2025-10-08
2219	85	2024-08-10	250.00	250.00	pago	2024-08-09
1835	185	2025-10-10	250.00	250.00	pago	2025-10-09
1836	186	2025-10-10	350.00	350.00	pago	2025-10-10
1837	187	2025-10-10	450.00	450.00	pago	2025-10-09
1838	188	2025-10-10	150.00	150.00	pago	2025-10-09
1839	189	2025-10-10	250.00	250.00	pago	2025-10-10
2220	138	2024-08-10	250.00	250.00	pago	2024-08-08
1841	193	2025-10-10	250.00	250.00	pago	2025-10-07
2221	139	2024-08-10	150.00	150.00	pago	2024-08-08
2222	140	2024-08-10	450.00	450.00	pago	2024-08-10
1844	214	2025-10-10	350.00	350.00	pago	2025-10-08
2223	141	2024-08-10	250.00	250.00	pago	2024-08-08
1846	19	2025-10-10	250.00	250.00	pago	2025-10-09
1847	22	2025-10-10	250.00	250.00	pago	2025-10-08
1848	29	2025-10-10	250.00	250.00	pago	2025-10-10
2224	142	2024-08-10	150.00	150.00	pago	2024-08-10
2225	153	2024-08-10	250.00	250.00	pago	2024-08-10
1850	37	2025-10-10	250.00	250.00	pago	2025-10-07
1852	71	2025-10-10	250.00	250.00	pago	2025-10-11
1853	106	2025-10-10	250.00	250.00	pago	2025-10-11
1863	149	2025-10-10	350.00	350.00	pago	2025-10-11
1855	122	2025-10-10	250.00	250.00	pago	2025-10-10
1856	127	2025-10-10	250.00	250.00	pago	2025-10-10
1857	137	2025-10-10	250.00	250.00	pago	2025-10-10
1858	143	2025-10-10	250.00	250.00	pago	2025-10-10
1859	151	2025-10-10	250.00	250.00	pago	2025-10-09
1861	157	2025-10-10	250.00	250.00	pago	2025-10-10
1862	184	2025-10-10	250.00	250.00	pago	2025-10-09
1865	176	2025-10-10	350.00	350.00	pago	2025-10-11
1866	180	2025-10-10	350.00	350.00	pago	2025-10-09
1868	148	2025-10-10	450.00	450.00	pago	2025-10-08
1876	124	2025-10-10	250.00	250.00	pago	2025-10-11
1870	192	2025-10-10	450.00	450.00	pago	2025-10-10
1871	105	2025-10-10	250.00	250.00	pago	2025-10-09
1872	32	2025-10-10	250.00	250.00	pago	2025-10-08
1877	155	2025-10-10	250.00	250.00	pago	2025-10-11
1874	72	2025-10-10	250.00	250.00	pago	2025-10-07
1875	116	2025-10-10	250.00	250.00	pago	2025-10-09
1849	34	2025-10-10	250.00	250.00	pago	2025-10-25
1948	91	2025-11-10	150.00	\N	atrasado	\N
1878	160	2025-10-10	250.00	250.00	pago	2025-10-10
1879	171	2025-10-10	250.00	250.00	pago	2025-10-09
1880	175	2025-10-10	250.00	250.00	pago	2025-10-07
1883	190	2025-10-10	250.00	250.00	pago	2025-10-10
1914	44	2025-11-10	350.00	\N	atrasado	\N
1915	46	2025-11-10	150.00	\N	atrasado	\N
1916	47	2025-11-10	150.00	\N	atrasado	\N
1917	48	2025-11-10	350.00	\N	atrasado	\N
1918	51	2025-11-10	250.00	\N	atrasado	\N
1919	52	2025-11-10	350.00	\N	atrasado	\N
1920	53	2025-11-10	150.00	\N	atrasado	\N
1921	54	2025-11-10	250.00	\N	atrasado	\N
1922	55	2025-11-10	450.00	\N	atrasado	\N
1923	56	2025-11-10	350.00	\N	atrasado	\N
1924	57	2025-11-10	250.00	\N	atrasado	\N
1925	58	2025-11-10	150.00	\N	atrasado	\N
1926	59	2025-11-10	150.00	\N	atrasado	\N
1927	61	2025-11-10	150.00	\N	atrasado	\N
1928	62	2025-11-10	150.00	\N	atrasado	\N
1929	63	2025-11-10	250.00	\N	atrasado	\N
1930	64	2025-11-10	350.00	\N	atrasado	\N
1931	65	2025-11-10	450.00	\N	atrasado	\N
1932	66	2025-11-10	250.00	\N	atrasado	\N
1933	67	2025-11-10	150.00	\N	atrasado	\N
1934	69	2025-11-10	250.00	\N	atrasado	\N
1935	70	2025-11-10	450.00	\N	atrasado	\N
1936	74	2025-11-10	150.00	\N	atrasado	\N
1937	77	2025-11-10	150.00	\N	atrasado	\N
1938	78	2025-11-10	250.00	\N	atrasado	\N
1939	79	2025-11-10	150.00	\N	atrasado	\N
1940	80	2025-11-10	450.00	\N	atrasado	\N
1941	81	2025-11-10	250.00	\N	atrasado	\N
1942	82	2025-11-10	150.00	\N	atrasado	\N
1943	84	2025-11-10	350.00	\N	atrasado	\N
1944	86	2025-11-10	150.00	\N	atrasado	\N
1945	87	2025-11-10	250.00	\N	atrasado	\N
1946	88	2025-11-10	350.00	\N	atrasado	\N
1947	89	2025-11-10	150.00	\N	atrasado	\N
1949	92	2025-11-10	350.00	\N	atrasado	\N
1950	93	2025-11-10	250.00	\N	atrasado	\N
1951	95	2025-11-10	450.00	\N	atrasado	\N
1952	96	2025-11-10	350.00	\N	atrasado	\N
1953	97	2025-11-10	150.00	\N	atrasado	\N
1954	98	2025-11-10	150.00	\N	atrasado	\N
1955	99	2025-11-10	250.00	\N	atrasado	\N
1956	100	2025-11-10	450.00	\N	atrasado	\N
1957	102	2025-11-10	250.00	\N	atrasado	\N
1958	104	2025-11-10	350.00	\N	atrasado	\N
1959	108	2025-11-10	350.00	\N	atrasado	\N
1960	110	2025-11-10	450.00	\N	atrasado	\N
1961	111	2025-11-10	250.00	\N	atrasado	\N
1962	112	2025-11-10	350.00	\N	atrasado	\N
1963	113	2025-11-10	150.00	\N	atrasado	\N
1964	114	2025-11-10	250.00	\N	atrasado	\N
1965	115	2025-11-10	450.00	\N	atrasado	\N
1966	117	2025-11-10	250.00	\N	atrasado	\N
1967	118	2025-11-10	150.00	\N	atrasado	\N
1968	119	2025-11-10	150.00	\N	atrasado	\N
1969	120	2025-11-10	450.00	\N	atrasado	\N
1970	123	2025-11-10	250.00	\N	atrasado	\N
1971	125	2025-11-10	450.00	\N	atrasado	\N
1972	126	2025-11-10	250.00	\N	atrasado	\N
1973	129	2025-11-10	250.00	\N	atrasado	\N
1974	130	2025-11-10	450.00	\N	atrasado	\N
1975	131	2025-11-10	150.00	\N	atrasado	\N
1976	132	2025-11-10	350.00	\N	atrasado	\N
1977	133	2025-11-10	150.00	\N	atrasado	\N
1978	134	2025-11-10	150.00	\N	atrasado	\N
1979	135	2025-11-10	450.00	\N	atrasado	\N
1980	136	2025-11-10	350.00	\N	atrasado	\N
1981	5	2025-11-10	250.00	\N	atrasado	\N
1982	73	2025-11-10	350.00	\N	atrasado	\N
1983	83	2025-11-10	350.00	\N	atrasado	\N
1984	94	2025-11-10	350.00	\N	atrasado	\N
1986	103	2025-11-10	350.00	\N	atrasado	\N
1987	107	2025-11-10	350.00	\N	atrasado	\N
1988	109	2025-11-10	350.00	\N	atrasado	\N
1989	16	2025-11-10	450.00	\N	atrasado	\N
1990	76	2025-11-10	450.00	\N	atrasado	\N
1991	128	2025-11-10	450.00	\N	atrasado	\N
1992	31	2025-11-10	450.00	\N	atrasado	\N
1993	20	2025-11-10	250.00	\N	atrasado	\N
1994	25	2025-11-10	250.00	\N	atrasado	\N
1995	35	2025-11-10	250.00	\N	atrasado	\N
1996	40	2025-11-10	250.00	\N	atrasado	\N
1997	45	2025-11-10	250.00	\N	atrasado	\N
1998	50	2025-11-10	250.00	\N	atrasado	\N
1999	60	2025-11-10	250.00	\N	atrasado	\N
2000	75	2025-11-10	250.00	\N	atrasado	\N
2001	85	2025-11-10	250.00	\N	atrasado	\N
2002	138	2025-11-10	250.00	\N	atrasado	\N
2003	139	2025-11-10	150.00	\N	atrasado	\N
2004	140	2025-11-10	450.00	\N	atrasado	\N
2005	141	2025-11-10	250.00	\N	atrasado	\N
2006	142	2025-11-10	150.00	\N	atrasado	\N
2007	144	2025-11-10	350.00	\N	atrasado	\N
2008	145	2025-11-10	450.00	\N	atrasado	\N
2009	146	2025-11-10	150.00	\N	atrasado	\N
2010	147	2025-11-10	250.00	\N	atrasado	\N
2011	150	2025-11-10	450.00	\N	atrasado	\N
2012	153	2025-11-10	250.00	\N	atrasado	\N
2013	156	2025-11-10	350.00	\N	atrasado	\N
2014	158	2025-11-10	150.00	\N	atrasado	\N
2015	159	2025-11-10	250.00	\N	atrasado	\N
2016	161	2025-11-10	250.00	\N	atrasado	\N
1311	21	2025-08-10	250.00	\N	atrasado	\N
2017	162	2025-11-10	350.00	\N	atrasado	\N
1436	173	2025-08-10	250.00	\N	atrasado	\N
1457	34	2025-08-10	250.00	\N	atrasado	\N
1449	193	2025-08-10	250.00	\N	atrasado	\N
1392	5	2025-08-10	250.00	\N	atrasado	\N
1464	127	2025-08-10	250.00	\N	atrasado	\N
1362	95	2025-08-10	450.00	\N	atrasado	\N
1467	151	2025-08-10	250.00	\N	atrasado	\N
1860	154	2025-10-10	250.00	\N	atrasado	\N
1873	68	2025-10-10	250.00	\N	atrasado	\N
2018	163	2025-11-10	450.00	\N	atrasado	\N
2019	165	2025-11-10	250.00	\N	atrasado	\N
2020	167	2025-11-10	450.00	\N	atrasado	\N
1854	121	2025-10-10	250.00	\N	atrasado	\N
2226	156	2024-08-10	350.00	350.00	pago	2024-08-09
2227	158	2024-08-10	150.00	150.00	pago	2024-08-08
2228	159	2024-08-10	250.00	250.00	pago	2024-08-09
2229	163	2024-08-10	450.00	450.00	pago	2024-08-08
2230	165	2024-08-10	250.00	250.00	pago	2024-08-09
2231	167	2024-08-10	450.00	450.00	pago	2024-08-09
1763	110	2025-10-10	450.00	450.00	pago	2025-11-17
1869	166	2025-10-10	450.00	450.00	pago	2025-11-23
918	18	2025-06-10	250.00	250.00	pago	2025-06-11
978	108	2025-06-10	350.00	350.00	pago	2025-06-20
1281	166	2025-07-10	450.00	450.00	pago	2025-07-11
1534	61	2025-09-10	150.00	150.00	pago	2025-09-17
1697	12	2025-10-10	350.00	350.00	pago	2025-10-11
1790	107	2025-10-10	350.00	350.00	pago	2025-10-11
1888	6	2025-11-10	250.00	\N	atrasado	\N
1889	7	2025-11-10	150.00	\N	atrasado	\N
1890	8	2025-11-10	350.00	\N	atrasado	\N
1891	9	2025-11-10	250.00	\N	atrasado	\N
1892	10	2025-11-10	450.00	\N	atrasado	\N
1893	229	2025-11-10	150.00	\N	atrasado	\N
1894	12	2025-11-10	350.00	\N	atrasado	\N
1895	13	2025-11-10	150.00	\N	atrasado	\N
1896	14	2025-11-10	150.00	\N	atrasado	\N
1897	15	2025-11-10	450.00	\N	atrasado	\N
1898	17	2025-11-10	150.00	\N	atrasado	\N
1899	18	2025-11-10	250.00	\N	atrasado	\N
1900	21	2025-11-10	250.00	\N	atrasado	\N
1901	23	2025-11-10	150.00	\N	atrasado	\N
1902	24	2025-11-10	350.00	\N	atrasado	\N
1903	26	2025-11-10	150.00	\N	atrasado	\N
1904	27	2025-11-10	250.00	\N	atrasado	\N
1905	28	2025-11-10	350.00	\N	atrasado	\N
1906	30	2025-11-10	450.00	\N	atrasado	\N
1907	33	2025-11-10	250.00	\N	atrasado	\N
1908	36	2025-11-10	350.00	\N	atrasado	\N
1909	38	2025-11-10	150.00	\N	atrasado	\N
1910	39	2025-11-10	250.00	\N	atrasado	\N
1911	41	2025-11-10	150.00	\N	atrasado	\N
1912	42	2025-11-10	250.00	\N	atrasado	\N
1913	43	2025-11-10	150.00	\N	atrasado	\N
1985	101	2025-11-10	350.00	\N	atrasado	\N
2021	168	2025-11-10	150.00	\N	atrasado	\N
2022	169	2025-11-10	250.00	\N	atrasado	\N
2023	170	2025-11-10	350.00	\N	atrasado	\N
2024	172	2025-11-10	150.00	\N	atrasado	\N
2025	173	2025-11-10	250.00	\N	atrasado	\N
2026	174	2025-11-10	350.00	\N	atrasado	\N
2027	177	2025-11-10	250.00	\N	atrasado	\N
2028	178	2025-11-10	350.00	\N	atrasado	\N
2029	179	2025-11-10	450.00	\N	atrasado	\N
2030	181	2025-11-10	250.00	\N	atrasado	\N
2031	183	2025-11-10	450.00	\N	atrasado	\N
2032	185	2025-11-10	250.00	\N	atrasado	\N
2033	186	2025-11-10	350.00	\N	atrasado	\N
2034	187	2025-11-10	450.00	\N	atrasado	\N
2035	188	2025-11-10	150.00	\N	atrasado	\N
2036	189	2025-11-10	250.00	\N	atrasado	\N
2037	191	2025-11-10	450.00	\N	atrasado	\N
2038	193	2025-11-10	250.00	\N	atrasado	\N
2039	194	2025-11-10	350.00	\N	atrasado	\N
2040	213	2025-11-10	250.00	\N	atrasado	\N
2041	214	2025-11-10	350.00	\N	atrasado	\N
2042	11	2025-11-10	250.00	\N	atrasado	\N
2043	19	2025-11-10	250.00	\N	atrasado	\N
2044	22	2025-11-10	250.00	\N	atrasado	\N
2045	29	2025-11-10	250.00	\N	atrasado	\N
2046	34	2025-11-10	250.00	\N	atrasado	\N
2047	37	2025-11-10	250.00	\N	atrasado	\N
2048	49	2025-11-10	250.00	\N	atrasado	\N
2049	71	2025-11-10	250.00	\N	atrasado	\N
2050	106	2025-11-10	250.00	\N	atrasado	\N
2051	121	2025-11-10	250.00	\N	atrasado	\N
2052	122	2025-11-10	250.00	\N	atrasado	\N
2053	127	2025-11-10	250.00	\N	atrasado	\N
2054	137	2025-11-10	250.00	\N	atrasado	\N
2055	143	2025-11-10	250.00	\N	atrasado	\N
2056	151	2025-11-10	250.00	\N	atrasado	\N
2057	154	2025-11-10	250.00	\N	atrasado	\N
2058	157	2025-11-10	250.00	\N	atrasado	\N
2059	184	2025-11-10	250.00	\N	atrasado	\N
2060	149	2025-11-10	350.00	\N	atrasado	\N
2061	164	2025-11-10	350.00	\N	atrasado	\N
2062	176	2025-11-10	350.00	\N	atrasado	\N
2063	180	2025-11-10	350.00	\N	atrasado	\N
2064	90	2025-11-10	250.00	\N	atrasado	\N
2065	148	2025-11-10	450.00	\N	atrasado	\N
2066	166	2025-11-10	450.00	\N	atrasado	\N
2067	192	2025-11-10	450.00	\N	atrasado	\N
2068	105	2025-11-10	250.00	\N	atrasado	\N
2069	32	2025-11-10	250.00	\N	atrasado	\N
2070	68	2025-11-10	250.00	\N	atrasado	\N
2072	116	2025-11-10	250.00	\N	atrasado	\N
2073	124	2025-11-10	250.00	\N	atrasado	\N
1643	189	2025-09-10	250.00	\N	atrasado	\N
1686	182	2025-09-10	250.00	\N	atrasado	\N
1623	161	2025-09-10	250.00	\N	atrasado	\N
1585	134	2025-09-10	150.00	\N	atrasado	\N
1572	115	2025-09-10	450.00	\N	atrasado	\N
1610	139	2025-09-10	150.00	\N	atrasado	\N
1884	1	2025-11-10	150.00	150.00	pago	2025-11-17
1885	2	2025-11-10	150.00	150.00	pago	2025-11-17
1887	4	2025-11-10	350.00	350.00	pago	2025-11-17
1886	3	2025-11-10	250.00	250.00	pago	2025-11-17
1233	163	2025-07-10	450.00	450.00	pago	2025-07-08
2232	177	2024-08-10	250.00	250.00	pago	2024-08-09
1401	76	2025-08-10	450.00	450.00	pago	2025-08-10
2233	178	2024-08-10	350.00	350.00	pago	2024-08-08
1543	74	2025-09-10	150.00	150.00	pago	2025-09-09
1590	83	2025-09-10	350.00	350.00	pago	2025-09-07
1594	107	2025-09-10	350.00	350.00	pago	2025-09-08
2234	179	2024-08-10	450.00	450.00	pago	2024-08-15
2235	187	2024-08-10	450.00	450.00	pago	2024-08-09
2236	188	2024-08-10	150.00	150.00	pago	2024-08-15
2237	189	2024-08-10	250.00	250.00	pago	2024-08-08
2238	191	2024-08-10	450.00	450.00	pago	2024-08-12
2239	213	2024-08-10	250.00	250.00	pago	2024-08-08
2240	214	2024-08-10	350.00	350.00	pago	2024-08-10
2241	11	2024-08-10	250.00	250.00	pago	2024-08-08
2242	29	2024-08-10	250.00	250.00	pago	2024-08-13
2243	34	2024-08-10	250.00	250.00	pago	2024-08-10
2244	49	2024-08-10	250.00	250.00	pago	2024-08-13
2245	71	2024-08-10	250.00	250.00	pago	2024-08-08
2246	106	2024-08-10	250.00	250.00	pago	2024-08-10
2247	121	2024-08-10	250.00	250.00	pago	2024-08-09
2248	122	2024-08-10	250.00	250.00	pago	2024-08-10
2249	137	2024-08-10	250.00	250.00	pago	2024-08-10
2250	143	2024-08-10	250.00	250.00	pago	2024-08-09
2251	154	2024-08-10	250.00	250.00	pago	2024-08-09
2252	157	2024-08-10	250.00	250.00	pago	2024-08-08
2253	164	2024-08-10	350.00	350.00	pago	2024-08-08
2254	176	2024-08-10	350.00	350.00	pago	2024-08-09
2255	166	2024-08-10	450.00	450.00	pago	2024-08-08
2256	105	2024-08-10	250.00	250.00	pago	2024-08-09
2257	32	2024-08-10	250.00	250.00	pago	2024-08-08
2258	68	2024-08-10	250.00	250.00	pago	2024-08-08
2259	124	2024-08-10	250.00	250.00	pago	2024-08-08
2260	155	2024-08-10	250.00	250.00	pago	2024-08-10
2261	160	2024-08-10	250.00	250.00	pago	2024-08-10
2262	175	2024-08-10	250.00	250.00	pago	2024-08-10
2263	190	2024-08-10	250.00	250.00	pago	2024-08-10
2264	8	2024-09-10	350.00	350.00	pago	2024-09-10
2265	9	2024-09-10	250.00	250.00	pago	2024-09-08
2266	10	2024-09-10	450.00	450.00	pago	2024-09-08
2267	12	2024-09-10	350.00	350.00	pago	2024-09-08
2268	13	2024-09-10	150.00	150.00	pago	2024-09-08
2269	14	2024-09-10	150.00	150.00	pago	2024-09-09
2270	15	2024-09-10	450.00	450.00	pago	2024-09-10
2271	17	2024-09-10	150.00	150.00	pago	2024-09-08
2272	26	2024-09-10	150.00	150.00	pago	2024-09-08
2273	27	2024-09-10	250.00	250.00	pago	2024-09-08
2274	28	2024-09-10	350.00	350.00	pago	2024-09-10
2275	30	2024-09-10	450.00	450.00	pago	2024-09-08
2276	33	2024-09-10	250.00	250.00	pago	2024-09-09
1851	49	2025-10-10	250.00	\N	atrasado	\N
1881	152	2025-10-10	250.00	\N	atrasado	\N
1882	182	2025-10-10	250.00	\N	atrasado	\N
2277	44	2024-09-10	350.00	350.00	pago	2024-09-09
2278	46	2024-09-10	150.00	150.00	pago	2024-09-09
2279	47	2024-09-10	150.00	150.00	pago	2024-09-08
2280	48	2024-09-10	350.00	350.00	pago	2024-09-08
2281	51	2024-09-10	250.00	250.00	pago	2024-09-08
2282	52	2024-09-10	350.00	350.00	pago	2024-09-09
2283	53	2024-09-10	150.00	150.00	pago	2024-09-09
2284	62	2024-09-10	150.00	150.00	pago	2024-09-09
2285	63	2024-09-10	250.00	250.00	pago	2024-09-10
2286	64	2024-09-10	350.00	350.00	pago	2024-09-08
2287	65	2024-09-10	450.00	450.00	pago	2024-09-08
2288	66	2024-09-10	250.00	250.00	pago	2024-09-09
2289	67	2024-09-10	150.00	150.00	pago	2024-09-10
2290	69	2024-09-10	250.00	250.00	pago	2024-09-09
2291	70	2024-09-10	450.00	450.00	pago	2024-09-08
2292	80	2024-09-10	450.00	450.00	pago	2024-09-09
2293	81	2024-09-10	250.00	250.00	pago	2024-09-09
2294	82	2024-09-10	150.00	150.00	pago	2024-09-08
2295	84	2024-09-10	350.00	350.00	pago	2024-09-09
2296	86	2024-09-10	150.00	150.00	pago	2024-09-10
2297	87	2024-09-10	250.00	250.00	pago	2024-09-10
2298	88	2024-09-10	350.00	350.00	pago	2024-09-10
2299	89	2024-09-10	150.00	150.00	pago	2024-09-14
2300	98	2024-09-10	150.00	150.00	pago	2024-09-09
2301	99	2024-09-10	250.00	250.00	pago	2024-09-13
2302	100	2024-09-10	450.00	450.00	pago	2024-09-08
2303	102	2024-09-10	250.00	250.00	pago	2024-09-09
2304	104	2024-09-10	350.00	350.00	pago	2024-09-10
2305	117	2024-09-10	250.00	250.00	pago	2024-09-09
2306	118	2024-09-10	150.00	150.00	pago	2024-09-08
2307	119	2024-09-10	150.00	150.00	pago	2024-09-09
2308	120	2024-09-10	450.00	450.00	pago	2024-09-09
2309	123	2024-09-10	250.00	250.00	pago	2024-09-10
2310	125	2024-09-10	450.00	450.00	pago	2024-09-10
2311	134	2024-09-10	150.00	150.00	pago	2024-09-13
2312	135	2024-09-10	450.00	450.00	pago	2024-09-14
2313	136	2024-09-10	350.00	350.00	pago	2024-09-10
2314	83	2024-09-10	350.00	350.00	pago	2024-09-09
2315	101	2024-09-10	350.00	350.00	pago	2024-09-08
2316	103	2024-09-10	350.00	350.00	pago	2024-09-08
2317	107	2024-09-10	350.00	350.00	pago	2024-09-10
2318	16	2024-09-10	450.00	450.00	pago	2024-09-14
2319	31	2024-09-10	450.00	450.00	pago	2024-09-08
2320	35	2024-09-10	250.00	250.00	pago	2024-09-10
2321	45	2024-09-10	250.00	250.00	pago	2024-09-13
2322	50	2024-09-10	250.00	250.00	pago	2024-09-08
2323	85	2024-09-10	250.00	250.00	pago	2024-09-12
2324	138	2024-09-10	250.00	250.00	pago	2024-09-09
2325	139	2024-09-10	150.00	150.00	pago	2024-09-08
2326	140	2024-09-10	450.00	450.00	pago	2024-09-08
2327	141	2024-09-10	250.00	250.00	pago	2024-09-08
2328	142	2024-09-10	150.00	150.00	pago	2024-09-10
2329	153	2024-09-10	250.00	250.00	pago	2024-09-15
2330	156	2024-09-10	350.00	350.00	pago	2024-09-10
2331	158	2024-09-10	150.00	150.00	pago	2024-09-10
2332	159	2024-09-10	250.00	250.00	pago	2024-09-10
2333	162	2024-09-10	350.00	350.00	pago	2024-09-09
2334	163	2024-09-10	450.00	450.00	pago	2024-09-10
2335	165	2024-09-10	250.00	250.00	pago	2024-09-08
2336	167	2024-09-10	450.00	450.00	pago	2024-09-08
2337	174	2024-09-10	350.00	350.00	pago	2024-09-10
2338	177	2024-09-10	250.00	250.00	pago	2024-09-09
2339	178	2024-09-10	350.00	350.00	pago	2024-09-09
2340	179	2024-09-10	450.00	450.00	pago	2024-09-14
2341	186	2024-09-10	350.00	350.00	pago	2024-09-12
2342	187	2024-09-10	450.00	450.00	pago	2024-09-08
2343	188	2024-09-10	150.00	150.00	pago	2024-09-08
2344	189	2024-09-10	250.00	250.00	pago	2024-09-08
2345	191	2024-09-10	450.00	450.00	pago	2024-09-08
2346	213	2024-09-10	250.00	250.00	pago	2024-09-10
2347	214	2024-09-10	350.00	350.00	pago	2024-09-08
2348	11	2024-09-10	250.00	250.00	pago	2024-09-08
2349	29	2024-09-10	250.00	250.00	pago	2024-09-10
2350	34	2024-09-10	250.00	250.00	pago	2024-09-09
2351	49	2024-09-10	250.00	250.00	pago	2024-09-08
2352	71	2024-09-10	250.00	250.00	pago	2024-09-09
2353	106	2024-09-10	250.00	250.00	pago	2024-09-09
2354	121	2024-09-10	250.00	250.00	pago	2024-09-08
2355	122	2024-09-10	250.00	250.00	pago	2024-09-15
2356	137	2024-09-10	250.00	250.00	pago	2024-09-09
2357	143	2024-09-10	250.00	250.00	pago	2024-09-09
2358	154	2024-09-10	250.00	250.00	pago	2024-09-08
2359	157	2024-09-10	250.00	250.00	pago	2024-09-10
2360	164	2024-09-10	350.00	350.00	pago	2024-09-10
2361	176	2024-09-10	350.00	350.00	pago	2024-09-10
2362	166	2024-09-10	450.00	450.00	pago	2024-09-10
2363	105	2024-09-10	250.00	250.00	pago	2024-09-08
2364	32	2024-09-10	250.00	250.00	pago	2024-09-10
2365	68	2024-09-10	250.00	250.00	pago	2024-09-09
2366	116	2024-09-10	250.00	250.00	pago	2024-09-09
2367	124	2024-09-10	250.00	250.00	pago	2024-09-15
2368	155	2024-09-10	250.00	250.00	pago	2024-09-10
2369	160	2024-09-10	250.00	250.00	pago	2024-09-08
2370	175	2024-09-10	250.00	250.00	pago	2024-09-09
2371	152	2024-09-10	250.00	250.00	pago	2024-09-10
2372	190	2024-09-10	250.00	250.00	pago	2024-09-09
2373	7	2024-10-10	150.00	150.00	pago	2024-10-09
2374	8	2024-10-10	350.00	350.00	pago	2024-10-09
2375	9	2024-10-10	250.00	250.00	pago	2024-10-08
2376	10	2024-10-10	450.00	450.00	pago	2024-10-09
2377	12	2024-10-10	350.00	350.00	pago	2024-10-08
2378	13	2024-10-10	150.00	150.00	pago	2024-10-09
2379	14	2024-10-10	150.00	150.00	pago	2024-10-11
2380	15	2024-10-10	450.00	450.00	pago	2024-10-09
2381	17	2024-10-10	150.00	150.00	pago	2024-10-10
2382	26	2024-10-10	150.00	150.00	pago	2024-10-08
2383	27	2024-10-10	250.00	250.00	pago	2024-10-10
2384	28	2024-10-10	350.00	350.00	pago	2024-10-09
2385	30	2024-10-10	450.00	450.00	pago	2024-10-08
2386	33	2024-10-10	250.00	250.00	pago	2024-10-09
2387	43	2024-10-10	150.00	150.00	pago	2024-10-08
2388	44	2024-10-10	350.00	350.00	pago	2024-10-10
2389	46	2024-10-10	150.00	150.00	pago	2024-10-10
2390	47	2024-10-10	150.00	150.00	pago	2024-10-09
2391	48	2024-10-10	350.00	350.00	pago	2024-10-09
2392	51	2024-10-10	250.00	250.00	pago	2024-10-08
2393	52	2024-10-10	350.00	350.00	pago	2024-10-10
2394	53	2024-10-10	150.00	150.00	pago	2024-10-10
2395	61	2024-10-10	150.00	150.00	pago	2024-10-08
2396	62	2024-10-10	150.00	150.00	pago	2024-10-13
2397	63	2024-10-10	250.00	250.00	pago	2024-10-12
2398	64	2024-10-10	350.00	350.00	pago	2024-10-10
2399	65	2024-10-10	450.00	450.00	pago	2024-10-08
2400	66	2024-10-10	250.00	250.00	pago	2024-10-10
2401	67	2024-10-10	150.00	150.00	pago	2024-10-08
2402	69	2024-10-10	250.00	250.00	pago	2024-10-09
2403	70	2024-10-10	450.00	450.00	pago	2024-10-14
2404	79	2024-10-10	150.00	150.00	pago	2024-10-08
2405	80	2024-10-10	450.00	450.00	pago	2024-10-08
2406	81	2024-10-10	250.00	250.00	pago	2024-10-09
2407	82	2024-10-10	150.00	150.00	pago	2024-10-10
2408	84	2024-10-10	350.00	350.00	pago	2024-10-12
2409	86	2024-10-10	150.00	150.00	pago	2024-10-08
1017	50	2025-06-10	250.00	\N	atrasado	\N
2082	1	2026-01-10	250.00	\N	pendente	\N
2410	87	2024-10-10	250.00	250.00	pago	2024-10-12
2411	88	2024-10-10	350.00	350.00	pago	2024-10-10
2412	89	2024-10-10	150.00	150.00	pago	2024-10-08
2413	97	2024-10-10	150.00	150.00	pago	2024-10-09
2414	98	2024-10-10	150.00	150.00	pago	2024-10-09
1016	45	2025-06-10	250.00	\N	atrasado	\N
2656	63	2024-12-10	250.00	\N	atrasado	\N
909	7	2025-06-10	150.00	150.00	pago	2025-06-11
911	9	2025-06-10	250.00	250.00	pago	2025-06-11
912	10	2025-06-10	450.00	450.00	pago	2025-06-11
915	14	2025-06-10	150.00	150.00	pago	2025-06-11
2074	155	2025-11-10	250.00	\N	atrasado	\N
2075	160	2025-11-10	250.00	\N	atrasado	\N
2076	171	2025-11-10	250.00	\N	atrasado	\N
2077	175	2025-11-10	250.00	\N	atrasado	\N
2415	99	2024-10-10	250.00	250.00	pago	2024-10-10
2416	100	2024-10-10	450.00	450.00	pago	2024-10-09
2417	102	2024-10-10	250.00	250.00	pago	2024-10-10
2418	104	2024-10-10	350.00	350.00	pago	2024-10-08
2419	115	2024-10-10	450.00	450.00	pago	2024-10-12
2420	117	2024-10-10	250.00	250.00	pago	2024-10-09
2421	118	2024-10-10	150.00	150.00	pago	2024-10-10
2422	119	2024-10-10	150.00	150.00	pago	2024-10-09
2423	120	2024-10-10	450.00	450.00	pago	2024-10-10
2424	123	2024-10-10	250.00	250.00	pago	2024-10-09
2425	125	2024-10-10	450.00	450.00	pago	2024-10-10
2426	133	2024-10-10	150.00	150.00	pago	2024-10-09
2427	134	2024-10-10	150.00	150.00	pago	2024-10-13
2428	135	2024-10-10	450.00	450.00	pago	2024-10-10
2429	136	2024-10-10	350.00	350.00	pago	2024-10-09
2430	83	2024-10-10	350.00	350.00	pago	2024-10-08
2431	101	2024-10-10	350.00	350.00	pago	2024-10-09
2432	103	2024-10-10	350.00	350.00	pago	2024-10-14
2433	107	2024-10-10	350.00	350.00	pago	2024-10-11
2434	16	2024-10-10	450.00	450.00	pago	2024-10-10
2435	31	2024-10-10	450.00	450.00	pago	2024-10-09
2436	25	2024-10-10	250.00	250.00	pago	2024-10-08
2437	35	2024-10-10	250.00	250.00	pago	2024-10-10
2438	45	2024-10-10	250.00	250.00	pago	2024-10-10
2439	50	2024-10-10	250.00	250.00	pago	2024-10-09
2440	85	2024-10-10	250.00	250.00	pago	2024-10-09
2441	138	2024-10-10	250.00	250.00	pago	2024-10-09
2442	139	2024-10-10	150.00	150.00	pago	2024-10-09
2443	140	2024-10-10	450.00	450.00	pago	2024-10-14
2444	141	2024-10-10	250.00	250.00	pago	2024-10-11
2445	142	2024-10-10	150.00	150.00	pago	2024-10-09
2446	153	2024-10-10	250.00	250.00	pago	2024-10-12
2447	156	2024-10-10	350.00	350.00	pago	2024-10-08
2448	158	2024-10-10	150.00	150.00	pago	2024-10-09
2449	159	2024-10-10	250.00	250.00	pago	2024-10-09
2450	161	2024-10-10	250.00	250.00	pago	2024-10-08
2451	162	2024-10-10	350.00	350.00	pago	2024-10-10
2452	163	2024-10-10	450.00	450.00	pago	2024-10-09
2453	165	2024-10-10	250.00	250.00	pago	2024-10-10
2454	167	2024-10-10	450.00	450.00	pago	2024-10-09
2455	173	2024-10-10	250.00	250.00	pago	2024-10-09
2456	174	2024-10-10	350.00	350.00	pago	2024-10-09
2457	177	2024-10-10	250.00	250.00	pago	2024-10-10
2458	178	2024-10-10	350.00	350.00	pago	2024-10-10
2459	179	2024-10-10	450.00	450.00	pago	2024-10-08
2460	185	2024-10-10	250.00	250.00	pago	2024-10-10
2461	186	2024-10-10	350.00	350.00	pago	2024-10-15
2462	187	2024-10-10	450.00	450.00	pago	2024-10-08
2463	188	2024-10-10	150.00	150.00	pago	2024-10-08
2464	189	2024-10-10	250.00	250.00	pago	2024-10-10
2465	191	2024-10-10	450.00	450.00	pago	2024-10-09
2466	213	2024-10-10	250.00	250.00	pago	2024-10-14
2467	214	2024-10-10	350.00	350.00	pago	2024-10-09
2468	11	2024-10-10	250.00	250.00	pago	2024-10-09
2469	29	2024-10-10	250.00	250.00	pago	2024-10-09
2470	34	2024-10-10	250.00	250.00	pago	2024-10-10
2471	49	2024-10-10	250.00	250.00	pago	2024-10-09
2472	71	2024-10-10	250.00	250.00	pago	2024-10-09
2473	106	2024-10-10	250.00	250.00	pago	2024-10-09
2474	121	2024-10-10	250.00	250.00	pago	2024-10-10
2475	122	2024-10-10	250.00	250.00	pago	2024-10-09
2476	137	2024-10-10	250.00	250.00	pago	2024-10-09
2477	143	2024-10-10	250.00	250.00	pago	2024-10-10
2478	151	2024-10-10	250.00	250.00	pago	2024-10-09
2479	154	2024-10-10	250.00	250.00	pago	2024-10-08
2480	157	2024-10-10	250.00	250.00	pago	2024-10-09
2481	164	2024-10-10	350.00	350.00	pago	2024-10-09
2482	176	2024-10-10	350.00	350.00	pago	2024-10-09
2483	166	2024-10-10	450.00	450.00	pago	2024-10-14
2484	105	2024-10-10	250.00	250.00	pago	2024-10-09
2485	32	2024-10-10	250.00	250.00	pago	2024-10-08
2486	68	2024-10-10	250.00	250.00	pago	2024-10-09
2487	116	2024-10-10	250.00	250.00	pago	2024-10-08
2488	124	2024-10-10	250.00	250.00	pago	2024-10-08
2489	155	2024-10-10	250.00	250.00	pago	2024-10-08
2490	160	2024-10-10	250.00	250.00	pago	2024-10-10
2491	175	2024-10-10	250.00	250.00	pago	2024-10-08
2492	152	2024-10-10	250.00	250.00	pago	2024-10-15
2493	190	2024-10-10	250.00	250.00	pago	2024-10-10
2494	6	2024-11-10	250.00	250.00	pago	2024-11-09
2495	7	2024-11-10	150.00	150.00	pago	2024-11-10
2496	8	2024-11-10	350.00	350.00	pago	2024-11-09
2497	9	2024-11-10	250.00	250.00	pago	2024-11-09
2498	10	2024-11-10	450.00	450.00	pago	2024-11-10
2499	12	2024-11-10	350.00	350.00	pago	2024-11-09
2500	13	2024-11-10	150.00	150.00	pago	2024-11-12
2501	14	2024-11-10	150.00	150.00	pago	2024-11-08
2502	15	2024-11-10	450.00	450.00	pago	2024-11-10
2503	17	2024-11-10	150.00	150.00	pago	2024-11-09
2504	24	2024-11-10	350.00	350.00	pago	2024-11-08
2505	26	2024-11-10	150.00	150.00	pago	2024-11-09
2506	27	2024-11-10	250.00	250.00	pago	2024-11-08
2507	28	2024-11-10	350.00	350.00	pago	2024-11-08
2508	30	2024-11-10	450.00	450.00	pago	2024-11-09
2509	33	2024-11-10	250.00	250.00	pago	2024-11-10
2510	42	2024-11-10	250.00	250.00	pago	2024-11-08
2511	43	2024-11-10	150.00	150.00	pago	2024-11-09
2512	44	2024-11-10	350.00	350.00	pago	2024-11-08
2513	46	2024-11-10	150.00	150.00	pago	2024-11-09
2514	47	2024-11-10	150.00	150.00	pago	2024-11-10
2515	48	2024-11-10	350.00	350.00	pago	2024-11-08
2516	51	2024-11-10	250.00	250.00	pago	2024-11-10
2517	52	2024-11-10	350.00	350.00	pago	2024-11-08
2518	53	2024-11-10	150.00	150.00	pago	2024-11-08
2519	61	2024-11-10	150.00	150.00	pago	2024-11-10
2520	62	2024-11-10	150.00	150.00	pago	2024-11-12
2521	63	2024-11-10	250.00	250.00	pago	2024-11-10
2522	64	2024-11-10	350.00	350.00	pago	2024-11-08
2523	65	2024-11-10	450.00	450.00	pago	2024-11-10
2524	66	2024-11-10	250.00	250.00	pago	2024-11-10
2525	67	2024-11-10	150.00	150.00	pago	2024-11-09
2526	69	2024-11-10	250.00	250.00	pago	2024-11-10
2527	70	2024-11-10	450.00	450.00	pago	2024-11-08
2528	78	2024-11-10	250.00	250.00	pago	2024-11-09
2704	25	2024-12-10	250.00	\N	atrasado	\N
2672	88	2024-12-10	350.00	\N	atrasado	\N
2078	152	2025-11-10	250.00	\N	atrasado	\N
2079	182	2025-11-10	250.00	\N	atrasado	\N
2080	190	2025-11-10	250.00	\N	atrasado	\N
2071	72	2025-11-10	250.00	\N	atrasado	\N
1383	126	2025-08-10	250.00	\N	atrasado	\N
1385	130	2025-08-10	450.00	\N	atrasado	\N
2083	10	2024-07-10	450.00	450.00	pago	2024-07-11
2084	12	2024-07-10	350.00	350.00	pago	2024-07-15
2085	13	2024-07-10	150.00	150.00	pago	2024-07-09
2086	14	2024-07-10	150.00	150.00	pago	2024-07-10
2087	15	2024-07-10	450.00	450.00	pago	2024-07-09
2088	17	2024-07-10	150.00	150.00	pago	2024-07-08
2089	28	2024-07-10	350.00	350.00	pago	2024-07-08
2090	30	2024-07-10	450.00	450.00	pago	2024-07-10
2091	33	2024-07-10	250.00	250.00	pago	2024-07-11
2092	46	2024-07-10	150.00	150.00	pago	2024-07-09
2093	47	2024-07-10	150.00	150.00	pago	2024-07-10
2094	48	2024-07-10	350.00	350.00	pago	2024-07-08
2095	51	2024-07-10	250.00	250.00	pago	2024-07-15
2096	52	2024-07-10	350.00	350.00	pago	2024-07-10
2097	53	2024-07-10	150.00	150.00	pago	2024-07-10
2098	64	2024-07-10	350.00	350.00	pago	2024-07-08
2099	65	2024-07-10	450.00	450.00	pago	2024-07-11
2100	66	2024-07-10	250.00	250.00	pago	2024-07-08
2101	67	2024-07-10	150.00	150.00	pago	2024-07-10
2102	69	2024-07-10	250.00	250.00	pago	2024-07-08
2103	70	2024-07-10	450.00	450.00	pago	2024-07-09
2104	82	2024-07-10	150.00	150.00	pago	2024-07-10
2105	84	2024-07-10	350.00	350.00	pago	2024-07-10
2106	86	2024-07-10	150.00	150.00	pago	2024-07-08
2107	87	2024-07-10	250.00	250.00	pago	2024-07-10
2108	88	2024-07-10	350.00	350.00	pago	2024-07-09
2109	89	2024-07-10	150.00	150.00	pago	2024-07-10
2110	100	2024-07-10	450.00	450.00	pago	2024-07-08
2111	102	2024-07-10	250.00	250.00	pago	2024-07-12
2112	104	2024-07-10	350.00	350.00	pago	2024-07-09
2113	118	2024-07-10	150.00	150.00	pago	2024-07-10
2114	119	2024-07-10	150.00	150.00	pago	2024-07-09
2115	120	2024-07-10	450.00	450.00	pago	2024-07-08
2116	123	2024-07-10	250.00	250.00	pago	2024-07-09
2117	125	2024-07-10	450.00	450.00	pago	2024-07-08
2118	136	2024-07-10	350.00	350.00	pago	2024-07-08
2119	83	2024-07-10	350.00	350.00	pago	2024-07-08
2120	101	2024-07-10	350.00	350.00	pago	2024-07-08
2121	103	2024-07-10	350.00	350.00	pago	2024-07-11
2122	107	2024-07-10	350.00	350.00	pago	2024-07-08
2123	16	2024-07-10	450.00	450.00	pago	2024-07-10
2124	31	2024-07-10	450.00	450.00	pago	2024-07-08
2125	35	2024-07-10	250.00	250.00	pago	2024-07-09
2126	50	2024-07-10	250.00	250.00	pago	2024-07-08
2127	85	2024-07-10	250.00	250.00	pago	2024-07-10
2128	138	2024-07-10	250.00	250.00	pago	2024-07-09
2129	139	2024-07-10	150.00	150.00	pago	2024-07-10
2130	140	2024-07-10	450.00	450.00	pago	2024-07-09
2131	141	2024-07-10	250.00	250.00	pago	2024-07-08
2132	142	2024-07-10	150.00	150.00	pago	2024-07-08
2133	156	2024-07-10	350.00	350.00	pago	2024-07-10
2134	158	2024-07-10	150.00	150.00	pago	2024-07-09
2135	159	2024-07-10	250.00	250.00	pago	2024-07-09
2136	165	2024-07-10	250.00	250.00	pago	2024-07-14
2137	167	2024-07-10	450.00	450.00	pago	2024-07-12
2138	177	2024-07-10	250.00	250.00	pago	2024-07-08
2139	178	2024-07-10	350.00	350.00	pago	2024-07-10
2140	179	2024-07-10	450.00	450.00	pago	2024-07-09
2141	188	2024-07-10	150.00	150.00	pago	2024-07-08
2142	189	2024-07-10	250.00	250.00	pago	2024-07-08
2143	191	2024-07-10	450.00	450.00	pago	2024-07-09
2144	214	2024-07-10	350.00	350.00	pago	2024-07-09
2145	11	2024-07-10	250.00	250.00	pago	2024-07-10
2146	29	2024-07-10	250.00	250.00	pago	2024-07-08
2147	34	2024-07-10	250.00	250.00	pago	2024-07-08
2148	49	2024-07-10	250.00	250.00	pago	2024-07-10
2149	71	2024-07-10	250.00	250.00	pago	2024-07-10
2150	106	2024-07-10	250.00	250.00	pago	2024-07-09
2151	121	2024-07-10	250.00	250.00	pago	2024-07-10
2152	122	2024-07-10	250.00	250.00	pago	2024-07-10
2153	137	2024-07-10	250.00	250.00	pago	2024-07-08
2154	143	2024-07-10	250.00	250.00	pago	2024-07-10
2155	154	2024-07-10	250.00	250.00	pago	2024-07-10
2156	157	2024-07-10	250.00	250.00	pago	2024-07-10
2157	164	2024-07-10	350.00	350.00	pago	2024-07-10
2158	176	2024-07-10	350.00	350.00	pago	2024-07-09
2159	166	2024-07-10	450.00	450.00	pago	2024-07-08
2160	105	2024-07-10	250.00	250.00	pago	2024-07-10
2161	32	2024-07-10	250.00	250.00	pago	2024-07-08
2162	68	2024-07-10	250.00	250.00	pago	2024-07-08
2163	124	2024-07-10	250.00	250.00	pago	2024-07-09
2164	155	2024-07-10	250.00	250.00	pago	2024-07-09
2165	160	2024-07-10	250.00	250.00	pago	2024-07-15
2166	190	2024-07-10	250.00	250.00	pago	2024-07-08
2167	9	2024-08-10	250.00	250.00	pago	2024-08-09
2168	10	2024-08-10	450.00	450.00	pago	2024-08-08
2169	12	2024-08-10	350.00	350.00	pago	2024-08-12
2170	13	2024-08-10	150.00	150.00	pago	2024-08-10
2171	14	2024-08-10	150.00	150.00	pago	2024-08-10
2172	15	2024-08-10	450.00	450.00	pago	2024-08-08
2173	17	2024-08-10	150.00	150.00	pago	2024-08-12
2174	27	2024-08-10	250.00	250.00	pago	2024-08-10
2175	28	2024-08-10	350.00	350.00	pago	2024-08-08
2176	30	2024-08-10	450.00	450.00	pago	2024-08-10
2177	33	2024-08-10	250.00	250.00	pago	2024-08-09
2178	46	2024-08-10	150.00	150.00	pago	2024-08-09
2179	47	2024-08-10	150.00	150.00	pago	2024-08-10
2180	48	2024-08-10	350.00	350.00	pago	2024-08-08
2181	51	2024-08-10	250.00	250.00	pago	2024-08-10
2182	52	2024-08-10	350.00	350.00	pago	2024-08-14
2183	53	2024-08-10	150.00	150.00	pago	2024-08-12
2184	63	2024-08-10	250.00	250.00	pago	2024-08-08
2185	64	2024-08-10	350.00	350.00	pago	2024-08-09
2186	65	2024-08-10	450.00	450.00	pago	2024-08-10
2187	66	2024-08-10	250.00	250.00	pago	2024-08-09
2188	67	2024-08-10	150.00	150.00	pago	2024-08-10
2189	69	2024-08-10	250.00	250.00	pago	2024-08-10
2190	70	2024-08-10	450.00	450.00	pago	2024-08-10
2191	81	2024-08-10	250.00	250.00	pago	2024-08-10
2192	82	2024-08-10	150.00	150.00	pago	2024-08-09
2193	84	2024-08-10	350.00	350.00	pago	2024-08-09
2194	86	2024-08-10	150.00	150.00	pago	2024-08-08
2195	87	2024-08-10	250.00	250.00	pago	2024-08-08
2196	88	2024-08-10	350.00	350.00	pago	2024-08-08
2197	89	2024-08-10	150.00	150.00	pago	2024-08-10
2198	99	2024-08-10	250.00	250.00	pago	2024-08-09
1387	132	2025-08-10	350.00	350.00	pago	2025-08-11
1397	103	2025-08-10	350.00	350.00	pago	2025-08-11
1400	16	2025-08-10	450.00	450.00	pago	2025-08-11
1404	20	2025-08-10	250.00	250.00	pago	2025-08-18
1415	140	2025-08-10	450.00	450.00	pago	2025-08-11
1418	144	2025-08-10	350.00	350.00	pago	2025-08-11
1419	145	2025-08-10	450.00	450.00	pago	2025-08-11
1425	158	2025-08-10	150.00	150.00	pago	2025-08-11
1432	168	2025-08-10	150.00	150.00	pago	2025-08-11
1342	65	2025-08-10	450.00	450.00	pago	2025-08-11
1445	187	2025-08-10	450.00	450.00	pago	2025-08-15
1456	29	2025-08-10	250.00	250.00	pago	2025-08-11
1459	49	2025-08-10	250.00	250.00	pago	2025-08-31
1460	71	2025-08-10	250.00	250.00	pago	2025-08-23
1461	106	2025-08-10	250.00	250.00	pago	2025-08-21
2199	100	2024-08-10	450.00	450.00	pago	2024-08-08
2200	102	2024-08-10	250.00	250.00	pago	2024-08-11
2529	79	2024-11-10	150.00	150.00	pago	2024-11-10
2530	80	2024-11-10	450.00	450.00	pago	2024-11-09
2531	81	2024-11-10	250.00	250.00	pago	2024-11-10
2532	82	2024-11-10	150.00	150.00	pago	2024-11-10
2533	84	2024-11-10	350.00	350.00	pago	2024-11-08
2534	86	2024-11-10	150.00	150.00	pago	2024-11-08
2535	87	2024-11-10	250.00	250.00	pago	2024-11-08
2536	88	2024-11-10	350.00	350.00	pago	2024-11-09
2537	89	2024-11-10	150.00	150.00	pago	2024-11-08
2538	96	2024-11-10	350.00	350.00	pago	2024-11-08
2539	97	2024-11-10	150.00	150.00	pago	2024-11-10
2540	98	2024-11-10	150.00	150.00	pago	2024-11-13
2541	99	2024-11-10	250.00	250.00	pago	2024-11-08
2542	100	2024-11-10	450.00	450.00	pago	2024-11-09
2543	102	2024-11-10	250.00	250.00	pago	2024-11-10
2544	104	2024-11-10	350.00	350.00	pago	2024-11-15
2545	114	2024-11-10	250.00	250.00	pago	2024-11-12
2546	115	2024-11-10	450.00	450.00	pago	2024-11-09
2547	117	2024-11-10	250.00	250.00	pago	2024-11-09
2548	118	2024-11-10	150.00	150.00	pago	2024-11-09
2549	119	2024-11-10	150.00	150.00	pago	2024-11-08
2550	120	2024-11-10	450.00	450.00	pago	2024-11-10
2551	123	2024-11-10	250.00	250.00	pago	2024-11-09
2552	125	2024-11-10	450.00	450.00	pago	2024-11-10
2553	132	2024-11-10	350.00	350.00	pago	2024-11-10
2554	133	2024-11-10	150.00	150.00	pago	2024-11-08
2555	134	2024-11-10	150.00	150.00	pago	2024-11-09
2556	135	2024-11-10	450.00	450.00	pago	2024-11-09
2557	136	2024-11-10	350.00	350.00	pago	2024-11-08
2558	83	2024-11-10	350.00	350.00	pago	2024-11-10
2559	101	2024-11-10	350.00	350.00	pago	2024-11-09
2560	103	2024-11-10	350.00	350.00	pago	2024-11-08
2561	107	2024-11-10	350.00	350.00	pago	2024-11-08
2562	16	2024-11-10	450.00	450.00	pago	2024-11-09
2563	31	2024-11-10	450.00	450.00	pago	2024-11-12
2564	25	2024-11-10	250.00	250.00	pago	2024-11-09
2565	35	2024-11-10	250.00	250.00	pago	2024-11-09
2566	45	2024-11-10	250.00	250.00	pago	2024-11-10
2567	50	2024-11-10	250.00	250.00	pago	2024-11-08
2568	60	2024-11-10	250.00	250.00	pago	2024-11-08
2569	85	2024-11-10	250.00	250.00	pago	2024-11-15
2570	138	2024-11-10	250.00	250.00	pago	2024-11-10
2571	139	2024-11-10	150.00	150.00	pago	2024-11-08
2572	140	2024-11-10	450.00	450.00	pago	2024-11-09
2573	141	2024-11-10	250.00	250.00	pago	2024-11-08
2574	142	2024-11-10	150.00	150.00	pago	2024-11-09
2575	150	2024-11-10	450.00	450.00	pago	2024-11-10
2576	153	2024-11-10	250.00	250.00	pago	2024-11-10
2577	156	2024-11-10	350.00	350.00	pago	2024-11-08
2578	158	2024-11-10	150.00	150.00	pago	2024-11-10
2579	159	2024-11-10	250.00	250.00	pago	2024-11-08
2580	161	2024-11-10	250.00	250.00	pago	2024-11-08
2581	162	2024-11-10	350.00	350.00	pago	2024-11-09
2582	163	2024-11-10	450.00	450.00	pago	2024-11-09
2583	165	2024-11-10	250.00	250.00	pago	2024-11-10
2584	167	2024-11-10	450.00	450.00	pago	2024-11-10
2585	172	2024-11-10	150.00	150.00	pago	2024-11-10
2586	173	2024-11-10	250.00	250.00	pago	2024-11-09
2587	174	2024-11-10	350.00	350.00	pago	2024-11-08
2588	177	2024-11-10	250.00	250.00	pago	2024-11-08
2589	178	2024-11-10	350.00	350.00	pago	2024-11-10
2590	179	2024-11-10	450.00	450.00	pago	2024-11-15
2591	185	2024-11-10	250.00	250.00	pago	2024-11-10
2592	186	2024-11-10	350.00	350.00	pago	2024-11-09
2593	187	2024-11-10	450.00	450.00	pago	2024-11-08
2594	188	2024-11-10	150.00	150.00	pago	2024-11-09
2595	189	2024-11-10	250.00	250.00	pago	2024-11-09
2596	191	2024-11-10	450.00	450.00	pago	2024-11-09
2597	213	2024-11-10	250.00	250.00	pago	2024-11-10
2598	214	2024-11-10	350.00	350.00	pago	2024-11-08
2599	11	2024-11-10	250.00	250.00	pago	2024-11-10
2600	29	2024-11-10	250.00	250.00	pago	2024-11-10
2601	34	2024-11-10	250.00	250.00	pago	2024-11-10
2602	49	2024-11-10	250.00	250.00	pago	2024-11-10
2603	71	2024-11-10	250.00	250.00	pago	2024-11-08
2604	106	2024-11-10	250.00	250.00	pago	2024-11-10
2605	121	2024-11-10	250.00	250.00	pago	2024-11-10
2606	122	2024-11-10	250.00	250.00	pago	2024-11-08
2607	137	2024-11-10	250.00	250.00	pago	2024-11-08
2608	143	2024-11-10	250.00	250.00	pago	2024-11-12
2609	151	2024-11-10	250.00	250.00	pago	2024-11-14
2610	154	2024-11-10	250.00	250.00	pago	2024-11-08
2611	157	2024-11-10	250.00	250.00	pago	2024-11-10
2612	184	2024-11-10	250.00	250.00	pago	2024-11-10
2613	164	2024-11-10	350.00	350.00	pago	2024-11-10
2614	176	2024-11-10	350.00	350.00	pago	2024-11-10
2615	166	2024-11-10	450.00	450.00	pago	2024-11-09
2616	105	2024-11-10	250.00	250.00	pago	2024-11-08
2617	32	2024-11-10	250.00	250.00	pago	2024-11-09
2618	68	2024-11-10	250.00	250.00	pago	2024-11-10
2619	116	2024-11-10	250.00	250.00	pago	2024-11-08
2620	124	2024-11-10	250.00	250.00	pago	2024-11-10
2621	155	2024-11-10	250.00	250.00	pago	2024-11-09
2622	160	2024-11-10	250.00	250.00	pago	2024-11-08
2623	175	2024-11-10	250.00	250.00	pago	2024-11-08
2624	152	2024-11-10	250.00	250.00	pago	2024-11-10
2625	190	2024-11-10	250.00	250.00	pago	2024-11-09
2626	6	2024-12-10	250.00	250.00	pago	2024-12-08
2627	7	2024-12-10	150.00	150.00	pago	2024-12-09
2628	8	2024-12-10	350.00	350.00	pago	2024-12-10
2629	9	2024-12-10	250.00	250.00	pago	2024-12-09
2630	10	2024-12-10	450.00	450.00	pago	2024-12-09
2631	12	2024-12-10	350.00	350.00	pago	2024-12-10
2632	13	2024-12-10	150.00	150.00	pago	2024-12-09
2633	14	2024-12-10	150.00	150.00	pago	2024-12-10
2634	15	2024-12-10	450.00	450.00	pago	2024-12-08
2635	17	2024-12-10	150.00	150.00	pago	2024-12-10
2636	23	2024-12-10	150.00	150.00	pago	2024-12-08
2637	24	2024-12-10	350.00	350.00	pago	2024-12-08
2638	26	2024-12-10	150.00	150.00	pago	2024-12-10
2639	27	2024-12-10	250.00	250.00	pago	2024-12-10
2640	28	2024-12-10	350.00	350.00	pago	2024-12-10
2641	30	2024-12-10	450.00	450.00	pago	2024-12-08
2642	33	2024-12-10	250.00	250.00	pago	2024-12-08
2643	41	2024-12-10	150.00	150.00	pago	2024-12-08
2644	42	2024-12-10	250.00	250.00	pago	2024-12-10
2645	43	2024-12-10	150.00	150.00	pago	2024-12-08
2646	44	2024-12-10	350.00	350.00	pago	2024-12-08
2647	46	2024-12-10	150.00	150.00	pago	2024-12-08
2648	47	2024-12-10	150.00	150.00	pago	2024-12-08
2649	48	2024-12-10	350.00	350.00	pago	2024-12-09
2650	51	2024-12-10	250.00	250.00	pago	2024-12-08
2651	52	2024-12-10	350.00	350.00	pago	2024-12-12
2652	53	2024-12-10	150.00	150.00	pago	2024-12-09
2654	61	2024-12-10	150.00	150.00	pago	2024-12-12
2655	62	2024-12-10	150.00	150.00	pago	2024-12-09
2657	64	2024-12-10	350.00	350.00	pago	2024-12-08
2658	65	2024-12-10	450.00	450.00	pago	2024-12-08
2659	66	2024-12-10	250.00	250.00	pago	2024-12-10
2660	67	2024-12-10	150.00	150.00	pago	2024-12-10
2661	69	2024-12-10	250.00	250.00	pago	2024-12-10
2662	70	2024-12-10	450.00	450.00	pago	2024-12-09
2663	77	2024-12-10	150.00	150.00	pago	2024-12-09
2664	78	2024-12-10	250.00	250.00	pago	2024-12-10
2665	79	2024-12-10	150.00	150.00	pago	2024-12-09
2666	80	2024-12-10	450.00	450.00	pago	2024-12-10
2667	81	2024-12-10	250.00	250.00	pago	2024-12-10
2668	82	2024-12-10	150.00	150.00	pago	2024-12-13
2669	84	2024-12-10	350.00	350.00	pago	2024-12-09
2670	86	2024-12-10	150.00	150.00	pago	2024-12-09
2671	87	2024-12-10	250.00	250.00	pago	2024-12-08
2673	89	2024-12-10	150.00	150.00	pago	2024-12-09
2674	95	2024-12-10	450.00	450.00	pago	2024-12-09
2675	96	2024-12-10	350.00	350.00	pago	2024-12-09
2676	97	2024-12-10	150.00	150.00	pago	2024-12-08
2677	98	2024-12-10	150.00	150.00	pago	2024-12-08
2678	99	2024-12-10	250.00	250.00	pago	2024-12-10
2679	100	2024-12-10	450.00	450.00	pago	2024-12-10
2680	102	2024-12-10	250.00	250.00	pago	2024-12-09
2681	104	2024-12-10	350.00	350.00	pago	2024-12-08
2682	113	2024-12-10	150.00	150.00	pago	2024-12-08
2683	114	2024-12-10	250.00	250.00	pago	2024-12-09
2684	115	2024-12-10	450.00	450.00	pago	2024-12-09
2685	117	2024-12-10	250.00	250.00	pago	2024-12-10
2686	118	2024-12-10	150.00	150.00	pago	2024-12-09
2687	119	2024-12-10	150.00	150.00	pago	2024-12-08
2688	120	2024-12-10	450.00	450.00	pago	2024-12-09
2689	123	2024-12-10	250.00	250.00	pago	2024-12-08
2690	125	2024-12-10	450.00	450.00	pago	2024-12-09
2691	131	2024-12-10	150.00	150.00	pago	2024-12-08
2692	132	2024-12-10	350.00	350.00	pago	2024-12-10
2693	133	2024-12-10	150.00	150.00	pago	2024-12-15
2694	134	2024-12-10	150.00	150.00	pago	2024-12-09
2695	135	2024-12-10	450.00	450.00	pago	2024-12-08
2696	136	2024-12-10	350.00	350.00	pago	2024-12-08
2697	5	2024-12-10	250.00	250.00	pago	2024-12-09
2698	83	2024-12-10	350.00	350.00	pago	2024-12-10
2699	101	2024-12-10	350.00	350.00	pago	2024-12-10
2700	103	2024-12-10	350.00	350.00	pago	2024-12-10
2701	107	2024-12-10	350.00	350.00	pago	2024-12-09
2702	16	2024-12-10	450.00	450.00	pago	2024-12-08
2703	31	2024-12-10	450.00	450.00	pago	2024-12-08
2706	45	2024-12-10	250.00	250.00	pago	2024-12-08
2707	50	2024-12-10	250.00	250.00	pago	2024-12-10
2708	60	2024-12-10	250.00	250.00	pago	2024-12-08
2709	85	2024-12-10	250.00	250.00	pago	2024-12-10
2710	138	2024-12-10	250.00	250.00	pago	2024-12-09
2711	139	2024-12-10	150.00	150.00	pago	2024-12-09
2712	140	2024-12-10	450.00	450.00	pago	2024-12-11
2713	141	2024-12-10	250.00	250.00	pago	2024-12-09
2714	142	2024-12-10	150.00	150.00	pago	2024-12-09
2715	150	2024-12-10	450.00	450.00	pago	2024-12-08
2716	153	2024-12-10	250.00	250.00	pago	2024-12-08
2717	156	2024-12-10	350.00	350.00	pago	2024-12-10
2718	158	2024-12-10	150.00	150.00	pago	2024-12-08
2719	159	2024-12-10	250.00	250.00	pago	2024-12-10
2720	161	2024-12-10	250.00	250.00	pago	2024-12-09
2721	162	2024-12-10	350.00	350.00	pago	2024-12-14
2722	163	2024-12-10	450.00	450.00	pago	2024-12-09
2723	165	2024-12-10	250.00	250.00	pago	2024-12-08
2724	167	2024-12-10	450.00	450.00	pago	2024-12-08
2725	172	2024-12-10	150.00	150.00	pago	2024-12-08
2726	173	2024-12-10	250.00	250.00	pago	2024-12-08
2727	174	2024-12-10	350.00	350.00	pago	2024-12-13
2729	178	2024-12-10	350.00	350.00	pago	2024-12-10
2730	179	2024-12-10	450.00	450.00	pago	2024-12-08
2731	183	2024-12-10	450.00	450.00	pago	2024-12-09
2732	185	2024-12-10	250.00	250.00	pago	2024-12-09
2733	186	2024-12-10	350.00	350.00	pago	2024-12-08
2734	187	2024-12-10	450.00	450.00	pago	2024-12-08
2735	188	2024-12-10	150.00	150.00	pago	2024-12-10
2736	189	2024-12-10	250.00	250.00	pago	2024-12-10
2738	213	2024-12-10	250.00	250.00	pago	2024-12-10
2739	214	2024-12-10	350.00	350.00	pago	2024-12-08
2740	11	2024-12-10	250.00	250.00	pago	2024-12-10
2741	29	2024-12-10	250.00	250.00	pago	2024-12-08
2742	34	2024-12-10	250.00	250.00	pago	2024-12-08
2743	49	2024-12-10	250.00	250.00	pago	2024-12-09
2744	71	2024-12-10	250.00	250.00	pago	2024-12-08
2745	106	2024-12-10	250.00	250.00	pago	2024-12-08
2746	121	2024-12-10	250.00	250.00	pago	2024-12-14
2747	122	2024-12-10	250.00	250.00	pago	2024-12-09
2748	137	2024-12-10	250.00	250.00	pago	2024-12-09
2749	143	2024-12-10	250.00	250.00	pago	2024-12-08
2750	151	2024-12-10	250.00	250.00	pago	2024-12-09
2751	154	2024-12-10	250.00	250.00	pago	2024-12-10
2752	157	2024-12-10	250.00	250.00	pago	2024-12-09
2754	149	2024-12-10	350.00	350.00	pago	2024-12-08
2755	164	2024-12-10	350.00	350.00	pago	2024-12-08
2756	176	2024-12-10	350.00	350.00	pago	2024-12-10
2757	166	2024-12-10	450.00	450.00	pago	2024-12-09
2758	105	2024-12-10	250.00	250.00	pago	2024-12-08
2761	116	2024-12-10	250.00	250.00	pago	2024-12-08
2762	124	2024-12-10	250.00	250.00	pago	2024-12-10
2763	155	2024-12-10	250.00	250.00	pago	2024-12-08
2764	160	2024-12-10	250.00	250.00	pago	2024-12-13
2765	171	2024-12-10	250.00	250.00	pago	2024-12-08
2766	175	2024-12-10	250.00	250.00	pago	2024-12-09
2767	152	2024-12-10	250.00	250.00	pago	2024-12-08
2768	190	2024-12-10	250.00	250.00	pago	2024-12-09
2770	6	2025-01-10	250.00	250.00	pago	2025-01-10
2772	8	2025-01-10	350.00	350.00	pago	2025-01-09
2773	9	2025-01-10	250.00	250.00	pago	2025-01-08
2774	10	2025-01-10	450.00	450.00	pago	2025-01-10
2775	12	2025-01-10	350.00	350.00	pago	2025-01-10
2776	13	2025-01-10	150.00	150.00	pago	2025-01-10
2777	14	2025-01-10	150.00	150.00	pago	2025-01-08
2778	15	2025-01-10	450.00	450.00	pago	2025-01-10
2779	17	2025-01-10	150.00	150.00	pago	2025-01-12
2780	23	2025-01-10	150.00	150.00	pago	2025-01-08
2781	24	2025-01-10	350.00	350.00	pago	2025-01-13
2782	26	2025-01-10	150.00	150.00	pago	2025-01-10
2783	27	2025-01-10	250.00	250.00	pago	2025-01-10
2784	28	2025-01-10	350.00	350.00	pago	2025-01-08
2785	30	2025-01-10	450.00	450.00	pago	2025-01-10
2786	33	2025-01-10	250.00	250.00	pago	2025-01-10
2788	42	2025-01-10	250.00	250.00	pago	2025-01-08
2789	43	2025-01-10	150.00	150.00	pago	2025-01-10
2790	44	2025-01-10	350.00	350.00	pago	2025-01-09
2791	46	2025-01-10	150.00	150.00	pago	2025-01-08
2792	47	2025-01-10	150.00	150.00	pago	2025-01-08
2793	48	2025-01-10	350.00	350.00	pago	2025-01-10
2794	51	2025-01-10	250.00	250.00	pago	2025-01-08
2795	52	2025-01-10	350.00	350.00	pago	2025-01-10
2796	53	2025-01-10	150.00	150.00	pago	2025-01-08
2797	58	2025-01-10	150.00	150.00	pago	2025-01-09
2798	59	2025-01-10	150.00	150.00	pago	2025-01-08
2799	61	2025-01-10	150.00	150.00	pago	2025-01-09
2800	62	2025-01-10	150.00	150.00	pago	2025-01-09
2769	4	2025-01-10	350.00	\N	atrasado	\N
2787	41	2025-01-10	150.00	\N	atrasado	\N
2771	7	2025-01-10	150.00	\N	atrasado	\N
2802	64	2025-01-10	350.00	350.00	pago	2025-01-10
2803	65	2025-01-10	450.00	450.00	pago	2025-01-10
2804	66	2025-01-10	250.00	250.00	pago	2025-01-10
2805	67	2025-01-10	150.00	150.00	pago	2025-01-08
2806	69	2025-01-10	250.00	250.00	pago	2025-01-10
2807	70	2025-01-10	450.00	450.00	pago	2025-01-08
2808	77	2025-01-10	150.00	150.00	pago	2025-01-10
2809	78	2025-01-10	250.00	250.00	pago	2025-01-09
2810	79	2025-01-10	150.00	150.00	pago	2025-01-08
2811	80	2025-01-10	450.00	450.00	pago	2025-01-10
2812	81	2025-01-10	250.00	250.00	pago	2025-01-08
2813	82	2025-01-10	150.00	150.00	pago	2025-01-08
2814	84	2025-01-10	350.00	350.00	pago	2025-01-08
2815	86	2025-01-10	150.00	150.00	pago	2025-01-08
2816	87	2025-01-10	250.00	250.00	pago	2025-01-10
2817	88	2025-01-10	350.00	350.00	pago	2025-01-10
2818	89	2025-01-10	150.00	150.00	pago	2025-01-10
2819	95	2025-01-10	450.00	450.00	pago	2025-01-09
2820	96	2025-01-10	350.00	350.00	pago	2025-01-09
2821	97	2025-01-10	150.00	150.00	pago	2025-01-08
2822	98	2025-01-10	150.00	150.00	pago	2025-01-12
2823	99	2025-01-10	250.00	250.00	pago	2025-01-10
2824	100	2025-01-10	450.00	450.00	pago	2025-01-08
2825	102	2025-01-10	250.00	250.00	pago	2025-01-09
2826	104	2025-01-10	350.00	350.00	pago	2025-01-08
2827	112	2025-01-10	350.00	350.00	pago	2025-01-10
2828	113	2025-01-10	150.00	150.00	pago	2025-01-09
2829	114	2025-01-10	250.00	250.00	pago	2025-01-08
2830	115	2025-01-10	450.00	450.00	pago	2025-01-08
2831	117	2025-01-10	250.00	250.00	pago	2025-01-08
2832	118	2025-01-10	150.00	150.00	pago	2025-01-10
2833	119	2025-01-10	150.00	150.00	pago	2025-01-09
2834	120	2025-01-10	450.00	450.00	pago	2025-01-08
2835	123	2025-01-10	250.00	250.00	pago	2025-01-10
2836	125	2025-01-10	450.00	450.00	pago	2025-01-09
2837	130	2025-01-10	450.00	450.00	pago	2025-01-10
2838	131	2025-01-10	150.00	150.00	pago	2025-01-10
2839	132	2025-01-10	350.00	350.00	pago	2025-01-09
2840	133	2025-01-10	150.00	150.00	pago	2025-01-08
2841	134	2025-01-10	150.00	150.00	pago	2025-01-10
2842	135	2025-01-10	450.00	450.00	pago	2025-01-10
2843	136	2025-01-10	350.00	350.00	pago	2025-01-09
2844	5	2025-01-10	250.00	250.00	pago	2025-01-10
2845	83	2025-01-10	350.00	350.00	pago	2025-01-09
2846	94	2025-01-10	350.00	350.00	pago	2025-01-10
2847	101	2025-01-10	350.00	350.00	pago	2025-01-10
2848	103	2025-01-10	350.00	350.00	pago	2025-01-10
2849	107	2025-01-10	350.00	350.00	pago	2025-01-09
2850	16	2025-01-10	450.00	450.00	pago	2025-01-10
2851	76	2025-01-10	450.00	450.00	pago	2025-01-08
2852	31	2025-01-10	450.00	450.00	pago	2025-01-11
2853	25	2025-01-10	250.00	250.00	pago	2025-01-09
2854	35	2025-01-10	250.00	250.00	pago	2025-01-10
2855	40	2025-01-10	250.00	250.00	pago	2025-01-08
2856	45	2025-01-10	250.00	250.00	pago	2025-01-09
2857	50	2025-01-10	250.00	250.00	pago	2025-01-08
2858	60	2025-01-10	250.00	250.00	pago	2025-01-08
2859	85	2025-01-10	250.00	250.00	pago	2025-01-08
2860	138	2025-01-10	250.00	250.00	pago	2025-01-09
2861	139	2025-01-10	150.00	150.00	pago	2025-01-14
2862	140	2025-01-10	450.00	450.00	pago	2025-01-08
2863	141	2025-01-10	250.00	250.00	pago	2025-01-10
2865	150	2025-01-10	450.00	450.00	pago	2025-01-10
2866	153	2025-01-10	250.00	250.00	pago	2025-01-10
2867	156	2025-01-10	350.00	350.00	pago	2025-01-08
2869	159	2025-01-10	250.00	250.00	pago	2025-01-10
2870	161	2025-01-10	250.00	250.00	pago	2025-01-10
2871	162	2025-01-10	350.00	350.00	pago	2025-01-08
2872	163	2025-01-10	450.00	450.00	pago	2025-01-10
2873	165	2025-01-10	250.00	250.00	pago	2025-01-09
2874	167	2025-01-10	450.00	450.00	pago	2025-01-08
2875	170	2025-01-10	350.00	350.00	pago	2025-01-10
2876	172	2025-01-10	150.00	150.00	pago	2025-01-08
2877	173	2025-01-10	250.00	250.00	pago	2025-01-10
2878	174	2025-01-10	350.00	350.00	pago	2025-01-08
2879	177	2025-01-10	250.00	250.00	pago	2025-01-08
2880	178	2025-01-10	350.00	350.00	pago	2025-01-10
2881	179	2025-01-10	450.00	450.00	pago	2025-01-10
2882	183	2025-01-10	450.00	450.00	pago	2025-01-09
2884	186	2025-01-10	350.00	350.00	pago	2025-01-08
2885	187	2025-01-10	450.00	450.00	pago	2025-01-10
2886	188	2025-01-10	150.00	150.00	pago	2025-01-08
2887	189	2025-01-10	250.00	250.00	pago	2025-01-09
2888	191	2025-01-10	450.00	450.00	pago	2025-01-10
2889	194	2025-01-10	350.00	350.00	pago	2025-01-09
2890	213	2025-01-10	250.00	250.00	pago	2025-01-08
2892	11	2025-01-10	250.00	250.00	pago	2025-01-10
2894	29	2025-01-10	250.00	250.00	pago	2025-01-10
2895	34	2025-01-10	250.00	250.00	pago	2025-01-09
2896	49	2025-01-10	250.00	250.00	pago	2025-01-08
2897	71	2025-01-10	250.00	250.00	pago	2025-01-09
2898	106	2025-01-10	250.00	250.00	pago	2025-01-08
2899	121	2025-01-10	250.00	250.00	pago	2025-01-10
2900	122	2025-01-10	250.00	250.00	pago	2025-01-13
2901	137	2025-01-10	250.00	250.00	pago	2025-01-10
2902	143	2025-01-10	250.00	250.00	pago	2025-01-08
2903	151	2025-01-10	250.00	250.00	pago	2025-01-10
2904	154	2025-01-10	250.00	250.00	pago	2025-01-08
2905	157	2025-01-10	250.00	250.00	pago	2025-01-08
2906	184	2025-01-10	250.00	250.00	pago	2025-01-10
2907	149	2025-01-10	350.00	350.00	pago	2025-01-10
2908	164	2025-01-10	350.00	350.00	pago	2025-01-09
2909	176	2025-01-10	350.00	350.00	pago	2025-01-09
2910	148	2025-01-10	450.00	450.00	pago	2025-01-10
2911	166	2025-01-10	450.00	450.00	pago	2025-01-10
2912	105	2025-01-10	250.00	250.00	pago	2025-01-08
2913	32	2025-01-10	250.00	250.00	pago	2025-01-08
2914	68	2025-01-10	250.00	250.00	pago	2025-01-08
2915	116	2025-01-10	250.00	250.00	pago	2025-01-10
2917	155	2025-01-10	250.00	250.00	pago	2025-01-08
2918	160	2025-01-10	250.00	250.00	pago	2025-01-09
2919	171	2025-01-10	250.00	250.00	pago	2025-01-08
2920	175	2025-01-10	250.00	250.00	pago	2025-01-10
2921	152	2025-01-10	250.00	250.00	pago	2025-01-08
2922	182	2025-01-10	250.00	250.00	pago	2025-01-10
2923	190	2025-01-10	250.00	250.00	pago	2025-01-10
2924	3	2025-02-10	250.00	250.00	pago	2025-02-11
2925	4	2025-02-10	350.00	350.00	pago	2025-02-12
2926	6	2025-02-10	250.00	250.00	pago	2025-02-08
2927	7	2025-02-10	150.00	150.00	pago	2025-02-11
2928	8	2025-02-10	350.00	350.00	pago	2025-02-08
2929	9	2025-02-10	250.00	250.00	pago	2025-02-10
2930	10	2025-02-10	450.00	450.00	pago	2025-02-09
2931	12	2025-02-10	350.00	350.00	pago	2025-02-10
2932	13	2025-02-10	150.00	150.00	pago	2025-02-10
2933	14	2025-02-10	150.00	150.00	pago	2025-02-10
2934	15	2025-02-10	450.00	450.00	pago	2025-02-13
2935	17	2025-02-10	150.00	150.00	pago	2025-02-12
2936	21	2025-02-10	250.00	250.00	pago	2025-02-08
2937	23	2025-02-10	150.00	150.00	pago	2025-02-10
2938	24	2025-02-10	350.00	350.00	pago	2025-02-09
2939	26	2025-02-10	150.00	150.00	pago	2025-02-10
2940	27	2025-02-10	250.00	250.00	pago	2025-02-08
2942	30	2025-02-10	450.00	450.00	pago	2025-02-10
2943	33	2025-02-10	250.00	250.00	pago	2025-02-09
2944	39	2025-02-10	250.00	250.00	pago	2025-02-10
2945	41	2025-02-10	150.00	150.00	pago	2025-02-10
2946	42	2025-02-10	250.00	250.00	pago	2025-02-10
2947	43	2025-02-10	150.00	150.00	pago	2025-02-08
2948	44	2025-02-10	350.00	350.00	pago	2025-02-09
2949	46	2025-02-10	150.00	150.00	pago	2025-02-08
2950	47	2025-02-10	150.00	150.00	pago	2025-02-10
2951	48	2025-02-10	350.00	350.00	pago	2025-02-11
2953	52	2025-02-10	350.00	350.00	pago	2025-02-09
2954	53	2025-02-10	150.00	150.00	pago	2025-02-10
2955	57	2025-02-10	250.00	250.00	pago	2025-02-08
2956	58	2025-02-10	150.00	150.00	pago	2025-02-15
2957	59	2025-02-10	150.00	150.00	pago	2025-02-08
2958	61	2025-02-10	150.00	150.00	pago	2025-02-09
2959	62	2025-02-10	150.00	150.00	pago	2025-02-10
2960	63	2025-02-10	250.00	250.00	pago	2025-02-12
2961	64	2025-02-10	350.00	350.00	pago	2025-02-15
2962	65	2025-02-10	450.00	450.00	pago	2025-02-08
2963	66	2025-02-10	250.00	250.00	pago	2025-02-08
2964	67	2025-02-10	150.00	150.00	pago	2025-02-08
2965	69	2025-02-10	250.00	250.00	pago	2025-02-09
2966	70	2025-02-10	450.00	450.00	pago	2025-02-08
2967	77	2025-02-10	150.00	150.00	pago	2025-02-09
2969	79	2025-02-10	150.00	150.00	pago	2025-02-09
2971	81	2025-02-10	250.00	250.00	pago	2025-02-08
2972	82	2025-02-10	150.00	150.00	pago	2025-02-09
2973	84	2025-02-10	350.00	350.00	pago	2025-02-09
2974	86	2025-02-10	150.00	150.00	pago	2025-02-09
2975	87	2025-02-10	250.00	250.00	pago	2025-02-14
2976	88	2025-02-10	350.00	350.00	pago	2025-02-08
2977	89	2025-02-10	150.00	150.00	pago	2025-02-09
2978	93	2025-02-10	250.00	250.00	pago	2025-02-08
2979	95	2025-02-10	450.00	450.00	pago	2025-02-10
2980	96	2025-02-10	350.00	350.00	pago	2025-02-10
2981	97	2025-02-10	150.00	150.00	pago	2025-02-08
2982	98	2025-02-10	150.00	150.00	pago	2025-02-09
2983	99	2025-02-10	250.00	250.00	pago	2025-02-10
2984	100	2025-02-10	450.00	450.00	pago	2025-02-08
2985	102	2025-02-10	250.00	250.00	pago	2025-02-09
2986	104	2025-02-10	350.00	350.00	pago	2025-02-09
2988	112	2025-02-10	350.00	350.00	pago	2025-02-08
2989	113	2025-02-10	150.00	150.00	pago	2025-02-10
2990	114	2025-02-10	250.00	250.00	pago	2025-02-09
2991	115	2025-02-10	450.00	450.00	pago	2025-02-10
2992	117	2025-02-10	250.00	250.00	pago	2025-02-08
2993	118	2025-02-10	150.00	150.00	pago	2025-02-08
2994	119	2025-02-10	150.00	150.00	pago	2025-02-09
2995	120	2025-02-10	450.00	450.00	pago	2025-02-09
2996	123	2025-02-10	250.00	250.00	pago	2025-02-09
2997	125	2025-02-10	450.00	450.00	pago	2025-02-09
2998	129	2025-02-10	250.00	250.00	pago	2025-02-09
2999	130	2025-02-10	450.00	450.00	pago	2025-02-15
3000	131	2025-02-10	150.00	150.00	pago	2025-02-08
3001	132	2025-02-10	350.00	350.00	pago	2025-02-08
3002	133	2025-02-10	150.00	150.00	pago	2025-02-14
3003	134	2025-02-10	150.00	150.00	pago	2025-02-12
3004	135	2025-02-10	450.00	450.00	pago	2025-02-10
3005	136	2025-02-10	350.00	350.00	pago	2025-02-08
3006	5	2025-02-10	250.00	250.00	pago	2025-02-08
3007	83	2025-02-10	350.00	350.00	pago	2025-02-10
3008	94	2025-02-10	350.00	350.00	pago	2025-02-10
3009	101	2025-02-10	350.00	350.00	pago	2025-02-10
3010	103	2025-02-10	350.00	350.00	pago	2025-02-08
3011	107	2025-02-10	350.00	350.00	pago	2025-02-09
3012	16	2025-02-10	450.00	450.00	pago	2025-02-10
3013	76	2025-02-10	450.00	450.00	pago	2025-02-13
3014	31	2025-02-10	450.00	450.00	pago	2025-02-08
3015	25	2025-02-10	250.00	250.00	pago	2025-02-10
3016	35	2025-02-10	250.00	250.00	pago	2025-02-08
3017	40	2025-02-10	250.00	250.00	pago	2025-02-10
3018	45	2025-02-10	250.00	250.00	pago	2025-02-09
3019	50	2025-02-10	250.00	250.00	pago	2025-02-09
3020	60	2025-02-10	250.00	250.00	pago	2025-02-08
3021	75	2025-02-10	250.00	250.00	pago	2025-02-08
3022	85	2025-02-10	250.00	250.00	pago	2025-02-10
3023	138	2025-02-10	250.00	250.00	pago	2025-02-10
3024	139	2025-02-10	150.00	150.00	pago	2025-02-10
3025	140	2025-02-10	450.00	450.00	pago	2025-02-09
3026	141	2025-02-10	250.00	250.00	pago	2025-02-08
3027	142	2025-02-10	150.00	150.00	pago	2025-02-09
3028	147	2025-02-10	250.00	250.00	pago	2025-02-08
3029	150	2025-02-10	450.00	450.00	pago	2025-02-08
3030	153	2025-02-10	250.00	250.00	pago	2025-02-08
3031	156	2025-02-10	350.00	350.00	pago	2025-02-09
3033	159	2025-02-10	250.00	250.00	pago	2025-02-08
3034	161	2025-02-10	250.00	250.00	pago	2025-02-10
3035	162	2025-02-10	350.00	350.00	pago	2025-02-09
3036	163	2025-02-10	450.00	450.00	pago	2025-02-09
3037	165	2025-02-10	250.00	250.00	pago	2025-02-09
3038	167	2025-02-10	450.00	450.00	pago	2025-02-08
3039	169	2025-02-10	250.00	250.00	pago	2025-02-08
3040	170	2025-02-10	350.00	350.00	pago	2025-02-10
3041	172	2025-02-10	150.00	150.00	pago	2025-02-09
3042	173	2025-02-10	250.00	250.00	pago	2025-02-10
3043	174	2025-02-10	350.00	350.00	pago	2025-02-08
3044	177	2025-02-10	250.00	250.00	pago	2025-02-10
3045	178	2025-02-10	350.00	350.00	pago	2025-02-10
3046	179	2025-02-10	450.00	450.00	pago	2025-02-10
3047	181	2025-02-10	250.00	250.00	pago	2025-02-09
3048	183	2025-02-10	450.00	450.00	pago	2025-02-08
3049	185	2025-02-10	250.00	250.00	pago	2025-02-10
3050	186	2025-02-10	350.00	350.00	pago	2025-02-08
3051	187	2025-02-10	450.00	450.00	pago	2025-02-10
3052	188	2025-02-10	150.00	150.00	pago	2025-02-09
3053	189	2025-02-10	250.00	250.00	pago	2025-02-09
3054	191	2025-02-10	450.00	450.00	pago	2025-02-08
3055	193	2025-02-10	250.00	250.00	pago	2025-02-10
3056	194	2025-02-10	350.00	350.00	pago	2025-02-09
3057	213	2025-02-10	250.00	250.00	pago	2025-02-10
3058	214	2025-02-10	350.00	350.00	pago	2025-02-08
3059	11	2025-02-10	250.00	250.00	pago	2025-02-10
3060	22	2025-02-10	250.00	250.00	pago	2025-02-10
3061	29	2025-02-10	250.00	250.00	pago	2025-02-09
3062	34	2025-02-10	250.00	250.00	pago	2025-02-08
3063	49	2025-02-10	250.00	250.00	pago	2025-02-08
3064	71	2025-02-10	250.00	250.00	pago	2025-02-10
3065	106	2025-02-10	250.00	250.00	pago	2025-02-08
3066	121	2025-02-10	250.00	250.00	pago	2025-02-10
3067	122	2025-02-10	250.00	250.00	pago	2025-02-11
3068	137	2025-02-10	250.00	250.00	pago	2025-02-08
3069	143	2025-02-10	250.00	250.00	pago	2025-02-15
3070	151	2025-02-10	250.00	250.00	pago	2025-02-10
3071	154	2025-02-10	250.00	250.00	pago	2025-02-09
3073	184	2025-02-10	250.00	250.00	pago	2025-02-09
3075	164	2025-02-10	350.00	350.00	pago	2025-02-10
3076	176	2025-02-10	350.00	350.00	pago	2025-02-08
3077	148	2025-02-10	450.00	450.00	pago	2025-02-10
3078	166	2025-02-10	450.00	450.00	pago	2025-02-09
3079	105	2025-02-10	250.00	250.00	pago	2025-02-09
3080	32	2025-02-10	250.00	250.00	pago	2025-02-09
3081	68	2025-02-10	250.00	250.00	pago	2025-02-08
3082	116	2025-02-10	250.00	250.00	pago	2025-02-08
3083	124	2025-02-10	250.00	250.00	pago	2025-02-09
3084	155	2025-02-10	250.00	250.00	pago	2025-02-10
3086	171	2025-02-10	250.00	250.00	pago	2025-02-09
3087	175	2025-02-10	250.00	250.00	pago	2025-02-09
3089	182	2025-02-10	250.00	250.00	pago	2025-02-08
3090	190	2025-02-10	250.00	250.00	pago	2025-02-09
3091	2	2025-03-10	150.00	150.00	pago	2025-03-09
3093	4	2025-03-10	350.00	350.00	pago	2025-03-09
3094	6	2025-03-10	250.00	250.00	pago	2025-03-09
3095	7	2025-03-10	150.00	150.00	pago	2025-03-10
3096	8	2025-03-10	350.00	350.00	pago	2025-03-08
3097	9	2025-03-10	250.00	250.00	pago	2025-03-13
3098	10	2025-03-10	450.00	450.00	pago	2025-03-09
3099	12	2025-03-10	350.00	350.00	pago	2025-03-08
3100	13	2025-03-10	150.00	150.00	pago	2025-03-08
3101	14	2025-03-10	150.00	150.00	pago	2025-03-08
3102	15	2025-03-10	450.00	450.00	pago	2025-03-08
3103	17	2025-03-10	150.00	150.00	pago	2025-03-10
3104	21	2025-03-10	250.00	250.00	pago	2025-03-10
3105	23	2025-03-10	150.00	150.00	pago	2025-03-08
3106	24	2025-03-10	350.00	350.00	pago	2025-03-09
3107	26	2025-03-10	150.00	150.00	pago	2025-03-09
3108	27	2025-03-10	250.00	250.00	pago	2025-03-08
3109	28	2025-03-10	350.00	350.00	pago	2025-03-10
3111	33	2025-03-10	250.00	250.00	pago	2025-03-08
3112	38	2025-03-10	150.00	150.00	pago	2025-03-10
3113	39	2025-03-10	250.00	250.00	pago	2025-03-09
3115	42	2025-03-10	250.00	250.00	pago	2025-03-08
3116	43	2025-03-10	150.00	150.00	pago	2025-03-08
3119	47	2025-03-10	150.00	150.00	pago	2025-03-09
3120	48	2025-03-10	350.00	350.00	pago	2025-03-10
3121	51	2025-03-10	250.00	250.00	pago	2025-03-10
3122	52	2025-03-10	350.00	350.00	pago	2025-03-14
3123	53	2025-03-10	150.00	150.00	pago	2025-03-08
3124	56	2025-03-10	350.00	350.00	pago	2025-03-09
3125	57	2025-03-10	250.00	250.00	pago	2025-03-10
3126	58	2025-03-10	150.00	150.00	pago	2025-03-09
3127	59	2025-03-10	150.00	150.00	pago	2025-03-09
3129	62	2025-03-10	150.00	150.00	pago	2025-03-13
3130	63	2025-03-10	250.00	250.00	pago	2025-03-08
3131	64	2025-03-10	350.00	350.00	pago	2025-03-10
3132	65	2025-03-10	450.00	450.00	pago	2025-03-10
3133	66	2025-03-10	250.00	250.00	pago	2025-03-10
3134	67	2025-03-10	150.00	150.00	pago	2025-03-10
3135	69	2025-03-10	250.00	250.00	pago	2025-03-09
3136	70	2025-03-10	450.00	450.00	pago	2025-03-10
3137	74	2025-03-10	150.00	150.00	pago	2025-03-08
3138	77	2025-03-10	150.00	150.00	pago	2025-03-08
3139	78	2025-03-10	250.00	250.00	pago	2025-03-10
3140	79	2025-03-10	150.00	150.00	pago	2025-03-08
3141	80	2025-03-10	450.00	450.00	pago	2025-03-08
3142	81	2025-03-10	250.00	250.00	pago	2025-03-08
3143	82	2025-03-10	150.00	150.00	pago	2025-03-08
3144	84	2025-03-10	350.00	350.00	pago	2025-03-10
3145	86	2025-03-10	150.00	150.00	pago	2025-03-08
3146	87	2025-03-10	250.00	250.00	pago	2025-03-08
3147	88	2025-03-10	350.00	350.00	pago	2025-03-13
3148	89	2025-03-10	150.00	150.00	pago	2025-03-09
3149	92	2025-03-10	350.00	350.00	pago	2025-03-09
3150	93	2025-03-10	250.00	250.00	pago	2025-03-09
3151	95	2025-03-10	450.00	450.00	pago	2025-03-09
3152	96	2025-03-10	350.00	350.00	pago	2025-03-09
3153	97	2025-03-10	150.00	150.00	pago	2025-03-08
3154	98	2025-03-10	150.00	150.00	pago	2025-03-10
3155	99	2025-03-10	250.00	250.00	pago	2025-03-09
3156	100	2025-03-10	450.00	450.00	pago	2025-03-10
3157	102	2025-03-10	250.00	250.00	pago	2025-03-09
3158	104	2025-03-10	350.00	350.00	pago	2025-03-08
3159	110	2025-03-10	450.00	450.00	pago	2025-03-09
3160	111	2025-03-10	250.00	250.00	pago	2025-03-09
3161	112	2025-03-10	350.00	350.00	pago	2025-03-09
3162	113	2025-03-10	150.00	150.00	pago	2025-03-08
3163	114	2025-03-10	250.00	250.00	pago	2025-03-10
3164	115	2025-03-10	450.00	450.00	pago	2025-03-10
3165	117	2025-03-10	250.00	250.00	pago	2025-03-08
3166	118	2025-03-10	150.00	150.00	pago	2025-03-12
3167	119	2025-03-10	150.00	150.00	pago	2025-03-09
3168	120	2025-03-10	450.00	450.00	pago	2025-03-15
3169	123	2025-03-10	250.00	250.00	pago	2025-03-08
3170	125	2025-03-10	450.00	450.00	pago	2025-03-09
3171	129	2025-03-10	250.00	250.00	pago	2025-03-10
3172	130	2025-03-10	450.00	450.00	pago	2025-03-09
3173	131	2025-03-10	150.00	150.00	pago	2025-03-11
3174	132	2025-03-10	350.00	350.00	pago	2025-03-10
3175	133	2025-03-10	150.00	150.00	pago	2025-03-08
3176	134	2025-03-10	150.00	150.00	pago	2025-03-08
3177	135	2025-03-10	450.00	450.00	pago	2025-03-09
3178	136	2025-03-10	350.00	350.00	pago	2025-03-10
3179	5	2025-03-10	250.00	250.00	pago	2025-03-09
3180	83	2025-03-10	350.00	350.00	pago	2025-03-08
3181	94	2025-03-10	350.00	350.00	pago	2025-03-10
3182	101	2025-03-10	350.00	350.00	pago	2025-03-10
3183	103	2025-03-10	350.00	350.00	pago	2025-03-10
3184	107	2025-03-10	350.00	350.00	pago	2025-03-09
3185	16	2025-03-10	450.00	450.00	pago	2025-03-08
3186	76	2025-03-10	450.00	450.00	pago	2025-03-10
3187	128	2025-03-10	450.00	450.00	pago	2025-03-10
3188	31	2025-03-10	450.00	450.00	pago	2025-03-10
3189	20	2025-03-10	250.00	250.00	pago	2025-03-10
3190	25	2025-03-10	250.00	250.00	pago	2025-03-09
3191	35	2025-03-10	250.00	250.00	pago	2025-03-08
3192	40	2025-03-10	250.00	250.00	pago	2025-03-09
3193	45	2025-03-10	250.00	250.00	pago	2025-03-12
3194	50	2025-03-10	250.00	250.00	pago	2025-03-10
3195	60	2025-03-10	250.00	250.00	pago	2025-03-09
3196	75	2025-03-10	250.00	250.00	pago	2025-03-09
3197	85	2025-03-10	250.00	250.00	pago	2025-03-09
3198	138	2025-03-10	250.00	250.00	pago	2025-03-08
3199	139	2025-03-10	150.00	150.00	pago	2025-03-10
3200	140	2025-03-10	450.00	450.00	pago	2025-03-10
3201	141	2025-03-10	250.00	250.00	pago	2025-03-09
3202	142	2025-03-10	150.00	150.00	pago	2025-03-10
3203	146	2025-03-10	150.00	150.00	pago	2025-03-15
3204	147	2025-03-10	250.00	250.00	pago	2025-03-08
3205	150	2025-03-10	450.00	450.00	pago	2025-03-11
3206	153	2025-03-10	250.00	250.00	pago	2025-03-10
3207	156	2025-03-10	350.00	350.00	pago	2025-03-09
3208	158	2025-03-10	150.00	150.00	pago	2025-03-08
3118	46	2025-03-10	150.00	\N	atrasado	\N
3114	41	2025-03-10	150.00	\N	atrasado	\N
3110	30	2025-03-10	450.00	\N	atrasado	\N
3209	159	2025-03-10	250.00	250.00	pago	2025-03-10
3210	161	2025-03-10	250.00	250.00	pago	2025-03-08
3211	162	2025-03-10	350.00	350.00	pago	2025-03-10
3212	163	2025-03-10	450.00	450.00	pago	2025-03-08
3213	165	2025-03-10	250.00	250.00	pago	2025-03-09
3214	167	2025-03-10	450.00	450.00	pago	2025-03-08
3215	168	2025-03-10	150.00	150.00	pago	2025-03-10
3216	169	2025-03-10	250.00	250.00	pago	2025-03-08
3217	170	2025-03-10	350.00	350.00	pago	2025-03-09
3218	172	2025-03-10	150.00	150.00	pago	2025-03-12
3219	173	2025-03-10	250.00	250.00	pago	2025-03-10
3220	174	2025-03-10	350.00	350.00	pago	2025-03-12
3221	177	2025-03-10	250.00	250.00	pago	2025-03-10
3222	178	2025-03-10	350.00	350.00	pago	2025-03-08
3224	181	2025-03-10	250.00	250.00	pago	2025-03-09
3225	183	2025-03-10	450.00	450.00	pago	2025-03-10
3226	185	2025-03-10	250.00	250.00	pago	2025-03-10
3227	186	2025-03-10	350.00	350.00	pago	2025-03-08
3228	187	2025-03-10	450.00	450.00	pago	2025-03-08
3229	188	2025-03-10	150.00	150.00	pago	2025-03-09
3230	189	2025-03-10	250.00	250.00	pago	2025-03-10
3231	191	2025-03-10	450.00	450.00	pago	2025-03-10
3232	193	2025-03-10	250.00	250.00	pago	2025-03-09
3233	194	2025-03-10	350.00	350.00	pago	2025-03-08
3235	214	2025-03-10	350.00	350.00	pago	2025-03-09
3236	11	2025-03-10	250.00	250.00	pago	2025-03-08
3238	29	2025-03-10	250.00	250.00	pago	2025-03-10
3240	49	2025-03-10	250.00	250.00	pago	2025-03-09
3241	71	2025-03-10	250.00	250.00	pago	2025-03-09
3242	106	2025-03-10	250.00	250.00	pago	2025-03-08
3243	121	2025-03-10	250.00	250.00	pago	2025-03-10
3244	122	2025-03-10	250.00	250.00	pago	2025-03-08
3245	137	2025-03-10	250.00	250.00	pago	2025-03-08
3246	143	2025-03-10	250.00	250.00	pago	2025-03-11
3247	151	2025-03-10	250.00	250.00	pago	2025-03-09
3248	154	2025-03-10	250.00	250.00	pago	2025-03-09
3249	157	2025-03-10	250.00	250.00	pago	2025-03-09
3250	184	2025-03-10	250.00	250.00	pago	2025-03-08
3251	149	2025-03-10	350.00	350.00	pago	2025-03-09
3252	164	2025-03-10	350.00	350.00	pago	2025-03-10
3253	176	2025-03-10	350.00	350.00	pago	2025-03-10
3254	180	2025-03-10	350.00	350.00	pago	2025-03-10
3255	148	2025-03-10	450.00	450.00	pago	2025-03-10
3256	166	2025-03-10	450.00	450.00	pago	2025-03-09
3257	192	2025-03-10	450.00	450.00	pago	2025-03-10
3258	105	2025-03-10	250.00	250.00	pago	2025-03-10
3259	32	2025-03-10	250.00	250.00	pago	2025-03-10
3260	68	2025-03-10	250.00	250.00	pago	2025-03-08
3261	116	2025-03-10	250.00	250.00	pago	2025-03-09
3262	124	2025-03-10	250.00	250.00	pago	2025-03-09
3263	155	2025-03-10	250.00	250.00	pago	2025-03-08
3264	160	2025-03-10	250.00	250.00	pago	2025-03-10
3265	171	2025-03-10	250.00	250.00	pago	2025-03-10
3266	175	2025-03-10	250.00	250.00	pago	2025-03-09
3267	152	2025-03-10	250.00	250.00	pago	2025-03-09
3268	182	2025-03-10	250.00	250.00	pago	2025-03-10
3269	190	2025-03-10	250.00	250.00	pago	2025-03-10
3270	2	2025-04-10	150.00	150.00	pago	2025-04-15
3271	3	2025-04-10	250.00	250.00	pago	2025-04-09
3272	4	2025-04-10	350.00	350.00	pago	2025-04-08
3273	6	2025-04-10	250.00	250.00	pago	2025-04-09
3274	7	2025-04-10	150.00	150.00	pago	2025-04-10
3275	8	2025-04-10	350.00	350.00	pago	2025-04-09
3276	9	2025-04-10	250.00	250.00	pago	2025-04-08
3277	10	2025-04-10	450.00	450.00	pago	2025-04-10
3278	12	2025-04-10	350.00	350.00	pago	2025-04-12
3279	13	2025-04-10	150.00	150.00	pago	2025-04-09
3280	14	2025-04-10	150.00	150.00	pago	2025-04-10
3281	15	2025-04-10	450.00	450.00	pago	2025-04-08
3282	17	2025-04-10	150.00	150.00	pago	2025-04-12
3283	21	2025-04-10	250.00	250.00	pago	2025-04-09
3284	23	2025-04-10	150.00	150.00	pago	2025-04-09
3285	24	2025-04-10	350.00	350.00	pago	2025-04-09
3286	26	2025-04-10	150.00	150.00	pago	2025-04-09
3287	27	2025-04-10	250.00	250.00	pago	2025-04-09
3288	28	2025-04-10	350.00	350.00	pago	2025-04-09
3289	30	2025-04-10	450.00	450.00	pago	2025-04-09
3290	33	2025-04-10	250.00	250.00	pago	2025-04-09
3291	38	2025-04-10	150.00	150.00	pago	2025-04-08
3292	39	2025-04-10	250.00	250.00	pago	2025-04-09
3293	41	2025-04-10	150.00	150.00	pago	2025-04-10
3294	42	2025-04-10	250.00	250.00	pago	2025-04-08
3295	43	2025-04-10	150.00	150.00	pago	2025-04-08
3296	44	2025-04-10	350.00	350.00	pago	2025-04-10
3297	46	2025-04-10	150.00	150.00	pago	2025-04-10
3298	47	2025-04-10	150.00	150.00	pago	2025-04-08
3299	48	2025-04-10	350.00	350.00	pago	2025-04-09
3300	51	2025-04-10	250.00	250.00	pago	2025-04-08
3301	52	2025-04-10	350.00	350.00	pago	2025-04-08
3302	53	2025-04-10	150.00	150.00	pago	2025-04-10
3303	55	2025-04-10	450.00	450.00	pago	2025-04-09
3304	56	2025-04-10	350.00	350.00	pago	2025-04-10
3305	57	2025-04-10	250.00	250.00	pago	2025-04-08
3306	58	2025-04-10	150.00	150.00	pago	2025-04-08
3307	59	2025-04-10	150.00	150.00	pago	2025-04-10
3308	61	2025-04-10	150.00	150.00	pago	2025-04-10
3309	62	2025-04-10	150.00	150.00	pago	2025-04-10
3310	63	2025-04-10	250.00	250.00	pago	2025-04-10
3311	64	2025-04-10	350.00	350.00	pago	2025-04-10
3312	65	2025-04-10	450.00	450.00	pago	2025-04-09
3313	66	2025-04-10	250.00	250.00	pago	2025-04-10
3314	67	2025-04-10	150.00	150.00	pago	2025-04-09
3315	69	2025-04-10	250.00	250.00	pago	2025-04-09
3316	70	2025-04-10	450.00	450.00	pago	2025-04-10
3317	74	2025-04-10	150.00	150.00	pago	2025-04-11
3318	77	2025-04-10	150.00	150.00	pago	2025-04-10
3319	78	2025-04-10	250.00	250.00	pago	2025-04-10
3320	79	2025-04-10	150.00	150.00	pago	2025-04-08
3321	80	2025-04-10	450.00	450.00	pago	2025-04-08
3322	81	2025-04-10	250.00	250.00	pago	2025-04-09
3323	82	2025-04-10	150.00	150.00	pago	2025-04-10
3324	84	2025-04-10	350.00	350.00	pago	2025-04-15
3326	87	2025-04-10	250.00	250.00	pago	2025-04-10
3327	88	2025-04-10	350.00	350.00	pago	2025-04-08
3328	89	2025-04-10	150.00	150.00	pago	2025-04-09
3330	92	2025-04-10	350.00	350.00	pago	2025-04-10
3331	93	2025-04-10	250.00	250.00	pago	2025-04-08
3332	95	2025-04-10	450.00	450.00	pago	2025-04-10
3333	96	2025-04-10	350.00	350.00	pago	2025-04-10
3334	97	2025-04-10	150.00	150.00	pago	2025-04-08
3335	98	2025-04-10	150.00	150.00	pago	2025-04-10
3336	99	2025-04-10	250.00	250.00	pago	2025-04-14
3337	100	2025-04-10	450.00	450.00	pago	2025-04-10
3338	102	2025-04-10	250.00	250.00	pago	2025-04-08
3339	104	2025-04-10	350.00	350.00	pago	2025-04-09
3340	110	2025-04-10	450.00	450.00	pago	2025-04-09
3341	111	2025-04-10	250.00	250.00	pago	2025-04-08
3342	112	2025-04-10	350.00	350.00	pago	2025-04-10
3343	113	2025-04-10	150.00	150.00	pago	2025-04-10
3344	114	2025-04-10	250.00	250.00	pago	2025-04-09
3329	91	2025-04-10	150.00	\N	atrasado	\N
3325	86	2025-04-10	150.00	\N	atrasado	\N
3345	115	2025-04-10	450.00	450.00	pago	2025-04-15
3346	117	2025-04-10	250.00	250.00	pago	2025-04-09
3347	118	2025-04-10	150.00	150.00	pago	2025-04-10
3348	119	2025-04-10	150.00	150.00	pago	2025-04-10
3349	120	2025-04-10	450.00	450.00	pago	2025-04-09
3350	123	2025-04-10	250.00	250.00	pago	2025-04-12
3351	125	2025-04-10	450.00	450.00	pago	2025-04-14
3352	129	2025-04-10	250.00	250.00	pago	2025-04-09
3353	130	2025-04-10	450.00	450.00	pago	2025-04-08
3355	132	2025-04-10	350.00	350.00	pago	2025-04-10
3356	133	2025-04-10	150.00	150.00	pago	2025-04-08
3357	134	2025-04-10	150.00	150.00	pago	2025-04-10
3358	135	2025-04-10	450.00	450.00	pago	2025-04-09
3359	136	2025-04-10	350.00	350.00	pago	2025-04-08
3360	5	2025-04-10	250.00	250.00	pago	2025-04-08
3361	73	2025-04-10	350.00	350.00	pago	2025-04-08
3362	83	2025-04-10	350.00	350.00	pago	2025-04-09
3363	94	2025-04-10	350.00	350.00	pago	2025-04-08
3364	101	2025-04-10	350.00	350.00	pago	2025-04-08
3365	103	2025-04-10	350.00	350.00	pago	2025-04-08
3366	107	2025-04-10	350.00	350.00	pago	2025-04-10
3367	109	2025-04-10	350.00	350.00	pago	2025-04-09
3369	76	2025-04-10	450.00	450.00	pago	2025-04-09
3370	128	2025-04-10	450.00	450.00	pago	2025-04-08
3371	31	2025-04-10	450.00	450.00	pago	2025-04-10
3372	20	2025-04-10	250.00	250.00	pago	2025-04-08
3373	25	2025-04-10	250.00	250.00	pago	2025-04-10
3374	35	2025-04-10	250.00	250.00	pago	2025-04-10
3375	40	2025-04-10	250.00	250.00	pago	2025-04-13
3376	45	2025-04-10	250.00	250.00	pago	2025-04-09
3377	50	2025-04-10	250.00	250.00	pago	2025-04-08
3378	60	2025-04-10	250.00	250.00	pago	2025-04-15
3379	75	2025-04-10	250.00	250.00	pago	2025-04-09
3380	85	2025-04-10	250.00	250.00	pago	2025-04-08
3381	138	2025-04-10	250.00	250.00	pago	2025-04-10
3382	139	2025-04-10	150.00	150.00	pago	2025-04-09
3383	140	2025-04-10	450.00	450.00	pago	2025-04-09
3384	141	2025-04-10	250.00	250.00	pago	2025-04-08
3385	142	2025-04-10	150.00	150.00	pago	2025-04-09
3386	145	2025-04-10	450.00	450.00	pago	2025-04-09
3387	146	2025-04-10	150.00	150.00	pago	2025-04-08
3389	150	2025-04-10	450.00	450.00	pago	2025-04-10
3390	153	2025-04-10	250.00	250.00	pago	2025-04-10
3391	156	2025-04-10	350.00	350.00	pago	2025-04-10
3392	158	2025-04-10	150.00	150.00	pago	2025-04-08
3393	159	2025-04-10	250.00	250.00	pago	2025-04-10
3395	162	2025-04-10	350.00	350.00	pago	2025-04-09
3396	163	2025-04-10	450.00	450.00	pago	2025-04-09
3397	165	2025-04-10	250.00	250.00	pago	2025-04-08
3398	167	2025-04-10	450.00	450.00	pago	2025-04-08
3399	168	2025-04-10	150.00	150.00	pago	2025-04-08
3400	169	2025-04-10	250.00	250.00	pago	2025-04-09
3401	170	2025-04-10	350.00	350.00	pago	2025-04-10
3402	172	2025-04-10	150.00	150.00	pago	2025-04-09
3403	173	2025-04-10	250.00	250.00	pago	2025-04-10
3404	174	2025-04-10	350.00	350.00	pago	2025-04-10
3405	177	2025-04-10	250.00	250.00	pago	2025-04-15
3406	178	2025-04-10	350.00	350.00	pago	2025-04-10
3408	181	2025-04-10	250.00	250.00	pago	2025-04-12
3409	183	2025-04-10	450.00	450.00	pago	2025-04-10
3410	185	2025-04-10	250.00	250.00	pago	2025-04-10
3411	186	2025-04-10	350.00	350.00	pago	2025-04-13
3412	187	2025-04-10	450.00	450.00	pago	2025-04-10
3413	188	2025-04-10	150.00	150.00	pago	2025-04-09
3414	189	2025-04-10	250.00	250.00	pago	2025-04-08
3415	191	2025-04-10	450.00	450.00	pago	2025-04-09
3416	193	2025-04-10	250.00	250.00	pago	2025-04-10
3417	194	2025-04-10	350.00	350.00	pago	2025-04-08
3418	213	2025-04-10	250.00	250.00	pago	2025-04-10
3420	11	2025-04-10	250.00	250.00	pago	2025-04-10
3422	22	2025-04-10	250.00	250.00	pago	2025-04-10
3423	29	2025-04-10	250.00	250.00	pago	2025-04-09
3424	34	2025-04-10	250.00	250.00	pago	2025-04-08
3425	37	2025-04-10	250.00	250.00	pago	2025-04-08
3426	49	2025-04-10	250.00	250.00	pago	2025-04-10
3427	71	2025-04-10	250.00	250.00	pago	2025-04-09
3428	106	2025-04-10	250.00	250.00	pago	2025-04-09
3429	121	2025-04-10	250.00	250.00	pago	2025-04-08
3430	122	2025-04-10	250.00	250.00	pago	2025-04-09
3431	127	2025-04-10	250.00	250.00	pago	2025-04-09
3432	137	2025-04-10	250.00	250.00	pago	2025-04-09
3433	143	2025-04-10	250.00	250.00	pago	2025-04-10
3434	151	2025-04-10	250.00	250.00	pago	2025-04-13
3435	154	2025-04-10	250.00	250.00	pago	2025-04-09
3436	157	2025-04-10	250.00	250.00	pago	2025-04-08
3437	184	2025-04-10	250.00	250.00	pago	2025-04-08
3438	149	2025-04-10	350.00	350.00	pago	2025-04-09
3439	164	2025-04-10	350.00	350.00	pago	2025-04-09
3440	176	2025-04-10	350.00	350.00	pago	2025-04-09
3441	180	2025-04-10	350.00	350.00	pago	2025-04-08
3442	148	2025-04-10	450.00	450.00	pago	2025-04-10
3443	166	2025-04-10	450.00	450.00	pago	2025-04-10
3445	105	2025-04-10	250.00	250.00	pago	2025-04-12
3446	32	2025-04-10	250.00	250.00	pago	2025-04-09
3447	68	2025-04-10	250.00	250.00	pago	2025-04-08
3448	116	2025-04-10	250.00	250.00	pago	2025-04-12
3449	124	2025-04-10	250.00	250.00	pago	2025-04-10
3450	155	2025-04-10	250.00	250.00	pago	2025-04-10
3451	160	2025-04-10	250.00	250.00	pago	2025-04-08
3452	171	2025-04-10	250.00	250.00	pago	2025-04-09
3453	175	2025-04-10	250.00	250.00	pago	2025-04-10
3454	152	2025-04-10	250.00	250.00	pago	2025-04-10
3455	182	2025-04-10	250.00	250.00	pago	2025-04-09
3456	190	2025-04-10	250.00	250.00	pago	2025-04-10
3457	1	2025-04-10	250.00	250.00	pago	2025-04-09
3458	2	2025-05-10	150.00	150.00	pago	2025-05-09
3460	4	2025-05-10	350.00	350.00	pago	2025-05-08
3461	6	2025-05-10	250.00	250.00	pago	2025-05-10
3462	7	2025-05-10	150.00	150.00	pago	2025-05-09
3463	8	2025-05-10	350.00	350.00	pago	2025-05-10
3464	9	2025-05-10	250.00	250.00	pago	2025-05-08
3465	10	2025-05-10	450.00	450.00	pago	2025-05-10
3466	12	2025-05-10	350.00	350.00	pago	2025-05-15
3467	13	2025-05-10	150.00	150.00	pago	2025-05-10
3468	14	2025-05-10	150.00	150.00	pago	2025-05-10
3469	15	2025-05-10	450.00	450.00	pago	2025-05-12
3470	17	2025-05-10	150.00	150.00	pago	2025-05-10
3471	18	2025-05-10	250.00	250.00	pago	2025-05-10
3472	21	2025-05-10	250.00	250.00	pago	2025-05-10
3473	23	2025-05-10	150.00	150.00	pago	2025-05-10
3474	24	2025-05-10	350.00	350.00	pago	2025-05-10
3476	27	2025-05-10	250.00	250.00	pago	2025-05-08
3477	28	2025-05-10	350.00	350.00	pago	2025-05-08
3478	30	2025-05-10	450.00	450.00	pago	2025-05-09
3479	33	2025-05-10	250.00	250.00	pago	2025-05-15
3480	36	2025-05-10	350.00	350.00	pago	2025-05-10
3475	26	2025-05-10	150.00	\N	atrasado	\N
3459	3	2025-05-10	250.00	250.00	pago	2025-11-17
3481	38	2025-05-10	150.00	150.00	pago	2025-05-10
3482	39	2025-05-10	250.00	250.00	pago	2025-05-10
3483	41	2025-05-10	150.00	150.00	pago	2025-05-08
3484	42	2025-05-10	250.00	250.00	pago	2025-05-11
3485	43	2025-05-10	150.00	150.00	pago	2025-05-09
3486	44	2025-05-10	350.00	350.00	pago	2025-05-10
3487	46	2025-05-10	150.00	150.00	pago	2025-05-09
3488	47	2025-05-10	150.00	150.00	pago	2025-05-08
3489	48	2025-05-10	350.00	350.00	pago	2025-05-09
3490	51	2025-05-10	250.00	250.00	pago	2025-05-10
3491	52	2025-05-10	350.00	350.00	pago	2025-05-09
3494	55	2025-05-10	450.00	450.00	pago	2025-05-09
3495	56	2025-05-10	350.00	350.00	pago	2025-05-09
3496	57	2025-05-10	250.00	250.00	pago	2025-05-10
3497	58	2025-05-10	150.00	150.00	pago	2025-05-09
3498	59	2025-05-10	150.00	150.00	pago	2025-05-08
3499	61	2025-05-10	150.00	150.00	pago	2025-05-08
3500	62	2025-05-10	150.00	150.00	pago	2025-05-10
3501	63	2025-05-10	250.00	250.00	pago	2025-05-10
3502	64	2025-05-10	350.00	350.00	pago	2025-05-08
3503	65	2025-05-10	450.00	450.00	pago	2025-05-09
3504	66	2025-05-10	250.00	250.00	pago	2025-05-09
3505	67	2025-05-10	150.00	150.00	pago	2025-05-10
3506	69	2025-05-10	250.00	250.00	pago	2025-05-09
3507	70	2025-05-10	450.00	450.00	pago	2025-05-10
3508	74	2025-05-10	150.00	150.00	pago	2025-05-15
3509	77	2025-05-10	150.00	150.00	pago	2025-05-10
3510	78	2025-05-10	250.00	250.00	pago	2025-05-09
3511	79	2025-05-10	150.00	150.00	pago	2025-05-10
3512	80	2025-05-10	450.00	450.00	pago	2025-05-14
3513	81	2025-05-10	250.00	250.00	pago	2025-05-10
3514	82	2025-05-10	150.00	150.00	pago	2025-05-09
3515	84	2025-05-10	350.00	350.00	pago	2025-05-08
3516	86	2025-05-10	150.00	150.00	pago	2025-05-09
3517	87	2025-05-10	250.00	250.00	pago	2025-05-08
3518	88	2025-05-10	350.00	350.00	pago	2025-05-08
3520	91	2025-05-10	150.00	150.00	pago	2025-05-10
3521	92	2025-05-10	350.00	350.00	pago	2025-05-09
3522	93	2025-05-10	250.00	250.00	pago	2025-05-08
3523	95	2025-05-10	450.00	450.00	pago	2025-05-10
3525	97	2025-05-10	150.00	150.00	pago	2025-05-10
3527	99	2025-05-10	250.00	250.00	pago	2025-05-10
3528	100	2025-05-10	450.00	450.00	pago	2025-05-10
3529	102	2025-05-10	250.00	250.00	pago	2025-05-08
3530	104	2025-05-10	350.00	350.00	pago	2025-05-13
3531	108	2025-05-10	350.00	350.00	pago	2025-05-10
3532	110	2025-05-10	450.00	450.00	pago	2025-05-10
3533	111	2025-05-10	250.00	250.00	pago	2025-05-08
3534	112	2025-05-10	350.00	350.00	pago	2025-05-13
3535	113	2025-05-10	150.00	150.00	pago	2025-05-10
3536	114	2025-05-10	250.00	250.00	pago	2025-05-10
3537	115	2025-05-10	450.00	450.00	pago	2025-05-09
3538	117	2025-05-10	250.00	250.00	pago	2025-05-08
3539	118	2025-05-10	150.00	150.00	pago	2025-05-10
3540	119	2025-05-10	150.00	150.00	pago	2025-05-10
3541	120	2025-05-10	450.00	450.00	pago	2025-05-09
3542	123	2025-05-10	250.00	250.00	pago	2025-05-08
3543	125	2025-05-10	450.00	450.00	pago	2025-05-11
3544	126	2025-05-10	250.00	250.00	pago	2025-05-09
3545	129	2025-05-10	250.00	250.00	pago	2025-05-10
3546	130	2025-05-10	450.00	450.00	pago	2025-05-10
3547	131	2025-05-10	150.00	150.00	pago	2025-05-10
3548	132	2025-05-10	350.00	350.00	pago	2025-05-09
3549	133	2025-05-10	150.00	150.00	pago	2025-05-09
3550	134	2025-05-10	150.00	150.00	pago	2025-05-14
3551	135	2025-05-10	450.00	450.00	pago	2025-05-08
3552	136	2025-05-10	350.00	350.00	pago	2025-05-08
3553	5	2025-05-10	250.00	250.00	pago	2025-05-08
3554	73	2025-05-10	350.00	350.00	pago	2025-05-10
3555	83	2025-05-10	350.00	350.00	pago	2025-05-09
3556	94	2025-05-10	350.00	350.00	pago	2025-05-10
3557	101	2025-05-10	350.00	350.00	pago	2025-05-09
3558	103	2025-05-10	350.00	350.00	pago	2025-05-10
3559	107	2025-05-10	350.00	350.00	pago	2025-05-09
3560	109	2025-05-10	350.00	350.00	pago	2025-05-09
3561	16	2025-05-10	450.00	450.00	pago	2025-05-09
3562	76	2025-05-10	450.00	450.00	pago	2025-05-10
3563	128	2025-05-10	450.00	450.00	pago	2025-05-09
3564	31	2025-05-10	450.00	450.00	pago	2025-05-08
3565	20	2025-05-10	250.00	250.00	pago	2025-05-09
3566	25	2025-05-10	250.00	250.00	pago	2025-05-10
3567	35	2025-05-10	250.00	250.00	pago	2025-05-10
3568	40	2025-05-10	250.00	250.00	pago	2025-05-09
3569	45	2025-05-10	250.00	250.00	pago	2025-05-09
3570	50	2025-05-10	250.00	250.00	pago	2025-05-08
3571	60	2025-05-10	250.00	250.00	pago	2025-05-10
3572	75	2025-05-10	250.00	250.00	pago	2025-05-09
3573	85	2025-05-10	250.00	250.00	pago	2025-05-10
3574	138	2025-05-10	250.00	250.00	pago	2025-05-08
3575	139	2025-05-10	150.00	150.00	pago	2025-05-10
3576	140	2025-05-10	450.00	450.00	pago	2025-05-13
3577	141	2025-05-10	250.00	250.00	pago	2025-05-09
3578	142	2025-05-10	150.00	150.00	pago	2025-05-09
3579	144	2025-05-10	350.00	350.00	pago	2025-05-09
3580	145	2025-05-10	450.00	450.00	pago	2025-05-09
3581	146	2025-05-10	150.00	150.00	pago	2025-05-09
3582	147	2025-05-10	250.00	250.00	pago	2025-05-08
3583	150	2025-05-10	450.00	450.00	pago	2025-05-08
3584	153	2025-05-10	250.00	250.00	pago	2025-05-09
3585	156	2025-05-10	350.00	350.00	pago	2025-05-08
3586	158	2025-05-10	150.00	150.00	pago	2025-05-09
3587	159	2025-05-10	250.00	250.00	pago	2025-05-13
3588	161	2025-05-10	250.00	250.00	pago	2025-05-09
3590	163	2025-05-10	450.00	450.00	pago	2025-05-10
3591	165	2025-05-10	250.00	250.00	pago	2025-05-09
3592	167	2025-05-10	450.00	450.00	pago	2025-05-10
3593	168	2025-05-10	150.00	150.00	pago	2025-05-08
3594	169	2025-05-10	250.00	250.00	pago	2025-05-08
3595	170	2025-05-10	350.00	350.00	pago	2025-05-08
3596	172	2025-05-10	150.00	150.00	pago	2025-05-09
3597	173	2025-05-10	250.00	250.00	pago	2025-05-09
3598	174	2025-05-10	350.00	350.00	pago	2025-05-10
3599	177	2025-05-10	250.00	250.00	pago	2025-05-09
3600	178	2025-05-10	350.00	350.00	pago	2025-05-09
3601	179	2025-05-10	450.00	450.00	pago	2025-05-10
3602	181	2025-05-10	250.00	250.00	pago	2025-05-10
3603	183	2025-05-10	450.00	450.00	pago	2025-05-08
3604	185	2025-05-10	250.00	250.00	pago	2025-05-09
3605	186	2025-05-10	350.00	350.00	pago	2025-05-08
3606	187	2025-05-10	450.00	450.00	pago	2025-05-09
3607	188	2025-05-10	150.00	150.00	pago	2025-05-10
3608	189	2025-05-10	250.00	250.00	pago	2025-05-10
3609	191	2025-05-10	450.00	450.00	pago	2025-05-10
3610	193	2025-05-10	250.00	250.00	pago	2025-05-09
3611	194	2025-05-10	350.00	350.00	pago	2025-05-08
3612	213	2025-05-10	250.00	250.00	pago	2025-05-10
3613	214	2025-05-10	350.00	350.00	pago	2025-05-10
3614	11	2025-05-10	250.00	250.00	pago	2025-05-08
3615	19	2025-05-10	250.00	250.00	pago	2025-05-08
3616	22	2025-05-10	250.00	250.00	pago	2025-05-08
3617	29	2025-05-10	250.00	250.00	pago	2025-05-09
3618	34	2025-05-10	250.00	250.00	pago	2025-05-08
3619	37	2025-05-10	250.00	250.00	pago	2025-05-08
3620	49	2025-05-10	250.00	250.00	pago	2025-05-09
3621	71	2025-05-10	250.00	250.00	pago	2025-05-11
3622	106	2025-05-10	250.00	250.00	pago	2025-05-10
3623	121	2025-05-10	250.00	250.00	pago	2025-05-10
3624	122	2025-05-10	250.00	250.00	pago	2025-05-10
3626	137	2025-05-10	250.00	250.00	pago	2025-05-09
3627	143	2025-05-10	250.00	250.00	pago	2025-05-10
3628	151	2025-05-10	250.00	250.00	pago	2025-05-10
3629	154	2025-05-10	250.00	250.00	pago	2025-05-10
3630	157	2025-05-10	250.00	250.00	pago	2025-05-08
3631	184	2025-05-10	250.00	250.00	pago	2025-05-13
3632	149	2025-05-10	350.00	350.00	pago	2025-05-09
3633	164	2025-05-10	350.00	350.00	pago	2025-05-09
3634	176	2025-05-10	350.00	350.00	pago	2025-05-10
3635	180	2025-05-10	350.00	350.00	pago	2025-05-10
3636	90	2025-05-10	250.00	250.00	pago	2025-05-10
3637	148	2025-05-10	450.00	450.00	pago	2025-05-10
3638	166	2025-05-10	450.00	450.00	pago	2025-05-08
3639	192	2025-05-10	450.00	450.00	pago	2025-05-10
3640	105	2025-05-10	250.00	250.00	pago	2025-05-12
3641	32	2025-05-10	250.00	250.00	pago	2025-05-10
3642	68	2025-05-10	250.00	250.00	pago	2025-05-09
3643	72	2025-05-10	250.00	250.00	pago	2025-05-10
3644	116	2025-05-10	250.00	250.00	pago	2025-05-08
3646	155	2025-05-10	250.00	250.00	pago	2025-05-15
3647	160	2025-05-10	250.00	250.00	pago	2025-05-09
3648	171	2025-05-10	250.00	250.00	pago	2025-05-10
3649	175	2025-05-10	250.00	250.00	pago	2025-05-08
3650	152	2025-05-10	250.00	250.00	pago	2025-05-09
3651	182	2025-05-10	250.00	250.00	pago	2025-05-12
3652	190	2025-05-10	250.00	250.00	pago	2025-05-08
3653	1	2025-05-10	250.00	250.00	pago	2025-05-08
2916	124	2025-01-10	250.00	\N	atrasado	\N
2868	158	2025-01-10	150.00	\N	atrasado	\N
2893	22	2025-01-10	250.00	\N	atrasado	\N
2891	214	2025-01-10	350.00	\N	atrasado	\N
2883	185	2025-01-10	250.00	\N	atrasado	\N
2801	63	2025-01-10	250.00	\N	atrasado	\N
2864	142	2025-01-10	150.00	\N	atrasado	\N
2941	28	2025-02-10	350.00	\N	atrasado	\N
3085	160	2025-02-10	250.00	\N	atrasado	\N
3239	34	2025-03-10	250.00	\N	atrasado	\N
3223	179	2025-03-10	450.00	\N	atrasado	\N
3092	3	2025-03-10	250.00	\N	atrasado	\N
3128	61	2025-03-10	150.00	\N	atrasado	\N
3117	44	2025-03-10	350.00	\N	atrasado	\N
3234	213	2025-03-10	250.00	\N	atrasado	\N
3237	22	2025-03-10	250.00	\N	atrasado	\N
3419	214	2025-04-10	350.00	\N	atrasado	\N
3394	161	2025-04-10	250.00	\N	atrasado	\N
3368	16	2025-04-10	450.00	\N	atrasado	\N
3444	192	2025-04-10	450.00	\N	atrasado	\N
3407	179	2025-04-10	450.00	\N	atrasado	\N
3354	131	2025-04-10	150.00	\N	atrasado	\N
3388	147	2025-04-10	250.00	\N	atrasado	\N
3421	19	2025-04-10	250.00	\N	atrasado	\N
3645	124	2025-05-10	250.00	\N	atrasado	\N
3524	96	2025-05-10	350.00	\N	atrasado	\N
3519	89	2025-05-10	150.00	\N	atrasado	\N
3493	54	2025-05-10	250.00	\N	atrasado	\N
3526	98	2025-05-10	150.00	\N	atrasado	\N
3625	127	2025-05-10	250.00	\N	atrasado	\N
3492	53	2025-05-10	150.00	\N	atrasado	\N
3589	162	2025-05-10	350.00	\N	atrasado	\N
2653	59	2024-12-10	150.00	150.00	pago	2025-11-17
1819	161	2025-10-10	250.00	250.00	pago	2025-11-17
\.


--
-- Data for Name: plano_modalidades; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.plano_modalidades (id_plano, id_modalidade) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
2	1
2	2
2	3
2	4
2	5
2	6
2	7
2	8
3	1
3	2
3	3
3	4
3	5
3	6
3	7
3	8
4	1
4	2
4	3
4	4
4	5
4	6
4	7
4	8
\.


--
-- Data for Name: planos; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.planos (id_plano, nome, descricao, preco_mensal, ativo) FROM stdin;
1	Starter	Acesso a 1 modalidade	150.00	t
2	Light	Acesso a 2 modalidades	250.00	t
3	Premium	Acesso a 4 modalidades	350.00	t
4	Fighter	Acesso ilimitado a todas as modalidades	450.00	t
\.


--
-- Data for Name: promocoes; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.promocoes (id_promocao, nome_campanha, descricao, tipo, valor, duracao_meses, data_inicio_validade, data_fim_validade, ativa) FROM stdin;
\.


--
-- Data for Name: tipos_transacao; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.tipos_transacao (id_tipo_transacao, nome, descricao) FROM stdin;
1	Mensalidade	Pagamento mensal do plano
2	Matr??cula	Taxa de matr??cula inicial
3	Taxa de Manuten????o	Taxa de manuten????o das instala????es
4	Multa por Atraso	Multa aplicada em pagamentos atrasados
5	Desconto	Desconto aplicado no pagamento
\.


--
-- Data for Name: unidades; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.unidades (id_unidade, nome, endereco, telefone) FROM stdin;
1	Unidade Centro	Rua das Flores, 123 - Centro	(77) 3423-1234
2	Unidade Bairro Alto	Av. Brasil, 456 - Bairro Alto	(77) 3423-5678
3	Unidade Sul	Rua do Com??rcio, 789 - Zona Sul	(77) 3423-9012
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: gym_admin
--

COPY public.usuarios (id_usuario, username, senha_hash, nome_completo, email, ativo, data_criacao, ultimo_acesso) FROM stdin;
1	admin	240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9	Administrador	admin@sudoestefight.com	t	2025-11-02 22:30:10.307866-03	2025-11-17 03:51:12.748266-03
\.


--
-- Name: inscricoes_id_inscricao_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.inscricoes_id_inscricao_seq', 229, true);


--
-- Name: itens_pagamento_id_item_pagamento_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.itens_pagamento_id_item_pagamento_seq', 886, true);


--
-- Name: modalidades_id_modalidade_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.modalidades_id_modalidade_seq', 8, true);


--
-- Name: pagamentos_id_pagamento_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.pagamentos_id_pagamento_seq', 3653, true);


--
-- Name: planos_id_plano_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.planos_id_plano_seq', 4, true);


--
-- Name: promocoes_id_promocao_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.promocoes_id_promocao_seq', 1, false);


--
-- Name: tipos_transacao_id_tipo_transacao_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.tipos_transacao_id_tipo_transacao_seq', 5, true);


--
-- Name: unidades_id_unidade_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.unidades_id_unidade_seq', 3, true);


--
-- Name: usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: gym_admin
--

SELECT pg_catalog.setval('public.usuarios_id_usuario_seq', 1, true);


--
-- Name: alunos alunos_cpf_key; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.alunos
    ADD CONSTRAINT alunos_cpf_key UNIQUE (cpf);


--
-- Name: alunos alunos_email_key; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.alunos
    ADD CONSTRAINT alunos_email_key UNIQUE (email);


--
-- Name: alunos alunos_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.alunos
    ADD CONSTRAINT alunos_pkey PRIMARY KEY (matricula);


--
-- Name: inscricoes_modalidades inscricoes_modalidades_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes_modalidades
    ADD CONSTRAINT inscricoes_modalidades_pkey PRIMARY KEY (id_inscricao, id_modalidade);


--
-- Name: inscricoes inscricoes_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes
    ADD CONSTRAINT inscricoes_pkey PRIMARY KEY (id_inscricao);


--
-- Name: itens_pagamento itens_pagamento_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.itens_pagamento
    ADD CONSTRAINT itens_pagamento_pkey PRIMARY KEY (id_item_pagamento);


--
-- Name: modalidades modalidades_nome_key; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.modalidades
    ADD CONSTRAINT modalidades_nome_key UNIQUE (nome);


--
-- Name: modalidades modalidades_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.modalidades
    ADD CONSTRAINT modalidades_pkey PRIMARY KEY (id_modalidade);


--
-- Name: pagamentos pagamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_pkey PRIMARY KEY (id_pagamento);


--
-- Name: plano_modalidades plano_modalidades_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.plano_modalidades
    ADD CONSTRAINT plano_modalidades_pkey PRIMARY KEY (id_plano, id_modalidade);


--
-- Name: planos planos_nome_key; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.planos
    ADD CONSTRAINT planos_nome_key UNIQUE (nome);


--
-- Name: planos planos_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.planos
    ADD CONSTRAINT planos_pkey PRIMARY KEY (id_plano);


--
-- Name: promocoes promocoes_nome_campanha_key; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.promocoes
    ADD CONSTRAINT promocoes_nome_campanha_key UNIQUE (nome_campanha);


--
-- Name: promocoes promocoes_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.promocoes
    ADD CONSTRAINT promocoes_pkey PRIMARY KEY (id_promocao);


--
-- Name: tipos_transacao tipos_transacao_nome_key; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.tipos_transacao
    ADD CONSTRAINT tipos_transacao_nome_key UNIQUE (nome);


--
-- Name: tipos_transacao tipos_transacao_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.tipos_transacao
    ADD CONSTRAINT tipos_transacao_pkey PRIMARY KEY (id_tipo_transacao);


--
-- Name: unidades unidades_nome_key; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.unidades
    ADD CONSTRAINT unidades_nome_key UNIQUE (nome);


--
-- Name: unidades unidades_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.unidades
    ADD CONSTRAINT unidades_pkey PRIMARY KEY (id_unidade);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- Name: usuarios usuarios_username_key; Type: CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_username_key UNIQUE (username);


--
-- Name: idx_alunos_cpf; Type: INDEX; Schema: public; Owner: gym_admin
--

CREATE INDEX idx_alunos_cpf ON public.alunos USING btree (cpf);


--
-- Name: idx_alunos_email; Type: INDEX; Schema: public; Owner: gym_admin
--

CREATE INDEX idx_alunos_email ON public.alunos USING btree (email);


--
-- Name: idx_inscricoes_aluno; Type: INDEX; Schema: public; Owner: gym_admin
--

CREATE INDEX idx_inscricoes_aluno ON public.inscricoes USING btree (id_aluno);


--
-- Name: idx_inscricoes_status; Type: INDEX; Schema: public; Owner: gym_admin
--

CREATE INDEX idx_inscricoes_status ON public.inscricoes USING btree (status);


--
-- Name: idx_pagamentos_inscricao; Type: INDEX; Schema: public; Owner: gym_admin
--

CREATE INDEX idx_pagamentos_inscricao ON public.pagamentos USING btree (id_inscricao);


--
-- Name: idx_pagamentos_status; Type: INDEX; Schema: public; Owner: gym_admin
--

CREATE INDEX idx_pagamentos_status ON public.pagamentos USING btree (status);


--
-- Name: idx_pagamentos_vencimento; Type: INDEX; Schema: public; Owner: gym_admin
--

CREATE INDEX idx_pagamentos_vencimento ON public.pagamentos USING btree (data_vencimento);


--
-- Name: inscricoes inscricoes_id_aluno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes
    ADD CONSTRAINT inscricoes_id_aluno_fkey FOREIGN KEY (id_aluno) REFERENCES public.alunos(matricula) ON DELETE RESTRICT;


--
-- Name: inscricoes inscricoes_id_plano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes
    ADD CONSTRAINT inscricoes_id_plano_fkey FOREIGN KEY (id_plano) REFERENCES public.planos(id_plano) ON DELETE RESTRICT;


--
-- Name: inscricoes inscricoes_id_promocao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes
    ADD CONSTRAINT inscricoes_id_promocao_fkey FOREIGN KEY (id_promocao) REFERENCES public.promocoes(id_promocao) ON DELETE SET NULL;


--
-- Name: inscricoes inscricoes_id_unidade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes
    ADD CONSTRAINT inscricoes_id_unidade_fkey FOREIGN KEY (id_unidade) REFERENCES public.unidades(id_unidade) ON DELETE RESTRICT;


--
-- Name: inscricoes_modalidades inscricoes_modalidades_id_inscricao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes_modalidades
    ADD CONSTRAINT inscricoes_modalidades_id_inscricao_fkey FOREIGN KEY (id_inscricao) REFERENCES public.inscricoes(id_inscricao) ON DELETE CASCADE;


--
-- Name: inscricoes_modalidades inscricoes_modalidades_id_modalidade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.inscricoes_modalidades
    ADD CONSTRAINT inscricoes_modalidades_id_modalidade_fkey FOREIGN KEY (id_modalidade) REFERENCES public.modalidades(id_modalidade) ON DELETE CASCADE;


--
-- Name: itens_pagamento itens_pagamento_id_pagamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.itens_pagamento
    ADD CONSTRAINT itens_pagamento_id_pagamento_fkey FOREIGN KEY (id_pagamento) REFERENCES public.pagamentos(id_pagamento) ON DELETE CASCADE;


--
-- Name: itens_pagamento itens_pagamento_id_tipo_transacao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.itens_pagamento
    ADD CONSTRAINT itens_pagamento_id_tipo_transacao_fkey FOREIGN KEY (id_tipo_transacao) REFERENCES public.tipos_transacao(id_tipo_transacao) ON DELETE RESTRICT;


--
-- Name: pagamentos pagamentos_id_inscricao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_id_inscricao_fkey FOREIGN KEY (id_inscricao) REFERENCES public.inscricoes(id_inscricao) ON DELETE CASCADE;


--
-- Name: plano_modalidades plano_modalidades_id_modalidade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.plano_modalidades
    ADD CONSTRAINT plano_modalidades_id_modalidade_fkey FOREIGN KEY (id_modalidade) REFERENCES public.modalidades(id_modalidade) ON DELETE CASCADE;


--
-- Name: plano_modalidades plano_modalidades_id_plano_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gym_admin
--

ALTER TABLE ONLY public.plano_modalidades
    ADD CONSTRAINT plano_modalidades_id_plano_fkey FOREIGN KEY (id_plano) REFERENCES public.planos(id_plano) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: gym_admin
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict zET9Cg6hqtLqrEENqmPfCCX5UetkixI5CqnnN8mGContitOaBzRHlh50z2eVhOr

