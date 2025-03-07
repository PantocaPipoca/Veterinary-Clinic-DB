-- Q1 - Servicos agendados para um certo veterinario apos a data atual,
-- para os funcionários prepararem o equipamento necessário
SELECT s.nome AS Servico, a.Data_Agendamento, a.Hora_Inicio, a.Hora_Fim
FROM agendamento a
JOIN servico s ON a.ID_Servico = s.ID_Servico
JOIN agendamento_veterinario av ON a.Nr_Agendamento = av.Nr_Agendamento
WHERE av.Nr_Veterenario = 1 AND a.Data_Agendamento >= CURRENT_DATE OR
(a.data_agendamento = CURRENT_DATE AND a.hora_inicio >= CURRENT_TIME);

-- Q2 - Dinheiro ganho pelos veterenarios, poderá ser útil para a gerência
-- saber que veterinários estão a ter um melhor desempenho a nível financeiro
SELECT v.nr_veterenario, p.nome, SUM(pag.valor) AS ganho_total
FROM Veterinario v
JOIN Pessoa p ON v.cc = p.cc
JOIN Agendamento_Veterinario av ON v.nr_veterenario = av.nr_veterenario
JOIN Agendamento a ON av.nr_agendamento = a.nr_agendamento
JOIN pagamento pag ON a.nr_agendamento = pag.nr_agendamento
WHERE pag.data_pagamento IS NOT NULL
GROUP BY v.nr_veterenario, p.nome;

-- Q3 - Locais com mais de 0 agendamentos marcados e os seus respetivos
-- números, útil para realizar estatísticas, por exemplo onde temos mais clientes
SELECT l.Ref_Local, l.localizacao, COUNT(a.Nr_agendamento) as total_agendamentos
FROM Localizacao l, Agendamento a
WHERE l.Ref_Local = a.Ref_Local
GROUP BY l.Ref_Local
HAVING COUNT(a.Nr_agendamento) > 0;

-- Q4 - Agendamentos sem o pagamento efetuado, util para a gerência
--saber quem não pagou e quem deve pagar
SELECT a.Nr_Agendamento, pag.valor
FROM Agendamento a
LEFT OUTER JOIN Pagamento pag ON a.Nr_Agendamento = pag.Nr_Agendamento
WHERE pag.metodo IS NULL;

-- Q5 - Veterinários mais ativos que a média, serve para a gerência
-- saber quais os veterinários que trabalham mais
SELECT p.Nome AS Veterinario
FROM Pessoa p
JOIN Veterinario v ON p.CC = v.CC
WHERE (
  SELECT COUNT(*)
  FROM Agendamento_Veterinario av
  WHERE av.Nr_Veterenario = v.Nr_Veterenario) > (
      SELECT AVG(participacao)
      FROM (
        SELECT COUNT(*) AS participacao
        FROM Agendamento_Veterinario
        GROUP BY Nr_Veterenario) sub);

-- Q6 - Clientes que gastaram acima da média, útil para determinar quais clientes
-- têm animais mais doentes e/ou quais clientes são mais leais à empresa
WITH MediaGastos AS (
    SELECT AVG(Total_Gasto) AS Media
    FROM (
        SELECT c.Nr_Cliente, SUM(s.Valor_Total) AS Total_Gasto
        FROM Cliente c
        JOIN Animal a ON c.Nr_Cliente = a.Nr_Cliente
        JOIN Agendamento ag ON a.Nr_Animal = ag.Nr_Animal
        JOIN Servico s ON ag.ID_Servico = s.ID_Servico
        GROUP BY c.Nr_Cliente
    ) AS GastosPorCliente
)
SELECT p.Nome AS Cliente, SUM(s.Valor_Total) AS Total_Gasto
FROM Pessoa p
JOIN Cliente c ON p.CC = c.CC
JOIN Animal a ON c.Nr_Cliente = a.Nr_Cliente
JOIN Agendamento ag ON a.Nr_Animal = ag.Nr_Animal
JOIN Servico s ON ag.ID_Servico = s.ID_Servico
GROUP BY p.Nome
HAVING SUM(s.Valor_Total) > (SELECT Media FROM MediaGastos);

