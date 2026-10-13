# 📚 BookLog

Aplicativo para **rastreamento, organização e acompanhamento do hábito de leitura**, permitindo que o usuário crie sua conta, cadastre livros na própria estante e acompanhe o progresso de leitura de cada livro.

O projeto foi desenvolvido como uma aplicação **Full Stack**, composta por uma API REST em C#/.NET, uma aplicação FrontEnd em Flutter e um banco de dados MySQL.

---

## 🎓 Identificação Acadêmica

| Informação | Descrição |
| :--- | :--- |
| **Autora** | Kelly Pitella |
| **Aplicação** | BookLogImpacta |
| **Tipo** | Aplicação Full Stack |
| **Escopo atual** | Entrega 2 |
| **Funcionalidades ativas** | Cadastro e login de usuários, estante de livros, adição de livros e registro de progresso de leitura |

---

## 🛠️ Tecnologias Utilizadas

### BackEnd

- **C#**
- **ASP.NET Core (.NET 10)**
- **Entity Framework Core**
- **Pomelo.EntityFrameworkCore.MySql**
- **JWT Bearer Authentication**
- **BCrypt.Net** para geração de hash seguro das senhas
- **Swagger / OpenAPI** para documentação e testes da API

### FrontEnd

- **Flutter**
- **Dart**
- Suporte para **Web** e **Android**
- **Material 3**
- Tema **Claro e Escuro**
- **SharedPreferences** para persistência local do token de autenticação
- Requisições **HTTP** para comunicação com a API REST

### Banco de Dados

- **MySQL**
- Schema: `booklogImpacta`
- Gerenciamento via **MySQL Workbench**

---

# 🗃️ Modelagem do Banco de Dados

O banco de dados `booklogImpacta` possui três tabelas principais:

- `Usuarios`
- `Livros`
- `ProgressosLeitura`

As tabelas possuem relacionamentos com **Cascade Delete**, garantindo que, ao excluir um usuário, seus livros associados sejam removidos; e ao excluir um livro, todos os seus registros de progresso vinculados também sejam excluídos.

### Tabela `Usuarios`

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `Id` | INT (PK) | Identificador único do usuário (Auto Increment) |
| `Nome` | VARCHAR(100) | Nome do usuário |
| `Email` | VARCHAR(255) | E-mail utilizado para autenticação |
| `SenhaHash` | LONGTEXT | Hash da senha gerado utilizando BCrypt |
| `DataCriacao` | DATETIME(6) | Data e hora de criação da conta |

O campo `Email` possui restrição de **unicidade** (`UNIQUE INDEX`), impedindo o cadastro de mais de uma conta com o mesmo endereço de e-mail.

---

### Tabela `Livros`

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `Id` | INT (PK) | Identificador único do livro (Auto Increment) |
| `Titulo` | VARCHAR(300) | Título da obra |
| `Autor` | VARCHAR(200) | Autor da obra (opcional) |
| `Genero` | VARCHAR(100) | Gênero literário (opcional) |
| `TotalPaginas` | INT | Número total de páginas do livro |
| `PaginasLidas` | INT | Quantidade total de páginas já lidas (Padrão: 0) |
| `Concluido` | TINYINT(1) | Indica se a leitura da obra foi finalizada (Padrão: 0) |
| `DataCadastro` | DATETIME(6) | Data e hora de cadastro do livro |
| `UsuarioId` | INT (FK) | Referência ao usuário proprietário (`ON DELETE CASCADE`) |

---

### Tabela `ProgressosLeitura`

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `Id` | INT (PK) | Identificador único do registro (Auto Increment) |
| `Data` | DATETIME(6) | Data e hora da sessão de leitura |
| `PaginasLidas` | INT | Quantidade de páginas lidas na sessão |
| `Nota` | VARCHAR(500) | Anotação ou observação opcional sobre a leitura |
| `LivroId` | INT (FK) | Referência ao livro lido (`ON DELETE CASCADE`) |

---

### Relacionamento

```text
Usuarios
   │
   1
   │
   N
   ▼
 Livros
   │
   1
   │
   N
   ▼
ProgressosLeitura
```

