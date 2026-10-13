CREATE DATABASE IF NOT EXISTS booklogImpacta;

USE booklogImpacta;

CREATE TABLE IF NOT EXISTS Usuarios (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    SenhaHash LONGTEXT NOT NULL,
    DataCriacao DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    UNIQUE INDEX IX_Usuarios_Email (Email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS Livros (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Titulo VARCHAR(300) NOT NULL,
    Autor VARCHAR(200) NULL,
    Genero VARCHAR(100) NULL,
    TotalPaginas INT NOT NULL,
    PaginasLidas INT NOT NULL DEFAULT 0,
    Concluido TINYINT(1) NOT NULL DEFAULT 0,
    DataCadastro DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UsuarioId INT NOT NULL,

    INDEX IX_Livros_UsuarioId (UsuarioId),

    CONSTRAINT FK_Livros_Usuarios
        FOREIGN KEY (UsuarioId)
        REFERENCES Usuarios(Id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'Livros'
      AND COLUMN_NAME = 'PaginasLidas'
);
SET @sql = IF(
    @column_exists = 0,
    'ALTER TABLE Livros ADD COLUMN PaginasLidas INT NOT NULL DEFAULT 0',
    'SELECT 1'
);
PREPARE migrate_column FROM @sql;
EXECUTE migrate_column;
DEALLOCATE PREPARE migrate_column;

SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'Livros'
      AND COLUMN_NAME = 'Concluido'
);
SET @sql = IF(
    @column_exists = 0,
    'ALTER TABLE Livros ADD COLUMN Concluido TINYINT(1) NOT NULL DEFAULT 0',
    'SELECT 1'
);
PREPARE migrate_column FROM @sql;
EXECUTE migrate_column;
DEALLOCATE PREPARE migrate_column;

CREATE TABLE IF NOT EXISTS ProgressosLeitura (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Data DATETIME(6) NOT NULL,
    PaginasLidas INT NOT NULL,
    Nota VARCHAR(500) NULL,
    LivroId INT NOT NULL,
    INDEX IX_ProgressosLeitura_LivroId (LivroId),
    CONSTRAINT FK_ProgressosLeitura_Livros
        FOREIGN KEY (LivroId)
        REFERENCES Livros(Id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;