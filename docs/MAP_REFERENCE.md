# Referência do Mapa OpenStreetMap

O sistema de mapas do quiManda foi unificado para utilizar **OpenStreetMap + Leaflet.js** em todas as plataformas, eliminando custos de API e proporcionando uma interface consistente.

## Widgets

### OpenStreetMapWidget
Widget de alto nível que seleciona automaticamente a implementação correta para a plataforma atual (Web, Windows ou Mobile).

**Localização:** `lib/features/map/presentation/widgets/open_street_map_widget.dart`

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `latitude` | `double` | Latitude inicial do mapa e do marcador |
| `longitude` | `double` | Longitude inicial do mapa e do marcador |
| `zoom` | `double` | Nível de zoom (padrão: 15) |
| `title` | `String?` | Título que aparece no Popup do marcador |
| `onTap` | `Function(double, double)?` | Callback disparado ao clicar no mapa |

---

### MapPage
Página completa para visualização em tela cheia ou seleção de coordenadas.

**Localização:** `lib/features/map/presentation/pages/map_page.dart`

```dart
MapPage(
  initialLocation: LocationEntity(
    latitude: -23.55,
    longitude: -46.63,
    title: "Ponto de Partida"
  ),
  isSelectable: true, // Habilita seleção de novo ponto
)
```

---

## Estrutura Técnica

O sistema utiliza um gerador de HTML (`OsmHtmlBuilder`) que injeta a biblioteca Leaflet.js e o CSS necessário em uma string carregada pela WebView.

### Fluxo de Comunicação (JS ↔ Flutter)

1.  **Flutter para JS**: Ocorre via `runJavaScript` (Mobile/Windows) chamando funções globais como `window.setLocation(lat, lng, zoom)`.
2.  **JS para Flutter**:
    *   **Mobile**: Utiliza o canal `FlutterChannel.postMessage`.
    *   **Web**: Utiliza `window.parent.postMessage` capturado pelo listener de mensagens do navegador.
    *   **Windows**: Versão 0.4.0 utiliza carregamento via Data URI.

### Implementações por Plataforma

*   **Android/iOS**: `webview_flutter` carregando string HTML.
*   **Web**: `HtmlElementView` com iframe nativo para evitar overhead de plugins.
*   **Windows**: `webview_windows` (v0.4.0) com suporte a WebView2 Runtime.

---

## Customização Visual

Para alterar as cores dos marcadores ou o provedor de tiles, edite o arquivo:
`lib/app/core/webview/osm_html_builder.dart`

**Exemplo de troca de Tile (Dark Mode):**
```javascript
L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
    attribution: '© OpenStreetMap'
}).addTo(map);
```
