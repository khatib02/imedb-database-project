--1 Atualizar a nota_geral para todos os filmes na tabela Titulo
UPDATE titulo
SET nota_geral = (
    SELECT ROUND(AVG(nota), 1)
    FROM usuario_avalia_titulo
    WHERE usuario_avalia_titulo.id_titulo = titulo.id_titulo
)
WHERE id_titulo IN (
    SELECT DISTINCT id_titulo
    FROM usuario_avalia_titulo
);

--2 Filmes e séries mais populares
SELECT nome_titulo, nota_geral
FROM titulo
WHERE nota_geral IS NOT NULL
ORDER BY nota_geral DESC;

--3 Usuários e seus gêneros favoritos
SELECT U.nome_completo, g.nome_genero AS genero_favorito
FROM Usuario as U, Usuario_favorita_genero AS UF, Genero as g
WHERE U.email = UF.email_usuario AND UF.nome_genero = G.nome_genero;

--4 Filmes dirigidos por Christopher Nolan
SELECT t.nome_titulo, t.nota_geral
FROM titulo as t, titulo_inclui_diretor as td, diretor as d, funcionario as f
WHERE t.id_titulo = td.id_titulo and td.id_diretor = d.id_diretor and d.id_diretor = f.id_funcionario and f.nome_funcionario = 'Christopher Nolan'
ORDER BY t.nota_geral DESC;

--5 Atores mais avaliados
SELECT f.nome_funcionario, ROUND(AVG(ua.nota), 1) AS media_nota
FROM ator as a, usuario_avalia_ator as ua, funcionario as f
WHERE a.id_ator = f.id_funcionario and a.id_ator = ua.id_ator
GROUP BY f.nome_funcionario
ORDER BY media_nota DESC;

--6 Filmes com tags "Indicado ao Oscar"
SELECT t.nome_titulo
FROM titulo as t, tag_apresenta_titulo as tt
WHERE t.id_titulo = tt.id_titulo and  tt.nome_tag = 'indicado ao Oscar';

--7 Filmes disponíveis na platafomra Infinity Stream
SELECT t.nome_titulo
FROM titulo as t, streaming_transmite_titulo as st, servico_streaming as ss
WHERE t.id_titulo = st.id_titulo and st.id_servico_streaming = ss.id_servico_streaming and ss.nome = 'Infinity Stream';

--8 Séries ainda em gravação
SELECT t.nome_titulo, s.numero_temporadas
FROM serie as s, titulo as t
WHERE s.id_serie = t.id_titulo and s.esta_encerrada = FALSE;

--9 Remover usuários inativos
DELETE FROM usuario
WHERE email NOT IN (SELECT DISTINCT email_usuario FROM busca);

--10 Alterar informações de contato de um usuário
UPDATE usuario
SET numero_telefone = '+5511987654321'
WHERE email = 'mariajuliadacruz@example.com';

--11 Listar estúdios e seus filmes
SELECT e.nome_estudio, t.nome_titulo
FROM estudio as e, titulo as t
WHERE e.id_estudio = t.id_estudio
ORDER BY e.nome_estudio;

--12 Histórico de avaliações de um usuário
SELECT t.nome_titulo, uat.nota
FROM usuario_avalia_titulo as uat, titulo as t
WHERE uat.id_titulo = t.id_titulo and uat.email_usuario = 'mariajuliadacruz@example.com';

--13 Usuários que mais avaliam títulos
SELECT u.nome_completo, COUNT(uat.id_titulo) AS quantidade_avaliacoes
FROM usuario as u, usuario_avalia_titulo as uat
WHERE u.email = uat.email_usuario
GROUP BY u.nome_completo
ORDER BY quantidade_avaliacoes DESC;

--14 Estatísticas de avaliação por país dos usuários
SELECT u.pais, COUNT(uat.nota) AS total_avaliacoes, AVG(uat.nota) AS media_nota
FROM usuario as u, usuario_avalia_titulo as uat
where u.email = uat.email_usuario
GROUP BY u.pais
ORDER BY total_avaliacoes DESC;

