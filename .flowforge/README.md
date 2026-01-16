# FlowForge v2.0 - Flutter Edition

Este projeto usa FlowForge para gestão de desenvolvimento profissional.

## 🚀 Quick Start

```bash
# Iniciar sessão de trabalho (SEMPRE PRIMEIRO!)
./run_ff_command.sh flowforge:session:start [issue-number]

# Ver comandos disponíveis
./run_ff_command.sh flowforge:help

# Finalizar sessão
./run_ff_command.sh flowforge:session:end "Mensagem de conclusão"
```

## 📋 Regras Importantes

1. **Sempre iniciar sessão**: `flowforge:session:start` antes de trabalhar
2. **Testes obrigatórios**: 80%+ coverage (Flutter test)
3. **Documentação DartDoc**: Use `///` para docs
4. **Sem referências AI**: Profissionalismo (Rule #33)
5. **Git Flow**: Nunca trabalhe em main/dev direto

## 🎯 Adaptações Flutter

- **Testes**: `test/` ao invés de `app/src/test/`
- **Documentação**: DartDoc (`///`) ao invés de KDoc
- **Linter**: `flutter analyze` ao invés de ktlint
- **Formato**: `dart format` automático
- **Dependencies**: `pubspec.yaml` ao invés de Gradle

## 📚 Documentação

- Ver `CLAUDE.md` para instruções completas
- Ver `.flowforge/RULES.md` para todas as 38 regras
- Ver `documentation/` para guias específicos

## 🤖 Agentes Disponíveis

- `fft-project-manager` - Planejamento e organização
- `fft-architecture` - Decisões arquiteturais
- `fft-security` - Validações de segurança
- `fft-performance` - Otimizações

## ⚠️ TODO: Adaptações Pendentes

Alguns arquivos precisam ser adaptados manualmente:

- [ ] `CLAUDE.md` - Adaptar referências KDoc → DartDoc
- [ ] `fft-documentation.md` - Criar versão Flutter
- [ ] `fft-testing.md` - Criar versão Flutter
- [ ] `fft-mobile.md` - Adaptar para Flutter
- [ ] `fft-code-reviewer.md` - Adaptar para Dart

Veja `FLOWFORGE_FLUTTER_MIGRATION_ANALYSIS.md` para detalhes.
