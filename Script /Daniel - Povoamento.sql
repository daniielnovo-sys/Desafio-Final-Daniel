
-- =====================================================
-- PROJETO: LOJA VIRTUAL
-- PASSO 4: POVOAMENTO INICIAL DAS TABELAS (DML)
-- ARQUIVO: 02_dml_povoamento.sql
-- SGBD: MySQL
-- =====================================================

-- 1. CRIACAO E SELECAO DO BANCO DE DADOS

CREATE DATABASE IF NOT EXISTS loja_virtual;
USE loja_virtual;

-- =====================================================
-- 2. CRIACAO DAS TABELAS
-- =====================================================

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    estoque_atual INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_preco CHECK (preco >= 0),
    CONSTRAINT chk_estoque CHECK (estoque_atual >= 0)
);

CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_pedido DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
);

CREATE TABLE IF NOT EXISTS itens_pedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_item_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedidos(id_pedido),
    CONSTRAINT fk_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES produtos(id_produto),
    CONSTRAINT chk_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_preco_unitario CHECK (preco_unitario >= 0)
);

-- =====================================================
-- 3. POVOAMENTO DA TABELA CLIENTES
-- =====================================================

INSERT INTO clientes (nome, email, telefone) VALUES
('Ana Silva', 'ana@email.com', '81999990001'),
('Bruno Santos', 'bruno@email.com', '81999990002'),
('Carla Oliveira', 'carla@email.com', '81999990003'),
('Diego Souza', 'diego@email.com', '81999990004'),
('Fernanda Lima', 'fernanda@email.com', '81999990005');

-- =====================================================
-- 4. POVOAMENTO DA TABELA PRODUTOS
-- =====================================================

INSERT INTO produtos (nome, preco, estoque_atual) VALUES
('Smartphone Galaxy S23', 4500.00, 15),
('Notebook Dell Inspiron', 3800.00, 8),
('Fone de Ouvido Bluetooth', 250.00, 30),
('Mouse Sem Fio Logitech', 120.00, 25),
('Teclado Mecanico Gamer', 350.00, 12);

-- =====================================================
-- 5. POVOAMENTO DA TABELA PEDIDOS
-- =====================================================

INSERT INTO pedidos (id_cliente, data_pedido, status) VALUES
(1, '2026-10-01', 'Concluido'),
(2, '2026-10-02', 'Pendente'),
(3, '2026-10-03', 'Processando'),
(4, '2026-10-04', 'Concluido'),
(5, '2026-10-05', 'Pendente');

-- =====================================================
-- 6. POVOAMENTO DA TABELA ITENS_PEDIDO
-- =====================================================

INSERT INTO itens_pedido
(id_pedido, id_produto, quantidade, preco_unitario)
VALUES
(1, 1, 1, 4500.00),
(2, 3, 2, 250.00),
(3, 2, 1, 3800.00),
(4, 4, 2, 120.00),
(5, 5, 1, 350.00);

-- =====================================================
-- 7. CONSULTAS DE VALIDACAO
-- =====================================================

-- Listar todos os clientes
SELECT * FROM clientes;

-- Listar todos os produtos
SELECT * FROM produtos;

-- Listar todos os pedidos
SELECT * FROM pedidos;

-- Listar todos os itens dos pedidos
SELECT * FROM itens_pedido;

-- =====================================================
-- 8. CONTAGEM DE REGISTROS POR TABELA
-- =====================================================

SELECT 'clientes' AS tabela, COUNT(*) AS total
FROM clientes
UNION ALL
SELECT 'produtos', COUNT(*)
FROM produtos
UNION ALL
SELECT 'pedidos', COUNT(*)
FROM pedidos
UNION ALL
SELECT 'itens_pedido', COUNT(*)
FROM itens_pedido;

-- =====================================================
-- 9. CONSULTA INTEGRADA DOS PEDIDOS
-- =====================================================

SELECT
    c.nome AS cliente,
    p.id_pedido,
    p.data_pedido,
    p.status,
    pr.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS subtotal
FROM clientes AS c
INNER JOIN pedidos AS p
    ON c.id_cliente = p.id_cliente
INNER JOIN itens_pedido AS ip
    ON p.id_pedido = ip.id_pedido
INNER JOIN produtos AS pr
    ON ip.id_produto = pr.id_produto
ORDER BY p.id_pedido;

-- =====================================================
-- 10. VALIDACAO DE ESTOQUE DOS PRODUTOS
-- =====================================================

SELECT
    nome AS produto,
    estoque_atual,
    CASE
        WHEN estoque_atual = 0 THEN 'Sem estoque'
        WHEN estoque_atual <= 10 THEN 'Estoque baixo'
        ELSE 'Estoque normal'
    END AS situacao_estoque
FROM produtos
ORDER BY estoque_atual ASC;

-- =====================================================
-- FIM DO SCRIPT DML
-- =====================================================
