# BookLog 📚

Aplicativo para acompanhamento e organização de leitura individual[cite: 1, 2, 25, 27].

---

## 🛠️ Tecnologias
* **BackEnd:** C# / .NET 10 (Web API), Entity Framework Core e Pomelo MySQL[cite: 16].
* **Segurança:** Autenticação JWT Bearer e hash de senha com BCrypt[cite: 12, 16].
* **Banco de Dados:** MySQL (`booklogImpacta`)[cite: 11, 15].
* **FrontEnd:** Flutter (Material 3, suporte Web e Android)[cite: 19, 21].
* **Gestão:** GitHub Projects (Kanban).

---

## 🗄️ Banco de Dados (MySQL)
* **`Usuarios`:** `Id`, `Nome`, `Email` (único), `SenhaHash`, `DataCriacao`[cite: 11].
* **`Livros`:** `Id`, `Titulo`, `Autor`, `Genero`, `TotalPaginas`, `DataCadastro`, `UsuarioId` (FK)[cite: 11].

---

## 🔌 Principais Endpoints
* `POST /api/Auth/register` — Cadastro de usuário[cite: 1].
* `POST /api/Auth/login` — Login e retorno do token JWT[cite: 1].
* `GET /api/Livros` — Listagem dos livros do usuário autenticado[cite: 2, 13].
* `POST /api/Livros` — Adicionar livro à estante[cite: 2, 13].

---

## 🚀 Como Rodar

### 1. Banco de Dados
Execute o script em `BackEnd/scripts/create_database_mysql.sql` no MySQL Workbench[cite: 11].

### 2. BackEnd (.NET 10)
```bash
cd BackEnd
dotnet run
