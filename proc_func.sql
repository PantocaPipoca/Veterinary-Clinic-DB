-------------------------------------Garantir a relacao animal cliente-------------------------------------
--Serve para quando o cliente ainda nao existe na base de dados
--Requires: Animal associado, telemovel ou email
CREATE OR REPLACE FUNCTION definirNovoCliente(
    p_cc CHAR(12),
    p_nomePessoa VARCHAR(100),
    p_nomeAnimal VARCHAR(50),
    p_especie VARCHAR(50),
    p_nrTelemovel VARCHAR(15) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_nrCliente INT;
BEGIN
    --Verifica se o cliente tem pelo menos um contacto fornecido
    IF p_nrTelemovel IS NULL AND p_email IS NULL THEN
        RAISE EXCEPTION 'Um cliente deve ter pelo menos um número de telemóvel ou um email associado.';
    END IF;
    --Insere os dados do cliente
    INSERT INTO Pessoa (CC, Nome)
    VALUES (p_cc, p_nomePessoa);

    INSERT INTO Cliente (CC)
    VALUES (p_cc)
    RETURNING Nr_Cliente INTO v_nrCliente;

    IF p_nrTelemovel IS NOT NULL THEN
        INSERT INTO Telemovel (CC, Nr_Telemovel)
        VALUES (p_cc, p_nrTelemovel);
    END IF;

    IF p_email IS NOT NULL THEN
        INSERT INTO Email (CC, Email)
        VALUES (p_cc, p_email);
    END IF;
    --Insere os dados do primeiro animal
    INSERT INTO Animal (Nr_Cliente, Nome, Especie)
    VALUES (v_nrCliente, p_nomeAnimal, p_especie);
END;
$$ LANGUAGE plpgsql;

-------------------------------------Garantir as relacoes e RI com o agendamento-------------------------------------
--Serve para garantir que nao ha sobreposicao de horarios de agendamento para um veterinario
--Requires: Veterinario
CREATE OR REPLACE FUNCTION validarSobreposicao(
    p_nrVeterinario INT,
    p_dataAgendamento DATE,
    p_horaInicio TIME,
    p_horaFim TIME
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS (
        FROM Agendamento AS a
        JOIN Agendamento_Veterinario AS av ON a.Nr_Agendamento = av.Nr_Agendamento
        WHERE av.Nr_Veterenario = p_nrVeterinario
        AND a.Data_Agendamento = p_dataAgendamento
        AND (p_horaInicio < a.Hora_Fim AND p_horaFim > a.Hora_Inicio)
    );
END;
$$ LANGUAGE plpgsql;

--Garantir que não há sobreposições de horários de agendamento para um animal
CREATE OR REPLACE FUNCTION validarSobreposicaoAnimal(
    p_nrAnimal INT,
    p_dataAgendamento DATE,
    p_horaInicio TIME,
    p_horaFim TIME
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS (
        FROM Agendamento AS a
        WHERE a.Nr_Animal = p_nrAnimal
        AND a.Data_Agendamento = p_dataAgendamento
        AND (p_horaInicio < a.Hora_Fim AND p_horaFim > a.Hora_Inicio)
    );
END;
$$ LANGUAGE plpgsql;


--Serve para quando o agendamento ainda nao existe na base de dados
--Requires: Veterinario, Localizacao, Servico ou Nome de Servico + Consulta ou Vacina
CREATE OR REPLACE PROCEDURE definirAgendamento(
    IN p_dataAgendamento DATE,
    IN p_horaInicio TIME,
    IN p_horaFim TIME,
    IN p_nrAnimal INT,
    IN p_refLocal INT,
    IN p_nrVeterinario INT,
    IN p_nomeServico VARCHAR(100) DEFAULT NULL,
    IN p_idServico INT DEFAULT NULL,
    IN p_nomeConsulta VARCHAR(100) DEFAULT NULL,
    IN p_nomeVacina VARCHAR(100) DEFAULT NULL,
    IN p_valorConsulta DECIMAL(10, 2) DEFAULT 0,
    IN p_valorVacina DECIMAL(10, 2) DEFAULT 0
)
AS $$
DECLARE
    v_nrAgendamento INT;
    v_idServico INT;
    v_valorServico DECIMAL(10, 2) DEFAULT 0;
    v_taxaDeslocamento DECIMAL(10, 2);
BEGIN

    --Verifica se o veterinario tem um agendamento marcado para esse horario
    IF NOT validarSobreposicao(p_nrVeterinario, p_dataAgendamento, p_horaInicio, p_horaFim) THEN
        RAISE EXCEPTION 'O veterinário tem um agendamento marcado para esse horário.';
    END IF;

    IF NOT validarSobreposicaoAnimal(p_nrAnimal, p_dataAgendamento, p_horaInicio, p_horaFim) THEN
    RAISE EXCEPTION 'O animal já possui um agendamento marcado para este horário.';
    END IF;


    --Verifica se o cliente forneceu ou um servico ja existente ou um nome para um servico novo
    IF p_idServico IS NULL AND p_nomeServico IS NULL THEN
        RAISE EXCEPTION 'Um agendamento requer um nome de serviço ou um ID de serviço existente.';
    END IF;

    IF p_idServico IS NULL THEN

        --Verifica se o cliente forneceu uma consulta ou uma vacina para associar ao servico novo
        IF p_nomeConsulta IS NULL AND p_nomeVacina IS NULL THEN
            RAISE EXCEPTION 'Ao criar um serviço, é obrigatório fornecer uma consulta ou uma vacina.';
        END IF;
        --Insere o servico e as suas associas
        INSERT INTO Servico (Nome, Valor_Total)
        VALUES (p_nomeServico, 0)
        RETURNING ID_Servico INTO v_idServico;


        IF p_nomeConsulta IS NOT NULL THEN
            PERFORM 1 FROM Consultas WHERE Nome_Consulta = p_nomeConsulta;
            IF NOT FOUND THEN
                IF p_valorConsulta = 0 THEN
                    RAISE EXCEPTION 'Uma consulta nova requer um valor associado.';
                END IF;
                INSERT INTO Consultas (Nome_Consulta, Valor_Consulta)
                VALUES (p_nomeConsulta, p_valorConsulta);
            END IF;
            INSERT INTO Servico_Consulta (ID_Servico, Nome_Consulta)
            VALUES (v_idServico, p_nomeConsulta);
            v_valorServico := v_valorServico + (SELECT Valor_Consulta FROM Consultas WHERE Nome_Consulta = p_nomeConsulta);
        END IF;

        IF p_nomeVacina IS NOT NULL THEN
            PERFORM 1 FROM Vacinas WHERE Nome_Vacina = p_nomeVacina;
            IF NOT FOUND THEN
                IF p_valorVacina = 0 THEN
                    RAISE EXCEPTION 'Uma vacina nova requer um valor associado.';
                END IF;
                INSERT INTO Vacinas (Nome_Vacina, Valor_Vacina)
                VALUES (p_nomeVacina, p_valorVacina);
            END IF;
            INSERT INTO Servico_Vacina (ID_Servico, Nome_Vacina)
            VALUES (v_idServico, p_nomeVacina);
            v_valorServico := v_valorServico + (SELECT Valor_Vacina FROM Vacinas WHERE Nome_Vacina = p_nomeVacina);
        END IF;

        UPDATE Servico
        SET Valor_Total = v_valorServico
        WHERE ID_Servico = v_idServico;

    ELSE
        v_idServico := p_idServico;
        SELECT Valor_Total INTO v_valorServico FROM Servico WHERE ID_Servico = v_idServico;
    END IF;

    --Cria o agendamento
    INSERT INTO Agendamento (Data_Agendamento, Hora_Inicio, Hora_Fim, Nr_Animal, Ref_Local, ID_Servico)
    VALUES (p_dataAgendamento, p_horaInicio, p_horaFim, p_nrAnimal, p_refLocal, v_idServico)
    RETURNING Nr_Agendamento INTO v_nrAgendamento;

    --Associa o veterinario ao agendamento
    INSERT INTO Agendamento_Veterinario (Nr_Agendamento, Nr_Veterenario)
    VALUES (v_nrAgendamento, p_nrVeterinario);

    SELECT Taxa_Deslocamento INTO v_taxaDeslocamento FROM Localizacao WHERE Ref_Local = p_refLocal;

    --Cria o pagamento inicial nao pago
    INSERT INTO Pagamento (Nr_Agendamento, Valor)
    VALUES (v_nrAgendamento, v_taxaDeslocamento + v_valorServico);

END;
$$ LANGUAGE plpgsql;

--Serve para quando o agendamento ja existe na base de dados e queremos adicionar mais um veterenario responsavel
--Requires: Algum agendamento
CREATE OR REPLACE FUNCTION associarVeterenarioAoAgendamento(
    p_nrAgendamento INT,
    p_nrVeterinario INT
)
RETURNS VOID AS $$
DECLARE
    v_dataAgendamento DATE;
    v_horaInicio TIME;
    v_horaFim TIME;
BEGIN
    SELECT Data_Agendamento, Hora_Inicio, Hora_Fim
    INTO v_dataAgendamento, v_horaInicio, v_horaFim
    FROM Agendamento
    WHERE Nr_Agendamento = p_nrAgendamento;
    
    IF NOT validarSobreposicao(p_nrVeterinario, v_dataAgendamento, v_horaInicio, v_horaFim) THEN
        RAISE EXCEPTION 'O veterinário tem um agendamento marcado para esse horário.';
    END IF;
    INSERT INTO Agendamento_Veterinario (Nr_Agendamento, Nr_Veterenario)
    VALUES (p_nrAgendamento, p_nrVeterinario);
END;
$$ LANGUAGE plpgsql;

-------------------------------------Garantir a consistencia dos valores apos alteracoes-------------------------------------
--Atualiza a taxa de deslocamento de acordo com a distancia
CREATE OR REPLACE FUNCTION atualizarTaxaDeslocamento()
RETURNS TRIGGER AS $$
BEGIN
    NEW.Taxa_Deslocamento :=
    CASE
        WHEN NEW.Distancia <= 1 THEN NEW.Distancia * 2
        WHEN NEW.Distancia <= 5 AND NEW.Distancia > 1 THEN NEW.Distancia * 3
        ELSE NEW.Distancia * 4
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER taxaDeslocamentoTrigger
BEFORE INSERT OR UPDATE ON Localizacao
FOR EACH ROW
EXECUTE FUNCTION atualizarTaxaDeslocamento();

--Atualiza o valor total do servico apos alteracoes nas consultas ou vacinas associadas
CREATE OR REPLACE FUNCTION atualizarValorTotalServico()
RETURNS TRIGGER AS $$
DECLARE
    v_valorConsultas DECIMAL(10, 2) DEFAULT 0;
    v_valorVacinas DECIMAL(10, 2) DEFAULT 0;
BEGIN
    -- Soma os valores das consultas associadas ao serviço
    SELECT COALESCE(SUM(c.Valor_Consulta), 0)
    INTO v_valorConsultas
    FROM Servico_Consulta AS sc
    JOIN Consultas AS c ON sc.Nome_Consulta = c.Nome_Consulta
    WHERE sc.ID_Servico = CASE
                          WHEN TG_OP = 'DELETE' THEN OLD.ID_Servico
                          ELSE NEW.ID_Servico
                          END;

    -- Soma os valores das vacinas associadas ao serviço
    SELECT COALESCE(SUM(v.Valor_Vacina), 0)
    INTO v_valorVacinas
    FROM Servico_Vacina AS sv
    JOIN Vacinas AS v ON sv.Nome_Vacina = v.Nome_Vacina
    WHERE sv.ID_Servico = CASE
                          WHEN TG_OP = 'DELETE' THEN OLD.ID_Servico
                          ELSE NEW.ID_Servico
                          END;

    -- Atualiza o valor total do serviço
    UPDATE Servico
    SET Valor_Total = v_valorConsultas + v_valorVacinas
    WHERE ID_Servico = CASE
                        WHEN TG_OP = 'DELETE' THEN OLD.ID_Servico
                        ELSE NEW.ID_Servico
                        END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER atualizarValorTotalServicoConsulta
AFTER INSERT OR UPDATE OR DELETE ON Servico_Consulta
FOR EACH ROW
EXECUTE FUNCTION atualizarValorTotalServico();

CREATE TRIGGER atualizarValorTotalServicoVacina
AFTER INSERT OR UPDATE OR DELETE ON Servico_Vacina
FOR EACH ROW
EXECUTE FUNCTION atualizarValorTotalServico();


CREATE OR REPLACE FUNCTION atualizarPagamentoTotalPeloServico()
RETURNS TRIGGER AS $$
DECLARE
    v_valorTotal DECIMAL(10, 2) DEFAULT 0;
BEGIN

    UPDATE Pagamento
    SET Valor = (
        SELECT l.Taxa_Deslocamento + NEW.Valor_Total
        FROM Agendamento AS a
        INNER JOIN Localizacao AS l ON a.Ref_Local = l.Ref_Local
        WHERE a.Nr_Agendamento = Pagamento.Nr_Agendamento
          AND a.ID_Servico = NEW.ID_Servico
    )
    WHERE Nr_Agendamento IN (
        SELECT a.Nr_Agendamento
        FROM Agendamento AS a
        WHERE a.ID_Servico = NEW.ID_Servico
    )
    AND pagamento.metodo IS NULL;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION atualizarPagamentoTotalPelaLocalizacao()
RETURNS TRIGGER AS $$
DECLARE
    v_valorTotal DECIMAL(10, 2) DEFAULT 0;
BEGIN

    UPDATE Pagamento
    SET Valor = (
        SELECT NEW.Taxa_Deslocamento + s.Valor_Total
        FROM Agendamento AS a
        INNER JOIN Servico AS s ON a.ID_Servico = s.ID_Servico
        WHERE a.Nr_Agendamento = Pagamento.Nr_Agendamento
          AND a.Ref_Local = NEW.Ref_Local
    )
    WHERE Nr_Agendamento IN (
        SELECT a.Nr_Agendamento
        FROM Agendamento AS a
        WHERE a.Ref_Local = NEW.Ref_Local
    )
    AND pagamento.metodo IS NULL;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION atualizarPagamentoPorRefLocal()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Pagamento
    SET Valor = (
        SELECT l.Taxa_Deslocamento + s.Valor_Total
        FROM Agendamento AS a
        INNER JOIN Localizacao AS l ON l.Ref_Local = NEW.Ref_Local
        INNER JOIN Servico AS s ON s.ID_Servico = a.ID_Servico
        WHERE a.Nr_Agendamento = Pagamento.Nr_Agendamento
    )
    WHERE Nr_Agendamento = NEW.Nr_Agendamento
    AND pagamento.metodo IS NULL;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER pagamentoTotalTriggerServico
AFTER UPDATE OF Valor_Total ON Servico
FOR EACH ROW
EXECUTE FUNCTION atualizarPagamentoTotalPeloServico();

CREATE TRIGGER pagamentoTotalTriggerLocalizacao
AFTER UPDATE OF distancia ON Localizacao
FOR EACH ROW
EXECUTE FUNCTION atualizarPagamentoTotalPelaLocalizacao();

CREATE TRIGGER pagamentoTotalTriggerAgendamento
AFTER UPDATE OF Ref_Local ON Agendamento
FOR EACH ROW
EXECUTE FUNCTION atualizarPagamentoPorRefLocal();

-----------------------------------Validar Remoção dos meios de Contacto
CREATE OR REPLACE FUNCTION validarRemocaoContactos()
RETURNS TRIGGER AS $$
DECLARE
    v_total_contatos INT;
BEGIN
    -- Conta os meios de contato restantes para o cliente
    SELECT COUNT(*) INTO v_total_contatos
    FROM (
        SELECT Nr_Telemovel AS Contato FROM Telemovel WHERE CC = OLD.CC
        UNION ALL
        SELECT Email AS Contato FROM Email WHERE CC = OLD.CC
    ) AS Contatos;

    -- Se for o último contato, impede a exclusão
    IF v_total_contatos <= 1 THEN
        RAISE EXCEPTION 'Não é possível remover o número de telemóvel. O cliente ficaria sem meios de contato.';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verificarRemocaoTelemovel
BEFORE DELETE ON Telemovel
FOR EACH ROW
EXECUTE FUNCTION validarRemocaoContactos();

CREATE TRIGGER verificarRemocaoEmail
BEFORE DELETE ON Email
FOR EACH ROW
EXECUTE FUNCTION validarRemocaoContactos();

-------------------------------------Estritamente estetico e simplicidade de escrita e leitura-------------------------------------\

CREATE FUNCTION criarVetereinario(
    p_cc CHAR(12),
    p_nome VARCHAR(100),
    p_salario DECIMAL(10, 2)
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Pessoa (CC, Nome)
    VALUES (p_cc, p_nome);

    INSERT INTO Veterinario (CC, Salario)
    VALUES (p_cc, p_salario);
END;
$$ LANGUAGE plpgsql;

--Serve para quando o cliente ja existe na base de dados e queremos adicionar um novo animal
--Requires: Cliente associado

CREATE OR REPLACE FUNCTION adicionarAnimal(
    p_nrCliente INT,
    p_nomeAnimal VARCHAR(50),
    p_especie VARCHAR(50)
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Animal (Nr_Cliente, Nome, Especie)
    VALUES (p_nrCliente, p_nomeAnimal, p_especie);
END;
$$ LANGUAGE plpgsql;

--Serve para quando o cliente realiza o pagamento do servico
--Requires: Algum agendamento
CREATE OR REPLACE FUNCTION atualizarPagamento(
    p_nrAgendamento INT,
    p_metodo VARCHAR(50),
    p_dataPagamento DATE,
    p_hora TIME
)
RETURNS VOID AS $$
BEGIN
    UPDATE Pagamento
    SET Metodo = p_metodo, Data_Pagamento = p_dataPagamento, Hora_Pagamento = p_hora
    WHERE Nr_Agendamento = p_nrAgendamento;
END;
$$ LANGUAGE plpgsql;

--Serve para quando queremos adicionar uma consulta ou vacina a um servico
--Requires: Servico existente
CREATE OR REPLACE FUNCTION adicionarConsultaAoServico(
    p_idServico INT,
    p_nomeConsulta VARCHAR(100)
)
RETURNS VOID AS $$
    BEGIN
        INSERT INTO Servico_Consulta (ID_Servico, Nome_Consulta)
        VALUES (p_idServico, p_nomeConsulta);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION adicionarVacinaAoServico(
    p_idServico INT,
    p_nomeVacina VARCHAR(100)
)
RETURNS VOID AS $$
    BEGIN
        INSERT INTO Servico_Vacina (ID_Servico, Nome_Vacina)
        VALUES (p_idServico, p_nomeVacina);
    END;
$$ LANGUAGE plpgsql;