**Relacionamentos:**

- `Usuarios (1) — (N) Livros`
- `Livros (1) — (N) ProgressosLeitura`

A chave estrangeira `UsuarioId` identifica o proprietário de cada livro e garante que cada usuário visualize apenas os livros associados à sua própria conta. A chave `LivroId` vincula cada registro de progresso à sua respectiva obra.

---

# 🔐 Autenticação

A autenticação da aplicação é realizada utilizando **JWT (JSON Web Token)**.

O fluxo de autenticação funciona da seguinte forma:

1. O usuário cria uma conta através da tela de cadastro.
2. A senha é transformada em um hash utilizando **BCrypt** antes de ser armazenada.
3. O usuário realiza o login utilizando e-mail e senha.
4. A API valida as credenciais.
5. Em caso de sucesso, um token JWT é gerado.
6. O FrontEnd armazena o token localmente utilizando **SharedPreferences**.
7. O token é enviado nas requisições que necessitam de autenticação.
8. A API identifica o usuário através das informações presentes no token.

---

# 🔌 Endpoints da API REST

## Autenticação – `/api/Auth`

| Método | Rota | Autenticação | Descrição |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/Auth/register` | Não | Cria uma nova conta de usuário (nome, email, senha) |
| `POST` | `/api/Auth/login` | Não | Autentica o usuário (email, senha) e retorna um token JWT |

### Schemas de Requisição (Auth)

**`RegisterDto`**

- `nome` (string, obrigatório, máx: 100 caracteres)
- `email` (string, formato email, obrigatório, máx: 255 caracteres)
- `senha` (string, obrigatório, mín: 6 caracteres)

**`LoginDto`**

- `email` (string, formato email, obrigatório)
- `senha` (string, obrigatório)

---

## Livros – `/api/Livros`

| Método | Rota | Autenticação | Descrição |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/Livros` | Bearer Token | Lista os livros da estante do usuário autenticado |
| `POST` | `/api/Livros` | Bearer Token | Adiciona um novo livro à estante do usuário autenticado |

### Schema de Requisição (Livros)

**`CreateLivroDto`**

- `titulo` (string, obrigatório, máx: 300 caracteres)
- `totalPaginas` (integer, obrigatório, mín: 1)
- `autor` (string, opcional, máx: 200 caracteres)
- `genero` (string, opcional, máx: 100 caracteres)

---

## Progresso de Leitura – `/api/Progresso`

