# BookLog 📚

> **Projeto Full-Stack de Acompanhamento e Organização de Leituras**  
> Aplicação desenvolvida para entrega acadêmica composta por API REST em C# .NET, cliente multi-plataforma em Flutter, banco de dados relacional MySQL e gestão ágil via GitHub Projects.

---

## 👥 Identificação do Projeto

* **Aluna:** Kelly Pitella
* **Aplicação:** BookLog
* **Escopo da Entrega:** Entrega 1 (Fundação, Autenticação, Estante Base e Gestão Ágil)

---

## 🎯 Visão Geral

O **BookLog** foi idealizado para apoiar o hábito da leitura através de uma interface minimalista e acolhedora. O sistema centraliza o controle individual de livros, permitindo registro de leitura, categorização da estante e cálculo de progresso por livro.

---

## 🛠️ Tecnologias Utilizadas

### 1. BackEnd (.NET 10 API)
* **ASP.NET Core Web API (.NET 10)**
* **Entity Framework Core 9 / Pomelo MySQL** para persistência e ORM
* **Autenticação JWT Bearer** para segurança e controle de sessões
* **BCrypt.Net** para hashing de senhas
* **Swagger / OpenAPI** para documentação e validação de endpoints
* **CORS Configurado** para requisições do frontend

### 2. FrontEnd (Flutter)
* **Flutter SDK** com suporte nativo focado em **Android** e **Web**
* **Material 3 Design System** com alternância dinâmica entre temas Claro e Escuro
* **SharedPreferences** para armazenamento local persistente de credenciais e tokens
* **HTTP Client** integrado a DTOs para comunicação com a API

### 3. Banco de Dados (MySQL)
* **MySQL 8.0**
* **MySQL Workbench** para modelagem e execução de scripts DDL
* **Engine InnoDB** com integridade referencial e deleção em cascata (`CASCADE`)

---

## 🗄️ Modelagem da Base de Dados

O banco de dados `booklogImpacta` foi construído com foco em consistência relacional e restrições de integridade:

### Diagrama Lógico / Tabelas

1. **`Usuarios`**
   * `Id` (INT, Primary Key, Auto Increment)
   * `Nome` (VARCHAR(100), NOT NULL)
   * `Email` (VARCHAR(255), NOT NULL, UNIQUE)
   * `SenhaHash` (LONGTEXT, NOT NULL)
   * `DataCriacao` (DATETIME(6), Default CURRENT_TIMESTAMP)

2. **`Livros`**
   * `Id` (INT, Primary Key, Auto Increment)
   * `Titulo` (VARCHAR(300), NOT NULL)
   * `Autor` (VARCHAR(200), NULL)
   * `Genero` (VARCHAR(100), NULL)
   * `TotalPaginas` (INT, NOT NULL)
   * `DataCadastro` (DATETIME(6), Default CURRENT_TIMESTAMP)
   * `UsuarioId` (INT, Foreign Key para `Usuarios(Id)` com `ON DELETE CASCADE`)

---

## 🔌 Documentação da API REST

### Módulo de Autenticação (`/api/Auth`)
* **`POST /api/Auth/register`**: Cadastro de novos usuários. Valida se o e-mail já existe, criptografa a senha com BCrypt e retorna os dados acompanhados do Token JWT.
* **`POST /api/Auth/login`**: Autenticação de credenciais. Valida o hash da senha e gera o token de acesso com validade de 8 horas.

### Módulo da Estante (`/api/Livros`)
* **`GET /api/Livros`**: Requer `Bearer Token`. Retorna a estante ordenada por data, filtrando unicamente os livros pertencentes ao usuário autenticado.
* **`POST /api/Livros`**: Requer `Bearer Token`. Salva um novo livro associado ao `UsuarioId` extraído das claims do token.

---

## 📱 Telas do Aplicativo (FrontEnd)

* **Tela de Login (`/login`)**: Formulário com alternância de visibilidade de senha e feedback por SnackBar.
* **Tela de Cadastro (`/register`)**: Validação de formulário e criação de conta.
* **Tela Inicial / Estante (`/home`)**: Visão em grade dos livros lidos/em leitura, chips de filtragem e menu de navegação inferior.
* **Adicionar Livro (`/add-book`)**: Cadastro de títulos, autores, total de páginas e metas.
* **Detalhes da Obra (`/book-details`)**: Indicador circular de progresso em porcentagem, histórico de sessões e edição rápida de página.
* **Painel de Configurações**: Modal inferior para alternância imediata de tema (Claro/Escuro) e logout seguro.

---

## 📋 Metodologia e Gestão Ágil (GitHub Projects)

O planejamento do desenvolvimento e o rastreamento das atividades foram estruturados no **GitHub Projects** utilizando o framework **Kanban**:

* **Quadro de Gestão:** Colunas divididas em *Backlog*, *Ready*, *In Progress*, *In Review* e *Done*.
* **Rastreabilidade de Issues:** Cada componente de infraestrutura, backend e frontend possui uma Issue documentada com checklist de critérios de aceite.
* **Ciclo de Entregas:** A primeira entrega formaliza o núcleo da aplicação (MVP), deixando as funcionalidades complementares priorizadas para as próximas fases.

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* [.NET 10 SDK](https://dotnet.microsoft.com/) instalado na máquina
* [Flutter SDK](https://flutter.dev/) com suporte habilitado para Web e Android
* [MySQL Server 8.0](https://www.mysql.com/) em execução local

---

### 1. Banco de Dados
1. Abra o **MySQL Workbench** e conecte-se à sua instância local.
2. Abra e execute o arquivo `BackEnd/scripts/create_database_mysql.sql`.
3. O banco `booklogImpacta` e as tabelas com constraints serão criados automaticamente.

---

### 2. BackEnd (.NET 10)
1. Acesse o diretório da API:
   ```bash
   cd BackEnd
