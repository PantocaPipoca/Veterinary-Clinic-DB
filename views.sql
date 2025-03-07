CREATE OR REPLACE VIEW infoParaVeterinarios AS
SELECT 
    a.Nr_Agendamento,
    a.Data_Agendamento,
    a.Hora_Inicio || ' - ' || a.Hora_Fim AS Horario_Completo,
    v.Nr_Veterenario AS Veterinario_ID,
    p.Nome AS Veterinario_Nome,
    l.Ref_Local AS Localizacao,
    l.Distancia || ' km' AS Distancia,
    pg.Valor AS Valor_Pagamento,
    COALESCE(sc.Nome_Consulta, 'Sem Consulta') AS Consulta,
    COALESCE(sv.Nome_Vacina, 'Sem Vacina') AS Vacina
FROM 
    Agendamento a
LEFT JOIN 
    Localizacao l ON a.Ref_Local = l.Ref_Local
LEFT JOIN 
    Agendamento_Veterinario av ON a.Nr_Agendamento = av.Nr_Agendamento
LEFT JOIN 
    Veterinario v ON av.Nr_Veterenario = v.Nr_Veterenario
LEFT JOIN 
    Pessoa p ON v.CC = p.CC
LEFT JOIN 
    Pagamento pg ON a.Nr_Agendamento = pg.Nr_Agendamento
LEFT JOIN 
    Servico_Consulta sc ON a.ID_Servico = sc.ID_Servico
LEFT JOIN 
    Servico_Vacina sv ON a.ID_Servico = sv.ID_Servico;


CREATE OR REPLACE VIEW infoParaClientes AS
SELECT 
    c.Nr_Cliente,
    p.Nome AS Nome_Cliente,
    an.Nome AS Nome_Animal,
    a.Data_Agendamento,
    a.Hora_Inicio || ' - ' || a.Hora_Fim AS Horario_Agendamento,
    pg.Valor AS Valor_Pagamento,
    s.Nome AS Nome_Servico
FROM 
    Cliente c
JOIN 
    Pessoa p ON c.CC = p.CC
JOIN 
    Animal an ON c.Nr_Cliente = an.Nr_Cliente
JOIN 
    Agendamento a ON an.Nr_Animal = a.Nr_Animal
LEFT JOIN 
    Pagamento pg ON a.Nr_Agendamento = pg.Nr_Agendamento
LEFT JOIN 
    Servico s ON a.ID_Servico = s.ID_Servico;