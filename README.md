# quiManda - Gestao de Pedidos e Cardapio

[![Flutter](https://img.shields.io/badge/Flutter-3.41.2-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.0-blue.svg)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com)
---

## Screenshots

---

## Sobre o Projeto

**quiManda** é um aplicativo de gestão de pedidos e cardápio para restaurantes e pizzarias. Desenvolvido com Flutter, oferece uma experiência completa para gerenciar pedidos, produtos e clientes em tempo real.

### 🎯 Funcionalidades Principais

- 🔐 **Autenticação**: Login com telefone/OTP via Firebase
- 📊 **Dashboard**: KPIs e métricas em tempo real
- 📦 **Pedidos**: Gerenciamento completo de pedidos ativos
- 📋 **Cardápio**: CRUD de produtos e categorias
- ⚙️ **Configurações**: Personalização do app e loja
- 🔔 **Notificações**: Push notifications com Firebase Messaging
- 🗣️ **TTS**: Leitura de pedidos em voz alta (Web)

### 🛠️ Tecnologias

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| Flutter | 3.41.2 | Framework principal |
| Dart | 3.11.0 | Linguagem |
| GoRouter | 13.2.5 | Navegação |
| Firebase | Latest | Autenticação, FCM |
| Flutter Bloc | 8.1.3 | Gerenciamento de estado |
| Dio | Latest | Requisições HTTP |
| Shelf | 1.4.0 | Servidor SPA |

---

## Arquitetura

### Estrutura de Pastas

```
lib/
├── app/
│   ├── navigation/
│   │   ├── navigation_cubit.dart    # Controle de navegação
│   │   ├── navigation_state.dart    # Estados de navegação
│   │   └── app_router_listener.dart # Listener de navegação
│   ├── routes/
│   │   └── app_router.dart          # Configuração GoRouter
│   ├── initialization/
│   │   └── app_initializer.dart     # Inicialização do app
│   └── widgets/
│       └── splash_screen.dart       # Tela de splash
├── modules/
│   ├── auth/
│   │   ├── cubit/
│   │   │   ├── auth_cubit.dart      # Autenticação
│   │   │   └── auth_state.dart      # Estados de auth
│   │   └── views/
│   │       ├── splash_page.dart
│   │       ├── phone_input_page.dart
│   │       └── otp_verify_page.dart
│   ├── dashboard/
│   │   ├── cubit/
│   │   └── views/
│   ├── pedidos/
│   │   ├── cubit/
│   │   └── views/
│   ├── cardapio/
│   │   ├── bloc/
│   │   └── views/
│   └── configuracoes/
│       ├── bloc/
│       └── views/
├── shared/
│   ├── api/
│   │   ├── api_client.dart
│   │   └── interceptors/
│   │       └── refresh_interceptor.dart
│   ├── services/
│   │   ├── token_service.dart
│   │   └── storage_service.dart
│   └── theme/
│       └── app_theme.dart
└── main.dart # Ponto de entrada
```

### Fluxo de Navegacao

```
Splash Screen
│
▼
┌─────────────┐
│ Autenticado? │
└─────────────┘
│             │
│ Sim         │ Não
▼             ▼
Dashboard    Onboarding → Phone Input → OTP → Dashboard
│
▼
┌─────────────────────────┐
│     Bottom Navigation   │
├─────────────────────────┤
│ 🏠 Dashboard            │
│ 📦 Pedidos              │
│ 📋 Cardápio             │
│ ⚙️ Configurações        │
└─────────────────────────┘
```

---

## Configuracao e Instalacao

### Pre-requisitos

- Flutter SDK 3.41.2+
- Dart SDK 3.11.0+
- Firebase account (para autenticação e FCM)
- Android Studio / VS Code

### Passos para rodar

```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/quimanda.git
cd quimanda

# 2. Instalar dependências
flutter pub get

# 3. Configurar Firebase
# Adicionar os arquivos de configuração do Firebase:
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist
# - lib/firebase_options.dart

# 4. Rodar em desenvolvimento
flutter run -d chrome
```

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
# Firebase
FIREBASE_API_KEY=xxx
FIREBASE_PROJECT_ID=xxx

# API
API_URL=http://localhost:8001/api
```

---

## Desenvolvimento

### Comandos Uteis

```bash
# Rodar em desenvolvimento
flutter run

# Rodar com logs detalhados
flutter run --verbose

# Rodar no Chrome
flutter run -d chrome

# Limpar cache
flutter clean

# Rodar análise do código
flutter analyze

# Rodar testes
flutter test
```

### Padrao de Navegacao

```text
context.read<NavigationCubit>().push('/pedidos/123');
context.read<NavigationCubit>().go('/dashboard');
context.read<NavigationCubit>().pop();
```

### Padrao de Logs

```text
debugPrint('[NAVIGATION] Navegando para: /pedidos');
debugPrint('[AUTH] Login bem-sucedido');
debugPrint('[API] Erro na requisicao: error');
```

### Estrutura de Rotas

```text
/splash          - Tela de inicializacao
/onboarding      - Tela de boas-vindas
/phone-input     - Entrada de telefone
/otp-verify      - Verificacao OTP
/dashboard       - Dashboard principal
/pedidos         - Lista de pedidos
/cardapio        - Gerenciamento de cardapio
/configuracoes   - Configuracoes
/formulario-produto - Formulario de produtos
```

---

## Build e Deploy

### Build de Producao

```bash
# Build para Web
flutter build web --release --source-maps

# Build para Android
flutter build apk --release

# Build para iOS
flutter build ios --release
```

### Servidor SPA (Produção)

```bash
# Entrar na pasta do build
cd build/web

# Adicionar dependências do servidor
dart pub add shelf shelf_router --dev

# Criar server.dart (o arquivo está incluso no projeto)
dart run server.dart
```

### Configuração para Diferentes Ambientes

| Ambiente | Comando | URL |
|------------|-----------|-------|
| Desenvolvimento | `flutter run` | `http://localhost:xxxxx` |
| Produção (Dev) | `flutter build web + dhttpd` | `http://localhost:8000` |
| Produção (SPA) | `flutter build web + server.dart` | `http://localhost:8000` |

---

## Contribuicao

### Como contribuir

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código

- Use `debugPrint()` em vez de `print()`
- Adicione emojis nos logs para facilitar leitura
- Siga o padrão de navegação com `NavigationCubit`
- Mantenha a estrutura de pastas organizada por módulos

---

## Changelog

### [2026-08-24] - Migracao para GoRouter & Firebase

#### Novas Funcionalidades

- **Firebase Integration**
  - Firebase Core para autenticação e serviços
  - Firebase Messaging para notificações push
  - Configuração multi-plataforma
- **GoRouter Navigation**
  - Deep linking funcional com URLs limpas
  - ShellRoute com BottomNavigationBar
  - Redirecionamento inteligente baseado em autenticação
  - Refresh token automático com interceptor
- **Web Improvements**
  - URLs sem # com `usePathUrlStrategy()`
  - Servidor SPA configurado para produção
  - Build otimizado com source maps

#### 🐛 Correções de Bugs

- Corrigido tela branca durante solicitação de permissões
- Corrigido redirecionamento forçado para Dashboard
- Corrigido Page Not Found ao abrir nova aba
- Adicionado SplashScreen com loading state

### [2026-08-20] - Versão Inicial

- Estrutura base do projeto
- Autenticação com telefone/OTP
- Módulo de pedidos
- Módulo de cardápio
- Integação com API REST

---

## 📞 Contato

**Equipe quiManda**
- **Email:** contato@quimanda.com.br
- **Website:** https://quimanda.com.br
- **GitHub:** https://github.com/seu-usuario/quimanda

---

## 🙏 Agradecimentos

- Flutter - Framework incrível
- Firebase - Backend services
- GoRouter - Navegação robusta
- Bloc - Gerenciamento de estado

<div> <sub>Feito com ❤️ pela equipe quiManda</sub> </div>
