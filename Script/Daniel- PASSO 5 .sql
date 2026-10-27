USE omnichannel_db;

-- -----------------------------------------------------
-- 1. Criação da Trigger de Auditoria de Preços
-- -----------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_auditoria_preco
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
    -- Verifica se houve alteração real no preço
    IF OLD.preco <> NEW.preco THEN
        INSERT INTO auditoria_preco (id_produto, preco_antigo, preco_novo, data_alteracao, usuario)
        VALUES (NEW.id_produto, OLD.preco, NEW.preco, NOW(), USER());
    END IF;
END$$

-- -----------------------------------------------------
-- 2. Criação da Stored Procedure de Processamento de Venda
-- -----------------------------------------------------
CREATE PROCEDURE sp_registrar_venda (
    IN p_id_cliente INT,
    IN p_id_loja INT,
    IN p_origem_compra ENUM('LOJA FISICA', 'E COMMERCE'),
    IN p_forma_pagamento ENUM('PIX', 'CARTAO', 'BOLETO'),
    IN p_id_produto INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_estoque_atual INT;
    DECLARE v_preco_unitario DECIMAL(10,2);
    DECLARE v_valor_total DECIMAL(10,2);
    DECLARE v_novo_pedido_id INT;

    -- Obtém o estoque atual e o preço unitário do produto
    SELECT estoque_atual, preco INTO v_estoque_atual, v_preco_unitario
    FROM produtos WHERE id_produto = p_id_produto;

    -- Validações de Estoque
    IF v_estoque_atual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRO: Produto não encontrado.';
    ELSEIF v_estoque_atual < p_quantidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRO: Estoque insuficiente para realizar a venda.';
    ELSE
        -- Calcula o valor total do item
        SET v_valor_total = v_preco_unitario * p_quantidade;

        -- Insere o registro na tabela de pedidos
        INSERT INTO pedidos (id_cliente, id_loja, origem_compra, forma_pagamento, valor_total, status)
        VALUES (p_id_cliente, p_id_loja, p_origem_compra, p_forma_pagamento, v_valor_total, 'CONCLUIDO');

        -- Captura o ID do pedido recém-criado
        SET v_novo_pedido_id = LAST_INSERT_ID();

        -- Insere o registro na tabela de itens do pedido
        INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
        VALUES (v_novo_pedido_id, p_id_produto, p_quantidade, v_preco_unitario);

        -- Atualiza (baixa) o estoque do produto
        UPDATE produtos
        SET estoque_atual = estoque_atual - p_quantidade
        WHERE id_produto = p_id_produto;

        -- Verifica a regra de negócio de estoque mínimo de segurança (< 5 unidades)
        IF (v_estoque_atual - p_quantidade) < 5 THEN
            SELECT CONCAT('ALERTA: Produto (ID ', p_id_produto, ') atingiu o nível de estoque mínimo de segurança!') AS alerta_estoque;
        END IF;
    END IF;
END$$

DELIMITER ;

-- =====================================================
-- 3. Testes de Validação (Obrigatórios)
-- =====================================================

-- Teste da Trigger de Auditoria (Modifique o preço de um produto)
UPDATE produtos SET preco = 4300.00 WHERE id_produto = 1;

-- Consulte a tabela de auditoria para verificar se o registro foi gerado automaticamente:
SELECT * FROM auditoria_preco;

-- Teste da Stored Procedure de Venda (Simule uma compra)
CALL sp_registrar_venda(1, 2, 'E COMMERCE', 'PIX', 1, 2);

-- Consulte o estoque atualizado do produto e o pedido gerado:
SELECT id_produto, nome, estoque_atual FROM produtos WHERE id_produto = 1;
SELECT * FROM pedidos;