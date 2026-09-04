# 📚 BookLog

Aplicativo para **rastreamento, organização e acompanhamento do hábito de leitura**, permitindo que o usuário crie sua conta, cadastre livros na própria estante e acompanhe o progresso de leitura de cada livro.

O projeto foi desenvolvido como uma aplicação **Full Stack**, composta por uma API REST em C#/.NET, uma aplicação FrontEnd em Flutter e um banco de dados MySQL.

---

## 🎓 Identificação Acadêmica

| Informação                     | Descrição                                                                                                |
| ------------------------------ | -------------------------------------------------------------------------------------------------------- |
| **Autora**                     | Kelly Pitella                                                                                            |
| **Aplicação**                  | BookLogImpacta                                                                                           |
| **Tipo**                       | Aplicação Full Stack                                                                                     |
| **Escopo desta entrega**       | Entrega 1                                                                                                |
| **Funcionalidades da entrega** | Cadastro e login de usuários, estante de livros, adição de livros e visualização do progresso de leitura |

---

## 🛠️ Tecnologias Utilizadas

### BackEnd

* **C#**
* **ASP.NET Core (.NET 10)**
* **Entity Framework Core**
* **Pomelo.EntityFrameworkCore.MySql**
* **JWT Bearer Authentication**
* **BCrypt.Net** para geração de hash seguro das senhas
* **Swagger / OpenAPI** para documentação e testes da API

### FrontEnd

* **Flutter**
* **Dart**
* Suporte para **Web** e **Android**
* **Material 3**
* Tema **Claro e Escuro**
* **SharedPreferences** para persistência local do token de autenticação
* Requisições **HTTP** para comunicação com a API REST

### Banco de Dados

* **MySQL**
* Schema: `booklogImpacta`
* **Entity Framework Core Migrations** para gerenciamento da estrutura do banco

---

# 🗃️ Modelagem do Banco de Dados

O banco de dados `booklogImpacta` possui duas tabelas principais:

* `Usuarios`
* `Livros`

As tabelas possuem um relacionamento **1:N**, onde um usuário pode possuir vários livros em sua estante.

O relacionamento utiliza **Cascade Delete**, garantindo que, ao excluir um usuário, seus livros associados também sejam removidos.

### Tabela `Usuarios`

| Campo         | Tipo         | Descrição                              |
| ------------- | ------------ | -------------------------------------- |
| `Id`          | INT (PK)     | Identificador único do usuário         |
| `Nome`        | VARCHAR(100) | Nome do usuário                        |
| `Email`       | VARCHAR(255) | E-mail utilizado para autenticação     |
| `SenhaHash`   | LONGTEXT     | Hash da senha gerado utilizando BCrypt |
| `DataCriacao` | DATETIME     | Data e hora de criação da conta        |

O campo `Email` possui restrição de **unicidade**, impedindo o cadastro de mais de uma conta com o mesmo endereço de e-mail.

### Tabela `Livros`

| Campo          | Tipo         | Descrição                                   |
| -------------- | ------------ | ------------------------------------------- |
| `Id`           | INT (PK)     | Identificador único do livro                |
| `UsuarioId`    | INT (FK)     | Referência ao usuário proprietário do livro |
| `Titulo`       | VARCHAR(300) | Título do livro                             |
| `Autor`        | VARCHAR(200) | Autor do livro                              |
| `TotalPaginas` | INT          | Número total de páginas                     |
| `PaginasLidas` | INT          | Quantidade de páginas já lidas              |
| `DataCadastro` | DATETIME     | Data de cadastro do livro                   |

### Relacionamento

```text
Usuarios
   │
   │ 1
   │
   │ N
   ▼
Livros
```

**Relacionamento:** `Usuarios (1) — (N) Livros`

A chave estrangeira `UsuarioId` identifica o proprietário de cada livro e garante que cada usuário visualize apenas os livros associados à sua própria conta.

---

# 🔐 Autenticação

A autenticação da aplicação é realizada utilizando **JWT (JSON Web Token)**.

O fluxo de autenticação funciona da seguinte forma:

