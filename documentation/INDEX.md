# 📚 Mnesis - Documentação Completa

> Assistente virtual inteligente para médicos. Gerenciamento de casos clínicos, pacientes e agendamentos através de IA conversacional.

---

## 🚀 Início Rápido

### Para Desenvolvedores
1. **[FLOWFORGE_WORKFLOW_QUICK.md](./FLOWFORGE_WORKFLOW_QUICK.md)** - Workflow de desenvolvimento FlowForge (14KB)
2. **[AGENT_RULES.md](./AGENT_RULES.md)** - Regras de orquestração de agentes (28KB)

### Para Documentação
1. **[DOCUMENTATION_GUIDE.md](./DOCUMENTATION_GUIDE.md)** - Padrões de documentação (19KB)
2. **[DART_DOC_GUIDE.md](./DART_DOC_GUIDE.md)** - Convenções Dart/Flutter (19KB)

---

## 📖 Documentação do Projeto Mnesis

### 🏗️ Arquitetura e Design
- **[mnesis/MNESIS_ARCHITECTURE_REVISED.md](./mnesis/MNESIS_ARCHITECTURE_REVISED.md)** (37KB)
  - Arquitetura backend-heavy
  - Clean Architecture 3-tier
  - SQLite mínimo (cache apenas)
  - Contrato de API com backend
  - Streaming SSE (Server-Sent Events)

- **[mnesis/MNESIS_DESIGN_SYSTEM.md](./mnesis/MNESIS_DESIGN_SYSTEM.md)** (54KB)
  - Tokens de design (cores, tipografia, espaçamento)
  - Tema dark-first com laranja (#FF7043)
  - Estratégia híbrida (Volan + shadcn_flutter)
  - Customização de componentes
  - Configuração completa de ThemeData

- **[mnesis/ARCHITECTURE_REVISION_SUMMARY.md](./mnesis/ARCHITECTURE_REVISION_SUMMARY.md)** (8KB)
  - Resumo das mudanças arquiteturais
  - Comparação antes/depois
  - Impacto na implementação

### 📅 Roadmap e Planejamento
- **[mnesis/MNESIS_ROADMAP_REVISED.md](./mnesis/MNESIS_ROADMAP_REVISED.md)** (25KB)
  - Timeline de 6 semanas (148 horas)
  - 6 epics detalhados
  - Epic 1 com 10 tarefas granulares
  - Foco em integração API (36h vs 2h SQLite)
  - Streaming chat (8h)

### 🗺️ Navegação e Referência
- **[mnesis/INDEX.md](./mnesis/INDEX.md)**
  - Guia de navegação da documentação Mnesis
  - Quick start por perfil (arquiteto, desenvolvedor, designer, PM)
  - Conceitos-chave
  - Prioridades de implementação

---

## 🏛️ Estrutura do Projeto

```
mnesis_flutter/
├── lib/
│   ├── core/              # Utilidades, constantes, DI
│   ├── features/          # Features (Clean Architecture)
│   │   ├── chat/         # 🔥 Feature principal (rica)
│   │   ├── patients/     # Thin wrapper de API
│   │   ├── appointments/ # Thin wrapper de API
│   │   └── cases/        # Thin wrapper de API
│   └── shared/           # Widgets e temas compartilhados
│
├── test/                 # Testes (80%+ cobertura)
│   ├── features/
│   ├── core/
│   └── helpers/
│
├── documentation/        # Esta documentação
│   ├── mnesis/          # Docs específicas do Mnesis
│   ├── technical/       # Docs técnicas
│   └── didactic/        # Tutoriais didáticos
│
└── .flowforge/          # Configuração FlowForge
    ├── agents/          # 8 agentes especializados
    └── commands/        # Comandos de workflow
```

---

## 🎯 Diferenças: Mnesis vs Volan

| Aspecto | Mnesis | Volan |
|---------|--------|-------|
| **Propósito** | Auxiliar médico + secretário | Faturamento médico |
| **Features** | Casos clínicos, pacientes, agendamentos | XMLs, convênios, produção |
| **Arquitetura** | Backend-heavy (LLM faz tudo) | Offline-first (CRUD local) |
| **SQLite** | Mínimo (2 tabelas: chat cache) | Completo (5+ tabelas) |
| **Interface** | Chat-first (conversacional) | Chat + dashboards |
| **Backend** | Node.js/Fastify + LLM | Supabase (auth/DB/storage) |

---

## 🛠️ Comandos FlowForge

### Iniciar Sessão de Trabalho
```bash
./run_ff_command.sh flowforge:session:start MNESIS-001
```

### Verificar Status
```bash
./run_ff_command.sh flowforge:dev:status
```

### Verificar Conformidade com Regras
```bash
./run_ff_command.sh flowforge:dev:checkrules
```

### Ajuda
```bash
./run_ff_command.sh flowforge:help
```

---

## 📊 Tech Stack

### Frontend (Flutter)
- **Flutter**: 3.35.5
- **Dart**: 3.9.2
- **State Management**: Riverpod 2.5.1
- **Navigation**: go_router
- **DI**: get_it + injectable
- **Immutable Models**: freezed
- **Functional**: dartz
- **UI Components**: shadcn_flutter + Volan widgets

### Backend (Separado)
- **Node.js/Fastify** com integração LLM
- **PostgreSQL** para dados persistentes
- **Redis** para cache (opcional)
- **SSE** para streaming de respostas

---

## 🎨 Design Tokens

### Cores Principais
```dart
#FF7043  // Orange (primary accent)
#2D3339  // Background Dark
#3D4349  // Surface Dark
#FFFFFF  // Text Primary
#A0A0A0  // Text Secondary
```

### Tipografia
- **Font**: Inter
- **Display Large**: 36px Bold
- **Body Large**: 18px Regular

### Espaçamento
- **Base unit**: 4px
- **Scale**: 4, 8, 12, 16, 24, 32, 48, 64

---

## ✅ Status do Projeto

- ✅ Repositório GitHub criado
- ✅ Projeto Flutter inicializado
- ✅ FlowForge 100% integrado
- ✅ Arquitetura documentada (backend-heavy)
- ✅ Design System completo
- ✅ Roadmap de 6 semanas definido
- ⏳ Desenvolvimento aguardando início

---

## 🔗 Links Úteis

- **GitHub**: https://github.com/jottap1405/mnesis_flutter
- **Volan Flutter**: https://github.com/jottap/volan_flutter (projeto de referência)
- **shadcn_flutter**: https://pub.dev/packages/shadcn_flutter

---

## 📞 Próximos Passos

1. **Configurar `pubspec.yaml`** com dependências
2. **Implementar core** (DI, routing, error handling)
3. **Criar design system** (tokens + componentes)
4. **Desenvolver feature Chat** (MVP prioritário)
5. **Integrar backend API** (streaming SSE)
6. **Testar** (TDD, 80%+ coverage)

---

*Última atualização: 2025-01-16*
*Mnesis v1.0.0 - Em desenvolvimento*
