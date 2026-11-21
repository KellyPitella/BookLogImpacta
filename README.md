# 📚 BookLog

Aplicativo para **rastreamento, organização e acompanhamento do hábito de leitura**, permitindo que o usuário crie sua conta, cadastre livros na própria estante, gerencie suas listas de leitura e acompanhe detalhadamente o progresso e as métricas de cada obra.

O projeto foi desenvolvido como uma aplicação **Full Stack**, composta por uma API REST robusta em C#/.NET 10, uma aplicação FrontEnd moderna em Flutter (Material 3) e um banco de dados relacional MySQL.

---

## 🎓 Identificação Acadêmica

| Informação | Descrição |
| :--- | :--- |
| **Instituição** | Faculdade Impacta de Tecnologia |
| **Curso** | Engenharia de Software / Análise e Desenvolvimento de Sistemas |
| **Autora** | Kelly Pitella |
| **Aplicação** | BookLogImpacta |
| **Tipo** | Aplicação Full Stack (API REST + Mobile/Web + Banco Relacional) |
| **Escopo atual** | **Entrega Final (Concluída)** ✅ |
| **Funcionalidades ativas** | Autenticação JWT/BCrypt, CRUD completo de livros, persistência de categorias (`QueroLer`, `Lendo`, `Lido`), persistência de `Favoritos` no MySQL, registro de histórico de sessões de leitura com exclusão em cascata, dashboard de estatísticas anuais e streaks. |

---

## 🛠️ Tecnologias Utilizadas

### BackEnd

- **C#**
- **ASP.NET Core (.NET 10)**
- **Entity Framework Core (EF Core)**
- **Pomelo.EntityFrameworkCore.MySql**
- **JWT (JSON Web Token) Bearer Authentication**
- **BCrypt.Net** para geração de hash criptográfico seguro de senhas
- **Injeção de Dependência nativa**
- **Swagger / OpenAPI** para documentação interativa e testes da API

### FrontEnd

- **Flutter 3.x**
- **Dart**
- Suporte multiplataforma para **Android** e **Web**
- **Material 3** com paleta de cores personalizada
- Suporte a **Tema Claro (Light)** e **Tema Escuro (Dark)** dinâmicos
- **SharedPreferences** para persistência do token de sessão e preferências locais
- **HTTP Client** para integração com a API REST

### Banco de Dados

- **MySQL Server (v8.0+)**
- Schema: `booklogImpacta`
- Script de inicialização e migrações incrementais: `create_database_mysql.sql`
- Gerenciamento visual via **MySQL Workbench**

---

# 🗃️ Modelagem do Banco de Dados

O banco de dados relacional `booklogImpacta` é estruturado em três tabelas centrais com integridade referencial estrita e regras de **Cascade Delete**:

- `Usuarios`
- `Livros`
- `ProgressosLeitura`

### Tabela `Usuarios`

Armazena as contas dos leitores da aplicação.

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `Id` | INT (PK) | Identificador único do usuário (Auto Increment) |
| `Nome` | VARCHAR(100) | Nome completo do usuário |
| `Email` | VARCHAR(255) | E-mail único utilizado para autenticação (`UNIQUE INDEX`) |
| `SenhaHash` | LONGTEXT | Hash seguro da senha gerado via algoritmo BCrypt |
| `DataCriacao` | DATETIME(6) | Data e hora de criação da conta (UTC) |

---

### Tabela `Livros`

Representa o catálogo de livros pertencentes a cada usuário, armazenando tanto os metadados quanto o status e a preferência de favorito diretamente no banco.

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `Id` | INT (PK) | Identificador único do livro (Auto Increment) |
| `Titulo` | VARCHAR(300) | Título da obra |
| `Autor` | VARCHAR(200) | Autor da obra (opcional) |
| `Genero` | VARCHAR(100) | Gênero literário (opcional) |
| `TotalPaginas` | INT | Número total de páginas do livro |
| `PaginasLidas` | INT | Quantidade total de páginas já lidas (Padrão: 0) |
| `Concluido` | TINYINT(1) | Flag booleana que indica conclusão da obra (Padrão: 0) |
| `Favorito` | TINYINT(1) | Indica se a obra está marcada como favorita (Padrão: 0) |
| `Status` | VARCHAR(20) | Estado atual da leitura: `QueroLer`, `Lendo` ou `Lido` (Padrão: `QueroLer`) |
| `DataCadastro` | DATETIME(6) | Data e hora de inclusão da obra na estante |
| `UsuarioId` | INT (FK) | Chave estrangeira referenciando `Usuarios(Id)` (`ON DELETE CASCADE`) |