1. O usuário cria uma conta através da tela de cadastro.
2. A senha é transformada em um **hash utilizando BCrypt** antes de ser armazenada.
3. O usuário realiza o login utilizando e-mail e senha.
4. A API valida as credenciais.
5. Em caso de sucesso, um **token JWT** é gerado.
6. O FrontEnd armazena o token localmente utilizando `SharedPreferences`.
7. O token é enviado nas requisições que necessitam de autenticação.
8. A API identifica o usuário através das informações presentes no token.

---

# 🔌 Endpoints da API REST

## Autenticação — `/api/Auth`

| Método | Rota                 | Autenticação | Descrição                                  |
| ------ | -------------------- | ------------ | ------------------------------------------ |
| `POST` | `/api/Auth/register` | Não          | Cria uma nova conta de usuário             |
| `POST` | `/api/Auth/login`    | Não          | Autentica o usuário e retorna um token JWT |

## Livros — `/api/Livros`

| Método | Rota          | Autenticação | Descrição                                               |
| ------ | ------------- | ------------ | ------------------------------------------------------- |
| `GET`  | `/api/Livros` | Bearer Token | Lista os livros da estante do usuário autenticado       |
| `POST` | `/api/Livros` | Bearer Token | Adiciona um novo livro à estante do usuário autenticado |

### Autorização

Os endpoints de livros utilizam autenticação **Bearer Token**.

Exemplo do cabeçalho utilizado nas requisições:

```http
Authorization: Bearer SEU_TOKEN_JWT
```

A API utiliza o identificador presente no token para garantir que o usuário acesse somente os seus próprios livros.

---

# 📱 FrontEnd

O aplicativo possui uma interface desenvolvida em **Flutter**, utilizando **Material 3** e suporte para temas claro e escuro.

## Telas e funcionalidades

### 🔑 Tela de Login

Permite que o usuário:

* Informe e-mail e senha;
* Realize a autenticação;
* Receba o token JWT;
* Acesse a estante após o login.

### 📝 Tela de Cadastro

Permite criar uma nova conta informando:

* Nome;
* E-mail;
* Senha.

### 📚 Tela de Estante

Apresenta os livros cadastrados pelo usuário autenticado.

Cada livro apresenta informações como:

* Título;
* Autor;
* Progresso de leitura.

### ➕ Tela de Adicionar Livro

Permite cadastrar um novo livro informando:

* Título;
* Autor;
* Número total de páginas;
* Página atual de leitura.

### 📖 Tela de Detalhes do Livro

Apresenta as informações cadastradas do livro e o percentual de progresso da leitura.

O percentual é calculado com base na quantidade de páginas lidas em relação ao total de páginas.

```text
Progresso (%) = (Páginas Lidas ÷ Total de Páginas) × 100
```

### 🌓 Tema Claro e Escuro

A aplicação possui suporte aos modos:

* ☀️ Tema Claro
* 🌙 Tema Escuro

A interface utiliza os componentes do **Material 3** para manter uma experiência visual consistente.

---

# 📋 Metodologia de Gestão Ágil

O gerenciamento do projeto é realizado através do **GitHub Projects**, utilizando a metodologia **Kanban**.

O quadro está organizado nas seguintes etapas:

| Coluna          | Descrição                                           |
| --------------- | --------------------------------------------------- |
| **Backlog**     | Funcionalidades e tarefas planejadas para o projeto |
| **Ready**       | Tarefas priorizadas e prontas para desenvolvimento  |
| **In Progress** | Tarefas atualmente em desenvolvimento               |
| **In Review**   | Funcionalidades em processo de revisão e validação  |
| **Done**        | Tarefas concluídas e validadas                      |

Essa organização permite acompanhar o desenvolvimento das funcionalidades e visualizar o progresso de cada etapa do projeto.

---

# ▶️ Como Executar o Projeto

## 📌 Pré-requisitos

Antes de executar o projeto, certifique-se de ter instalado:

