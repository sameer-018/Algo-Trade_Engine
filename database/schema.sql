sql
-- Algo-Trade Engine Database Schema
-- MySQL 8.0+

CREATE DATABASE IF NOT EXISTS algo_trade_engine;
USE algo_trade_engine;

-- Disable foreign key checks while recreating tables
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- Drop existing tables
-- =====================================================

DROP TABLE IF EXISTS trades;
DROP TABLE IF EXISTS strategy_parameters;
DROP TABLE IF EXISTS backtests;
DROP TABLE IF EXISTS stock_prices;
DROP TABLE IF EXISTS strategies;
DROP TABLE IF EXISTS stocks;

-- =====================================================
-- 1. STOCKS
-- =====================================================

CREATE TABLE stocks (
    stock_id INT NOT NULL AUTO_INCREMENT,
    symbol VARCHAR(10) NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    exchange VARCHAR(20) DEFAULT NULL,

    PRIMARY KEY (stock_id),
    UNIQUE KEY symbol (symbol)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- 2. STRATEGIES
-- =====================================================

CREATE TABLE strategies (
    strategy_id INT NOT NULL AUTO_INCREMENT,
    strategy_name VARCHAR(50) NOT NULL,
    description TEXT,

    PRIMARY KEY (strategy_id),
    UNIQUE KEY strategy_name (strategy_name)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- 3. STOCK PRICES
-- =====================================================

CREATE TABLE stock_prices (
    price_id INT NOT NULL AUTO_INCREMENT,
    stock_id INT NOT NULL,
    trade_date DATE NOT NULL,
    open_price DECIMAL(12,2) NOT NULL,
    high_price DECIMAL(12,2) NOT NULL,
    low_price DECIMAL(12,2) NOT NULL,
    close_price DECIMAL(12,2) NOT NULL,
    volume BIGINT DEFAULT NULL,

    PRIMARY KEY (price_id),
    UNIQUE KEY stock_id (stock_id, trade_date),

    CONSTRAINT stock_prices_ibfk_1
        FOREIGN KEY (stock_id)
        REFERENCES stocks (stock_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- 4. BACKTESTS
-- =====================================================

CREATE TABLE backtests (
    backtest_id INT NOT NULL AUTO_INCREMENT,
    stock_id INT NOT NULL,
    strategy_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    initial_capital DECIMAL(15,2) NOT NULL,
    final_capital DECIMAL(15,2) DEFAULT NULL,
    profit_loss DECIMAL(15,2) DEFAULT NULL,
    return_percentage DECIMAL(8,2) DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (backtest_id),
    KEY stock_id (stock_id),
    KEY strategy_id (strategy_id),

    CONSTRAINT backtests_ibfk_1
        FOREIGN KEY (stock_id)
        REFERENCES stocks (stock_id),

    CONSTRAINT backtests_ibfk_2
        FOREIGN KEY (strategy_id)
        REFERENCES strategies (strategy_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- 5. STRATEGY PARAMETERS
-- =====================================================

CREATE TABLE strategy_parameters (
    parameter_id INT NOT NULL AUTO_INCREMENT,
    backtest_id INT NOT NULL,
    parameter_name VARCHAR(50) NOT NULL,
    parameter_value VARCHAR(50) NOT NULL,

    PRIMARY KEY (parameter_id),
    KEY backtest_id (backtest_id),

    CONSTRAINT strategy_parameters_ibfk_1
        FOREIGN KEY (backtest_id)
        REFERENCES backtests (backtest_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- 6. TRADES
-- =====================================================

CREATE TABLE trades (
    trade_id INT NOT NULL AUTO_INCREMENT,
    backtest_id INT NOT NULL,
    trade_date DATE NOT NULL,
    trade_type ENUM('BUY','SELL') NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    quantity INT NOT NULL,
    profit_loss DECIMAL(15,2) DEFAULT NULL,

    PRIMARY KEY (trade_id),
    KEY backtest_id (backtest_id),

    CONSTRAINT trades_ibfk_1
        FOREIGN KEY (backtest_id)
        REFERENCES backtests (backtest_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- =====================================================
-- SAMPLE DATA
-- =====================================================

-- Stocks
INSERT INTO stocks
    (stock_id, symbol, company_name, exchange)
VALUES
    (1, 'AAPL', 'Apple Inc.', 'NASDAQ'),
    (2, 'MSFT', 'Microsoft Corporation', 'NASDAQ'),
    (3, 'GOOGL', 'Alphabet Inc.', 'NASDAQ');

-- Strategies
INSERT INTO strategies
    (strategy_id, strategy_name, description)
VALUES
    (1, 'SMA Crossover',
     'Buy when short-term SMA crosses above long-term SMA'),

    (2, 'RSI',
     'Buy and sell based on Relative Strength Index'),

    (3, 'Bollinger Bands',
     'Trade based on Bollinger Band price levels');

-- Stock prices
INSERT INTO stock_prices
    (price_id, stock_id, trade_date, open_price,
     high_price, low_price, close_price, volume)
VALUES
    (1, 1, '2026-01-02', 250.00, 255.00, 248.00, 253.50, 1000000),

    (2, 1, '2026-01-03', 253.50, 258.00, 251.00, 257.20, 1200000),

    (3, 1, '2026-01-04', 257.20, 260.00, 254.00, 259.80, 1100000);

-- Backtest
INSERT INTO backtests
    (backtest_id, stock_id, strategy_id, start_date,
     end_date, initial_capital, final_capital,
     profit_loss, return_percentage, created_at)
VALUES
    (1, 1, 1, '2026-01-01', '2026-03-31',
     100000.00, NULL, NULL, NULL,
     '2026-09-05 06:25:08');

-- Strategy parameters
INSERT INTO strategy_parameters
    (parameter_id, backtest_id, parameter_name, parameter_value)
VALUES
    (3, 1, 'short_sma', '20'),
    (4, 1, 'long_sma', '50');

-- Trades
INSERT INTO trades
    (trade_id, backtest_id, trade_date, trade_type,
     price, quantity, profit_loss)
VALUES
    (1, 1, '2026-01-10', 'BUY', 260.50, 10, 0.00),

    (2, 1, '2026-02-15', 'SELL', 275.50, 10, 150.00);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

