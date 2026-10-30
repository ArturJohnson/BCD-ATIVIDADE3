-- =====================================================================
-- Atividade III - SEDUC DEST2
-- Banco de dados: PetVida (Clínica Veterinária e Pet Shop)
-- Script 04: 15 consultas contextualizadas
--
-- Execute conectado ao banco "petvida":
--   psql -U postgres -d petvida -f sql/04_consultas.sql
-- =====================================================================

-- ---------------------------------------------------------------------
-- Consulta 01 - Tutores e seus animais
-- Recursos: INNER JOIN (4 tabelas), ORDER BY
-- Contexto: A recepção precisa imprimir a lista de todos os animais cadastrados com o nome do tutor, a espécie e a raça.
-- ---------------------------------------------------------------------
SELECT t.nome AS tutor, a.nome AS animal, e.nome AS especie, r.nome AS raca
FROM tutor t
INNER JOIN animal a  ON a.id_tutor   = t.id_tutor
INNER JOIN raca r    ON r.id_raca    = a.id_raca
INNER JOIN especie e ON e.id_especie = r.id_especie
ORDER BY t.nome, a.nome;

-- ---------------------------------------------------------------------
-- Consulta 02 - Cães de grande porte
-- Recursos: INNER JOIN, WHERE com AND, ORDER BY
-- Contexto: A veterinária quer separar os cães com mais de 10 kg para calcular a dose de vermífugo de grande porte.
-- ---------------------------------------------------------------------
SELECT a.nome AS animal, r.nome AS raca, a.peso_kg
FROM animal a
INNER JOIN raca r    ON r.id_raca    = a.id_raca
INNER JOIN especie e ON e.id_especie = r.id_especie
WHERE e.nome = 'Cão'
  AND a.peso_kg > 10
ORDER BY a.peso_kg DESC;

-- ---------------------------------------------------------------------
-- Consulta 03 - Busca de tutores por nome
-- Recursos: LIKE, OR
-- Contexto: Para uma ação de relacionamento, o marketing quer encontrar os tutores cujo nome começa com 'Ana' ou termina com 'Lima'.
-- ---------------------------------------------------------------------
SELECT id_tutor, nome, cidade
FROM tutor
WHERE nome LIKE 'Ana%'
   OR nome LIKE '%Lima'
ORDER BY nome;

-- ---------------------------------------------------------------------
-- Consulta 04 - Consultas realizadas entre março e junho de 2026
-- Recursos: BETWEEN, INNER JOIN, WHERE, ORDER BY
-- Contexto: A gerência quer conferir as consultas realizadas entre 01/03/2026 e 30/06/2026, com o animal e o veterinário responsável.
-- ---------------------------------------------------------------------
SELECT c.data_hora, a.nome AS animal, v.nome AS veterinario, c.diagnostico, c.valor
FROM consulta c
INNER JOIN animal a      ON a.id_animal      = c.id_animal
INNER JOIN veterinario v ON v.id_veterinario = c.id_veterinario
WHERE c.status = 'REALIZADA'
  AND c.data_hora BETWEEN '2026-03-01 00:00:00' AND '2026-06-30 23:59:59'
ORDER BY c.data_hora;

-- ---------------------------------------------------------------------
-- Consulta 05 - Faturamento por veterinário
-- Recursos: SUM, COUNT, GROUP BY, ORDER BY
-- Contexto: O financeiro precisa saber quanto cada veterinário faturou em consultas realizadas, do maior para o menor.
-- ---------------------------------------------------------------------
SELECT v.nome AS veterinario,
       COUNT(*)     AS qtd_consultas,
       SUM(c.valor) AS faturamento
FROM consulta c
INNER JOIN veterinario v ON v.id_veterinario = c.id_veterinario
WHERE c.status = 'REALIZADA'
GROUP BY v.nome
ORDER BY faturamento DESC, v.nome;

