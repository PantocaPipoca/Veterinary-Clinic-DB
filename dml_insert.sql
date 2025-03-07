-- Definir os clientes
SELECT definirNovoCliente(
    '123456789012', 
    'João Silva', 
    'Rex', 
    'Cão', 
    '912345678',
    'joao.silva@gmail.com'
);
SELECT definirNovoCliente(
    '123456789013', 
    'Maria Oliveira', 
    'Miau', 
    'Gato', 
    '915678234'
);
SELECT definirNovoCliente(
    '123456789014', 
    'Carlos Santos', 
    'Bobby', 
    'Cão', 
    NULL, 
    'carlos.santos@email.com'
);
SELECT definirNovoCliente(
    '123456789015', 
    'Ana Pereira', 
    'Luna', 
    'Gato', 
    '917654321',
    'ana.pereira@gmail.com'
);
SELECT definirNovoCliente(
    '123456789016', 
    'Pedro Costa', 
    'Max', 
    'Cão', 
    '918273645',
    'pedro.costa@hotmail.com'
);
SELECT definirNovoCliente(
    '123456789017', 
    'Rita Fernandes', 
    'Bella', 
    'Cão', 
    '919876543',
    'rita.fernandes@yahoo.com'
);
SELECT definirNovoCliente(
    '123456789018', 
    'Luis Almeida', 
    'Simba', 
    'Gato', 
    '911234567',
    'luis.almeida@outlook.com'
);
SELECT definirNovoCliente(
    '123456789019', 
    'Sofia Ribeiro', 
    'Nina', 
    'Cão', 
    '913579246',
    'sofia.ribeiro@gmail.com'
);
SELECT definirNovoCliente(
    '123456789020', 
    'Miguel Martins', 
    'Rocky', 
    'Cão', 
    '914682357',
    'miguel.martins@live.com'
);
SELECT definirNovoCliente(
    '123456789021', 
    'Patricia Lopes', 
    'Mimi', 
    'Gato', 
    '916345789',
    'patricia.lopes@gmail.com'
);

-- Inserir os animais extra para os clientes
SELECT adicionarAnimal(1, 'Whiskers', 'Cat');
SELECT adicionarAnimal(2, 'Buddy', 'Dog');
SELECT adicionarAnimal(3, 'Max', 'Dog');
SELECT adicionarAnimal(4, 'Max', 'Cat');
SELECT adicionarAnimal(5, 'Bella', 'Dog');
SELECT adicionarAnimal(6, 'Bella', 'Cat');
SELECT adicionarAnimal(7, 'Charlie', 'Dog');
SELECT adicionarAnimal(8, 'Charlie', 'Cat');
SELECT adicionarAnimal(9, 'Lucy', 'Dog');
SELECT adicionarAnimal(10, 'Lucy', 'Cat');

-- Sem esquecer os funcionarios
SELECT criarVetereinario('123456789', 'Dr. John Doe', 1500.0);
SELECT criarVetereinario('123456788', 'Dr. Jane Doe', 2000.0);
SELECT criarVetereinario('123456787', 'Dr. James Doe', 2500.0);
SELECT criarVetereinario('123456786', 'Dr. Emily Smith', 1800.0);
SELECT criarVetereinario('123456785', 'Dr. Michael Brown', 2200.0);
SELECT criarVetereinario('123456784', 'Dr. Sarah Johnson', 2400.0);
SELECT criarVetereinario('123456783', 'Dr. David Wilson', 2100.0);
SELECT criarVetereinario('123456782', 'Dr. Laura Martinez', 2300.0);
SELECT criarVetereinario('123456781', 'Dr. Robert Garcia', 1900.0);
SELECT criarVetereinario('123456780', 'Dr. Linda Rodriguez', 2600.0);

-- Localizacao (cometario util)
INSERT INTO Localizacao (Localizacao, Distancia)
VALUES (ROW('Main St', '12', 3, 'A', '1000-200'), 15.5),
       (ROW('Oak St', '8', 2, 'B', '2000-300'), 19.0),
       (ROW('Pine St', '5', 1, 'C', '3000-400'), 10.0),
       (ROW('Maple St', '20', 4, 'D', '4000-500'), 12.5),
       (ROW('Elm St', '15', 2, 'E', '5000-600'), 8.0),
       (ROW('Cedar St', '10', 3, 'F', '6000-700'), 14.0),
       (ROW('Birch St', '7', 1, 'G', '7000-800'), 9.5),
       (ROW('Spruce St', '3', 2, 'H', '8000-900'), 11.0),
       (ROW('Willow St', '18', 4, 'I', '9000-1000'), 13.5),
       (ROW('Ash St', '22', 5, 'J', '10000-1100'), 16.0);