| Método | Rota | Autenticação | Descrição |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/Progresso` | Bearer Token | Registra uma nova sessão de leitura e atualiza o progresso do livro |

### Schema de Requisição (Progresso)

**`CreateProgressoDto`**

- `livroId` (integer, obrigatório)
- `paginasLidas` (integer, obrigatório, mín: 1)
- `data` (datetime ISO 8601, obrigatório, ex: `2026-10-12T19:30:00Z`)
- `nota` (string, opcional, máx: 500 caracteres)

---

# 🔒 Autorização

Os endpoints protegidos utilizam autenticação **Bearer Token**.

Exemplo do cabeçalho utilizado nas requisições:

```http
Authorization: Bearer SEU_TOKEN_JWT
```

A API utiliza o identificador presente no token para garantir que o usuário acesse somente os seus próprios livros e registros.

---

# 📱 FrontEnd

O aplicativo possui uma interface desenvolvida em **Flutter**, utilizando **Material 3** e suporte para temas claro e escuro.

## Telas e funcionalidades

### 🔑 Tela de Login

Permite que o usuário:

- Informe e-mail e senha;
- Realize a autenticação;
- Receba o token JWT;
- Acesse a estante após o login.

### 📝 Tela de Cadastro

Permite criar uma nova conta informando:

- Nome;
- E-mail;
- Senha.

### 📚 Tela de Estante

Apresenta os livros cadastrados pelo usuário autenticado.

Cada livro apresenta informações como:

- Título;
- Autor;
- Progresso de leitura.

### ➕ Tela de Adicionar Livro

Permite cadastrar um novo livro informando:

- Título;
- Autor;
- Gênero literário;
- Número total de páginas.

### 📖 Tela de Detalhes do Livro e Registro de Progresso

Apresenta as informações cadastradas da obra e o percentual de leitura:

- Exibe indicador visual e percentual atualizado da leitura;
- Ação `+ Registrar Progresso` para inserção de novas páginas lidas;
- Histórico das sessões de leitura.

O percentual é calculado com base na quantidade de páginas lidas em relação ao total de páginas:

```text
Progresso (%) = (Páginas Lidas ÷ Total de Páginas) × 100
```

---

## 🌓 Tema Claro e Escuro

A aplicação possui suporte aos modos:

- ☀️ **Tema Claro**
- 🌙 **Tema Escuro**

A interface utiliza os componentes do **Material 3** para manter uma experiência visual consistente.

---

# 📋 Metodologia de Gestão Ágil

O gerenciamento do projeto é realizado através do **GitHub Projects**, utilizando a metodologia **Kanban**.

O quadro está organizado nas seguintes etapas:

| Coluna | Descrição |
| :--- | :--- |
| **Backlog** | Funcionalidades e tarefas planejadas para o projeto |
| **Ready** | Tarefas priorizadas e prontas para desenvolvimento |
| **In Progress** | Tarefas atualmente em desenvolvimento |
| **In Review** | Funcionalidades em processo de revisão e validação |
| **Done** | Tarefas concluídas e validadas |

Essa organização permite acompanhar o desenvolvimento das funcionalidades e visualizar o progresso de cada etapa do projeto.

---

# ▶️ Como Executar o Projeto

## 📌 Pré-requisitos

Antes de executar o projeto, certifique-se de ter instalado:

- **.NET SDK 10**
- **MySQL Server** (v8.0 ou superior)
- **MySQL Workbench** (opcional, para gerenciamento visual)
- **Flutter SDK**
- **Google Chrome** para execução Web
- **Android Studio** e/ou um dispositivo Android para execução mobile

Também é recomendado possuir:

- **Visual Studio** ou **Visual Studio Code**
- **Git**
- Extensões de **Flutter/Dart** e **C#** para o editor utilizado

---

## 🗄️ 1. Configuração do Banco de Dados

Certifique-se de que o serviço do MySQL esteja em execução.

Neste projeto, o banco de dados e suas tabelas podem ser criados através do script:

```text
create_database_mysql.sql (localizado em BackEnd/scripts/ ou raiz de BackEnd/)
```

Execute esse script no **MySQL Workbench** para criar o banco de dados `booklogImpacta` e suas respectivas tabelas.

> ⚠️ **Atenção:** Não é necessário executar o script e as migrations para criar a mesma estrutura. Para o estado atual do projeto, o script SQL é a forma mais direta.

Depois, configure a string de conexão no arquivo:

```text
BackEnd/appsettings.json
```

Exemplo:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "server=localhost;database=booklogImpacta;user=SEU_USUARIO;password=SUA_SENHA"
  }
}
```

---

## ⚙️ 2. Executar o BackEnd

Abra um terminal e acesse a pasta do BackEnd:

```bash
cd BackEnd
```

Restaure as dependências:

```bash
dotnet restore
```

Execute a aplicação:

```bash
dotnet run
```

Por padrão, nesta configuração do projeto, a API estará disponível em:

```text
http://localhost:5191
```

### Swagger

A documentação interativa da API pode ser acessada através do Swagger:

```text
http://localhost:5191/swagger
```

O Swagger permite visualizar os endpoints disponíveis e realizar testes diretamente pelo navegador.

> ⚠️ A porta pode ser diferente dependendo da configuração do ambiente. Caso isso aconteça, utilize a URL apresentada no terminal após executar `dotnet run`.

---

## 📱 3. Executar o FrontEnd

Abra outro terminal e acesse a pasta do FrontEnd:

```bash
cd frontend
```

Instale as dependências:

```bash
flutter pub get
```

Antes de executar o aplicativo, certifique-se de que a URL base da API configurada no FrontEnd aponta para o endereço correto do BackEnd (em `api_constants.dart`).

Exemplo:

```text
http://localhost:5191
```

### 🌐 Executar na Web

Para executar o aplicativo utilizando o Google Chrome:

