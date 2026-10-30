-- =====================================================================
-- Atividade III - SEDUC DEST2
-- Banco de dados: PetVida (Clínica Veterinária e Pet Shop)
-- Script 01: criação do banco de dados
-- SGBD: PostgreSQL 16
--
-- Execute conectado ao banco padrão "postgres":
--   psql -U postgres -d postgres -f sql/01_criar_banco.sql
-- =====================================================================

DROP DATABASE IF EXISTS petvida;

CREATE DATABASE petvida;