-- Q7 - Clientes que têm pelo menos um animal que nunca foi vacinado, serve para
-- determinar quais os animais que não podemos ter a certeza se foram vacinados,
-- por razões de segurança
SELECT p.Nome AS Cliente
FROM Pessoa p
JOIN Cliente c ON p.CC = c.CC
WHERE EXISTS (
    FROM Animal a
    WHERE a.Nr_Cliente = c.Nr_Cliente
    AND NOT EXISTS (
        FROM Agendamento ag
        JOIN Servico_Vacina sv ON ag.ID_Servico = sv.ID_Servico
        WHERE ag.Nr_Animal = a.Nr_Animal
    )
);

-- Q8 - Encontrar pares de animais com o mesmo nome mas espécies diferentes, útil
-- para não gerar confusões entre animais com o mesmo nome
SELECT
    a1.Nr_Animal AS Animal_1,
    a2.Nr_Animal AS Animal_2,
    a1.Nome AS Nome_Comum,
    a1.Especie AS Especie_Animal_1,
    a2.Especie AS Especie_Animal_2
FROM Animal a1, Animal a2
WHERE a1.Nr_Animal < a2.Nr_Animal
  AND a1.Nome = a2.Nome
  AND a1.Especie <> a2.Especie;

-- Q9 - Serviços que incluem todas as vacinas disponíveis, serve para demonstrar
-- a clientes "pacotes" de serviços que pode-se fazer que tenha todas as vacinas possíveis
SELECT s.ID_Servico, s.Nome
FROM Servico s
WHERE NOT EXISTS (
    (SELECT Nome_Vacina FROM Vacinas)
    EXCEPT
    (SELECT Nome_Vacina 
     FROM Servico_Vacina sv
     WHERE sv.ID_Servico = s.ID_Servico)
);


-- Q10 - Emails que acabam em email.com, será útil para fazer alguma automatização
-- de envio de emails.
SELECT email 
FROM Email
WHERE email LIKE '%@email.com';

-- Q11 - O veterinário mais bem pago, é útil para a gerência perceber qual o
-- veterinário "mais valioso" da clínica, e se devem-no manter assim
SELECT v.Nr_Veterenario, p.Nome, v.Salario
FROM Veterinario v
JOIN Pessoa p ON p.CC = v.CC
WHERE v.Salario > ALL (
    SELECT Salario
    FROM Veterinario
    WHERE Nr_Veterenario <> v.Nr_Veterenario
);

/* Q12 - Relatório do dia 12-11-2024, com várias estatísticas acerca dos rendimentos,
   agrupados por rua do agendamento Com informações como, a distância da rua, os
agendamentos, serviços que ocorreram nesse dia, o total de especies e clientes que foram atendidos, como também o veterinário mais ativo e agendamento mais ativo e com o rendimento do dia. Esta query é de utilidade enorme, pois apresenta todas as estatísticas da clínica diárias relevantes numa só, fazendo com que a  gerência consiga tomar decisões mais informadas e debruçadas
**/


WITH 
-- Agendamentos do dia especificado
AgendamentosDoDia AS (
    SELECT ag.Nr_Agendamento, ag.Ref_Local, ag.ID_Servico, ag.Nr_Animal
    FROM Agendamento ag
    WHERE ag.Data_Agendamento = '2024-12-11'
),

-- Todas as localizações envolvidas no dia (sem filtro por nome)
TodasLocalizacoesDia AS (
    SELECT DISTINCT ad.Ref_Local, (l.Localizacao).Rua AS Rua, l.Distancia
    FROM AgendamentosDoDia ad
    JOIN Localizacao l ON ad.Ref_Local = l.Ref_Local
),

