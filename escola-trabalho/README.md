# Escola — Trabalho Full Stack com Dart + Flutter

**Disciplina:** Tópicos Especiais  
**Aluno:** Vinicius Artus  
**Tema:** Sistema Escolar  
**Entidades:** Turmas (pai) × Alunos (filho) — relacionamento 1:N

---

## Descrição do tema

O sistema gerencia turmas de uma escola e os alunos vinculados a cada turma. Uma turma pode ter vários alunos, mas cada aluno pertence a apenas uma turma (1:N).

- **Turma:** id, nome, série, turno
- **Aluno:** id, nome, idade, matrícula, turma_id

---

## Estrutura do repositório

```
escola-trabalho/
├── backend/              → API REST em Dart + Shelf + SQLite
├── frontend/             → App Flutter com CRUD completo
│   └── lib/
│       ├── models/       → Modelos de dados (Aluno)
│       ├── services/     → Comunicação HTTP com a API
│       └── screens/      → Telas do app (Lista, Detalhe, Formulário)
├── postman/
│   └── collection.json   → Coleção exportada do Postman
├── docs/
│   └── diagrama-navegacao.svg  → Diagrama de navegação do app
└── README.md
```

---

## Como rodar o Backend

### Pré-requisitos
- [Dart SDK](https://dart.dev/get-dart) instalado e no PATH

### Passos

```bash
cd backend

# Instalar dependências
dart pub get

# Rodar o servidor
dart run bin/server.dart
```

O servidor sobe em **http://localhost:8080**

O banco de dados SQLite (`escola.db`) é criado automaticamente na pasta `backend/` na primeira execução.

---

## Como rodar o Flutter

### Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado
- Emulador Android configurado ou dispositivo físico

### Passos

```bash
cd frontend

# Instalar dependências
flutter pub get

# Rodar o app
flutter run
```

> ⚠️ O backend precisa estar rodando **antes** de abrir o app.  
> ⚠️ No emulador Android, o app acessa o backend via `10.0.2.2:8080` (equivalente ao `localhost` do PC).

---

## Telas do app Flutter

| Tela | Descrição |
|------|-----------|
| **ListaPage** | Lista todos os alunos. Botão + para criar. Toque no item para ver detalhe. |
| **DetalhePage** | Exibe todos os atributos do aluno. Botões Editar e Excluir (com confirmação). |
| **FormularioPage** | Criação ou edição de aluno. Validação, loading e mensagens de erro/sucesso. |

---

## Endpoints da API

### Turmas (entidade pai)

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | /turmas | Listar todas as turmas |
| GET | /turmas/:id | Buscar turma por ID |
| POST | /turmas | Criar nova turma |
| PUT | /turmas/:id | Atualizar turma |
| DELETE | /turmas/:id | Remover turma |
| GET | /turmas/:id/alunos | Listar alunos de uma turma |

### Alunos (entidade filho)

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | /alunos | Listar todos os alunos |
| GET | /alunos/:id | Buscar aluno por ID |
| POST | /alunos | Criar novo aluno |
| PUT | /alunos/:id | Atualizar aluno |
| DELETE | /alunos/:id | Remover aluno |

**Total: 11 rotas**

---

## Como importar a coleção no Postman

1. Abra o Postman
2. Clique em **Import**
3. Selecione o arquivo `postman/collection.json`
4. A variável `{{base_url}}` já está configurada para `http://localhost:8080`

---

## Diagrama de navegação

O diagrama completo de navegação entre as telas está disponível em `docs/diagrama-navegacao.svg`.

Fluxo resumido:
- **ListaPage** → toque no item → **DetalhePage**
- **ListaPage** → botão + → **FormularioPage** (criação)
- **DetalhePage** → botão Editar → **FormularioPage** (edição)
- **DetalhePage** → botão Excluir → Dialog de confirmação → volta para **ListaPage**
- **FormularioPage** (criação) → salvo → volta para **ListaPage**
- **FormularioPage** (edição) → salvo → volta para **DetalhePage**

---

## Status HTTP utilizados

| Código | Situação |
|--------|----------|
| 200 | Leitura bem-sucedida |
| 201 | Recurso criado |
| 204 | Exclusão bem-sucedida |
| 400 | Dados inválidos ou ausentes |
| 404 | Recurso não encontrado |
