CREATE TABLE Pessoa (
    CC CHAR(12) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL
);

CREATE TABLE Cliente (
    CC CHAR(12) PRIMARY KEY,
    Nr_Cliente SERIAL UNIQUE,
    FOREIGN KEY (CC) REFERENCES Pessoa(CC) ON DELETE CASCADE
);

CREATE TABLE Telemovel (
    CC CHAR(12),
    Nr_Telemovel VARCHAR(15) NOT NULL,
    PRIMARY KEY (Nr_Telemovel),
    FOREIGN KEY (CC) REFERENCES Cliente(CC) ON DELETE CASCADE
);

CREATE TABLE Email (
    CC CHAR(12),
    Email VARCHAR(100) NOT NULL,
    PRIMARY KEY (Email),
    FOREIGN KEY (CC) REFERENCES Cliente(CC) ON DELETE CASCADE
);

CREATE TABLE Veterinario (
    CC CHAR(12) PRIMARY KEY,
    Nr_Veterenario SERIAL UNIQUE,
    Salario DECIMAL(10, 2) NOT NULL CHECK(Salario > 0),
    FOREIGN KEY (CC) REFERENCES Pessoa(CC) ON DELETE CASCADE
);

CREATE TABLE Animal (
    Nr_Animal SERIAL PRIMARY KEY,
    Nr_Cliente INT NOT NULL, --Garante que cada animal tem um e so um dono
    Nome VARCHAR(50) NOT NULL,
    Especie VARCHAR(50) NOT NULL,
    FOREIGN KEY (Nr_Cliente) REFERENCES Cliente(Nr_Cliente) ON DELETE CASCADE
);

CREATE TABLE Servico (
    ID_Servico SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL UNIQUE,
    Valor_Total DECIMAL(10, 2) NOT NULL DEFAULT 0
);

CREATE TYPE Localizacao_Type AS (
    Rua VARCHAR(100),
    Lote VARCHAR(10),
    Andar INT,
    Porta VARCHAR(10),
    CP VARCHAR(10)
);

CREATE TABLE Localizacao (
    Ref_Local SERIAL PRIMARY KEY,
    Localizacao Localizacao_Type NOT NULL,
    Distancia DECIMAL(10, 2) NOT NULL CHECK (Distancia > 0 AND Distancia < 20),
    Taxa_Deslocamento DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Agendamento (
    Nr_Agendamento SERIAL PRIMARY KEY,
    Data_Agendamento DATE NOT NULL,
    Hora_Inicio TIME NOT NULL,
    Hora_Fim TIME NOT NULL CHECK (Hora_Fim > Hora_Inicio),
    Nr_Animal INT NOT NULL, --Garante que cada agendamento tem um e so um animal
    Ref_Local INT NOT NULL, --Garante que cada agendamento tem uma e so uma localizacao
    ID_Servico INT NOT NULL, --Garante que cada agendamento tem um e so um servico
    FOREIGN KEY (Nr_Animal) REFERENCES Animal(Nr_Animal) ON DELETE CASCADE,
    FOREIGN KEY (Ref_Local) REFERENCES Localizacao(Ref_Local) ON DELETE CASCADE,
    FOREIGN KEY (ID_Servico) REFERENCES Servico(ID_Servico) ON DELETE CASCADE
);

CREATE TABLE Agendamento_Veterinario (
    Nr_Agendamento INT,
    Nr_Veterenario INT,
    PRIMARY KEY (Nr_Agendamento, Nr_Veterenario),
    FOREIGN KEY (Nr_Agendamento) REFERENCES Agendamento(Nr_Agendamento) ON DELETE CASCADE,
    FOREIGN KEY (Nr_Veterenario) REFERENCES Veterinario(Nr_Veterenario) ON DELETE CASCADE
);

CREATE TABLE Pagamento (
    ID_Pagamento SERIAL PRIMARY KEY,
    Nr_Agendamento INT, --Pode ser null
    Valor DECIMAL(10, 2),
    Metodo VARCHAR(50),
    Data_Pagamento DATE,
    Hora_Pagamento TIME,
    FOREIGN KEY (Nr_Agendamento) REFERENCES Agendamento(Nr_Agendamento) ON DELETE SET NULL
);

CREATE TABLE Consultas (
    Nome_Consulta VARCHAR(100) PRIMARY KEY,
    Valor_Consulta DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Vacinas (
    Nome_Vacina VARCHAR(100) PRIMARY KEY,
    Valor_Vacina DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Servico_Consulta (
    ID_Servico INT,
    Nome_Consulta VARCHAR(100),
    PRIMARY KEY (ID_Servico, Nome_Consulta),
    FOREIGN KEY (ID_Servico) REFERENCES Servico(ID_Servico) ON DELETE CASCADE,
    FOREIGN KEY (Nome_Consulta) REFERENCES Consultas(Nome_Consulta) ON DELETE CASCADE
);

CREATE TABLE Servico_Vacina (
    ID_Servico INT,
    Nome_Vacina VARCHAR(100),
    PRIMARY KEY (ID_Servico, Nome_Vacina),
    FOREIGN KEY (ID_Servico) REFERENCES Servico(ID_Servico) ON DELETE CASCADE,
    FOREIGN KEY (Nome_Vacina) REFERENCES Vacinas(Nome_Vacina) ON DELETE CASCADE
);