--15 Estatísticas de avaliação por gênero
SELECT g.nome_genero, 
       COUNT(uat.nota) AS total_avaliacoes, 
       AVG(uat.nota) AS media_nota, 
       MIN(uat.nota) AS menor_nota, 
       MAX(uat.nota) AS maior_nota
FROM genero as g, genero_contido_em_titulo as gt, usuario_avalia_titulo as uat
WHERE g.nome_genero = gt.nome_genero and gt.id_titulo = uat.id_titulo
GROUP BY g.nome_genero
ORDER BY media_nota DESC;


--View1: Estúdios com maior quantidade de títulos
CREATE OR REPLACE VIEW estudios_mais_produtivos AS
SELECT e.nome_estudio, COUNT(t.id_titulo) AS total_titulos
FROM estudio as e, titulo as t
WHERE e.id_estudio = t.id_estudio
GROUP BY e.nome_estudio
ORDER BY total_titulos DESC;

--View2: Reações mais comuns dos usuários aos títulos
CREATE OR REPLACE VIEW reacoes_mais_comuns AS
SELECT reacao, COUNT(reacao) AS total_reacoes
FROM reacao_usuario_titulo
GROUP BY reacao
ORDER BY total_reacoes DESC;

--View3: Títulos por classificação etária
CREATE OR REPLACE VIEW titulos_por_classificacao AS
SELECT t.classificacao_etaria, 
       COUNT(t.id_titulo) AS total_titulos, 
       AVG(t.nota_geral) AS media_notas
FROM titulo t
GROUP BY t.classificacao_etaria
ORDER BY t.classificacao_etaria;

--Trigger1: Atualizar a nota geral de um título após uma nova avaliação
--Quando um usuário avalia um título, a nota geral do título é automaticamente recalculada.
CREATE OR REPLACE FUNCTION atualizar_nota_geral()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE titulo
  SET nota_geral = (
    SELECT ROUND(AVG(nota), 1)
    FROM usuario_avalia_titulo
    WHERE usuario_avalia_titulo.id_titulo = NEW.id_titulo
  )
  WHERE id_titulo = NEW.id_titulo;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_nota_geral
AFTER INSERT OR UPDATE ON usuario_avalia_titulo
FOR EACH ROW
EXECUTE FUNCTION atualizar_nota_geral();

--Triger2: Notificar usuários quando um novo título do gênero favorito é lançado
--Ao inserir um novo título, verifica se ele pertence a algum gênero favorito de usuários e registra uma recomendação para esses usuários.
CREATE OR REPLACE FUNCTION notificar_usuario_titulo_novo()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO recomendacao (data_horario, email_usuario, filme)
  SELECT CURRENT_TIMESTAMP, uf.email_usuario, NEW.nome_titulo
  FROM usuario_favorita_genero as uf, genero_contido_em_titulo as gt
  WHERE uf.nome_genero = gt.nome_genero and gt.id_titulo = NEW.id_titulo;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notificar_usuario_titulo_novo
AFTER INSERT ON titulo
FOR EACH ROW
EXECUTE FUNCTION notificar_usuario_titulo_novo();

--Triger3: Remover avaliações ao excluir um título
--Se um título for removido, todas as avaliações associadas a ele são excluídas automaticamente.
CREATE OR REPLACE FUNCTION remover_avaliacoes_titulo()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM usuario_avalia_titulo
  WHERE id_titulo = OLD.id_titulo;
  return old;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_remover_avaliacoes_titulo
AFTER DELETE ON titulo
FOR EACH ROW
EXECUTE FUNCTION remover_avaliacoes_titulo();

--Procedure: Recomendar filmes com base no gênero favorito
CREATE PROCEDURE recomendar_filmes(IN email_usuario_param VARCHAR(100))
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO recomendacao (data_horario, email_usuario, filme)
  SELECT CURRENT_TIMESTAMP, uf.email_usuario, t.nome_titulo
  FROM usuario_favorita_genero as uf, genero_contido_em_titulo as gt, titulo as t
  WHERE uf.nome_genero = gt.nome_genero and gt.id_titulo = t.id_titulo and uf.email_usuario = email_usuario_param
  ORDER BY t.nota_geral DESC
  LIMIT 5;
END;
$$;
