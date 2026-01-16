Create table Titulo (
  id_titulo INTEGER PRIMARY KEY, 
  bilheteria DECIMAL(14,2),
  nota_geral DECIMAL(3,1)
             CHECK(nota_geral >= 0 and nota_geral <= 10), 
  classificacao_etaria INT
                       CHECK(classificacao_etaria >=0 and classificacao_etaria <=18),
  nome_titulo VARCHAR(150) NOT NULL,
  sinopse VARCHAR(250),
  duracao INT,
  orcamento DECIMAL(15,2),
  data_lancamento_pais_origem DATE,
  id_estudio INT NOT NULL,
  avaliacao_critica DECIMAL(3,1)
  					CHECK(avaliacao_critica >=0 and avaliacao_critica <=10)
);

CREATE TABLE Premiacao_titulo (
  premiacao VARCHAR(100),
  id_titulo INT NOT NULL REFERENCES Titulo(id_titulo)
                         ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(premiacao, id_titulo)
);

CREATE TABLE Pais_gravacao_titulo (
  pais VARCHAR(100),
  id_titulo INT REFERENCES Titulo(id_titulo) 
                ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(pais, id_titulo)
);

CREATE TABLE Serie (
  id_serie INT PRIMARY KEY REFERENCES Titulo(id_titulo)
                           ON DELETE CASCADE ON UPDATE CASCADE,
  esta_encerrada BOOLEAN,
  numero_temporadas INT
                    CHECK(numero_temporadas > 0)
);
  
CREATE TAble Filme (
  id_filme INT PRIMARY KEY REFERENCES Titulo(id_titulo)
);
  
CREATE TABLE Funcionario (
  id_funcionario INT PRIMARY KEY,
  data_nascimento DATE,
  nota_geral DECIMAL(3,1)
             CHECK(nota_geral>=0 and nota_geral<=10),
  nome_funcionario VARCHAR(100) NOT NULL
);
  
CREATE TABLE Premiacao_funcionario (
  premiacao VARCHAR(100),
  id_funcionario INT REFERENCES Funcionario(id_funcionario)
                                 ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(premiacao, id_funcionario)
);