-- Veterinários envolvidos nos agendamentos do dia
VetInvolvidos AS (
    SELECT av.Nr_Agendamento, v.Nr_Veterenario, p.Nome AS Nome_Vet
    FROM Agendamento_Veterinario av
    JOIN Veterinario v ON av.Nr_Veterenario = v.Nr_Veterenario
    JOIN Pessoa p ON p.CC = v.CC
),

-- Animais (espécie) e clientes atendidos
AnimalCliente AS (
    SELECT a.Nr_Animal, a.Especie, c.Nr_Cliente
    FROM Animal a
    JOIN Cliente c ON a.Nr_Cliente = c.Nr_Cliente
),

-- Cliente => Nome_Cliente
ClientePessoa AS (
    SELECT c.Nr_Cliente, p.Nome AS Nome_Cliente
    FROM Cliente c
    JOIN Pessoa p ON p.CC = c.CC
),

-- Serviços e seus valores
ServicosInfo AS (
    SELECT s.ID_Servico, s.Valor_Total
    FROM Servico s
),

-- Vacinas disponíveis
TodasVacinas AS (
    SELECT Nome_Vacina
    FROM Vacinas
),

-- Vacinas administradas num agendamento
VacinasNoAgendamento AS (
    SELECT ad.Nr_Agendamento, sv.Nome_Vacina
    FROM AgendamentosDoDia ad
    JOIN Servico_Vacina sv ON ad.ID_Servico = sv.ID_Servico
)

SELECT 
    tld.Rua,
    tld.Distancia,
    COUNT(DISTINCT ad.Nr_Agendamento) AS Total_Agendamentos,
    COUNT(DISTINCT ad.ID_Servico) AS Total_Servicos,
    COUNT(DISTINCT ac.Nr_Cliente) AS Total_Clientes,
    COUNT(DISTINCT ac.Especie) AS Total_Especies,
    -- Veterinário mais ativo (com mais agendamentos) naquela localização
    (SELECT Nome_Vet
     FROM (
        SELECT vi.Nome_Vet, COUNT(*) AS AgendamentosVet
        FROM AgendamentosDoDia ad
        JOIN VetInvolvidos vi ON ad.Nr_Agendamento = vi.Nr_Agendamento
        WHERE ad.Ref_Local = tld.Ref_Local
        GROUP BY vi.Nome_Vet
        ORDER BY COUNT(*) DESC
        LIMIT 1
     )
    ) AS Vet_Mais_Ativo,
    (SELECT AgendamentosVet
     FROM (
        SELECT vi.Nome_Vet, COUNT(*) AS AgendamentosVet
        FROM AgendamentosDoDia ad
        JOIN VetInvolvidos vi ON ad.Nr_Agendamento = vi.Nr_Agendamento
        WHERE ad.Ref_Local = tld.Ref_Local
        GROUP BY vi.Nome_Vet
        ORDER BY COUNT(*) DESC
        LIMIT 1
     )
    ) AS Agend_Vet_Mais_Ativo,
    SUM(si.Valor_Total) AS Valor_Total_Faturado,
    -- Média real dos serviços: agrupar primeiro por serviço para evitar duplicação
    (SELECT AVG(Valor_Total) 
     FROM (
       SELECT DISTINCT ad.ID_Servico, si.Valor_Total
       FROM AgendamentosDoDia ad
       JOIN ServicosInfo si ON ad.ID_Servico = si.ID_Servico
       WHERE ad.Ref_Local = tld.Ref_Local
     ) ServicosUnicos
    ) AS Valor_Medio_Por_Servico
   
FROM TodasLocalizacoesDia tld
JOIN AgendamentosDoDia ad ON tld.Ref_Local = ad.Ref_Local
JOIN AnimalCliente ac ON ac.Nr_Animal = ad.Nr_Animal
JOIN ServicosInfo si ON ad.ID_Servico = si.ID_Servico
GROUP BY tld.Rua, tld.Distancia, tld.Ref_Local
ORDER BY Valor_Total_Faturado DESC;