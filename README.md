# Mnesis 🧠

> AI-powered medical assistant helping doctors manage clinical cases, patients, and appointments through conversational AI.

## Overview

Mnesis is a voice-first medical assistant designed to help healthcare professionals:
- 🩺 Record and analyze clinical cases
- 📋 Manage patient information
- 📅 Schedule and track appointments
- 💡 Get AI-powered diagnostic suggestions
- 📊 Review patient history and studies

## Architecture

- **Frontend**: Flutter 3.35.5 (Clean Architecture + Riverpod)
- **Backend**: Node.js/Fastify with LLM integration
- **Design**: Dark-first UI with orange accent (#FF7043)
- **Approach**: Backend-heavy (LLM handles business logic)

## Documentation

See `/documentation` folder for:
- Technical architecture
- Design system
- Implementation roadmap
- API contracts

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

## Development

This project follows FlowForge methodology. See `CLAUDE.md` for development workflow.

## Related Projects

- [Volan Flutter](https://github.com/jottap/volan_flutter) - Medical billing platform
- Mnesis Server - Backend API (coming soon)