CREATE TABLE Diretor (
  id_diretor INT PRIMARY KEY REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Ator (
  id_ator INT PRIMARY KEY REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Unidade_cinema (
  id_cinema INT PRIMARY KEY,
  localizacao VARCHAR(300),
  nome_empresa VARCHAR(200) NOT NULL,
  dominio VARCHAR(150)
);
  
CREATE TABLE Estudio (
  id_estudio INT PRIMARY KEY,
  dominio VARCHAR(200),
  nome_estudio VARCHAR(150) NOT NULL,
  data_fundacao DATE
);

ALTER TABLE Titulo
    ADD CONSTRAINT id_estudio FOREIGN KEY (id_estudio) REFERENCES Estudio(id_estudio);
    
CREATE TABLE Fundador_estudio (
  fundador VARCHAR(100),
  id_estudio INT REFERENCES Estudio(id_estudio)
                 ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(fundador, id_estudio)
);

CREATE TABLE Localizacao_sede_estudio (
  localizacao VARCHAR(300),
  id_estudio INT REFERENCES Estudio(id_estudio)
                 ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(localizacao, id_estudio)
);

CREATE TABLE Servico_streaming (
  id_servico_streaming INT PRIMARY KEY,
  dominio VARCHAR(200),
  nome VARCHAR(150)
);

CREATE TABLE Tag (
  nome_tag VARCHAR(150) PRIMARY KEY
);

CREATE TABLE Genero (
  nome_genero VARCHAR(100) PRIMARY KEY
);

create table Usuario (
  email VARCHAR(150) PRIMARY KEY,
  nome_completo VARCHAR(150) NOT NULL,
  data_nascimento DATE NOT NULL,
  senha VARCHAR(40) NOT NULL,
  numero_telefone VARCHAR(22) NOT NULL,
  estado VARCHAR(150) NOT NULL,
  cidade VARCHAR(150) NOT NULL,
  pais VARCHAR(150) NOT NULL
);

Create TABLE Reacao_usuario_titulo (
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                             ON DELETE CASCADE ON UPDATE CASCADE,
  id_titulo INT REFERENCES Titulo(id_titulo)
                ON DELETE CASCADE ON UPDATE CASCADE,
  reacao INT 
         CHECK(reacao>=1 and reacao<=12),
  PRIMARY KEY(email_usuario, id_titulo, reacao)
);

CREATE TABLE Recomendacao (
  data_horario TIMESTAMP,
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                             ON DELETE CASCADE ON UPDATE CASCADE,
  id_filme INT REFERENCES Titulo(id_titulo)
  			   ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(data_horario, email_usuario)
);

CREATE TABLE Busca (
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                             ON DELETE CASCADE ON UPDATE CASCADE,
  data_horario TIMESTAMP,
  PRIMARY KEY(email_usuario, data_horario)
);

CREATE TABLE Filtro_busca (
  filtro VARCHAR(150),
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                             ON DELETE CASCADE ON UPDATE CASCADE,
  data_horario TIMESTAMP,
  PRIMARY KEY(filtro, email_usuario, data_horario)
);

CREATE TABLE Personagem (
  nome_personagem VARCHAR(100),
  id_ator INT REFERENCES Ator(id_ator)
              ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(id_ator, nome_personagem)
);

CREATE TABLE Cinema_transmite_titulo (
  id_titulo INT REFERENCES Titulo(id_titulo)
                ON DELETE CASCADE ON UPDATE CASCADE,
  id_cinema INT REFERENCES Unidade_cinema(id_cinema)
                ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(id_titulo, id_cinema)
);

CREATE TABLE Streaming_transmite_titulo (
  id_titulo INT REFERENCES Titulo(id_titulo)
                ON DELETE CASCADE ON UPDATE CASCADE, 
  id_servico_streaming INT REFERENCES Servico_streaming(id_servico_streaming)
                           ON DELETE CASCADE ON UPDATE CASCADE,
  Primary KEY(id_titulo, id_servico_streaming)
);

Create Table Tag_apresenta_titulo (
  id_titulo INT REFERENCES Titulo(id_titulo)
                ON DELETE CASCADE ON UPDATE CASCADE,
  nome_tag VARCHAR(100) REFERENCES Tag(nome_tag)
                       ON DELETE CASCADE ON UPDATE CASCADE,
  Primary KEY(id_titulo, nome_tag)
);

CREATE TABLE Genero_contido_em_titulo (
  nome_genero VARCHAR(100) REFERENCES Genero(nome_genero)
                          ON DELETE CASCADE ON UPDATE CASCADE,
  id_titulo INT REFERENCES Titulo(id_titulo)
                ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(nome_genero, id_titulo)
);

CREATE TABLE Usuario_favorita_genero (
  nome_genero VARCHAR(100) REFERENCES Genero(nome_genero)
                          ON DELETE CASCADE ON UPDATE CASCADE,
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                            ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(nome_genero, email_usuario)
);

CREATE TABLE Usuario_avalia_titulo (
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                             ON DELETE CASCADE ON UPDATE CASCADE,
  id_titulo INT REFERENCES Titulo(id_titulo)
                ON DELETE CASCADE ON UPDATE CASCADE,
  curtida BOOLEAN,
  nota DECIMAL(3,1)
       CHECK(nota>=0 and nota<=10),
  PRIMARY KEY(email_usuario, id_titulo)
);

CREATE TABLE Usuario_favorita_personagem (
  nome_personagem VARCHAR(100),
  id_ator INT,
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                             ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(nome_personagem, id_ator, email_usuario),
  FOREIGN KEY(nome_personagem, id_ator) REFERENCES Personagem(nome_personagem, id_ator)
                                        ON DELETE CASCADE ON UPDATE CASCADE
);

Create TABLE Titulo_inclui_personagem (
  id_titulo INT REFERENCES Titulo(id_titulo)
                ON DELETE CASCADE ON UPDATE CASCADE,
  nome_personagem VARCHAR(100),
  id_ator INT,
  PRIMARY KEY(id_titulo, nome_personagem, id_ator),
  FOREIGN KEY(id_ator, nome_personagem) REFERENCES Personagem(id_ator, nome_personagem)
                                        ON DELETE CASCADE ON UPDATE CASCADE
);
  
CREATE TABLE Usuario_avalia_diretor (
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                             ON DELETE CASCADE ON UPDATE CASCADE,
  id_diretor INT REFERENCES Diretor(id_diretor)                       
                 ON DELETE CASCADE ON UPDATE CASCADE,
  curtida BOOLEAN,
  nota DECIMAL(3,1)
       CHECK(nota>=0 and nota<=10),
  PRIMARY KEY(email_usuario, id_diretor)
);
  
CREATE TABLE Usuario_avalia_ator (
  email_usuario VARCHAR(150) REFERENCES Usuario(email)
                             ON DELETE CASCADE ON UPDATE CASCADE,
  id_ator INT REFERENCES Ator(id_ator)
              ON DELETE CASCADE ON UPDATE CASCADE,
  curtida BOOLEAN,
  nota DECIMAL(3,1)
       CHECK(nota>=0 and nota<=10),
  Primary KEY(email_usuario, id_ator)
);
  
Create table Titulo_inclui_diretor (
  id_titulo INT REferences Titulo(id_titulo)
                ON DELETE CASCADE ON UPDATE CASCADE,
  id_diretor INT REFERENCES Diretor(id_diretor)
                 ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(id_titulo, id_diretor);
);