-- ---------------------------------------------------------------------
-- Consulta 06 - Perfil dos animais por espécie
-- Recursos: LEFT JOIN, COUNT, AVG, ROUND, GROUP BY
-- Contexto: A direção quer conhecer o perfil do público atendido: quantos animais, peso médio e idade média (em anos, em 30/10/2026) por espécie.
-- ---------------------------------------------------------------------
SELECT e.nome AS especie,
       COUNT(a.id_animal) AS qtd_animais,
       ROUND(AVG(a.peso_kg), 2) AS peso_medio_kg,
       ROUND(AVG(EXTRACT(YEAR FROM AGE(DATE '2026-10-30', a.data_nascimento))), 1) AS idade_media_anos
FROM especie e
LEFT JOIN raca r   ON r.id_especie = e.id_especie
LEFT JOIN animal a ON a.id_raca    = r.id_raca
GROUP BY e.nome
ORDER BY qtd_animais DESC, e.nome;

-- ---------------------------------------------------------------------
-- Consulta 07 - Tutores que mais gastaram
-- Recursos: SUM, GROUP BY, HAVING, ORDER BY
-- Contexto: O programa de fidelidade premia os tutores que gastaram mais de R$ 600,00 em consultas realizadas.
-- ---------------------------------------------------------------------
SELECT t.nome AS tutor, SUM(c.valor) AS total_gasto
FROM consulta c
INNER JOIN animal a ON a.id_animal = c.id_animal
INNER JOIN tutor t  ON t.id_tutor  = a.id_tutor
WHERE c.status = 'REALIZADA'
GROUP BY t.nome
HAVING SUM(c.valor) > 600
ORDER BY total_gasto DESC;

-- ---------------------------------------------------------------------
-- Consulta 08 - Medicamentos mais prescritos
-- Recursos: SUM, COUNT, GROUP BY, ORDER BY, LIMIT
-- Contexto: A farmácia quer saber os 5 medicamentos com maior volume prescrito para planejar as compras.
-- ---------------------------------------------------------------------
SELECT m.nome AS medicamento,
       COUNT(*)           AS qtd_prescricoes,
       SUM(cm.quantidade) AS unidades_prescritas
FROM consulta_medicamento cm
INNER JOIN medicamento m ON m.id_medicamento = cm.id_medicamento
GROUP BY m.nome
ORDER BY unidades_prescritas DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- Consulta 09 - Estoque baixo de medicamentos
-- Recursos: WHERE com operador de comparação, ORDER BY
-- Contexto: O almoxarifado precisa de um alerta com os medicamentos que têm menos de 50 unidades em estoque.
-- ---------------------------------------------------------------------
SELECT nome, fabricante, estoque
FROM medicamento
WHERE estoque < 50
ORDER BY estoque;

-- ---------------------------------------------------------------------
-- Consulta 10 - Custo total de cada consulta com medicamentos
-- Recursos: INNER JOIN (4 tabelas), SUM com expressão, GROUP BY, ORDER BY
-- Contexto: Para o fechamento, o caixa precisa do valor de cada consulta somado ao valor dos medicamentos prescritos nela.
-- ---------------------------------------------------------------------
SELECT c.id_consulta,
       a.nome AS animal,
       c.valor AS valor_consulta,
       SUM(cm.quantidade * m.preco_unitario) AS valor_medicamentos,
       c.valor + SUM(cm.quantidade * m.preco_unitario) AS total_a_pagar
FROM consulta c
INNER JOIN animal a               ON a.id_animal       = c.id_animal
INNER JOIN consulta_medicamento cm ON cm.id_consulta   = c.id_consulta
INNER JOIN medicamento m          ON m.id_medicamento  = cm.id_medicamento
GROUP BY c.id_consulta, a.nome, c.valor
ORDER BY total_a_pagar DESC;

-- ---------------------------------------------------------------------
-- Consulta 11 - Animais que nunca foram vacinados
-- Recursos: LEFT JOIN, IS NULL
-- Contexto: A campanha de vacinação quer contatar os tutores dos animais que ainda não têm nenhuma vacina registrada.
-- ---------------------------------------------------------------------
SELECT a.nome AS animal, t.nome AS tutor, t.telefone
FROM animal a
INNER JOIN tutor t ON t.id_tutor = a.id_tutor
LEFT JOIN aplicacao_vacina av ON av.id_animal = a.id_animal
WHERE av.id_aplicacao IS NULL
ORDER BY a.nome;