---

### Tabela `ProgressosLeitura`

Armazena cada sessão de leitura individual realizada pelo usuário, permitindo rastrear o histórico e calcular métricas de desempenho.

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `Id` | INT (PK) | Identificador único do registro (Auto Increment) |
| `Data` | DATETIME(6) | Data e hora da sessão de leitura |
| `PaginasLidas` | INT | Quantidade de páginas lidas na sessão |
| `Nota` | VARCHAR(500) | Anotação ou reflexão opcional sobre o trecho lido |
| `LivroId` | INT (FK) | Chave estrangeira referenciando `Livros(Id)` (`ON DELETE CASCADE`) |

---

### Relacionamentos e Integridade Referencial

```text
Usuarios
   │
   1
   │
   N (ON DELETE CASCADE)
   ▼
 Livros
   │
   1
   │
   N (ON DELETE CASCADE)
   ▼
ProgressosLeitura
```

- **`Usuarios (1) — (N) Livros`**: Cada livro pertence obrigatoriamente a um único usuário logado. Ao excluir um usuário, todas as suas obras cadastradas são eliminadas do banco automaticamente.
- **`Livros (1) — (N) ProgressosLeitura`**: Cada registro de progresso está atrelado a uma obra. Ao excluir um livro da estante, todo o seu histórico de sessões vinculadas é removido imediatamente em cascata.

---

# 🔐 Autenticação e Segurança

A autenticação é baseada no padrão da indústria **JWT (JSON Web Token)**:

1. **Registro:** A senha informada no cadastro é transformada em hash utilizando **BCrypt** com salt seguro antes de ser salva no banco.
2. **Login:** A API valida o e-mail e a senha contra o hash armazenado.
3. **Emissão de Token:** Em caso de sucesso, é gerado um token JWT assinado digitalmente, contendo o `NameIdentifier` (ID do usuário) e expiração configurada.
4. **Armazenamento:** O aplicativo Flutter armazena o token de forma persistente utilizando o `shared_preferences`.
5. **Autorização:** Todas as requisições para rotas protegidas enviam o cabeçalho:
   ```http
   Authorization: Bearer <SEU_TOKEN_JWT>
   ```
6. **Isolamento de Dados:** Os controllers extraem o ID do usuário diretamente das claims do token, impedindo que um usuário acesse ou modifique livros de outra conta.

---

# 🔌 Endpoints da API REST

A API possui documentação interativa completa via **Swagger UI** (`/swagger`).

## 1. Autenticação – `/api/Auth`

| Método | Rota | Autenticação | Descrição |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/Auth/register` | Pública | Cria uma nova conta de usuário (`RegisterDto`) |
| `POST` | `/api/Auth/login` | Pública | Autentica o usuário (`LoginDto`) e retorna o Token JWT |

## 2. Livros – `/api/Livros`

| Método | Rota | Autenticação | Descrição |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/Livros` | Bearer JWT | Lista os livros da estante com suporte a filtros |
| `POST` | `/api/Livros` | Bearer JWT | Cadastra um novo livro na estante (`CreateLivroDto`) |
| `PUT` | `/api/Livros/{id}` | Bearer JWT | Atualiza os dados cadastrais do livro (`UpdateLivroDto`) |
| `DELETE` | `/api/Livros/{id}` | Bearer JWT | Exclui o livro e seus históricos (Cascade Delete) |
| `PATCH` | `/api/Livros/{id}/favorito` | Bearer JWT | Alterna atomicamente o estado de favorito do livro |
| `PATCH` | `/api/Livros/{id}/status` | Bearer JWT | Altera o status (`QueroLer`, `Lendo`, `Lido`) e sincroniza a conclusão |

### Parâmetros de Filtro no `GET /api/Livros`:
- `status`: Aceita `QueroLer`, `Lendo` ou `Lido`.
- `favoritos`: `true` filtra exclusivamente obras favoritadas; `false` ou omitido retorna todas.
- Podem ser combinados livremente: ex: `GET /api/Livros?status=Lido&favoritos=true`.

