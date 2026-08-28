# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-08-28

### 🗺️ Novo Sistema de Mapas com OpenStreetMap

**Implementação:** Sistema de mapas unificado usando OpenStreetMap + Leaflet.js via WebView nativo em todas as plataformas.

#### 🎯 Funcionalidades
- ✅ Mapa em todas as plataformas (Android, iOS, Web, Windows)
- ✅ Marcadores personalizados com ícones/emoji
- ✅ Rotas/Polylines com cores customizáveis
- ✅ Seleção de localização via clique no mapa
- ✅ Controle programático via WebView Controller
- ✅ Comunicação bi-direcional Flutter ↔ JavaScript

#### 📦 Dependências Adicionadas
- `webview_flutter: ^4.4.0`
- `webview_flutter_android: ^3.12.0`
- `webview_flutter_wkwebview: ^3.9.0`
- `webview_windows: ^0.4.0`

#### 📂 Novos Arquivos
- `lib/app/core/webview/osm_html_builder.dart` - Gerador do template Leaflet.js
- `lib/features/map/presentation/widgets/` - Widgets de implementação por plataforma
- `lib/features/map/presentation/pages/map_page.dart` - Tela de mapa interativa
- `lib/features/map/domain/entities/location_entity.dart` - Modelo de dados de localização

#### 🚀 Melhorias
- **Independência de APIs Pagas:** Substituição total do Google Maps por OpenStreetMap (100% gratuito).
- **Experiência Consistente:** Visual idêntico em Mobile, Web e Windows.
- **Performance:** Uso de iframe nativo na Web e WebView2 no Windows.
- **Código Centralizado:** Lógica de mapas agora reside em uma feature dedicada seguindo Clean Architecture.

---

## [1.1.0] - 2026-08-24

### 🚀 Migração para GoRouter & Firebase

- **Firebase Integration:** Firebase Core e Messaging para notificações push multi-plataforma.
- **GoRouter Navigation:** Deep linking, ShellRoute com BottomNavigationBar e redirecionamento inteligente.
- **Web Improvements:** URLs sem `#` com `usePathUrlStrategy()` e servidor SPA configurado.

---

## [1.0.0] - 2026-08-20

### 🎉 Versão Inicial
- Estrutura base do projeto e autenticação com telefone/OTP.
- Módulos de pedidos e cardápio integrados com API REST.
