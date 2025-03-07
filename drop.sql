-- 1. Remoção de Triggers e suas funções associadas
DROP TRIGGER IF EXISTS pagamentoTotalTriggerServico ON Servico;
DROP TRIGGER IF EXISTS pagamentoTotalTriggerLocalizacao ON Localizacao;
DROP TRIGGER IF EXISTS pagamentoTotalTriggerAgendamento ON Agendamento;
DROP TRIGGER IF EXISTS taxaDeslocamentoTrigger ON Localizacao;
DROP TRIGGER IF EXISTS atualizarValorTotalServicoConsulta ON Servico_Consulta;
DROP TRIGGER IF EXISTS atualizarValorTotalServicoVacina ON Servico_Vacina;

DROP FUNCTION IF EXISTS atualizarTaxaDeslocamento;
DROP FUNCTION IF EXISTS atualizarValorTotalServico;
DROP FUNCTION IF EXISTS atualizarPagamentoTotalPeloServico;
DROP FUNCTION IF EXISTS atualizarPagamentoTotalPelaLocalizacao;
DROP FUNCTION IF EXISTS atualizarPagamentoPorRefLocal;
DROP FUNCTION IF EXISTS criarvetereinario;

-- 2. Funções e procedimentos personalizados
DROP FUNCTION IF EXISTS definirNovoCliente;
DROP FUNCTION IF EXISTS validarSobreposicao;
DROP FUNCTION IF EXISTS validarSobreposicaoAnimal;
DROP PROCEDURE IF EXISTS definirAgendamento;
DROP FUNCTION IF EXISTS associarVeterenarioAoAgendamento;

-- 3. Remover tabelas associadas aos objetos
DROP TABLE IF EXISTS Servico_Consulta CASCADE;
DROP TABLE IF EXISTS Servico_Vacina CASCADE;
DROP TABLE IF EXISTS Agendamento_Veterinario CASCADE;
DROP TABLE IF EXISTS Pagamento CASCADE;
DROP TABLE IF EXISTS Agendamento CASCADE;
DROP TABLE IF EXISTS Servico CASCADE;
DROP TABLE IF EXISTS Consultas CASCADE;
DROP TABLE IF EXISTS Vacinas CASCADE;
DROP TABLE IF EXISTS Localizacao CASCADE;
DROP TABLE IF EXISTS Animal CASCADE;
DROP TABLE IF EXISTS Cliente CASCADE;
DROP TABLE IF EXISTS Pessoa CASCADE;
DROP TABLE IF EXISTS Telemovel CASCADE;
DROP TABLE IF EXISTS Email CASCADE;
DROP TABLE IF EXISTS Veterinario CASCADE;

-- 4. Garantir remoção de funções não referenciadas
DROP FUNCTION IF EXISTS validarRemocaoContactos;

DROP TYPE IF EXISTS Localizacao_Type CASCADE;

-- 5. Mensagem de finalização
DO $$ BEGIN
    RAISE NOTICE 'Todos os objetos foram removidos com sucesso.';
END $$;