### Regras de Transição de Status (`PATCH /api/Livros/{id}/status`):
- **`Lido`**: Define `Concluido = true` e atualiza `PaginasLidas = TotalPaginas` (100% de progresso).
- **`QueroLer`**: Desmarca a conclusão (`Concluido = false`).
- **`Lendo`**: Desmarca a conclusão (`Concluido = false`), mantendo o histórico de páginas.
- **Registro de Progresso**: Sempre que uma sessão de leitura é registrada, a API recalcula automaticamente o percentual e atualiza o status para `Lendo` ou `Lido`.

## 3. Progresso e Estatísticas – `/api/Progresso`

| Método | Rota | Autenticação | Descrição |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/Progresso` | Bearer JWT | Registra uma nova sessão de leitura (`CreateProgressoDto`) |
| `GET` | `/api/Progresso/livro/{livroId}` | Bearer JWT | Lista o histórico cronológico de sessões da obra |
| `GET` | `/api/Progresso/estatisticas` | Bearer JWT | Retorna métricas anuais: livros concluídos, páginas, médias e streaks |

---

# 📱 FrontEnd (Flutter)

A interface foi desenvolvida seguindo as diretrizes do **Material 3**, com design limpo, tipografia expressiva e alta responsividade.

## Telas e Módulos Implementados

### 🔑 Autenticação (Login e Cadastro)
- Validação dinâmica de formulários de e-mail e senha;
- Feedback visual de carregamento e mensagens amigáveis em caso de credenciais inválidas;
- Armazenamento automático do token de sessão.

### 📚 Estante Geral (`HomeScreen`)
- Apresentação dos livros em grid elegante de 2 colunas;
- **Cards com proporções harmoniosas**:
  - Botão de favoritar compacto com ícone de coração (`Icons.favorite` / `Icons.favorite_border`) que persiste no MySQL em tempo real;
  - Menu de opções de 3 pontinhos (`Icons.more_vert`) para edição ou exclusão;
  - Barra de progresso percentual dinâmica;
- **Chips de filtro dinâmicos** no topo, com contadores atualizados:
  - `Lendo ({qtd})`
  - `Lidos ({qtd})`
  - `Quero Ler ({qtd})`
  - `Favoritos ({qtd})`
- Barra de navegação inferior com transições suaves para **Início**, **Novo Livro** e **Estatísticas**.

### 📖 Detalhes do Livro e Registro de Progresso (`BookDetailsScreen`)
- Metadados completos da obra (Título, Autor, Gênero, Data de Início);
- Badge visual do status atual (`Lendo`, `Lido`, `Quero Ler`);
- Botão de alternância de favorito;
- Formulário modal para registro de novas páginas lidas e notas;
- Histórico em linha do tempo com data, páginas lidas na sessão e anotações.

### ➕ Gerenciamento de Livros (`AddBookScreen`)
- Criação e edição de obras;
- Validação impedindo que o total de páginas seja menor do que as páginas já lidas;
- Modal de confirmação antes da exclusão permanente.

### 📊 Dashboard de Estatísticas (`StatisticsScreen`)
- Seletor de ano civil;
- Total de livros finalizados e total de páginas lidas;
- Média diária de páginas;
- **Maior sequência de dias de leitura (Streak)** e sequência atual;
- Gráficos de barras mensais de páginas e conclusões.

### 🌓 Suporte a Tema Claro e Escuro
- Alternância em tempo real entre **Modo Claro** e **Modo Escuro** via `ThemeController`, com persistência das preferências do usuário.

---

# 📋 Metodologia de Gestão Ágil

O projeto foi gerenciado utilizando a metodologia **Kanban** através do **GitHub Projects**:
[Quadro Kanban do Projeto](https://github.com/users/KellyPitella/projects/2/views/1)

- **Backlog:** Levantamento de histórias de usuário e requisitos.
- **Ready:** Tarefas priorizadas para a sprint.
- **In Progress:** Tarefas ativas em desenvolvimento.
- **In Review:** Revisão de código, testes de API e validação de interfaces.
- **Done:** Funcionalidades testadas e entregues.

---

# 📄 Documentação Técnica e Diagramas UML

A especificação arquitetural completa do projeto foi compilada em formato PDF oficial:

* 📄 **Documento Completo:** `Documentacao_UML_BookLog.pdf` (localizado na raiz do projeto)
* **Conteúdo:**
  - **Diagrama de Casos de Uso (UML 2.5):** 14 casos de uso com fluxos de inclusão e extensão.
  - **Tabela de Especificação de Casos de Uso:** Mapeamento de regras e pré-condições.
  - **Diagrama de Classes (UML 2.5):** Entidades de banco, DTOs, Serviços e Modelos Mobile com cardinalidades.
  - **Regras de Negócio e Persistência:** Detalhamento da integridade relacional e transições de estado.

---

# ▶️ Como Executar o Projeto

## 📌 Pré-requisitos

- **.NET SDK 10**
- **MySQL Server (v8.0+)** e **MySQL Workbench**
- **Flutter SDK (v3.10+)**
- **Google Chrome** (para Web) ou **Android Studio / Emulador** (para Mobile)
- **Visual Studio Code** ou **Visual Studio**

---

## 🗄️ 1. Banco de Dados

1. Abra o **MySQL Workbench** e conecte-se ao seu servidor local.
2. Abra o arquivo `BackEnd/scripts/create_database_mysql.sql`.
3. Execute o script completo (ícone do Raio ⚡). Ele criará o banco `booklogImpacta`, as tabelas com chaves estrangeiras e as migrações necessárias.
4. Configure a string de conexão no arquivo `BackEnd/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "server=localhost;database=booklogImpacta;user=SEU_USUARIO;password=SUA_SENHA"
     }
   }
   ```

---

## ⚙️ 2. Executar o BackEnd

Acesse a pasta do BackEnd:
```bash
cd BackEnd
```

Restaure e execute a API:
```bash
dotnet restore
dotnet run
```

A API estará rodando por padrão em:
```text
http://localhost:5191
Swagger: http://localhost:5191/swagger
```

---

## 📱 3. Executar o FrontEnd

Abra outro terminal e acesse a pasta do FrontEnd:
```bash
cd frontend
flutter pub get
```

Execute na plataforma desejada:

* **Na Web (Google Chrome):**
  ```bash
  flutter run -d chrome
  ```
* **No Emulador Android:**
  ```bash
  flutter run -d android
  ```
  *(O emulador utiliza automaticamente o endereço `http://10.0.2.2:5191` para se comunicar com o BackEnd local)*.