-- ---------------------------------------------------------------------
-- Consulta 12 - Reforços de vacina previstos para jan-fev/2027
-- Recursos: BETWEEN com datas, aritmética de datas, INNER JOIN
-- Contexto: O sistema de lembretes avisa os tutores dos animais cujo reforço vence entre 01/01/2027 e 28/02/2027 (data da aplicação + intervalo de reforço).
-- ---------------------------------------------------------------------
SELECT a.nome AS animal,
       t.nome AS tutor,
       v.nome AS vacina,
       av.data_aplicacao,
       av.data_aplicacao + v.intervalo_reforco_dias AS reforco_previsto
FROM aplicacao_vacina av
INNER JOIN animal a ON a.id_animal = av.id_animal
INNER JOIN tutor t  ON t.id_tutor  = a.id_tutor
INNER JOIN vacina v ON v.id_vacina = av.id_vacina
WHERE av.data_aplicacao + v.intervalo_reforco_dias
      BETWEEN DATE '2027-01-01' AND DATE '2027-02-28'
ORDER BY reforco_previsto, a.nome;

-- ---------------------------------------------------------------------
-- Consulta 13 - Veterinários, especialidades e dias de atendimento
-- Recursos: Subconsultas correlacionadas, INNER JOIN, string_agg com ORDER BY
-- Contexto: A recepção quer uma ficha única por veterinário com as especialidades e os dias em que ele atende, para orientar o agendamento. Como especialidades e dias são fatos independentes (4FN), cada lista é agregada em sua própria subconsulta, sem produto cartesiano.
-- ---------------------------------------------------------------------
SELECT v.nome AS veterinario,
       (SELECT string_agg(es.nome, ', ' ORDER BY es.nome)
        FROM veterinario_especialidade ve
        INNER JOIN especialidade es ON es.id_especialidade = ve.id_especialidade
        WHERE ve.id_veterinario = v.id_veterinario) AS especialidades,
       (SELECT string_agg(d.dia_semana, ', ' ORDER BY
               array_position(ARRAY['SEG','TER','QUA','QUI','SEX','SAB','DOM'], d.dia_semana))
        FROM veterinario_dia_atendimento d
        WHERE d.id_veterinario = v.id_veterinario) AS dias_atendimento
FROM veterinario v
ORDER BY v.nome;

-- ---------------------------------------------------------------------
-- Consulta 14 - Animais com microchip (relação 1:1)
-- Recursos: INNER JOIN, relacionamento 1:1, ORDER BY
-- Contexto: A clínica emite a carteirinha de identificação dos animais microchipados, com o número do chip, a data do implante e o contato do tutor.
-- ---------------------------------------------------------------------
SELECT a.nome AS animal, m.numero AS microchip, m.data_implante,
       t.nome AS tutor, t.telefone
FROM microchip m
INNER JOIN animal a ON a.id_animal = m.id_animal
INNER JOIN tutor t  ON t.id_tutor  = a.id_tutor
ORDER BY m.data_implante;

-- ---------------------------------------------------------------------
-- Consulta 15 - Animais atendidos por dermatologistas
-- Recursos: Subconsulta com IN, INNER JOIN, DISTINCT
-- Contexto: Para uma campanha de prevenção de alergias, a clínica lista os animais que já passaram por algum veterinário com especialidade em Dermatologia.
-- ---------------------------------------------------------------------
SELECT DISTINCT a.nome AS animal, t.nome AS tutor
FROM animal a
INNER JOIN tutor t ON t.id_tutor = a.id_tutor
WHERE a.id_animal IN (
      SELECT c.id_animal
      FROM consulta c
      INNER JOIN veterinario_especialidade ve ON ve.id_veterinario   = c.id_veterinario
      INNER JOIN especialidade es             ON es.id_especialidade = ve.id_especialidade
      WHERE es.nome = 'Dermatologia'
)
ORDER BY a.nome;