* [.NET SDK 10](https://dotnet.microsoft.com/)
* [MySQL Server](https://dev.mysql.com/downloads/)
* [Flutter SDK](https://flutter.dev/)
* Google Chrome para execução Web
* Android Studio e/ou um dispositivo Android para execução mobile

Também é recomendado possuir:

* Visual Studio ou Visual Studio Code
* Git
* Extensões de Flutter/Dart para o editor utilizado

---

# 🗄️ 1. Configuração do Banco de Dados

Certifique-se de que o serviço do **MySQL Server** esteja em execução.

Crie o banco de dados:

```sql
CREATE DATABASE booklogImpacta;
```

Em seguida, configure a string de conexão no arquivo:

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

> ⚠️ Substitua `SEU_USUARIO` e `SUA_SENHA` pelas credenciais do seu ambiente MySQL.

Depois, execute as migrations do Entity Framework Core para criar as tabelas:

```bash
dotnet ef database update
```

---

# ⚙️ 2. Executar o BackEnd

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

# 📱 3. Executar o FrontEnd

Abra outro terminal e acesse a pasta do FrontEnd:

```bash
cd FrontEnd
```

Instale as dependências:

```bash
flutter pub get
```

Antes de executar o aplicativo, certifique-se de que a **URL base da API** configurada no FrontEnd aponta para o endereço correto do BackEnd.

Exemplo:

```text
http://localhost:5191
```

---

## 🌐 Executar na Web

Para executar o aplicativo utilizando o Google Chrome:

```bash
flutter run -d chrome
```

---

## 🤖 Executar no Android

Para executar em um dispositivo ou emulador Android:

```bash
flutter run -d android
```

### ⚠️ Importante sobre `localhost` no Android

Quando o aplicativo é executado em um **emulador Android**, `localhost` representa o próprio emulador e não o computador onde a API está sendo executada.

Nesse caso, para o emulador Android padrão do Android Studio, utilize:

```text
http://10.0.2.2:5191
```

Em um dispositivo físico, pode ser necessário utilizar o **endereço IP local da máquina** que está executando o BackEnd, desde que ambos estejam conectados à mesma rede.

---

# 📂 Estrutura do Projeto

O projeto está organizado separando o BackEnd e o FrontEnd:

```text
BookLog/
│
├── BackEnd/
│   ├── Controllers/
│   ├── Data/
│   ├── DTOs/
│   ├── Models/
│   ├── Services/
│   ├── Migrations/
│   ├── Properties/
│   ├── appsettings.json
│   └── Program.cs
│
├── FrontEnd/
│   ├── lib/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── models/
│   │   └── ...
│   ├── android/
│   ├── web/
│   ├── pubspec.yaml
│   └── ...
│
└── README.md
```

A estrutura pode evoluir conforme novas funcionalidades forem implementadas.

---

# 🗺️ Roadmap

O projeto será desenvolvido de forma incremental, adicionando novas funcionalidades ao longo das próximas entregas.

## 🚀 Entrega 2

### Progresso de Leitura

* Atualização das páginas lidas;
* Persistência do progresso no BackEnd;
* Sincronização do progresso entre FrontEnd e BackEnd;
* Atualização do percentual de leitura.

---

## 🚀 Entrega 3

### Gerenciamento de Livros

* Implementação do CRUD completo de livros;
* Edição de informações dos livros;
* Exclusão de livros;
* Filtros na estante;
* Filtro por status de leitura;
* Filtro por autor;
* Filtro por título.

---

## 🚀 Entrega 4

### Dashboard e Metas

* Dashboard de leitura;
* Estatísticas do usuário;
* Quantidade de livros lidos;
* Livros em andamento;
* Livros ainda não iniciados;
* Acompanhamento de páginas lidas;
* Criação de metas anuais de leitura;
* Acompanhamento do progresso das metas.

---

# 🎯 Objetivo do Projeto

O **BookLog** tem como objetivo proporcionar uma forma simples e organizada de acompanhar o hábito de leitura, centralizando os livros do usuário em uma estante digital e permitindo acompanhar o progresso de cada leitura.

O projeto também tem como finalidade aplicar, de forma prática, conhecimentos relacionados a:

* Desenvolvimento BackEnd;
* Desenvolvimento FrontEnd;
* APIs REST;
* Banco de dados relacionais;
* Autenticação e autorização;
* Desenvolvimento mobile;
* Desenvolvimento Web;
* Git e GitHub;
* Metodologias ágeis;
* Organização e documentação de projetos.

---

# 👩‍💻 Autoria

**Kelly Pitella**

Projeto desenvolvido como parte da formação acadêmica/profissional na área de desenvolvimento de sistemas.

---

## 📌 Status do Projeto

**🚧 Em desenvolvimento**

A versão atual corresponde à **Entrega 1 **. Novas funcionalidades serão adicionadas nas próximas etapas do projeto.
