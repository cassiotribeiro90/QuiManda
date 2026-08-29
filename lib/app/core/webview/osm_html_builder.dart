class OsmHtmlBuilder {
  static String build({
    required double initialLat,
    required double initialLng,
    double initialZoom = 15,
    String? markerTitle,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>OpenStreetMap</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { margin: 0; padding: 0; height: 100vh; width: 100vw; overflow: hidden; background: #f5f5f5; }
        #map { position: absolute; top: 0; bottom: 0; left: 0; right: 0; width: 100%; height: 100%; }
        
        .custom-marker {
            background: #FF6B00;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            border: 3px solid white;
            box-shadow: 0 0 10px rgba(0,0,0,0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: white;
        }
        
        /* Ocultar atribuição para economizar espaço em widgets pequenos */
        .leaflet-control-attribution { font-size: 8px !important; }
        
        /* 🔥 DESABILITA SCROLL NO CONTAINER DO MAPA */
        .leaflet-container {
            touch-action: none !important;
            cursor: grab;
        }
        
        .leaflet-container:active {
            cursor: grabbing;
        }
        
        /* 🔥 BOTÕES DE ZOOM CONTINUAM FUNCIONANDO */
        .leaflet-control-zoom {
            touch-action: none !important;
        }
    </style>
</head>
<body>
    <div id="map"></div>
    <script>
        // 🔥 MAPA COM ZOOM DESABILITADO POR SCROLL
        var map = L.map('map', {
            zoomControl: true,           // Botões de zoom (+ e -) visíveis
            attributionControl: true,
            scrollWheelZoom: false,      // 🔥 Desabilita scroll do mouse
            touchZoom: false,            // 🔥 Desabilita zoom com toque (pinch)
            doubleClickZoom: false,      // 🔥 Desabilita duplo clique
            boxZoom: false,              // 🔥 Desabilita seleção de área
            dragging: true,              // Mantém arrastar para mover o mapa
            bounceAtZoomLimits: false,
            fadeAnimation: true,
            zoomAnimation: true,
            markerZoomAnimation: true,
        }).setView([$initialLat, $initialLng], $initialZoom);
        
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap',
            maxZoom: 19
        }).addTo(map);

        var markers = [];
        var polylines = [];

        // Adicionar marcador padrão
        window.addMarker = function(lat, lng, title, id) {
            var marker = L.marker([lat, lng]).addTo(map);
            if (title) marker.bindPopup(title);
            if (id) marker._id = id;
            markers.push(marker);
            return marker;
        };

        // Adicionar marcador customizado
        window.addCustomMarker = function(lat, lng, title, iconText) {
            var customIcon = L.divIcon({
                className: 'custom-marker',
                html: '<span>' + (iconText || '📍') + '</span>',
                iconSize: [30, 30],
                iconAnchor: [15, 15]
            });
            var marker = L.marker([lat, lng], { icon: customIcon }).addTo(map);
            if (title) marker.bindPopup(title);
            markers.push(marker);
            return marker;
        };

        // Centralizar
        window.setLocation = function(lat, lng, zoom) {
            map.setView([lat, lng], zoom || 15);
        };

        // Adicionar rota (Polyline)
        window.addRoute = function(points, color) {
            var polyline = L.polyline(points, {
                color: color || '#FF6B00',
                weight: 5,
                opacity: 0.7
            }).addTo(map);
            polylines.push(polyline);
            map.fitBounds(polyline.getBounds());
            return polyline;
        };

        window.clearAll = function() {
            markers.forEach(m => map.removeLayer(m));
            polylines.forEach(p => map.removeLayer(p));
            markers = [];
            polylines = [];
        };

        // 🔥 BLOQUEIA EVENTOS DE SCROLL NO CONTAINER DO MAPA
        var container = map.getContainer();
        
        // Bloqueia scroll do mouse (roda do mouse)
        container.addEventListener('wheel', function(e) {
            e.preventDefault();
            e.stopPropagation();
            return false;
        }, { passive: false });

        // Bloqueia touch move (arrastar com dois dedos no mobile)
        container.addEventListener('touchmove', function(e) {
            // Permite apenas se for um único toque (arrastar normal)
            if (e.touches && e.touches.length > 1) {
                e.preventDefault();
                e.stopPropagation();
            }
        }, { passive: false });

        // Bloqueia gestos de dois dedos (pinch)
        container.addEventListener('gesturestart', function(e) {
            e.preventDefault();
            e.stopPropagation();
        });

        container.addEventListener('gesturechange', function(e) {
            e.preventDefault();
            e.stopPropagation();
        });

        container.addEventListener('gestureend', function(e) {
            e.preventDefault();
            e.stopPropagation();
        });

        // Inicializar com o marcador se fornecido
        if ($initialLat && $initialLng) {
            window.addMarker($initialLat, $initialLng, '${markerTitle ?? 'Localização'}');
        }

        // Notificar Flutter que o mapa está pronto
        setTimeout(function() {
            if (window.FlutterChannel) {
                window.FlutterChannel.postMessage(JSON.stringify({type: 'ready'}));
            }
            // Para Web (HtmlElementView)
            window.parent.postMessage({type: 'ready'}, '*');
        }, 300);

        // Evento de clique
        map.on('click', function(e) {
            var data = JSON.stringify({type: 'tap', lat: e.latlng.lat, lng: e.latlng.lng});
            if (window.FlutterChannel) {
                window.FlutterChannel.postMessage(data);
            }
            window.parent.postMessage({type: 'tap', lat: e.latlng.lat, lng: e.latlng.lng}, '*');
        });
    </script>
</body>
</html>
''';
  }
}