```bash
flutter run -d chrome
```

### 🤖 Executar no Android

Para executar em um dispositivo ou emulador Android:

```bash
flutter run -d android
```

### ⚠️ Importante sobre localhost no Android

Quando o aplicativo é executado em um emulador Android, `localhost` representa o próprio emulador e não o computador onde a API está sendo executada.

Nesse caso, para o emulador Android padrão do Android Studio, utilize:

```text
http://10.0.2.2:5191
```

Em um dispositivo físico, utilize o endereço IP local da máquina que está executando o BackEnd, desde que ambos estejam conectados à mesma rede Wi-Fi.

---

# 📁 Estrutura do Projeto

O projeto está organizado separando o BackEnd e o FrontEnd:

```text
BookLogImpacta/
│
├── BackEnd/
│   ├── Controllers/
│   ├── Data/
│   ├── DTOs/
│   ├── Models/
│   ├── Properties/
│   ├── scripts/
│   ├── Services/
│   ├── appsettings.Development.json
│   ├── appsettings.json
│   ├── BackEnd.csproj
│   ├── BackEnd.http
│   └── Program.cs
│
├── frontend/
│   ├── android/
│   ├── assets/
│   ├── lib/
│   │   ├── core/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── main.dart
│   ├── test/
│   ├── web/
│   ├── analysis_options.yaml
│   ├── pubspec.yaml
│   └── README.md
│
└── .gitignore
```

---

# 🗺️ Roadmap

O projeto será desenvolvido de forma incremental, adicionando novas funcionalidades ao longo das próximas entregas.

## 🚀 Entrega 1 (Concluída)

- [x] Cadastro e login de usuários;
- [x] Autenticação com JWT e BCrypt;
- [x] Modelagem inicial do banco de dados (`Usuarios` e `Livros`);
- [x] Endpoints iniciais da API e documentação Swagger;
- [x] Interface em Flutter com Login, Cadastro, Estante e Formulário de Livros;
- [x] Suporte aos temas claro e escuro.

## 🚀 Entrega 2 (Concluída)

**Progresso de Leitura**

- [x] Atualização das páginas lidas;
- [x] Persistência do progresso no BackEnd (`ProgressosLeitura`);
- [x] Sincronização do progresso entre FrontEnd e BackEnd;
- [x] Atualização do percentual de leitura na interface.

## 🚀 Entrega 3 (Próxima Etapa)

**Gerenciamento de Livros**

- Implementação do CRUD completo de livros;
- Edição de informações dos livros;
- Exclusão de livros;
- Filtros na estante;
- Filtro por status de leitura;
- Filtro por autor;
- Filtro por título.

## 🚀 Entrega 4

**Dashboard e Metas**

- Dashboard de leitura;
- Estatísticas do usuário;
- Quantidade de livros lidos;
- Livros em andamento;
- Livros ainda não iniciados;
- Acompanhamento de páginas lidas;
- Criação de metas anuais de leitura;
- Acompanhamento do progresso das metas.

---

# 🎯 Objetivo do Projeto

O **BookLog** tem como objetivo proporcionar uma forma simples e organizada de acompanhar o hábito de leitura, centralizando os livros do usuário em uma estante digital e permitindo acompanhar o progresso de cada leitura.

O projeto também tem como finalidade aplicar, de forma prática, conhecimentos relacionados a:

- Desenvolvimento BackEnd;
- Desenvolvimento FrontEnd;
- APIs REST;
- Banco de dados relacionais;
- Autenticação e autorização;
- Desenvolvimento mobile;
- Desenvolvimento Web;
- Git e GitHub;
- Metodologias ágeis;
- Organização e documentação de projetos.

---

# 👩‍💻 Autoria

**Kelly Pitella**

Projeto desenvolvido como parte da formação acadêmica/profissional na área de desenvolvimento de sistemas.

---

# 📌 Status do Projeto

🚧 **Em desenvolvimento**

A versão atual corresponde à **Entrega 2 (Concluída)**. O próximo ciclo de desenvolvimento iniciará os itens da **Entrega 3 (CRUD e Filtros de Livros)**.