-- Consultas e Vacinas sem servico ainda
INSERT INTO Consultas (Nome_Consulta, Valor_Consulta)
VALUES  ('General Checkup', 50.0),
        ('Dental Cleaning', 70.0),
        ('Vaccination', 30.0),
        ('Spay/Neuter Surgery', 150.0),
        ('Emergency Visit', 100.0),
        ('Follow-up Visit', 40.0),
        ('Blood Test', 60.0),
        ('X-Ray', 120.0),
        ('Ultrasound', 200.0),
        ('Heartworm Test', 45.0),
        ('Flea and Tick Treatment', 35.0),
        ('Microchipping', 25.0),
        ('Nail Trimming', 20.0),
        ('Ear Cleaning', 25.0),
        ('Deworming', 30.0);

INSERT INTO Vacinas (Nome_Vacina, Valor_Vacina)
VALUES  ('Rabies', 30.0),
        ('Distemper', 40.0),
        ('Parvovirus', 35.0),
        ('Adenovirus', 35.0),
        ('Parainfluenza', 25.0),
        ('Leptospirosis', 45.0),
        ('Bordetella', 30.0),
        ('Lyme Disease', 50.0),
        ('Canine Influenza', 55.0),
        ('Feline Leukemia', 40.0),continuo sem quarto
    p_nrAnimal := 2,
    p_refLocal := 2,
    p_nrVeterinario := 2,
    p_nomeServico := 'Vaccine Appointment',
    p_nomeVacina := 'Rabies'
);

-- Criar agenda com servico predefinido e partilhado com outro agendamento
CALL definirAgendamento(
    p_dataAgendamento := '2030-12-12',
    p_horaInicio := '14:00:00',
    p_horaFim := '15:00:00',
    p_nrAnimal := 1,
    p_refLocal := 1,
    p_nrVeterinario := 3,
    p_idServico := 2
);

--Criar agendamento sem servico com consulta e vacina
CALL definirAgendamento(
    p_dataAgendamento := '2030-12-13',
    p_horaInicio := '16:00:00',
    p_horaFim := '17:00:00',
    p_nrAnimal := 2,
    p_refLocal := 2,
    p_nrVeterinario := 1,
    p_nomeServico := 'Cleaning and Vaccination',
    p_nomeConsulta := 'Dental Cleaning',
    p_nomeVacina := 'Distemper'
);

--Criar mais agendamentos apenas para encher a base de dados para as queries
CALL definirAgendamento(
    p_dataAgendamento := '2024-12-10',
    p_horaInicio := '09:00:00',
    p_horaFim := '10:00:00',
    p_nrAnimal := 3,
    p_refLocal := 3,
    p_nrVeterinario := 2,
    p_nomeServico := 'Morning Checkup',
    p_nomeConsulta := 'General Checkup'
);

CALL definirAgendamento(
    p_dataAgendamento := '2024-12-10',
    p_horaInicio := '10:00:00',
    p_horaFim := '11:00:00',
    p_nrAnimal := 4,
    p_refLocal := 4,
    p_nrVeterinario := 3,
    p_nomeServico := 'Routine Checkup',
    p_nomeConsulta := 'General Checkup'
);

CALL definirAgendamento(
    p_dataAgendamento := '2024-12-10',
    p_horaInicio := '10:00:00',
    p_horaFim := '11:00:00',
    p_nrAnimal := 5,
    p_refLocal := 5,
    p_nrVeterinario := 4,
    p_nomeServico := 'Vaccination',
    p_nomeVacina := 'Distemper'
);

CALL definirAgendamento(
    p_dataAgendamento := '2024-12-10',
    p_horaInicio := '11:00:00',
    p_horaFim := '12:00:00',
    p_nrAnimal := 6,
    p_refLocal := 6,
    p_nrVeterinario := 5,
    p_nomeServico := 'Health Check',
    p_nomeConsulta := 'Dental Cleaning'
);

CALL definirAgendamento(
    p_dataAgendamento := '2024-12-10',
    p_horaInicio := '12:00:00',
    p_horaFim := '13:00:00',
    p_nrAnimal := 7,
    p_refLocal := 7,
    p_nrVeterinario := 6,
    p_nomeServico := 'Afternoon Checkup',
    p_nomeConsulta := 'General Checkup'
);