---

# 🗺️ Histórico de Entregas e Roadmap

## 🚀 Entrega 1 (Concluída)
- [x] Cadastro e autenticação de usuários com JWT e BCrypt;
- [x] Modelagem inicial do banco de dados (`Usuarios` e `Livros`);
- [x] Endpoints iniciais com documentação Swagger;
- [x] Interface Flutter com Login, Cadastro e Estante inicial;
- [x] Suporte a Tema Claro e Escuro.

## 🚀 Entrega 2 (Concluída)
- [x] Tabela `ProgressosLeitura` no MySQL com Cascade Delete;
- [x] Registro de sessões de leitura (páginas lidas e anotações);
- [x] Cálculo e atualização dinâmica do percentual de progresso;
- [x] Sincronização entre FrontEnd e BackEnd.

## 🚀 Entrega 3 (Concluída)
- [x] CRUD completo de livros (Criação, Leitura, Edição e Exclusão);
- [x] Validação impedindo que o total de páginas seja inferior às páginas lidas;
- [x] Modal de confirmação para exclusão segura;
- [x] Reformulação visual dos cards na estante.

## 🚀 Entrega Final (Concluída) 🏆
- [x] **Persistência de Favoritos no MySQL:** Coluna `Favorito` na tabela `Livros` e endpoint `PATCH /api/Livros/{id}/favorito`;
- [x] **Persistência de Status de Leitura no MySQL:** Coluna `Status` (`QueroLer`, `Lendo`, `Lido`) com transições automáticas e manuais;
- [x] **Filtros Avançados na Estante:** Chips com contagens dinâmicas e filtros combinados na API;
- [x] **Dashboard de Estatísticas Completo:** Livros concluídos, páginas no ano, média diária e maior streak de leitura;
- [x] **Documentação Técnica UML Oficial:** Diagrama de Casos de Uso, Diagrama de Classes e Especificação de Regras de Negócio em PDF (`Documentacao_UML_BookLog.pdf`).

---

# 👩‍💻 Autoria

**Kelly Pitella**  
Faculdade Impacta de Tecnologia &bull; Engenharia de Software  
Projeto: **BookLogImpacta** &bull; 2026

---

# 📌 Status do Projeto

✅ **Concluído — Entrega Final Aprovada**

Todas as metas, requisitos funcionais, não-funcionais, regras de persistência relacional e artefatos de engenharia de software foram implementados, testados e documentados com sucesso.
