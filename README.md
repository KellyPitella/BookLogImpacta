# BookLog 📚

Aplicativo para acompanhamento e organização de leitura individual.

---

## 🛠️ Tecnologias
* **BackEnd:** C# / .NET 10 (Web API), Entity Framework Core e Pomelo MySQL.
* **Segurança:** Autenticação JWT Bearer e hash de senha com BCrypt.
* **Banco de Dados:** MySQL (`booklogImpacta`).
* **FrontEnd:** Flutter (Material 3, suporte Web e Android).
* **Gestão:** GitHub Projects (Kanban).

---

## 🗄️ Banco de Dados (MySQL)
* **`Usuarios`:** `Id`, `Nome`, `Email` (único), `SenhaHash`, `DataCriacao`.
* **`Livros`:** `Id`, `Titulo`, `Autor`, `Genero`, `TotalPaginas`, `DataCadastro`, `UsuarioId` (FK).

---

## 🔌 Principais Endpoints
* `POST /api/Auth/register` — Cadastro de usuário.
* `POST /api/Auth/login` — Login e retorno do token JWT.
* `GET /api/Livros` — Listagem dos livros do usuário autenticado.
* `POST /api/Livros` — Adicionar livro à estante.

---

## 🚀 Como Rodar

### 1. Banco de Dados
Execute o script em `BackEnd/scripts/create_database_mysql.sql` no MySQL Workbench.

### 2. BackEnd (.NET 10)
```bash
cd BackEnd
dotnet run