CALL definirAgendamento(
    p_dataAgendamento := '2024-12-10',
    p_horaInicio := '13:00:00',
    p_horaFim := '14:00:00',
    p_nrAnimal := 9,
    p_refLocal := 9,
    p_nrVeterinario := 8,
    p_nomeServico := 'Evening Checkup',
    p_nomeConsulta := 'General Checkup'
);

-- Associar mais veterinarios aos agendamentos
SELECT associarVeterenarioAoAgendamento(1, 2);

SELECT associarVeterenarioAoAgendamento(2, 4);

SELECT associarVeterenarioAoAgendamento(3, 5);
SELECT associarVeterenarioAoAgendamento(3, 6);
SELECT associarVeterenarioAoAgendamento(3, 7);

SELECT associarVeterenarioAoAgendamento(5, 8);

SELECT associarVeterenarioAoAgendamento(6, 9);
SELECT associarVeterenarioAoAgendamento(6, 10);

SELECT associarVeterenarioAoAgendamento(9, 2);
SELECT associarVeterenarioAoAgendamento(9, 3);
SELECT associarVeterenarioAoAgendamento(9, 4);

SELECT associarVeterenarioAoAgendamento(10, 5);
SELECT associarVeterenarioAoAgendamento(10, 6);

-- Finalizar o pagamento
SELECT atualizarPagamento(1, 'Credit Card', '2024-12-10', '11:15:00');
SELECT atualizarPagamento(2, 'Cash', '2024-12-11', '13:20:00');

-- Adicionar consultas aos serviços
SELECT adicionarConsultaAoServico(1, 'Follow-up Visit');
SELECT adicionarConsultaAoServico(2, 'Blood Test');
SELECT adicionarConsultaAoServico(2, 'X-Ray');
SELECT adicionarConsultaAoServico(3, 'Ultrasound');
SELECT adicionarConsultaAoServico(3, 'Heartworm Test');
SELECT adicionarConsultaAoServico(4, 'Flea and Tick Treatment');
SELECT adicionarConsultaAoServico(4, 'Microchipping');
SELECT adicionarConsultaAoServico(5, 'Nail Trimming');
SELECT adicionarConsultaAoServico(5, 'Ear Cleaning');
SELECT adicionarConsultaAoServico(6, 'Deworming');
SELECT adicionarConsultaAoServico(6, 'Spay/Neuter Surgery');

-- Adicionar vacinas aos serviços
SELECT adicionarVacinaAoServico(1, 'Rabies');
SELECT adicionarVacinaAoServico(1, 'Distemper');
SELECT adicionarVacinaAoServico(2, 'Parvovirus');
SELECT adicionarVacinaAoServico(2, 'Adenovirus');
SELECT adicionarVacinaAoServico(3, 'Parainfluenza');
SELECT adicionarVacinaAoServico(3, 'Leptospirosis');
SELECT adicionarVacinaAoServico(4, 'Bordetella');
SELECT adicionarVacinaAoServico(4, 'Lyme Disease');
SELECT adicionarVacinaAoServico(5, 'Canine Influenza');
SELECT adicionarVacinaAoServico(5, 'Feline Leukemia');
SELECT adicionarVacinaAoServico(6, 'Feline Immunodeficiency Virus');
SELECT adicionarVacinaAoServico(6, 'Feline Calicivirus');

--Adicionar todas as vacinas que temos no servico 1 para a query 9
SELECT adicionarVacinaAoServico(1, 'Parvovirus');
SELECT adicionarVacinaAoServico(1, 'Adenovirus');
SELECT adicionarVacinaAoServico(1, 'Parainfluenza');
SELECT adicionarVacinaAoServico(1, 'Leptospirosis');
SELECT adicionarVacinaAoServico(1, 'Bordetella');
SELECT adicionarVacinaAoServico(1, 'Lyme Disease');
SELECT adicionarVacinaAoServico(1, 'Canine Influenza');
SELECT adicionarVacinaAoServico(1, 'Feline Leukemia');
SELECT adicionarVacinaAoServico(1, 'Feline Immunodeficiency Virus');
SELECT adicionarVacinaAoServico(1, 'Feline Calicivirus');
SELECT adicionarVacinaAoServico(1, 'Feline Panleukopenia');
SELECT adicionarVacinaAoServico(1, 'Feline Herpesvirus');
SELECT adicionarVacinaAoServico(1, 'Feline Chlamydia');